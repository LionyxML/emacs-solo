;;; emacs-solo-gutter.el --- Git diff gutter indicators in buffers  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: vc, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Displays git diff indicators in the left margin of file-visiting
;; buffers.  Shows added, changed, and deleted lines with colored
;; symbols.  Refreshes on save, revert, and focus changes.

;;; Code:

(use-package emacs-solo-gutter
  :if emacs-solo-enable-buffer-gutter
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/goto-next-hunk ()
    "Jump cursor to the closest next hunk."
    (interactive)
    (let* ((current-line (line-number-at-pos))
           (line-numbers (mapcar #'car git-gutter-diff-info))
           (sorted-line-numbers (sort line-numbers '<))
           (next-line-number
            (if (not (member current-line sorted-line-numbers))
                ;; If the current line is not in the list, find the next closest line number
                (cl-find-if (lambda (line) (> line current-line)) sorted-line-numbers)
              ;; If the current line is in the list, find the next line number that is not consecutive
              (let ((last-line nil))
                (cl-loop for line in sorted-line-numbers
                         when (and (> line current-line)
                                   (or (not last-line)
                                       (/= line (1+ last-line))))
                         return line
                         do (setq last-line line))))))

      (when next-line-number
        (goto-char (point-min))
        (forward-line (1- next-line-number)))))

  (defun emacs-solo/goto-previous-hunk ()
    "Jump cursor to the closest previous hunk."
    (interactive)
    (let* ((current-line (line-number-at-pos))
           (line-numbers (mapcar #'car git-gutter-diff-info))
           (sorted-line-numbers (sort line-numbers '<))
           (previous-line-number
            (if (not (member current-line sorted-line-numbers))
                ;; If the current line is not in the list, find the previous closest line number
                (cl-find-if (lambda (line) (< line current-line)) (reverse sorted-line-numbers))
              ;; If the current line is in the list, find the previous line number that has no direct predecessor
              (let ((previous-line nil))
                (dolist (line sorted-line-numbers)
                  (when (and (< line current-line)
                             (not (member (1- line) line-numbers)))
                    (setq previous-line line)))
                previous-line))))

      (when previous-line-number
        (goto-char (point-min))
        (forward-line (1- previous-line-number)))))


  (defun emacs-solo/git-gutter-process-git-diff ()
    "Process git diff for adds/mods/removals.
Marks lines as added, deleted, or changed."
    (interactive)
    (let* ((result '())
           (file-path (buffer-file-name))
           (grep-command "rg -Po")                         ; for rgrep
           ;; (grep-command (if (eq system-type 'darwin)   ; for grep / ggrep
           ;;                   "ggrep -Po"
           ;;                 "grep -Po"))
           (output (shell-command-to-string
                    (format
                     "git diff --unified=0 %s | %s '^@@ -[0-9]+(,[0-9]+)? \\+\\K[0-9]+(,[0-9]+)?(?= @@)'"
                     (shell-quote-argument file-path)
                     grep-command)))
           (lines (split-string output "\n")))
      (dolist (line lines)
        (if (string-match "\\(^[0-9]+\\),\\([0-9]+\\)\\(?:,0\\)?$" line)
            (let ((num (string-to-number (match-string 1 line)))
                  (count (string-to-number (match-string 2 line))))
              (if (= count 0)
                  (push (cons (+ 1 num) "deleted") result)
                (dotimes (i count)
                  (push (cons (+ num i) "changed") result))))
          (if (string-match "\\(^[0-9]+\\)$" line)
              (push (cons (string-to-number line) "added") result))))
      (setq-local git-gutter-diff-info result)
      result))


  (defun emacs-solo/git-gutter-add-mark (&rest _args)
    "Add symbols to the left margin based on Git diff statuses.
- '+' for added lines (uses `success` face)
- '~' for changed lines (uses `warning` face)
- '-' for deleted lines (uses `error` face)."
    (interactive)
    (remove-overlays (point-min) (point-max) 'emacs-solo--git-gutter-overlay t)
    (let ((lines-status (or (emacs-solo/git-gutter-process-git-diff) '())))
      (save-excursion
        (dolist (line-status lines-status)
          (let* ((line-num (car line-status))
                 (status (cdr line-status))
                 (symbol (cond                                ;; Alternatives:
                          ((string= status "added")   "┃")    ;; +  │ ▏┃
                          ((string= status "changed") "┃")    ;; ~  │ ▏┃
                          ((string= status "deleted") "┃")))  ;; _  _‾ x
                 (face (cond
                        ((string= status "added")   'success)
                        ((string= status "changed") 'warning)
                        ((string= status "deleted") 'error))))
            (when (and line-num status)
              (goto-char (point-min))
              (forward-line (1- line-num))
              (let ((overlay (make-overlay (line-beginning-position) (line-beginning-position))))
                (overlay-put overlay 'emacs-solo--git-gutter-overlay t)
                (overlay-put overlay 'before-string
                             (propertize " "
                                         'display
                                         `((margin left-margin)
                                           ,(propertize symbol 'face face)))))))))))

  (defun emacs-solo/timed-git-gutter-on()
    (let ((buf (current-buffer)))
      (run-at-time 0.1 nil (lambda ()
                             (when (buffer-live-p buf)
                               (with-current-buffer buf
                                 (emacs-solo/git-gutter-add-mark)))))))

  (defun emacs-solo/git-gutter-off ()
    "Remove all `emacs-solo--git-gutter-overlay' marks and other overlays."
    (interactive)
    (remove-overlays (point-min) (point-max) 'emacs-solo--git-gutter-overlay t)
    (remove-hook 'find-file-hook #'emacs-solo/timed-git-gutter-on)
    (remove-hook 'after-save-hook #'emacs-solo/git-gutter-add-mark)
    (remove-hook 'after-revert-hook #'emacs-solo/timed-git-gutter-on)
    (remove-function after-focus-change-function #'emacs-solo/git-gutter-refresh-visible)
    (remove-hook 'window-selection-change-functions #'emacs-solo/git-gutter-on-window-switch))

  (defun emacs-solo/git-gutter-on ()
    (interactive)
    (add-hook 'find-file-hook #'emacs-solo/timed-git-gutter-on)
    (add-hook 'after-save-hook #'emacs-solo/git-gutter-add-mark)
    (add-hook 'after-revert-hook #'emacs-solo/timed-git-gutter-on)
    (add-function :after after-focus-change-function #'emacs-solo/git-gutter-refresh-visible)
    (add-hook 'window-selection-change-functions #'emacs-solo/git-gutter-on-window-switch)
    (when (not (string-match-p "^\\*" (buffer-name))) ; avoid *scratch*, etc.
      (emacs-solo/git-gutter-add-mark)))

  (defun emacs-solo/git-gutter-refresh-visible ()
    "Refresh gutter marks in all visible file-visiting buffers.
Runs after Emacs regains focus (e.g. switching back from terminal
after git add/commit, or after an external tool modifies files)."
    (when (frame-focus-state)
      (dolist (win (window-list))
        (let ((buf (window-buffer win)))
          (when (and (buffer-file-name buf)
                     (not (string-match-p "^\\*" (buffer-name buf)))
                     (vc-git-root (buffer-file-name buf)))
            (with-current-buffer buf
              (emacs-solo/timed-git-gutter-on)))))))

  (defun emacs-solo/git-gutter-on-window-switch (_frame)
    "Refresh gutter marks in the newly selected window's buffer.
Called by `window-selection-change-functions' on C-x o, etc."
    (let ((buf (window-buffer (selected-window))))
      (when (and (buffer-file-name buf)
                 (not (string-match-p "^\\*" (buffer-name buf)))
                 (vc-git-root (buffer-file-name buf)))
        (with-current-buffer buf
          (emacs-solo/timed-git-gutter-on)))))

  (global-set-key (kbd "M-9") 'emacs-solo/goto-previous-hunk)
  (global-set-key (kbd "M-0") 'emacs-solo/goto-next-hunk)
  (global-set-key (kbd "C-c g p") 'emacs-solo/goto-previous-hunk)
  (global-set-key (kbd "C-c g r") 'emacs-solo/git-gutter-off)
  (global-set-key (kbd "C-c g g") 'emacs-solo/git-gutter-on)
  (global-set-key (kbd "C-c g n") 'emacs-solo/goto-next-hunk)

  (add-hook 'after-init-hook #'emacs-solo/git-gutter-on))

(provide 'emacs-solo-gutter)
;;; emacs-solo-gutter.el ends here
