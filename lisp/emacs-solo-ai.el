;;; emacs-solo-ai.el --- AI assistant integration (Ollama, Gemini, Claude)  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: tools, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Provides interactive functions to launch AI chat sessions
;; (Ollama, Gemini, Claude) inside `ansi-term' buffers.  Supports
;; sending selected regions as context.

;;; Code:

(use-package emacs-solo-ai
  :ensure nil
  :no-require t
  :defer t
  :bind (("C-c C-0" . emacs-solo/claude-chat)
         ("C-c C-9" . emacs-solo/opencode-chat))
  :init
  (defun emacs-solo/ollama-run-model ()
    "Run `ollama list`, let the user choose a model.
And open it in `ansi-term`.
If a region is selected, use it as a query.
If a prompt is provided, it's prepended."
    (interactive)
    (let* ((output (shell-command-to-string "ollama list"))
           (models (mapcar (lambda (line) (car (split-string line)))
                           (cdr (split-string output "\n" t))))
           (selected (completing-read "Select Ollama model: " models nil t))
           (region-text (when (use-region-p)
                          (buffer-substring-no-properties (region-beginning)
                                                          (region-end))))
           (prompt (read-string "Ollama Prompt (optional): " nil nil nil)))
      (when (and selected (not (string-empty-p selected)))
        (ansi-term "/bin/sh")
        (sit-for 1)
        (let* ((body (string-join (delq nil (list prompt region-text)) "\n"))
               (escaped-body (replace-regexp-in-string "\"" "\\\\\"" body))
               (command (format "printf \"%s\" | ollama run %s" escaped-body selected)))
          (term-send-raw-string command)
          (term-send-raw-string "\n")))))


  (defun emacs-solo/gemini-chat ()
    "Start a new interactive `gemini` session in an `ansi-term` buffer.
This provides better rendering for the CLI's rich text user interface."
    (interactive)
    (let* ((default-directory (or (vc-root-dir)
                                  (and emacs-solo-ai-scratch-path
                                       (file-directory-p emacs-solo-ai-scratch-path)
                                       emacs-solo-ai-scratch-path)
                                  default-directory))
           (buffer-name (generate-new-buffer-name
                         (format "gemini-chat:%s"
                                 (file-name-nondirectory (directory-file-name default-directory))))))
      (let ((proc-buffer (ansi-term "gemini" buffer-name)))
        (with-current-buffer proc-buffer
          (pop-to-buffer proc-buffer)
          (setq-local column-number-mode nil)))))


  ;; ---------- Claude Code (SDK / stream-json) ----------
  ;;
  ;; Native Emacs chat client for Claude Code.  Spawns
  ;;   `claude --print --input-format stream-json --output-format stream-json --verbose'
  ;; and renders the event stream into an ordinary read-only transcript
  ;; with an editable input region at the bottom.  Supports multi-turn
  ;; chat, image paste from clipboard (PNG), session resume, and region
  ;; context.

  (require 'json)

  (defcustom emacs-solo-claude-executable "claude"
    "Path to the `claude' executable."
    :type 'string
    :group 'tools)

  (defcustom emacs-solo-claude-permission-mode "acceptEdits"
    "Permission mode passed to `claude --permission-mode'.
One of: default, acceptEdits, plan, bypassPermissions."
    :type 'string
    :group 'tools)

  (defcustom emacs-solo-claude-confirm-before-edit t
    "If non-nil, instruct claude to describe & pause before file-mutating tools."
    :type 'boolean
    :group 'tools)

  (defcustom emacs-solo-claude-confirm-system-prompt
    "Before invoking any file-mutating tool (Edit, Write, MultiEdit, \
NotebookEdit) or any Bash command that has side effects (writes files, \
runs git, installs packages, deletes things), FIRST state in one short \
line: the tool, the target file/command, and a one-sentence summary of \
the intended change. Then STOP and wait for the user to reply with \
'go', 'yes', 'ok', or similar before calling the tool. Do not chain \
edits without re-confirming. Read-only tools (Read, Grep, Glob, \
ToolSearch) need no confirmation."
    "System-prompt appendix asking claude to confirm before edits."
    :type 'string
    :group 'tools)

  (defcustom emacs-solo-claude-diff-max-lines 200
    "Max lines of an Edit/Write diff to render inline before truncating."
    :type 'integer
    :group 'tools)

  (defvar-local emacs-solo-claude--proc nil)
  (defvar-local emacs-solo-claude--pending "")
  (defvar-local emacs-solo-claude--input-start nil
    "Marker at the start of the input separator line.")
  (defvar-local emacs-solo-claude--session-id nil)
  (defvar-local emacs-solo-claude--model nil
    "Buffer-local model override (nil = default). Passed via `--model'.")

  (defface emacs-solo-claude-prompt-face
    '((t :inherit minibuffer-prompt :weight bold))
    "Face for the input separator line."
    :group 'tools)

  (defface emacs-solo-claude-user-face
    '((t :inherit font-lock-string-face))
    "Face for echoed user messages in the transcript."
    :group 'tools)

  (defface emacs-solo-claude-tool-face
    '((t :inherit font-lock-comment-face))
    "Face for tool-call annotations."
    :group 'tools)

  (defface emacs-solo-claude-image-face
    '((t :inherit font-lock-constant-face))
    "Face for image-attachment placeholders."
    :group 'tools)

  (defface emacs-solo-claude-diff-add-face
    '((((class color) (background dark))  :foreground "#a6e22e")
      (((class color) (background light)) :foreground "#22863a")
      (t :inherit default))
    "Face for added lines in inline tool diffs."
    :group 'tools)

  (defface emacs-solo-claude-diff-del-face
    '((((class color) (background dark))  :foreground "#f92672")
      (((class color) (background light)) :foreground "#b31d28")
      (t :inherit default))
    "Face for removed lines in inline tool diffs."
    :group 'tools)

  (defvar emacs-solo-claude-mode-map
    (let ((map (make-sparse-keymap)))
      (define-key map (kbd "RET")        #'emacs-solo/claude-send-input)
      (define-key map (kbd "C-<return>") #'newline)
      (define-key map (kbd "C-c C-c")    #'emacs-solo/claude-interrupt)
      (define-key map (kbd "C-c C-i")    #'emacs-solo/claude-paste-image)
      (define-key map (kbd "C-c C-k")    #'emacs-solo/claude-kill-session)
      (define-key map (kbd "C-c C-l")    #'emacs-solo/claude-clear-transcript)
      (define-key map (kbd "C-c C-r")    #'emacs-solo/claude-resume)
      (define-key map (kbd "C-c C-m")    #'emacs-solo/claude-set-model)
      map))

  (define-derived-mode emacs-solo-claude-mode fundamental-mode "Claude"
    "Major mode for Claude Code chat buffers."
    (setq-local truncate-lines nil)
    (visual-line-mode 1)
    (setq emacs-solo-claude--pending "")
    (setq emacs-solo-claude--input-start (make-marker)))

  (defun emacs-solo/claude--banner-text ()
    "Greeting shown at the top of the transcript on fresh / cleared buffers."
    (let* ((proj (file-name-nondirectory
                  (directory-file-name default-directory)))
           (model (or emacs-solo-claude--model "default")))
      (concat
       "──────────────────────────────────────────────────────────────────────────────────\n"
       (format "Claude Code  ·  project: %s  ·  model: %s\n" proj model)
       "──────────────────────────────────────────────────────────────────────────────────\n"
       "RET send          C-RET newline    C-c C-c interrupt           C-c C-k kill\n"
       "C-c C-r resume    C-c C-m model    C-c C-l clear-transcript    C-c C-i paste-image\n"
       "/clear            /model NAME      /resume\n"
       "──────────────────────────────────────────────────────────────────────────────────\n\n")))

  (defun emacs-solo/claude--insert-banner ()
    (emacs-solo/claude--append-transcript
     (emacs-solo/claude--banner-text)
     'emacs-solo-claude-tool-face))

  (defun emacs-solo/claude--init-buffer ()
    "Initialise the chat buffer layout."
    (let ((inhibit-read-only t))
      (erase-buffer)
      (let ((sep-start (point)))
        (insert "────── human ──────\n")
        (put-text-property sep-start (point) 'face 'emacs-solo-claude-prompt-face)
        (put-text-property sep-start (point) 'read-only t)
        (put-text-property sep-start (point) 'rear-nonsticky t)
        (set-marker emacs-solo-claude--input-start sep-start)
        (set-marker-insertion-type emacs-solo-claude--input-start t))
      (goto-char (point-max)))
    (emacs-solo/claude--insert-banner))

  (defun emacs-solo/claude--append-transcript (text &optional face)
    "Insert TEXT just before the input separator, with optional FACE."
    (let ((inhibit-read-only t)
          (mk emacs-solo-claude--input-start))
      (when (and mk (marker-position mk))
        (save-excursion
          (goto-char (marker-position mk))
          (let ((start (point)))
            (insert text)
            (when face
              (put-text-property start (point) 'face face))
            (put-text-property start (point) 'read-only t)
            (put-text-property start (point) 'rear-nonsticky t)))
        ;; Keep windows scrolled to show the input area.
        (dolist (win (get-buffer-window-list (current-buffer) nil t))
          (when (>= (window-point win) (marker-position mk))
            (set-window-point win (point-max)))))))

  (defun emacs-solo/claude--handle-event (event)
    (let ((type (alist-get 'type event)))
      (cond
       ((string= type "system")
        (when (string= (alist-get 'subtype event) "init")
          (setq emacs-solo-claude--session-id
                (alist-get 'session_id event))))
       ((string= type "assistant")
        (let* ((msg (alist-get 'message event))
               (content (alist-get 'content msg)))
          (dolist (block content)
            (emacs-solo/claude--render-block block))))
       ((string= type "result")
        (emacs-solo/claude--append-transcript "\n"))
       (t nil))))

  (defun emacs-solo/claude--render-diff-lines (prefix face text)
    "Insert TEXT prefixed by PREFIX with FACE, line-by-line, truncated."
    (let* ((lines (split-string (or text "") "\n"))
           (max emacs-solo-claude-diff-max-lines)
           (truncated (when (> (length lines) max)
                        (- (length lines) max)))
           (shown (if truncated (seq-take lines max) lines)))
      (dolist (l shown)
        (emacs-solo/claude--append-transcript
         (format "%s%s\n" prefix l) face))
      (when truncated
        (emacs-solo/claude--append-transcript
         (format "  … %d more line(s) truncated\n" truncated)
         'emacs-solo-claude-tool-face))))

  (defun emacs-solo/claude--render-edit-diff (old new)
    (emacs-solo/claude--render-diff-lines "- " 'emacs-solo-claude-diff-del-face old)
    (emacs-solo/claude--render-diff-lines "+ " 'emacs-solo-claude-diff-add-face new))

  (defun emacs-solo/claude--render-tool-use (name input)
    "Render a tool_use block with inline diff for file-mutating tools."
    (cond
     ((member name '("Edit" "Write" "MultiEdit" "NotebookEdit"))
      (let ((path (or (alist-get 'file_path input)
                      (alist-get 'notebook_path input)
                      "<file>")))
        (emacs-solo/claude--append-transcript
         (format "\n⚙ %s %s\n" name path)
         'emacs-solo-claude-tool-face))
      (cond
       ((string= name "Write")
        (emacs-solo/claude--render-diff-lines
         "+ " 'emacs-solo-claude-diff-add-face
         (or (alist-get 'content input) "")))
       ((member name '("Edit" "NotebookEdit"))
        (emacs-solo/claude--render-edit-diff
         (or (alist-get 'old_string input) "")
         (or (alist-get 'new_string input) "")))
       ((string= name "MultiEdit")
        (dolist (e (alist-get 'edits input))
          (emacs-solo/claude--render-edit-diff
           (or (alist-get 'old_string e) "")
           (or (alist-get 'new_string e) "")))))
      (emacs-solo/claude--append-transcript "\n"))
     ((string= name "Bash")
      (let ((cmd (or (alist-get 'command input) ""))
            (desc (alist-get 'description input)))
        (emacs-solo/claude--append-transcript
         (format "\n$ %s%s\n" cmd
                 (if (and desc (not (string-empty-p desc)))
                     (format "  # %s" desc) ""))
         'emacs-solo-claude-tool-face)))
     (t
      (let ((s (condition-case nil (json-encode input) (error ""))))
        (emacs-solo/claude--append-transcript
         (format "\n⚙ %s%s\n" name
                 (cond ((null s) "")
                       ((> (length s) 200)
                        (concat " " (substring s 0 200) "…"))
                       (t (concat " " s))))
         'emacs-solo-claude-tool-face)))))

  (defun emacs-solo/claude--render-block (block)
    (let ((btype (alist-get 'type block)))
      (cond
       ((string= btype "text")
        (emacs-solo/claude--append-transcript
         (or (alist-get 'text block) "")))
       ((string= btype "tool_use")
        (emacs-solo/claude--render-tool-use
         (alist-get 'name block)
         (alist-get 'input block)))
       (t nil))))

  (defun emacs-solo/claude--process-filter (proc output)
    (let ((buf (process-buffer proc)))
      (when (buffer-live-p buf)
        (with-current-buffer buf
          (setq emacs-solo-claude--pending
                (concat emacs-solo-claude--pending output))
          (let ((lines (split-string emacs-solo-claude--pending "\n")))
            (setq emacs-solo-claude--pending (car (last lines)))
            (dolist (line (butlast lines))
              (unless (string-empty-p line)
                (condition-case err
                    (let* ((json-object-type 'alist)
                           (json-array-type 'list)
                           (json-key-type 'symbol)
                           (event (json-read-from-string line)))
                      (emacs-solo/claude--handle-event event))
                  (error
                   (emacs-solo/claude--append-transcript
                    (format "\n[parse error: %S]\n" err)
                    'error))))))))))

  (defun emacs-solo/claude--process-sentinel (proc event)
    (let ((buf (process-buffer proc)))
      (when (buffer-live-p buf)
        (with-current-buffer buf
          (emacs-solo/claude--append-transcript
           (format "\n[claude process: %s]\n" (string-trim event))
           'emacs-solo-claude-tool-face)))))

  (defun emacs-solo/claude--start-process (buffer dir &optional resume-id)
    "Start the `claude' process for BUFFER, running in DIR.
With RESUME-ID, resume that session.  Uses a pipe (not a PTY) so
stream-json I/O is not mangled by terminal line discipline, and
sends stderr to a hidden companion buffer."
    (let* ((default-directory dir)
           (model (buffer-local-value 'emacs-solo-claude--model buffer))
           (args (append (list "--print"
                               "--input-format" "stream-json"
                               "--output-format" "stream-json"
                               "--verbose"
                               "--permission-mode"
                               emacs-solo-claude-permission-mode)
                         (when model (list "--model" model))
                         (when resume-id (list "--resume" resume-id))
                         (when (and emacs-solo-claude-confirm-before-edit
                                    (stringp emacs-solo-claude-confirm-system-prompt)
                                    (not (string-empty-p
                                          emacs-solo-claude-confirm-system-prompt)))
                           (list "--append-system-prompt"
                                 emacs-solo-claude-confirm-system-prompt))))
           (err-buf (get-buffer-create
                     (format " *claude-stderr:%s*" (buffer-name buffer))))
           (proc (make-process
                  :name (format "claude:%s" (buffer-name buffer))
                  :buffer buffer
                  :stderr err-buf
                  :command (cons emacs-solo-claude-executable args)
                  :connection-type 'pipe
                  :coding 'utf-8
                  :noquery t
                  :filter #'emacs-solo/claude--process-filter
                  :sentinel #'emacs-solo/claude--process-sentinel)))
      (with-current-buffer buffer
        (setq emacs-solo-claude--proc proc))
      proc))

  (defun emacs-solo/claude--build-content (text)
    "Build content-block list from TEXT, expanding `[image:PATH]' tokens."
    (let ((blocks nil) (pos 0))
      (while (string-match "\\[image:\\([^]]+\\)\\]" text pos)
        (let ((before (substring text pos (match-beginning 0)))
              (path (match-string 1 text)))
          (unless (string-empty-p before)
            (push `((type . "text") (text . ,before)) blocks))
          (when (file-readable-p path)
            (let ((data (with-temp-buffer
                          (set-buffer-multibyte nil)
                          (insert-file-contents-literally path)
                          (base64-encode-region (point-min) (point-max) t)
                          (buffer-string))))
              (push `((type . "image")
                      (source . ((type . "base64")
                                 (media_type . "image/png")
                                 (data . ,data))))
                    blocks)))
          (setq pos (match-end 0))))
      (let ((rest (substring text pos)))
        (unless (string-empty-p rest)
          (push `((type . "text") (text . ,rest)) blocks)))
      (or (nreverse blocks)
          `(((type . "text") (text . ,text))))))

  (defun emacs-solo/claude--input-region-start ()
    "Return position where the editable input area starts."
    (let ((mk emacs-solo-claude--input-start))
      (when (and mk (marker-position mk))
        (save-excursion
          (goto-char (marker-position mk))
          (forward-line 1)
          (point)))))

  (defun emacs-solo/claude-send-input ()
    "Send the editable input area to Claude.
If the trimmed input matches a recognised slash command, dispatch
that command locally instead of forwarding it to Claude."
    (interactive)
    (let ((text-start (emacs-solo/claude--input-region-start)))
      (cond
       ((not text-start)
        (user-error "Claude buffer not initialised"))
       (t
        (let* ((text (buffer-substring-no-properties text-start (point-max)))
               (trimmed (string-trim text)))
          (when (not (string-empty-p trimmed))
            (let ((inhibit-read-only t))
              (delete-region text-start (point-max)))
            (emacs-solo/claude--append-transcript
             (format "\n> %s\n\n" trimmed)
             'emacs-solo-claude-user-face)
            (cond
             ((emacs-solo/claude--dispatch-slash trimmed) nil)
             ((not (process-live-p emacs-solo-claude--proc))
              (emacs-solo/claude--append-transcript
               "[claude process not running — try /clear or C-c C-0]\n"
               'emacs-solo-claude-tool-face))
             (t
              (let* ((content (emacs-solo/claude--build-content trimmed))
                     (msg `((type . "user")
                            (message . ((role . "user")
                                        (content . ,content)))))
                     (json (json-encode msg)))
                (process-send-string emacs-solo-claude--proc
                                     (concat json "\n")))))))))))

  (defun emacs-solo/claude-paste-image ()
    "Paste a PNG image from the clipboard and insert it as `[image:PATH]'."
    (interactive)
    (let ((data (or (ignore-errors (gui-get-selection 'CLIPBOARD 'image/png))
                    (ignore-errors (gui-get-selection 'PRIMARY   'image/png)))))
      (if (not data)
          (message "No PNG image in clipboard")
        (let ((file (make-temp-file "emacs-claude-img-" nil ".png"))
              (coding-system-for-write 'binary))
          (with-temp-file file
            (set-buffer-multibyte nil)
            (insert data))
          (insert (propertize (format "[image:%s]" file)
                              'face 'emacs-solo-claude-image-face))
          (message "Image attached: %s" file)))))

  (defun emacs-solo/claude-interrupt ()
    "Send SIGINT to the running claude process."
    (interactive)
    (when (process-live-p emacs-solo-claude--proc)
      (interrupt-process emacs-solo-claude--proc)))

  (defun emacs-solo/claude-kill-session ()
    "Kill the claude process for this buffer (transcript kept)."
    (interactive)
    (when (process-live-p emacs-solo-claude--proc)
      (delete-process emacs-solo-claude--proc))
    (setq emacs-solo-claude--proc nil))

  (defun emacs-solo/claude-clear-transcript ()
    "Clear the transcript area, keeping the input region intact."
    (interactive)
    (let ((inhibit-read-only t)
          (mk emacs-solo-claude--input-start))
      (when (and mk (marker-position mk))
        (delete-region (point-min) (marker-position mk)))))

  ;; ----- Session resume & model selection -----

  (defun emacs-solo/claude--encode-cwd (dir)
    "Encode DIR the way `claude' stores it under ~/.claude/projects.
Claude maps any non-alphanumeric character (including `/', `_', `.')
to `-'."
    (replace-regexp-in-string
     "[^A-Za-z0-9-]" "-"
     (directory-file-name (expand-file-name dir))))

  (defun emacs-solo/claude--session-dir (dir)
    "Return the absolute path where claude stores sessions for DIR."
    (expand-file-name (emacs-solo/claude--encode-cwd dir)
                      (expand-file-name "~/.claude/projects/")))

  (defun emacs-solo/claude--session-preview (file)
    "Return (SESSION-ID . PREVIEW-TEXT) for jsonl session FILE."
    (let ((id (file-name-base file))
          preview)
      (with-temp-buffer
        (insert-file-contents file nil 0 32768)
        (goto-char (point-min))
        (catch 'done
          (while (not (eobp))
            (let ((line (buffer-substring-no-properties
                         (line-beginning-position) (line-end-position))))
              (unless (string-empty-p line)
                (condition-case nil
                    (let* ((json-object-type 'alist)
                           (json-array-type 'list)
                           (json-key-type 'symbol)
                           (ev (json-read-from-string line)))
                      (when (and (string= (alist-get 'type ev) "user")
                                 (not (alist-get 'isMeta ev)))
                        (let* ((msg (alist-get 'message ev))
                               (content (alist-get 'content msg))
                               (text (cond
                                      ((stringp content) content)
                                      ((listp content)
                                       (let (found)
                                         (dolist (b content)
                                           (when (and (not found)
                                                      (equal (alist-get 'type b)
                                                             "text"))
                                             (setq found (alist-get 'text b))))
                                         found)))))
                          (when (and text
                                     (not (string-match-p
                                           "\\`<\\(local-command\\|command-\\|system-reminder\\)"
                                           text)))
                            (setq preview text)
                            (throw 'done nil)))))
                  (error nil))))
            (forward-line 1))))
      (cons id (or preview "(empty session)"))))

  (defun emacs-solo/claude--list-sessions (dir)
    "List sessions for DIR.  Each entry: plist (:id :mtime :preview :file)."
    (let ((sdir (emacs-solo/claude--session-dir dir)))
      (when (file-directory-p sdir)
        (let ((files (directory-files sdir t "\\.jsonl\\'")))
          (sort
           (mapcar (lambda (f)
                     (let ((pair (emacs-solo/claude--session-preview f)))
                       (list :id (car pair)
                             :preview (cdr pair)
                             :mtime (file-attribute-modification-time
                                     (file-attributes f))
                             :file f)))
                   files)
           (lambda (a b)
             (time-less-p (plist-get b :mtime)
                          (plist-get a :mtime))))))))

  (defun emacs-solo/claude--read-session-events (file)
    "Return list of parsed jsonl events from FILE (nil on per-line errors)."
    (let (events)
      (with-temp-buffer
        (insert-file-contents file)
        (goto-char (point-min))
        (while (not (eobp))
          (let ((line (buffer-substring-no-properties
                       (line-beginning-position) (line-end-position))))
            (unless (string-empty-p line)
              (condition-case nil
                  (let* ((json-object-type 'alist)
                         (json-array-type 'list)
                         (json-key-type 'symbol))
                    (push (json-read-from-string line) events))
                (error nil))))
          (forward-line 1)))
      (nreverse events)))

  (defun emacs-solo/claude--render-session-file (file)
    "Render past user/assistant messages from session FILE into transcript.
Must be called with the chat buffer as `current-buffer'."
    (dolist (ev (emacs-solo/claude--read-session-events file))
      (let ((type (alist-get 'type ev)))
        (cond
         ((and (string= type "user")
               (not (alist-get 'isMeta ev)))
          (let* ((msg (alist-get 'message ev))
                 (content (alist-get 'content msg))
                 (text (cond
                        ((stringp content) content)
                        ((listp content)
                         (mapconcat
                          (lambda (b)
                            (if (equal (alist-get 'type b) "text")
                                (or (alist-get 'text b) "")
                              ""))
                          content "")))))
            (when (and text
                       (not (string-empty-p (string-trim text)))
                       (not (string-match-p
                             "\\`<\\(local-command\\|command-\\|system-reminder\\)"
                             text)))
              (emacs-solo/claude--append-transcript
               (format "\n> %s\n\n" text)
               'emacs-solo-claude-user-face))))
         ((string= type "assistant")
          (let* ((msg (alist-get 'message ev))
                 (content (alist-get 'content msg)))
            (dolist (block content)
              (emacs-solo/claude--render-block block))
            (emacs-solo/claude--append-transcript "\n")))))))

  (defun emacs-solo/claude--restart (&optional resume-id)
    "Kill the current claude process (if any) and start a new one.
With RESUME-ID, resume that session."
    (let ((dir default-directory))
      (when (process-live-p emacs-solo-claude--proc)
        (set-process-sentinel emacs-solo-claude--proc #'ignore)
        (delete-process emacs-solo-claude--proc))
      (emacs-solo/claude--start-process (current-buffer) dir resume-id)))

  (defun emacs-solo/claude-resume ()
    "Pick a previous Claude session for this project and resume it."
    (interactive)
    (let* ((entries (emacs-solo/claude--list-sessions default-directory))
           (max-prev 90))
      (unless entries
        (user-error "No saved sessions in %s"
                    (emacs-solo/claude--session-dir default-directory)))
      (let* ((cands
              (mapcar
               (lambda (e)
                 (let* ((ts (format-time-string "%Y-%m-%d %H:%M"
                                                (plist-get e :mtime)))
                        (prev (replace-regexp-in-string
                               "[\n\r\t]+" " "
                               (or (plist-get e :preview) "")))
                        (prev (if (> (length prev) max-prev)
                                  (concat (substring prev 0 max-prev) "…")
                                prev)))
                   (cons (format "%s  %s" ts prev) (plist-get e :id))))
               entries))
             (labels (mapcar #'car cands))
             (table (lambda (string pred action)
                      (if (eq action 'metadata)
                          '(metadata (display-sort-function . identity)
                                     (cycle-sort-function . identity))
                        (complete-with-action action labels string pred))))
             (pick (completing-read "Resume Claude session: " table nil t))
             (id (cdr (assoc pick cands)))
             (file (catch 'f
                     (dolist (e entries)
                       (when (string= (plist-get e :id) id)
                         (throw 'f (plist-get e :file)))))))
        (when id
          (setq emacs-solo-claude--session-id id)
          (let ((inhibit-read-only t))
            (emacs-solo/claude--init-buffer))
          (emacs-solo/claude--append-transcript
           (format "[resumed session %s]\n\n" id)
           'emacs-solo-claude-tool-face)
          (when (and file (file-readable-p file))
            (emacs-solo/claude--render-session-file file))
          (emacs-solo/claude--restart id)))))

  (defcustom emacs-solo-claude-model-choices
    '("default" "opus" "sonnet" "haiku"
      "claude-opus-4-7"
      "claude-sonnet-4-6"
      "claude-haiku-4-5-20251001")
    "Models offered by `emacs-solo/claude-set-model'.
The string \"default\" clears the override and uses Claude's default."
    :type '(repeat string)
    :group 'tools)

  (defun emacs-solo/claude-set-model (&optional model)
    "Pick MODEL and restart the session with it.
\"default\" clears the override."
    (interactive
     (list (completing-read "Claude model: "
                            emacs-solo-claude-model-choices nil nil)))
    (setq emacs-solo-claude--model
          (and model
               (not (string= model "default"))
               (not (string-empty-p model))
               model))
    (emacs-solo/claude--append-transcript
     (format "[model: %s]\n" (or emacs-solo-claude--model "default"))
     'emacs-solo-claude-tool-face)
    (emacs-solo/claude--restart emacs-solo-claude--session-id))

  ;; ----- Slash-command interception -----

  (defun emacs-solo/claude--slash-clear ()
    "Start a fresh Claude session, preserving the visible transcript."
    (when (process-live-p emacs-solo-claude--proc)
      (set-process-sentinel emacs-solo-claude--proc #'ignore)
      (delete-process emacs-solo-claude--proc))
    (setq emacs-solo-claude--session-id nil)
    (emacs-solo/claude--append-transcript
     "\n──── new session ────\n\n"
     'emacs-solo-claude-prompt-face)
    (emacs-solo/claude--start-process (current-buffer) default-directory))

  (defun emacs-solo/claude--slash-model (arg)
    (if (or (null arg) (string-empty-p (string-trim arg)))
        (call-interactively #'emacs-solo/claude-set-model)
      (emacs-solo/claude-set-model (string-trim arg))))

  (defun emacs-solo/claude--slash-resume (_arg)
    (call-interactively #'emacs-solo/claude-resume))

  (defun emacs-solo/claude--dispatch-slash (text)
    "If TEXT is a recognised slash command, dispatch and return non-nil."
    (let ((trimmed (string-trim text)))
      (when (string-match "\\`/\\([A-Za-z][-A-Za-z0-9]*\\)\\s-*\\(.*\\)\\'"
                          trimmed)
        (let ((cmd (match-string 1 trimmed))
              (arg (match-string 2 trimmed)))
          (pcase cmd
            ("clear"  (emacs-solo/claude--slash-clear) t)
            ("model"  (emacs-solo/claude--slash-model arg) t)
            ("resume" (emacs-solo/claude--slash-resume arg) t)
            (_ nil))))))

  (defun emacs-solo/claude-chat ()
    "Open or focus a Claude Code chat buffer for the current project.
If a region is active, prompt for a query and send the region as
initial context.  Image paste via \\[emacs-solo/claude-paste-image]."
    (interactive)
    (let* ((source-file (buffer-file-name))
           (project-root (vc-root-dir))
           (dir (or project-root
                    (and (boundp 'emacs-solo-ai-scratch-path)
                         emacs-solo-ai-scratch-path
                         (file-directory-p emacs-solo-ai-scratch-path)
                         emacs-solo-ai-scratch-path)
                    default-directory))
           (file-ref (when source-file
                       (if project-root
                           (file-relative-name source-file project-root)
                         source-file)))
           (region-text (when (use-region-p)
                          (buffer-substring-no-properties
                           (region-beginning) (region-end))))
           (query (when region-text
                    (read-string "Prompt about this region: "
                                 (when file-ref (format "On file @%s " file-ref)))))
           (initial (when region-text
                      (format "%s\n\n```\n%s\n```" query region-text)))
           (buf-name (format "*claude:%s*"
                             (file-name-nondirectory (directory-file-name dir))))
           (buf (get-buffer buf-name)))
      (cond
       ;; Buffer + live process — reuse.
       ((and buf (buffer-live-p buf)
             (with-current-buffer buf
               (process-live-p emacs-solo-claude--proc)))
        nil)
       ;; Buffer exists but process dead — restart, keep transcript.
       ((and buf (buffer-live-p buf))
        (with-current-buffer buf
          (let ((session emacs-solo-claude--session-id))
            (emacs-solo/claude--start-process buf default-directory session))))
       ;; Fresh.
       (t
        (setq buf (get-buffer-create buf-name))
        (with-current-buffer buf
          (emacs-solo-claude-mode)
          (setq default-directory dir)
          (emacs-solo/claude--init-buffer)
          (emacs-solo/claude--start-process buf dir))))
      (pop-to-buffer buf)
      (with-current-buffer buf
        (goto-char (point-max))
        (when initial
          (insert initial)
          (emacs-solo/claude-send-input)))))


  (defun emacs-solo/opencode-chat ()
    "Start or reuse an interactive `opencode-chat' session in an `ansi-term' buffer.

This provides interaction with opencode AI assistant, supporting task-based
model selection (general, explore, code-reviewer, etc.). If a region is
active, it prompts for a query and sends context with the query to opencode.
If an opencode buffer for the current project already exists with a live
process, it reuses it. Otherwise, a new session is started.

Keybindings are configured in `opencode/chat-model-suffix' for common
task types like 'general', 'explore', 'code-reviewer', 'fixer', 'planner',
and 'explainer'."
    (interactive)
    (let* ((source-file (buffer-file-name))
           (project-root (vc-root-dir))
           (default-directory (or project-root
                                  (and emacs-solo-ai-scratch-path
                                       (file-directory-p emacs-solo-ai-scratch-path)
                                       emacs-solo-ai-scratch-path)
                                  default-directory))
           (file-ref (when source-file
                       (if project-root
                           (file-relative-name source-file project-root)
                         source-file)))
           (file-prefix (when file-ref
                          (format "On file @%s " file-ref)))
           (region-text (when (use-region-p)
                          (buffer-substring-no-properties (region-beginning) (region-end))))
           (query (when region-text
                    (read-string "Prompt about this region: " file-prefix)))
           (initial-input (when region-text
                            (format "%s\n\n```\n%s\n```" query region-text)))
           (base-name (format "opencode:%s"
                              (file-name-nondirectory (directory-file-name default-directory))))
           (term-buffer-name (format "*%s*" base-name))
           (existing-buffer (get-buffer term-buffer-name)))
      (if (and existing-buffer
               (buffer-live-p existing-buffer)
               (get-buffer-process existing-buffer))
          ;; Reuse existing buffer — just switch and send input
          (progn
            (pop-to-buffer existing-buffer)
            (when initial-input
              (let ((proc (get-buffer-process existing-buffer)))
                (term-send-string proc "\e[200~")
                (term-send-string proc initial-input)
                (term-send-string proc "\e[201~"))))
        ;; Kill stale buffer if process is dead
        (when (and existing-buffer (not (get-buffer-process existing-buffer)))
          (kill-buffer existing-buffer))
        ;; Create new session
        (let* ((resize-fn (make-symbol "emacs-solo--opencode-resize"))
               (proc-buffer (ansi-term "opencode" base-name)))
          (fset resize-fn
                (lambda (frame)
                  (if (buffer-live-p proc-buffer)
                      (when-let* ((win (get-buffer-window proc-buffer frame)))
                        (with-current-buffer proc-buffer
                          (term-reset-size (window-body-height win)
                                           (window-body-width win))))
                    (remove-hook 'window-size-change-functions resize-fn))))
          (add-hook 'window-size-change-functions resize-fn)
          (with-current-buffer proc-buffer
            (pop-to-buffer proc-buffer)
            (when-let* ((win (get-buffer-window proc-buffer t)))
              (term-reset-size (window-body-height win) (window-body-width win)))
            (setq-local column-number-mode nil)
            (setq-local term-buffer-maximum-size 2048)
            (run-at-time 0.5 nil
                         (lambda (buf)
                           (when (buffer-live-p buf)
                             (when-let* ((win (get-buffer-window buf t)))
                               (with-current-buffer buf
                                 (term-reset-size (window-body-height win)
                                                  (window-body-width win))))))
                         proc-buffer)))))))

(provide 'emacs-solo-ai)
;;; emacs-solo-ai.el ends here
