;;; emacs-solo-icons-dired.el --- File type icons for Dired buffers  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: faces, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Adds file type icons and executable/directory suffixes as
;; overlays to filenames in Dired buffers.

;;; Code:

(use-package emacs-solo-icons-dired
  :if (memq 'dired emacs-solo-enabled-icons)
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/dired-icons-icon-for-file (file)
    (if (file-directory-p file)
        (assoc-default "direddir" emacs-solo/file-icons)
      (let* ((ext (file-name-extension file))
             (icon (and ext (assoc-default (downcase ext) emacs-solo/file-icons))))
        (or icon (assoc-default "diredfile" emacs-solo/file-icons)))))

  (defun emacs-solo/dired-icons-icons-regexp ()
    "Return a regexp that matches any icon we use."
    (let ((icons (mapcar #'cdr emacs-solo/file-icons)))
      (concat "^\\(" (regexp-opt (cons "📁" icons)) "\\) ")))

  (defun emacs-solo/dired-icons-add-icons ()
    "Add icons and suffixes as overlays to filenames in Dired buffer."
    (when (and (derived-mode-p 'dired-mode)
               (not (file-remote-p default-directory))) ; skip icons on TRAMP — file-directory-p/file-executable-p per file kills performance
      (let ((inhibit-read-only t))
        (remove-overlays (point-min) (point-max) 'emacs-solo-dired-icon-overlay t)

        (save-excursion
          (goto-char (point-min))
          (while (not (eobp))
            (condition-case nil
                (when-let* ((file (dired-get-filename nil t)))
                  (dired-move-to-filename)
                  (let* ((beg (point))
                         (end (line-end-position))
                         (icon (emacs-solo/dired-icons-icon-for-file file))
                         (suffix
                          (cond
                           ((file-directory-p file)
                            (propertize "/" 'face 'dired-directory))
                           ((file-executable-p file)
                            (propertize "*" 'face '(:foreground "#79a8ff")))
                           (t ""))))
                    ;; Add icon before filename
                    (let ((ov1 (make-overlay beg beg)))
                      (overlay-put ov1 'before-string (concat icon " "))
                      (overlay-put ov1 'emacs-solo-dired-icon-overlay t))
                    ;; Add styled suffix after filename
                    (let ((ov2 (make-overlay end end)))
                      (overlay-put ov2 'after-string suffix)
                      (overlay-put ov2 'emacs-solo-dired-icon-overlay t))))
              (error nil))
            (forward-line 1))))))

  (add-hook 'dired-after-readin-hook #'emacs-solo/dired-icons-add-icons)
  (defvar-local emacs-solo/dired-icons--last-mod-tick nil)

  (defun emacs-solo/dired-icons-refresh-if-changed ()
    "Redraw dired icons when the buffer content changes."
    (when (derived-mode-p 'dired-mode)
      (let ((tick (buffer-modified-tick)))
        (unless (equal tick emacs-solo/dired-icons--last-mod-tick)
          (setq emacs-solo/dired-icons--last-mod-tick tick)
          (emacs-solo/dired-icons-add-icons)))))

  (add-hook 'dired-mode-hook
            (lambda ()
              (setq emacs-solo/dired-icons--last-mod-tick (buffer-modified-tick))
              (add-hook 'post-command-hook #'emacs-solo/dired-icons-refresh-if-changed nil t))))

(provide 'emacs-solo-icons-dired)
;;; emacs-solo-icons-dired.el ends here
