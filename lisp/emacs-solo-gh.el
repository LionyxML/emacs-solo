;;; emacs-solo-gh.el --- GitHub CLI interface with transient menu  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: vc, tools, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Provides a full GitHub interface using the `gh' CLI.  Browse
;; and manage pull requests, issues, and notifications in tabulated
;; list buffers with a transient menu for common operations.

;;; Code:

(use-package emacs-solo-gh
  :ensure nil
  :no-require t
  :defer t
  :init
  (require 'transient)
  (require 'tabulated-list)
  (require 'json)

  (defvar gh--active-list nil
    "Currently active list: \\='prs, \\='issues, or \\='notifications.")

  (defvar gh--marked-ids nil
    "List of marked entry IDs in the current list.")

  (defvar gh--pr-filter 'all
    "PR filter: \\='mine or \\='all.")

  (defvar gh--issue-filter 'open
    "Issue filter: \\='open, \\='closed, or \\='all.")

  (defvar gh--repo nil
    "Current repo (owner/name).  Nil means auto-detect from git remote.")

  (defun gh--repo ()
    "Return the current repo as owner/name."
    (or gh--repo
        (string-trim
         (shell-command-to-string
          "gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null"))))

  (defun gh--browse-url (url)
    "Open URL in the default browser."
    (browse-url url))

  (defun gh--run-json (args)
    "Run gh ARGS and return parsed JSON."
    (let ((output (string-trim
                   (shell-command-to-string (format "gh %s 2>&1" args)))))
      (if (or (string-empty-p output) (string-prefix-p "no " output))
          nil
        (condition-case nil
            (json-parse-string output :object-type 'alist :array-type 'list)
          (error (message "gh JSON parse error: %s" (truncate-string-to-width output 120))
                 nil)))))

  (defun gh--run-string (args)
    "Run gh ARGS and return trimmed output string."
    (let ((raw (string-trim (shell-command-to-string (format "gh %s 2>&1" args)))))
      (replace-regexp-in-string "\r" "" raw)))

  (defun gh--date-short (date)
    "Return first 10 chars (YYYY-MM-DD) of DATE string."
    (if (and date (>= (length date) 10)) (substring date 0 10) (or date "")))

  (defun gh--format-review-comments (repo number)
    "Fetch inline review comments for PR NUMBER in REPO.
Returns an alist of (review-id . list-of-formatted-strings)."
    (let* ((repo-slug (or repo (gh--repo)))
           (raw (gh--run-string
                 (format "api /repos/%s/pulls/%s/comments --paginate" repo-slug number)))
           (data (condition-case nil
                     (json-parse-string raw :object-type 'alist :array-type 'list)
                   (error nil)))
           (by-review (make-hash-table :test 'equal)))
      (dolist (c (or data '()))
        (let* ((review-id (alist-get 'pull_request_review_id c))
               (author (or (alist-get 'login (alist-get 'user c)) ""))
               (path (or (alist-get 'path c) ""))
               (line (or (alist-get 'line c) (alist-get 'original_line c) ""))
               (body (or (alist-get 'body c) ""))
               (formatted (format "    %s:%s  @%s\n    %s"
                                  path line author
                                  (replace-regexp-in-string
                                   "\n" "\n    " body))))
          (push formatted (gethash review-id by-review nil))))
      ;; Reverse each list so they're in order
      (maphash (lambda (k v) (puthash k (nreverse v) by-review)) by-review)
      by-review))

  (defun gh--format-timeline (repo number)
    "Fetch and format timeline events for issue/PR NUMBER in REPO.
Returns a string with the full conversation thread including
comments, reviews with inline comments, cross-references,
commits, labels, assignments, and state changes."
    (let* ((repo-slug (or repo (gh--repo)))
           (repo-api (format "/repos/%s" repo-slug))
           (api-path (format "%s/issues/%s/timeline" repo-api number))
           (raw (gh--run-string (format "api %s --paginate" api-path)))
           (data (condition-case nil
                     (json-parse-string raw :object-type 'alist :array-type 'list)
                   (error nil)))
           ;; Detect if this is a PR by checking for reviewed/committed events
           (is-pr (seq-some (lambda (e)
                              (let ((et (or (alist-get 'event e) "")))
                                (or (string= et "reviewed")
                                    (string= et "committed"))))
                            data))
           (review-comments (when is-pr
                              (gh--format-review-comments repo-slug number)))
           (parts '()))
      (dolist (event (or data '()))
        (let ((etype (or (alist-get 'event event) "")))
          (cond
           ;; Comments (issue/PR conversation comments)
           ((string= etype "commented")
            (let* ((author (or (alist-get 'login (alist-get 'user event)) ""))
                   (date (gh--date-short (alist-get 'created_at event)))
                   (body (or (alist-get 'body event) "")))
              (push (format "── %s commented on %s ──\n%s" author date body) parts)))

           ;; PR reviews (approved, changes_requested, commented)
           ((string= etype "reviewed")
            (let* ((author (or (alist-get 'login (alist-get 'user event)) ""))
                   (date (gh--date-short (alist-get 'submitted_at event)))
                   (state (or (alist-get 'state event) ""))
                   (body (or (alist-get 'body event) ""))
                   (review-id (alist-get 'id event))
                   (state-label (pcase (downcase state)
                                  ("approved" "approved")
                                  ("changes_requested" "requested changes")
                                  ("commented" "reviewed")
                                  ("dismissed" "review dismissed")
                                  (_ state)))
                   (inline (when review-comments
                             (gethash review-id review-comments)))
                   (text (format "── %s %s on %s ──" author state-label date)))
              (when (and body (not (string-empty-p body)))
                (setq text (concat text "\n" body)))
              (when inline
                (setq text (concat text "\n\n  Inline comments:\n"
                                   (string-join inline "\n\n"))))
              (push text parts)))

           ;; Commits pushed to the PR
           ((string= etype "committed")
            (let* ((sha (or (alist-get 'sha event) ""))
                   (sha-short (if (>= (length sha) 7) (substring sha 0 7) sha))
                   (msg (or (alist-get 'message event) ""))
                   (msg-first-line (car (split-string msg "\n" t)))
                   (author-data (alist-get 'author event))
                   (author (or (alist-get 'name author-data) "")))
              (push (format "── %s pushed %s ──\n%s" author sha-short msg-first-line) parts)))

           ;; Cross-references
           ((string= etype "cross-referenced")
            (let* ((actor (or (alist-get 'login (alist-get 'actor event)) ""))
                   (date (gh--date-short (alist-get 'created_at event)))
                   (source (alist-get 'issue (alist-get 'source event)))
                   (src-number (alist-get 'number source))
                   (src-title (or (alist-get 'title source) ""))
                   (src-repo (or (alist-get 'full_name
                                            (alist-get 'repository
                                                       (alist-get 'source event))) "")))
              (push (format "── %s mentioned this on %s ──\n%s#%s %s"
                            actor date src-repo src-number src-title)
                    parts)))

           ;; Labels
           ((string= etype "labeled")
            (let* ((actor (or (alist-get 'login (alist-get 'actor event)) ""))
                   (date (gh--date-short (alist-get 'created_at event)))
                   (label (or (alist-get 'name (alist-get 'label event)) "")))
              (push (format "── %s added label \"%s\" on %s ──" actor label date) parts)))
           ((string= etype "unlabeled")
            (let* ((actor (or (alist-get 'login (alist-get 'actor event)) ""))
                   (date (gh--date-short (alist-get 'created_at event)))
                   (label (or (alist-get 'name (alist-get 'label event)) "")))
              (push (format "── %s removed label \"%s\" on %s ──" actor label date) parts)))

           ;; Assigned / unassigned
           ((string= etype "assigned")
            (let* ((actor (or (alist-get 'login (alist-get 'actor event)) ""))
                   (assignee (or (alist-get 'login (alist-get 'assignee event)) ""))
                   (date (gh--date-short (alist-get 'created_at event))))
              (push (format "── %s assigned %s on %s ──" actor assignee date) parts)))

           ;; Closed / reopened / merged
           ((string= etype "closed")
            (let* ((actor (or (alist-get 'login (alist-get 'actor event)) ""))
                   (date (gh--date-short (alist-get 'created_at event))))
              (push (format "── %s closed this on %s ──" actor date) parts)))
           ((string= etype "reopened")
            (let* ((actor (or (alist-get 'login (alist-get 'actor event)) ""))
                   (date (gh--date-short (alist-get 'created_at event))))
              (push (format "── %s reopened this on %s ──" actor date) parts)))
           ((string= etype "merged")
            (let* ((actor (or (alist-get 'login (alist-get 'actor event)) ""))
                   (date (gh--date-short (alist-get 'created_at event)))
                   (sha (or (alist-get 'commit_id event) ""))
                   (sha-short (if (>= (length sha) 7) (substring sha 0 7) sha)))
              (push (format "── %s merged this in %s on %s ──" actor sha-short date) parts)))

           ;; Milestoned
           ((string= etype "milestoned")
            (let* ((actor (or (alist-get 'login (alist-get 'actor event)) ""))
                   (milestone (or (alist-get 'title (alist-get 'milestone event)) ""))
                   (date (gh--date-short (alist-get 'created_at event))))
              (push (format "── %s added milestone \"%s\" on %s ──" actor milestone date) parts)))

           ;; Renamed
           ((string= etype "renamed")
            (let* ((actor (or (alist-get 'login (alist-get 'actor event)) ""))
                   (rename (alist-get 'rename event))
                   (from-title (or (alist-get 'from rename) ""))
                   (to-title (or (alist-get 'to rename) ""))
                   (date (gh--date-short (alist-get 'created_at event))))
              (push (format "── %s renamed this on %s ──\n\"%s\" → \"%s\""
                            actor date from-title to-title)
                    parts)))

           ;; Referenced (commit references)
           ((string= etype "referenced")
            (let* ((actor (or (alist-get 'login (alist-get 'actor event)) ""))
                   (sha (or (alist-get 'commit_id event) ""))
                   (sha-short (if (>= (length sha) 7) (substring sha 0 7) sha))
                   (date (gh--date-short (alist-get 'created_at event))))
              (push (format "── %s referenced this in %s on %s ──" actor sha-short date) parts)))

           ;; Review requested
           ((string= etype "review_requested")
            (let* ((actor (or (alist-get 'login (alist-get 'actor event)) ""))
                   (reviewer (or (alist-get 'login (alist-get 'requested_reviewer event)) ""))
                   (date (gh--date-short (alist-get 'created_at event))))
              (push (format "── %s requested review from %s on %s ──" actor reviewer date) parts)))

           ;; Head ref force-pushed / deleted
           ((string= etype "head_ref_force_pushed")
            (let* ((actor (or (alist-get 'login (alist-get 'actor event)) ""))
                   (date (gh--date-short (alist-get 'created_at event))))
              (push (format "── %s force-pushed the branch on %s ──" actor date) parts)))

           ((string= etype "head_ref_deleted")
            (let* ((actor (or (alist-get 'login (alist-get 'actor event)) ""))
                   (date (gh--date-short (alist-get 'created_at event))))
              (push (format "── %s deleted the branch on %s ──" actor date) parts))))))
      (string-join (nreverse parts) "\n\n")))

  (defun gh-mark ()
    "Toggle mark on entry at point and move to next line."
    (interactive)
    (when (derived-mode-p 'tabulated-list-mode)
      (let ((id (tabulated-list-get-id)))
        (when id
          (if (member id gh--marked-ids)
              (progn
                (setq gh--marked-ids (delete id gh--marked-ids))
                (tabulated-list-put-tag "  "))
            (push id gh--marked-ids)
            (tabulated-list-put-tag "* "))
          (forward-line 1)))))

  (defun gh-unmark-all ()
    "Unmark all entries."
    (interactive)
    (when (derived-mode-p 'tabulated-list-mode)
      (setq gh--marked-ids nil)
      (save-excursion
        (goto-char (point-min))
        (while (not (eobp))
          (tabulated-list-put-tag "  ")
          (forward-line 1)))))

  (defun gh--selected-ids ()
    "Return marked IDs, or a list with just the ID at point."
    (or gh--marked-ids
        (when (derived-mode-p 'tabulated-list-mode)
          (let ((id (tabulated-list-get-id)))
            (when id (list id))))))

  (defun gh-nav-next ()
    "Move to next entry."
    (interactive)
    (when (derived-mode-p 'tabulated-list-mode)
      (forward-line 1)))

  (defun gh-nav-prev ()
    "Move to previous entry."
    (interactive)
    (when (derived-mode-p 'tabulated-list-mode)
      (forward-line -1)))

  (defvar-keymap gh-pr-mode-map
    :doc "Keymap for GitHub PR list mode."
    "n"   #'next-line
    "p"   #'previous-line
    "m"   #'gh-mark
    "M"   #'gh-unmark-all
    "RET" #'gh-pr-view
    "o"   #'gh-pr-browse
    "d"   #'gh-pr-diff
    "c"   #'gh-pr-checkout
    "C"   #'gh-pr-comment
    "A"   #'gh-pr-approve
    "R"   #'gh-pr-request-changes
    "E"   #'gh-pr-merge
    "w"   #'gh-pr-copy-url
    "g"   #'gh-pr-list
    "i"   #'gh-issue-list
    "N"   #'gh-notifications
    "?"   #'gh-menu)

  (define-derived-mode gh-pr-mode tabulated-list-mode "GitHub PRs"
    "Major mode for listing GitHub pull requests.
n/p navigate | m mark | RET view | o browse | d diff
c checkout | C comment | A approve | R request changes
E merge | w copy URL | g refresh | i issues | N notifications

\\{gh-pr-mode-map}"
    (setq tabulated-list-format [("#" 6 (lambda (a b) (< (string-to-number (aref (cadr a) 0))
                                                         (string-to-number (aref (cadr b) 0)))))
                                 ("Title" 50 t)
                                 ("Author" 15 t)
                                 ("Status" 10 t)
                                 ("Updated" 12 t)
                                 ("Branch" 25 t)]
          tabulated-list-padding 2)
    (tabulated-list-init-header)
    (hl-line-mode 1))

  (defun gh-pr-list ()
    "List pull requests in a tabulated buffer."
    (interactive)
    (setq gh--active-list 'prs
          gh--marked-ids nil)
    (message "Fetching PRs...")
    (let* ((filter-args (pcase gh--pr-filter
                          ('mine "--author @me")
                          ('all  "")))
           (cmd (format "pr list --json number,title,author,state,updatedAt,headRefName %s --limit 50"
                        filter-args))
           (data (gh--run-json cmd))
           (entries (mapcar
                     (lambda (pr)
                       (let* ((num (number-to-string (alist-get 'number pr)))
                              (title (or (alist-get 'title pr) ""))
                              (author (or (alist-get 'login (alist-get 'author pr)) ""))
                              (state (or (alist-get 'state pr) ""))
                              (updated (or (alist-get 'updatedAt pr) ""))
                              (updated-short (if (>= (length updated) 10)
                                                 (substring updated 0 10)
                                               updated))
                              (branch (or (alist-get 'headRefName pr) "")))
                         (list num (vector num title author state updated-short branch))))
                     (or data '()))))
      (with-current-buffer (get-buffer-create "*github-prs*")
        (let ((pos (point)))
          (gh-pr-mode)
          (setq tabulated-list-entries entries)
          (tabulated-list-print t)
          (goto-char (min pos (point-max))))
        (switch-to-buffer (current-buffer)))
      (message "PRs: %d found" (length entries))))

  (defun gh--pr-number ()
    "Get PR number at point."
    (if (derived-mode-p 'gh-pr-mode)
        (let ((entry (tabulated-list-get-entry)))
          (if entry (string-trim (aref entry 0))
            (user-error "No PR at point")))
      (read-string "PR number: ")))

  (defun gh-pr-view ()
    "View PR details (left) and diff (right).  q closes both."
    (interactive)
    (let* ((from (current-buffer))
           (num (gh--pr-number))
           (buf (get-buffer-create (format "*github-pr-%s*" num)))
           (diff-buf (get-buffer-create (format "*github-pr-%s-diff*" num)))
           (body (gh--run-string (format "pr view %s" num)))
           (timeline (gh--format-timeline nil num))
           (diff (gh--run-string (format "pr diff %s" num))))
      ;; diff buffer (right side)
      (with-current-buffer diff-buf
        (setq buffer-read-only nil)
        (erase-buffer)
        (insert (or diff ""))
        (goto-char (point-min))
        (diff-mode)
        (setq gh--return-buffer from)
        (setq gh--paired-buffer buf)
        (gh-detail-minor-mode 1)
        (setq buffer-read-only t))
      ;; detail buffer (left side)
      (with-current-buffer buf
        (setq buffer-read-only nil)
        (erase-buffer)
        (insert body)
        (when (and timeline (not (string-empty-p timeline)))
          (insert "\n\n── Timeline ─────────────────────────────────────\n\n")
          (insert timeline))
        (goto-char (point-min))
        (setq gh--return-buffer from)
        (gh--setup-detail-buffer)
        (setq gh--paired-buffer diff-buf))
      (switch-to-buffer buf)
      (display-buffer diff-buf '(display-buffer-in-direction
                                 . ((direction . right)
                                    (window-width . 0.5))))))

  (defun gh-pr-browse ()
    "Open PR in browser."
    (interactive)
    (let ((num (gh--pr-number)))
      (shell-command (format "gh pr view %s --web" num))
      (message "Opened PR #%s in browser" num)))

  (defun gh-pr-diff ()
    "View PR diff in a buffer."
    (interactive)
    (let* ((num (gh--pr-number))
           (buf (get-buffer-create (format "*github-pr-%s-diff*" num))))
      (with-current-buffer buf
        (setq buffer-read-only nil)
        (erase-buffer)
        (insert (gh--run-string (format "pr diff %s" num)))
        (goto-char (point-min))
        (diff-mode)
        (setq buffer-read-only t))
      (display-buffer buf '(display-buffer-in-direction
                            . ((direction . right)
                               (window-width . 0.5))))))

  (defun gh-pr-checkout ()
    "Check out the PR branch at point."
    (interactive)
    (let ((num (gh--pr-number)))
      (when (y-or-n-p (format "Checkout PR #%s? " num))
        (message "Checking out PR #%s..." num)
        (let ((output (gh--run-string (format "pr checkout %s" num))))
          (message "%s" output)))))

  (defun gh-pr-comment ()
    "Add a comment to the PR at point."
    (interactive)
    (let* ((num (gh--pr-number))
           (body (read-string (format "Comment on PR #%s: " num))))
      (when (and body (not (string-empty-p body)))
        (let ((output (gh--run-string
                       (format "pr comment %s --body %s"
                               num (shell-quote-argument body)))))
          (message "%s" output)))))

  (defun gh-pr-approve ()
    "Approve the PR at point."
    (interactive)
    (let ((num (gh--pr-number)))
      (when (y-or-n-p (format "Approve PR #%s? " num))
        (let ((body (read-string "Approval message (optional): ")))
          (let ((cmd (if (string-empty-p body)
                         (format "pr review %s --approve" num)
                       (format "pr review %s --approve --body %s"
                               num (shell-quote-argument body)))))
            (message "%s" (gh--run-string cmd)))))))

  (defun gh-pr-request-changes ()
    "Request changes on the PR at point."
    (interactive)
    (let* ((num (gh--pr-number))
           (body (read-string (format "Changes requested on PR #%s: " num))))
      (when (and body (not (string-empty-p body)))
        (message "%s"
                 (gh--run-string
                  (format "pr review %s --request-changes --body %s"
                          num (shell-quote-argument body)))))))

  (defun gh-pr-merge ()
    "Merge the PR at point."
    (interactive)
    (let* ((num (gh--pr-number))
           (method (completing-read (format "Merge PR #%s method: " num)
                                    '("merge" "squash" "rebase") nil t)))
      (when (y-or-n-p (format "%s PR #%s? " (capitalize method) num))
        (message "%s"
                 (gh--run-string
                  (format "pr merge %s --%s" num method))))))

  (defun gh-pr-copy-url ()
    "Copy PR URL to kill ring."
    (interactive)
    (let* ((num (gh--pr-number))
           (url (gh--run-string (format "pr view %s --json url -q .url" num))))
      (kill-new url)
      (message "Copied: %s" url)))

  (defun gh-pr-create ()
    "Create a new pull request interactively."
    (interactive)
    (let* ((title (read-string "PR title: "))
           (body (read-string "PR body (optional): "))
           (draft (y-or-n-p "Create as draft? "))
           (cmd (format "pr create --title %s %s %s"
                        (shell-quote-argument title)
                        (if (string-empty-p body) ""
                          (format "--body %s" (shell-quote-argument body)))
                        (if draft "--draft" ""))))
      (message "%s" (gh--run-string cmd))))

  (defun gh-toggle-pr-filter ()
    "Toggle between my PRs and all PRs."
    (interactive)
    (setq gh--pr-filter (if (eq gh--pr-filter 'mine) 'all 'mine))
    (message "PR filter: %s" gh--pr-filter))

  (defun gh-toggle-issue-filter ()
    "Cycle issue filter: open -> closed -> all."
    (interactive)
    (setq gh--issue-filter (pcase gh--issue-filter
                             ('open 'closed)
                             ('closed 'all)
                             ('all 'open)))
    (message "Issue filter: %s" gh--issue-filter))

  (defvar-keymap gh-issue-mode-map
    :doc "Keymap for GitHub issue list mode."
    "n"   #'next-line
    "p"   #'previous-line
    "m"   #'gh-mark
    "M"   #'gh-unmark-all
    "RET" #'gh-issue-view
    "o"   #'gh-issue-browse
    "C"   #'gh-issue-comment
    "X"   #'gh-issue-close
    "O"   #'gh-issue-reopen
    "L"   #'gh-issue-add-label
    "a"   #'gh-issue-assign
    "w"   #'gh-issue-copy-url
    "g"   #'gh-issue-list
    "l"   #'gh-pr-list
    "N"   #'gh-notifications
    "?"   #'gh-menu)

  (define-derived-mode gh-issue-mode tabulated-list-mode "GitHub Issues"
    "Major mode for listing GitHub issues.
n/p navigate | m mark | RET view | o browse | C comment
X close | O reopen | L label | a assign | w copy URL
g refresh | l PRs | N notifications

\\{gh-issue-mode-map}"
    (setq tabulated-list-format [("#" 6 (lambda (a b) (< (string-to-number (aref (cadr a) 0))
                                                         (string-to-number (aref (cadr b) 0)))))
                                 ("Title" 55 t)
                                 ("Author" 15 t)
                                 ("Labels" 20 t)
                                 ("Updated" 12 t)]
          tabulated-list-padding 2)
    (tabulated-list-init-header)
    (hl-line-mode 1))

  (defun gh-issue-list ()
    "List issues in a tabulated buffer."
    (interactive)
    (setq gh--active-list 'issues
          gh--marked-ids nil)
    (message "Fetching issues...")
    (let* ((state-arg (pcase gh--issue-filter
                        ('open "--state open")
                        ('closed "--state closed")
                        ('all "--state all")))
           (cmd (format "issue list --json number,title,author,labels,updatedAt %s --limit 50"
                        state-arg))
           (data (gh--run-json cmd))
           (entries (mapcar
                     (lambda (issue)
                       (let* ((num (number-to-string (alist-get 'number issue)))
                              (title (or (alist-get 'title issue) ""))
                              (author (or (alist-get 'login (alist-get 'author issue)) ""))
                              (labels-raw (alist-get 'labels issue))
                              (labels (if labels-raw
                                          (mapconcat (lambda (l) (alist-get 'name l))
                                                     labels-raw ",")
                                        ""))
                              (updated (or (alist-get 'updatedAt issue) ""))
                              (updated-short (if (>= (length updated) 10)
                                                 (substring updated 0 10)
                                               updated)))
                         (list num (vector num title author labels updated-short))))
                     (or data '()))))
      (with-current-buffer (get-buffer-create "*github-issues*")
        (let ((pos (point)))
          (gh-issue-mode)
          (setq tabulated-list-entries entries)
          (tabulated-list-print t)
          (goto-char (min pos (point-max))))
        (switch-to-buffer (current-buffer)))
      (message "Issues: %d found" (length entries))))

  (defun gh--issue-number ()
    "Get issue number at point."
    (if (derived-mode-p 'gh-issue-mode)
        (let ((entry (tabulated-list-get-entry)))
          (if entry (string-trim (aref entry 0))
            (user-error "No issue at point")))
      (read-string "Issue number: ")))

  (defun gh-issue-view ()
    "View issue details with full timeline (comments, mentions, events)."
    (interactive)
    (let* ((from (current-buffer))
           (num (gh--issue-number))
           (buf (get-buffer-create (format "*github-issue-%s*" num)))
           (body (gh--run-string (format "issue view %s" num)))
           (timeline (gh--format-timeline nil num)))
      (with-current-buffer buf
        (setq buffer-read-only nil)
        (erase-buffer)
        (insert body)
        (when (and timeline (not (string-empty-p timeline)))
          (insert "\n\n── Timeline ─────────────────────────────────────\n\n")
          (insert timeline))
        (goto-char (point-min))
        (setq gh--return-buffer from)
        (gh--setup-detail-buffer))
      (switch-to-buffer buf)))

  (defun gh-issue-browse ()
    "Open issue in browser."
    (interactive)
    (let ((num (gh--issue-number)))
      (shell-command (format "gh issue view %s --web" num))
      (message "Opened issue #%s in browser" num)))

  (defun gh-issue-comment ()
    "Add a comment to the issue at point."
    (interactive)
    (let* ((num (gh--issue-number))
           (body (read-string (format "Comment on issue #%s: " num))))
      (when (and body (not (string-empty-p body)))
        (message "%s"
                 (gh--run-string
                  (format "issue comment %s --body %s"
                          num (shell-quote-argument body)))))))

  (defun gh-issue-close ()
    "Close selected issues."
    (interactive)
    (let ((ids (gh--selected-ids)))
      (when (y-or-n-p (format "Close %s? "
                              (if (= (length ids) 1)
                                  (format "issue #%s" (car ids))
                                (format "%d issues" (length ids)))))
        (dolist (id ids)
          (message "%s" (gh--run-string (format "issue close %s" id))))
        (setq gh--marked-ids nil)
        (gh-issue-list))))

  (defun gh-issue-reopen ()
    "Reopen the issue at point."
    (interactive)
    (let ((num (gh--issue-number)))
      (when (y-or-n-p (format "Reopen issue #%s? " num))
        (message "%s" (gh--run-string (format "issue reopen %s" num)))
        (gh-issue-list))))

  (defun gh-issue-add-label ()
    "Add a label to the issue at point."
    (interactive)
    (let* ((num (gh--issue-number))
           (label (read-string (format "Add label to issue #%s: " num))))
      (when (and label (not (string-empty-p label)))
        (message "%s"
                 (gh--run-string
                  (format "issue edit %s --add-label %s"
                          num (shell-quote-argument label)))))))

  (defun gh-issue-assign ()
    "Assign the issue at point."
    (interactive)
    (let* ((num (gh--issue-number))
           (user (read-string (format "Assign issue #%s to (@me for self): " num))))
      (when (and user (not (string-empty-p user)))
        (message "%s"
                 (gh--run-string
                  (format "issue edit %s --add-assignee %s"
                          num (shell-quote-argument user)))))))

  (defun gh-issue-copy-url ()
    "Copy issue URL to kill ring."
    (interactive)
    (let* ((num (gh--issue-number))
           (url (gh--run-string (format "issue view %s --json url -q .url" num))))
      (kill-new url)
      (message "Copied: %s" url)))

  (defun gh-issue-create ()
    "Create a new issue interactively."
    (interactive)
    (let* ((title (read-string "Issue title: "))
           (body (read-string "Issue body (optional): "))
           (cmd (format "issue create --title %s %s"
                        (shell-quote-argument title)
                        (if (string-empty-p body) ""
                          (format "--body %s" (shell-quote-argument body))))))
      (message "%s" (gh--run-string cmd))))

  (defvar-keymap gh-notification-mode-map
    :doc "Keymap for GitHub notifications mode."
    "n"   #'next-line
    "p"   #'previous-line
    "m"   #'gh-mark
    "M"   #'gh-unmark-all
    "RET" #'gh-notification-view
    "o"   #'gh-notification-browse
    "r"   #'gh-notification-mark-read
    "w"   #'gh-notification-copy-url
    "g"   #'gh-notifications
    "l"   #'gh-pr-list
    "i"   #'gh-issue-list
    "?"   #'gh-menu)

  (define-derived-mode gh-notification-mode tabulated-list-mode "GitHub Notifications"
    "Major mode for listing GitHub notifications.
n/p navigate | RET view | o browse | r mark read
g refresh | l PRs | i issues

\\{gh-notification-mode-map}"
    (setq tabulated-list-format [("Type" 12 t)
                                 ("Repo" 30 t)
                                 ("Title" 55 t)
                                 ("Updated" 12 t)]
          tabulated-list-padding 2)
    (tabulated-list-init-header)
    (hl-line-mode 1))

  (defun gh-notifications ()
    "List notifications in a tabulated buffer."
    (interactive)
    (setq gh--active-list 'notifications
          gh--marked-ids nil)
    (message "Fetching notifications...")
    (let* ((output (gh--run-string "api notifications --paginate"))
           (data (condition-case nil
                     (json-parse-string output :object-type 'alist :array-type 'list)
                   (error nil)))
           (entries (mapcar
                     (lambda (notif)
                       (let* ((id (alist-get 'id notif))
                              (subject (alist-get 'subject notif))
                              (type (or (alist-get 'type subject) ""))
                              (title (or (alist-get 'title subject) ""))
                              (repo (or (alist-get 'full_name (alist-get 'repository notif)) ""))
                              (updated (or (alist-get 'updated_at notif) ""))
                              (updated-short (if (>= (length updated) 10)
                                                 (substring updated 0 10)
                                               updated))
                              (api-url (or (alist-get 'url subject) "")))
                         (list (cons id api-url) (vector type repo title updated-short))))
                     (or data '()))))
      (with-current-buffer (get-buffer-create "*github-notifications*")
        (let ((pos (point)))
          (gh-notification-mode)
          (setq tabulated-list-entries entries)
          (tabulated-list-print t)
          (goto-char (min pos (point-max))))
        (switch-to-buffer (current-buffer)))
      (message "Notifications: %d" (length entries))))

  (defun gh--notification-at-point ()
    "Return (id . api-url) for the notification at point."
    (tabulated-list-get-id))

  (defun gh-notification-view ()
    "View the notification subject (issue/PR) in a buffer."
    (interactive)
    (let* ((from (current-buffer))
           (id-pair (gh--notification-at-point))
           (api-url (cdr id-pair)))
      (if (or (null api-url) (string-empty-p api-url))
          (message "No viewable subject for this notification")
        ;; Extract type and number from API URL
        (let* ((parts (split-string api-url "/"))
               (type-str (car (last parts 2)))
               (number (car (last parts)))
               (repo-parts (seq-drop (seq-take parts (- (length parts) 2)) 4))
               (repo (string-join repo-parts "/")))
          (cond
           ((string= type-str "pulls")
            (let* ((buf (get-buffer-create (format "*github-pr-%s-%s*" repo number)))
                   (diff-buf (get-buffer-create (format "*github-pr-%s-%s-diff*" repo number)))
                   (body (gh--run-string (format "pr view %s --repo %s" number repo)))
                   (timeline (gh--format-timeline repo number))
                   (diff (gh--run-string (format "pr diff %s --repo %s" number repo))))
              (with-current-buffer diff-buf
                (setq buffer-read-only nil)
                (erase-buffer)
                (insert (or diff ""))
                (goto-char (point-min))
                (diff-mode)
                (setq gh--return-buffer from)
                (setq gh--paired-buffer buf)
                (gh-detail-minor-mode 1)
                (setq buffer-read-only t))
              (with-current-buffer buf
                (setq buffer-read-only nil)
                (erase-buffer)
                (insert body)
                (when (and timeline (not (string-empty-p timeline)))
                  (insert "\n\n── Timeline ─────────────────────────────────────\n\n")
                  (insert timeline))
                (goto-char (point-min))
                (setq gh--return-buffer from)
                (gh--setup-detail-buffer)
                (setq gh--paired-buffer diff-buf))
              (switch-to-buffer buf)
              (display-buffer diff-buf '(display-buffer-in-direction
                                         . ((direction . right)
                                            (window-width . 0.5))))))
           ((string= type-str "issues")
            (let* ((buf (get-buffer-create (format "*github-issue-%s-%s*" repo number)))
                   (body (gh--run-string (format "issue view %s --repo %s" number repo)))
                   (timeline (gh--format-timeline repo number)))
              (with-current-buffer buf
                (setq buffer-read-only nil)
                (erase-buffer)
                (insert body)
                (when (and timeline (not (string-empty-p timeline)))
                  (insert "\n\n── Timeline ─────────────────────────────────────\n\n")
                  (insert timeline))
                (goto-char (point-min))
                (setq gh--return-buffer from)
                (gh--setup-detail-buffer))
              (switch-to-buffer buf)))
           (t (message "Unknown subject type: %s" type-str)))))))

  (defun gh-notification-browse ()
    "Open the notification subject in the browser."
    (interactive)
    (let* ((id-pair (gh--notification-at-point))
           (api-url (cdr id-pair)))
      (if (or (null api-url) (string-empty-p api-url))
          (message "No browsable URL for this notification")
        (let* ((parts (split-string api-url "/"))
               (type-str (car (last parts 2)))
               (number (car (last parts)))
               (repo-parts (seq-drop (seq-take parts (- (length parts) 2)) 4))
               (repo (string-join repo-parts "/")))
          (cond
           ((string= type-str "pulls")
            (shell-command (format "gh pr view %s --repo %s --web" number repo)))
           ((string= type-str "issues")
            (shell-command (format "gh issue view %s --repo %s --web" number repo)))
           (t (message "Cannot browse this notification type")))))))

  (defun gh-notification-mark-read ()
    "Mark selected notifications as read."
    (interactive)
    (let ((ids (gh--selected-ids)))
      (dolist (id-pair ids)
        (let ((id (if (consp id-pair) (car id-pair) id-pair)))
          (gh--run-string (format "api -X PATCH notifications/threads/%s" id))))
      (setq gh--marked-ids nil)
      (message "Marked %d notification(s) as read" (length ids))
      (gh-notifications)))

  (defun gh-notification-copy-url ()
    "Copy notification subject URL to kill ring."
    (interactive)
    (let* ((entry (tabulated-list-get-entry))
           (title (aref entry 2)))
      (kill-new title)
      (message "Copied title: %s" title)))

  (defvar-local gh--return-buffer nil
    "Buffer to return to when quitting detail view.")

  (defvar-local gh--paired-buffer nil
    "Paired buffer (e.g. diff window) to close together.")

  (defun gh-detail-quit ()
    "Quit detail view, return to the list buffer and reopen transient."
    (interactive)
    (let ((ret gh--return-buffer)
          (paired gh--paired-buffer))
      (quit-window)
      (when (and paired (buffer-live-p paired))
        (when-let* ((win (get-buffer-window paired)))
          (delete-window win))
        (kill-buffer paired))
      (when (and ret (buffer-live-p ret))
        (switch-to-buffer ret)
        (gh-menu))))

  (defvar-keymap gh-detail-minor-mode-map
    :doc "Keymap for GitHub detail view."
    "q"   #'gh-detail-quit
    "o"   #'gh-detail-browse
    "g"   #'gh-detail-refresh)

  (define-minor-mode gh-detail-minor-mode
    "Minor mode for GitHub detail view keybindings.
q quit (back to list + menu) | o open in browser | g refresh"
    :lighter " GH"
    :keymap gh-detail-minor-mode-map)

  (defun gh--skip-line-p (line)
    "Return non-nil if LINE should not be filled."
    (or (string-empty-p line)
        (string-match-p "^#" line)
        (string-match-p "^\\s-*[-*+>|]" line)
        (string-match-p "^\\s-*[0-9]+\\." line)
        (string-match-p "^\\s-*\\[" line)
        (string-match-p "^---" line)
        (string-match-p "^<" line)
        (string-match-p "^\t" line)
        (string-match-p "^diff " line)
        (string-match-p "^@@" line)
        (string-match-p "^[+-]" line)
        (string-match-p "^index " line)
        (string-match-p "^── " line)
        (string-match-p "^[a-z]+:\t" line)))

  (defun gh--fill-prose ()
    "Fill only prose paragraphs, leaving code blocks, tables, diffs, etc. alone."
    (let ((inhibit-read-only t)
          (in-code nil)
          (in-diff nil))
      (save-excursion
        (goto-char (point-min))
        (while (not (eobp))
          (let ((line (string-trim-right
                       (buffer-substring-no-properties
                        (line-beginning-position) (line-end-position)))))
            (cond
             ;; Entering diff section -- skip everything after
             ((string-match-p "^── Diff" line)
              (setq in-diff t)
              (forward-line 1))
             (in-diff (forward-line 1))
             ;; Toggle code fence
             ((string-match-p "^\\s-*```" line)
              (setq in-code (not in-code))
              (forward-line 1))
             (in-code (forward-line 1))
             ;; Skip structured lines
             ((gh--skip-line-p line)
              (forward-line 1))
             ;; Prose paragraph
             (t
              (let ((start (line-beginning-position)))
                (forward-line 1)
                (while (and (not (eobp))
                            (let ((l (string-trim-right
                                      (buffer-substring-no-properties
                                       (line-beginning-position)
                                       (line-end-position)))))
                              (and (not (gh--skip-line-p l))
                                   (not (string-match-p "^\\s-*```" l)))))
                  (forward-line 1))
                (fill-region start (point))))))))))

  (defun gh--setup-detail-buffer ()
    "Set up the current buffer as a GitHub detail view."
    (let ((ret gh--return-buffer))
      (setq-local fill-column 80)
      (gh--fill-prose)
      (goto-char (point-min))
      (if (and (fboundp 'markdown-ts-mode)
               (treesit-language-available-p 'markdown))
          (markdown-ts-mode)
        (special-mode))
      (setq-local gh--return-buffer ret)
      (gh-detail-minor-mode 1)
      (visual-line-mode 1)
      (setq buffer-read-only t)))

  (defun gh-detail-browse ()
    "Open the current PR/issue in the browser."
    (interactive)
    (let ((name (buffer-name)))
      (cond
       ((string-match "\\*github-pr-\\(?:\\([^-]+/[^-]+\\)-\\)?\\([0-9]+\\)" name)
        (let ((repo (match-string 1 name))
              (num (match-string 2 name)))
          (shell-command (format "gh pr view %s %s --web"
                                 num (if repo (format "--repo %s" repo) "")))))
       ((string-match "\\*github-issue-\\(?:\\([^-]+/[^-]+\\)-\\)?\\([0-9]+\\)" name)
        (let ((repo (match-string 1 name))
              (num (match-string 2 name)))
          (shell-command (format "gh issue view %s %s --web"
                                 num (if repo (format "--repo %s" repo) "")))))
       (t (message "Cannot determine PR/issue from buffer name")))))

  (defun gh-detail-refresh ()
    "Refresh the current detail view."
    (interactive)
    (let ((name (buffer-name))
          (ret gh--return-buffer))
      (cond
       ((string-match "\\*github-pr-\\(?:\\([^-]+/[^-]+\\)-\\)?\\([0-9]+\\)\\*" name)
        (let* ((repo (match-string 1 name))
               (num (match-string 2 name))
               (repo-flag (if repo (format "--repo %s" repo) ""))
               (body (gh--run-string (format "pr view %s %s" num repo-flag)))
               (timeline (gh--format-timeline repo num))
               (diff (gh--run-string (format "pr diff %s %s" num repo-flag)))
               (diff-buf (or gh--paired-buffer
                             (get-buffer-create (format "*github-pr-%s-diff*"
                                                        (match-string 0 name))))))
          (when (and diff-buf (buffer-live-p diff-buf))
            (with-current-buffer diff-buf
              (setq buffer-read-only nil)
              (erase-buffer)
              (insert (or diff ""))
              (goto-char (point-min))
              (diff-mode)
              (setq buffer-read-only t)))
          (setq buffer-read-only nil)
          (erase-buffer)
          (insert body)
          (when (and timeline (not (string-empty-p timeline)))
            (insert "\n\n── Timeline ─────────────────────────────────────\n\n")
            (insert timeline))
          (goto-char (point-min))
          (setq gh--return-buffer ret)
          (gh--setup-detail-buffer)
          (setq gh--paired-buffer diff-buf)))
       ((string-match "\\*github-issue-\\(?:\\([^-]+/[^-]+\\)-\\)?\\([0-9]+\\)\\*" name)
        (let* ((repo (match-string 1 name))
               (num (match-string 2 name))
               (repo-flag (if repo (format "--repo %s" repo) ""))
               (body (gh--run-string (format "issue view %s %s" num repo-flag)))
               (timeline (gh--format-timeline repo num)))
          (setq buffer-read-only nil)
          (erase-buffer)
          (insert body)
          (when (and timeline (not (string-empty-p timeline)))
            (insert "\n\n── Timeline ─────────────────────────────────────\n\n")
            (insert timeline))
          (goto-char (point-min))
          (setq gh--return-buffer ret)
          (gh--setup-detail-buffer))))))

  (defun gh-run-list ()
    "Show recent workflow runs in a buffer."
    (interactive)
    (let ((buf (get-buffer-create "*github-runs*")))
      (with-current-buffer buf
        (setq buffer-read-only nil)
        (erase-buffer)
        (insert (gh--run-string "run list --limit 20"))
        (goto-char (point-min))
        (special-mode))
      (switch-to-buffer buf)))

  (defun gh-repo-view ()
    "Show repo info in a buffer."
    (interactive)
    (let ((from (current-buffer))
          (buf (get-buffer-create "*github-repo*")))
      (with-current-buffer buf
        (setq buffer-read-only nil)
        (erase-buffer)
        (insert (gh--run-string "repo view"))
        (goto-char (point-min))
        (setq gh--return-buffer from)
        (gh--setup-detail-buffer))
      (switch-to-buffer buf)))

  (defun gh-repo-browse ()
    "Open the repo in the browser."
    (interactive)
    (shell-command "gh repo view --web")
    (message "Opened repo in browser"))

  (defun gh--in-pr-list-p ()
    (eq gh--active-list 'prs))

  (defun gh--in-issue-list-p ()
    (eq gh--active-list 'issues))

  (defun gh--in-notification-list-p ()
    (eq gh--active-list 'notifications))

  (transient-define-prefix gh-menu ()
    "GitHub management menu."
    :refresh-suffixes t
    [["Settings"
      ("f" (lambda () (format "PR filter (%s)" gh--pr-filter))
       gh-toggle-pr-filter :transient t)
      ("F" (lambda () (format "Issue filter (%s)" gh--issue-filter))
       gh-toggle-issue-filter :transient t)]
     ["Browse"
      ("l" "Pull Requests" gh-pr-list :transient t)
      ("i" "Issues" gh-issue-list :transient t)
      ("N" "Notifications" gh-notifications :transient t)
      ("W" "Workflow Runs" gh-run-list)
      ("V" "Repo Info" gh-repo-view)]
     ["Navigate / Mark"
      ("n" "Next" gh-nav-next :transient t)
      ("p" "Prev" gh-nav-prev :transient t)
      ("m" "Mark" gh-mark :transient t)
      ("M" "Unmark all" gh-unmark-all :transient t)
      ("w" "Copy URL" gh-pr-copy-url :transient t)]]
    [["PR Actions"
      ("RET" "View" gh-pr-view
       :inapt-if-not gh--in-pr-list-p)
      ("o" "Browse" gh-pr-browse
       :transient t :inapt-if-not gh--in-pr-list-p)
      ("d" "Diff" gh-pr-diff
       :inapt-if-not gh--in-pr-list-p)
      ("c" "Checkout" gh-pr-checkout
       :transient t :inapt-if-not gh--in-pr-list-p)
      ("C" "Comment" gh-pr-comment
       :transient t :inapt-if-not gh--in-pr-list-p)
      ("A" "Approve" gh-pr-approve
       :transient t :inapt-if-not gh--in-pr-list-p)
      ("R" "Request changes" gh-pr-request-changes
       :transient t :inapt-if-not gh--in-pr-list-p)
      ("E" "Merge" gh-pr-merge
       :transient t :inapt-if-not gh--in-pr-list-p)]
     ["Issue Actions"
      ("RET" "View" gh-issue-view
       :inapt-if-not gh--in-issue-list-p)
      ("o" "Browse" gh-issue-browse
       :transient t :inapt-if-not gh--in-issue-list-p)
      ("C" "Comment" gh-issue-comment
       :transient t :inapt-if-not gh--in-issue-list-p)
      ("X" "Close" gh-issue-close
       :transient t :inapt-if-not gh--in-issue-list-p)
      ("O" "Reopen" gh-issue-reopen
       :transient t :inapt-if-not gh--in-issue-list-p)
      ("L" "Add label" gh-issue-add-label
       :transient t :inapt-if-not gh--in-issue-list-p)
      ("a" "Assign" gh-issue-assign
       :transient t :inapt-if-not gh--in-issue-list-p)]
     ["Notification Actions"
      ("RET" "View" gh-notification-view
       :inapt-if-not gh--in-notification-list-p)
      ("o" "Browse" gh-notification-browse
       :transient t :inapt-if-not gh--in-notification-list-p)
      ("r" "Mark read" gh-notification-mark-read
       :transient t :inapt-if-not gh--in-notification-list-p)]]
    [["Create"
      ("P" "New PR" gh-pr-create)
      ("I" "New Issue" gh-issue-create)]
     ["Repo"
      ("B" "Browse repo" gh-repo-browse)
      ("G" "Repo info" gh-repo-view)]
     [""
      ("q" "Quit" transient-quit-one)]])

  (global-set-key (kbd "C-c G") #'gh-menu))

(provide 'emacs-solo-gh)
;;; emacs-solo-gh.el ends here
