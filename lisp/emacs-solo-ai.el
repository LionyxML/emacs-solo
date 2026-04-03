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

  (defun emacs-solo/claude-chat ()
    "Start or reuse an interactive `claude' session in an `ansi-term' buffer.
  If a region is active, prompt for a query and send the region text
  along with the query to Claude. If a claude buffer for the current
  project already exists with a live process, reuse it. Otherwise,
  start a new session.

  In order to Emacs best behave using the built-in `ansi-term', edit
  `~/.claude/settings.json' and add these to the json:

  {
  ...
    \"prefersReducedMotion\": true,
    \"spinnerVerbs\": {
      \"mode\": \"replace\",
      \"verbs\": [\"Processing\"]
    }
  ...
  }
"
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
           (initial-input (cond
                           (region-text
                            (format "%s\n\n```\n%s\n```" query region-text))
                           (file-prefix
                            file-prefix)))
           (base-name (format "claude:%s"
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
                (term-send-string proc "\e[201~")
                (term-send-string proc "\r"))))
        ;; Kill stale buffer if process is dead
        (when (and existing-buffer (not (get-buffer-process existing-buffer)))
          (kill-buffer existing-buffer))
        ;; Create new session
        (let ((proc-buffer (ansi-term "claude" base-name)))
          (with-current-buffer proc-buffer
            (pop-to-buffer proc-buffer)
            ;; HACK: ansi-term sets the process window size before
            ;; display-buffer-alist moves the buffer to the side window.
            ;; Without this delay, Claude CLI renders its UI based on the
            ;; original window dimensions, causing misaligned separators.
            (run-at-time 0.2 nil
                         (lambda (buf)
                           (when-let* ((win (get-buffer-window buf t))
                                       (proc (get-buffer-process buf)))
                             (set-process-window-size
                              proc (window-height win) (window-width win))))
                         proc-buffer)
            (setq-local column-number-mode nil)
            (setq-local term-buffer-maximum-size 2048)
            (when initial-input
              (run-at-time 1 nil
                           (lambda (buf input)
                             (when (buffer-live-p buf)
                               (let ((proc (get-buffer-process buf)))
                                 (when proc
                                   (term-send-string proc "\e[200~")
                                   (term-send-string proc input)
                                   (term-send-string proc "\e[201~")
                                   (term-send-string proc "\r")))))
                           proc-buffer initial-input)))))))


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
           (initial-input (cond
                           (region-text
                            (format "%s\n\n```\n%s\n```" query region-text))
                           (file-prefix
                            file-prefix)))
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
                (term-send-string proc "\e[201~")
                (term-send-string proc "\r"))))
        ;; Kill stale buffer if process is dead
        (when (and existing-buffer (not (get-buffer-process existing-buffer)))
          (kill-buffer existing-buffer))
        ;; Create new session
        (let ((proc-buffer (ansi-term "opencode" base-name)))
          (with-current-buffer proc-buffer
            (pop-to-buffer proc-buffer)
            ;; HACK: ansi-term sets the process window size before
            ;; display-buffer-alist moves the buffer to the side window.
            ;; Without this delay, opencode renders its UI based on the
            ;; original window dimensions, causing misaligned separators.
            (run-at-time 0.2 nil
                         (lambda (buf)
                           (when-let* ((win (get-buffer-window buf t))
                                       (proc (get-buffer-process buf)))
                             (set-process-window-size
                              proc (window-height win) (window-width win))))
                         proc-buffer)
            (setq-local column-number-mode nil)
            (setq-local term-buffer-maximum-size 2048)))))))

(provide 'emacs-solo-ai)
;;; emacs-solo-ai.el ends here
