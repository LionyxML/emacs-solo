;;; emacs-solo-formatter.el --- Configurable format-on-save with formatter registry  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: languages, tools, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Configurable format-on-save with a registry of formatters per
;; file extension.  Supports local (project-level) and global
;; formatter discovery with optional config file requirements.

;;; Code:

(use-package emacs-solo-formatter
  :ensure nil
  :no-require t
  :if emacs-solo-enable-auto-formatter
  :init
  (defcustom emacs-solo-formatter-alist
    '(;; Node.js ecosystem — try biome first, fall back to prettier
      (("js" "jsx" "ts" "tsx" "json" "css" "html" "sass" "yaml")
       . ((:cmd "biome" :args ("format" "--write") :local "node_modules/.bin/biome" :config "biome.json")
          (:cmd "prettier" :args ("--write") :local "node_modules/.bin/prettier")))
      ;; Shell scripts
      (("sh" "bash")
       . ((:cmd "shfmt" :args ("-w")))))
    "Alist mapping file extensions to an ordered list of formatter candidates.
Each entry is (EXTENSIONS . FORMATTERS) where EXTENSIONS is a list of
file extension strings (without dots) and FORMATTERS is a list of plists.

Each formatter plist supports the following keys:
  :cmd    — executable name for `executable-find' (global fallback)
  :args   — list of arguments (file path is appended automatically)
  :local  — optional relative path from project root for local install lookup
  :config — optional config file that must exist in the project root for
            this formatter to be selected (e.g. biome needs \"biome.json\")"
    :type '(alist :key-type (repeat string)
                  :value-type (repeat plist))
    :group 'emacs-solo)

  (defun emacs-solo-formatter--find-formatter (file)
    "Find a suitable formatter for FILE based on `emacs-solo-formatter-alist'.
Returns a plist (:executable CMD :args ARGS :source SOURCE) or nil."
    (let* ((ext (file-name-extension file))
           (project-root (or (locate-dominating-file file "node_modules")
                             (locate-dominating-file file ".git")))
           (entry (cl-find-if (lambda (e) (member ext (car e)))
                              emacs-solo-formatter-alist)))
      (when entry
        (cl-loop for fmt in (cdr entry) do
                 (let* ((cmd (plist-get fmt :cmd))
                        (args (plist-get fmt :args))
                        (local-path (plist-get fmt :local))
                        (config (plist-get fmt :config))
                        ;; Check config requirement
                        (config-ok (or (null config)
                                       (and project-root
                                            (file-exists-p (expand-file-name config project-root)))))
                        ;; Find executable: local first, then global
                        (local-bin (and local-path project-root
                                        (let ((p (expand-file-name local-path project-root)))
                                          (and (file-executable-p p) p))))
                        (global-bin (executable-find cmd))
                        (executable (or local-bin global-bin))
                        (source (cond
                                 (local-bin (format "%s (local)" cmd))
                                 (global-bin (format "%s (global)" cmd)))))
                   (when (and config-ok executable)
                     (cl-return (list :executable executable
                                      :args args
                                      :source source))))))))

  (defun emacs-solo-formatter/format-current-file (&optional manual)
    "Format the current file using the first matching formatter.
Runs the formatter asynchronously so Emacs stays responsive.
If MANUAL is non-nil, save the buffer before formatting."
    (interactive (list t))
    (let* ((file (buffer-file-name))
           (buf (current-buffer))
           (result (and file (emacs-solo-formatter--find-formatter file))))
      (if result
          (let* ((executable (plist-get result :executable))
                 (args (append (plist-get result :args) (list file)))
                 (source (plist-get result :source))
                 (start-time (float-time)))
            (when manual
              (save-buffer))
            (make-process
             :name "formatter"
             :command (cons executable args)
             :connection-type 'pipe
             :noquery t
             :sentinel
             (lambda (_proc event)
               (when (string-match-p "finished" event)
                 (when (buffer-live-p buf)
                   (with-current-buffer buf
                     (revert-buffer t t t)
                     (let ((elapsed-time (* 1000 (- (float-time) start-time))))
                       (message "Formatted with %s - %.0f ms" source elapsed-time))))))))
        (when manual
          (message "No formatter found for this file")))))

  (defun emacs-solo-formatter/format-current-file-manual ()
    "Manually invoke format for current file (saves first)."
    (interactive)
    (emacs-solo-formatter/format-current-file t))

  (defun emacs-solo-formatter/enable-format-on-save ()
    "Add format-on-save to the current buffer's `after-save-hook'."
    (interactive)
    (add-hook 'after-save-hook #'emacs-solo-formatter/format-current-file nil t)
    (message "Format-on-save enabled for this buffer."))

  (defun emacs-solo-formatter/disable-format-on-save ()
    "Remove format-on-save from the current buffer's `after-save-hook'."
    (interactive)
    (remove-hook 'after-save-hook #'emacs-solo-formatter/format-current-file t)
    (message "Format-on-save disabled for this buffer."))

  (defun emacs-solo-formatter/toggle-format-on-save ()
    "Toggle format-on-save for the current buffer."
    (interactive)
    (if (memq #'emacs-solo-formatter/format-current-file after-save-hook)
        (progn
          (remove-hook 'after-save-hook #'emacs-solo-formatter/format-current-file t)
          (message "Formatting on save turned OFF"))
      (add-hook 'after-save-hook #'emacs-solo-formatter/format-current-file nil t)
      (message "Formatting on save turned ON")))

  (defun emacs-solo-formatter--maybe-enable ()
    "Auto-enable format-on-save if the file's extension has a registered formatter."
    (when-let* ((file (buffer-file-name))
                (ext (file-name-extension file)))
      (when (cl-find-if (lambda (e) (member ext (car e)))
                        emacs-solo-formatter-alist)
        (add-hook 'after-save-hook #'emacs-solo-formatter/format-current-file nil t))))

  (add-hook 'find-file-hook #'emacs-solo-formatter--maybe-enable)

  (global-set-key (kbd "C-c p") #'emacs-solo-formatter/format-current-file-manual)
  (global-set-key (kbd "C-c C-p") #'emacs-solo-formatter/format-current-file-manual)
  (global-set-key (kbd "C-c t f") #'emacs-solo-formatter/toggle-format-on-save))

(provide 'emacs-solo-formatter)
;;; emacs-solo-formatter.el ends here
