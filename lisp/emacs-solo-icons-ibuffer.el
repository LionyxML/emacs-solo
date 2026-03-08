;;; emacs-solo-icons-ibuffer.el --- File type icons for ibuffer  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: faces, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Adds a custom icon column to ibuffer that shows file type or
;; mode-based icons for each buffer.

;;; Code:

(use-package emacs-solo-icons-ibuffer
  :if (memq 'ibuffer emacs-solo-enabled-icons)
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/ibuffer-icon-for-buffer (buf)
    "Return an icon for BUF: file-extension emoji if visiting a file,
otherwise mode-based emoji."
    (with-current-buffer buf
      (if-let* ((file (buffer-file-name)))
          ;; File-based icons
          (let* ((ext (file-name-extension file))
                 (icon (and ext (assoc-default (downcase ext) emacs-solo/file-icons))))
            (or icon (assoc-default "diredfile" emacs-solo/file-icons)))
        ;; Mode-based icons for non-file buffers
        (cond
         ((derived-mode-p 'dired-mode)  (assoc-default "direddir" emacs-solo/file-icons))
         ((derived-mode-p 'eshell-mode) (assoc-default "terminal" emacs-solo/file-icons))
         ((derived-mode-p 'org-mode)    (assoc-default "terminal" emacs-solo/file-icons))
         ((derived-mode-p 'shell-mode)  (assoc-default "terminal" emacs-solo/file-icons))
         ((derived-mode-p 'term-mode)   (assoc-default "terminal" emacs-solo/file-icons))
         ((derived-mode-p 'help-mode)   (assoc-default "info" emacs-solo/file-icons))
         ((derived-mode-p 'erc-mode)    (assoc-default "hash" emacs-solo/file-icons))
         ((derived-mode-p 'rcirc-mode)  (assoc-default "hash" emacs-solo/file-icons))
         ((derived-mode-p 'gnus-mode)   (assoc-default "mail" emacs-solo/file-icons))
         ((derived-mode-p 'newsticker-treeview-mode)   (assoc-default "news" emacs-solo/file-icons))
         (t                             (assoc-default "wranch" emacs-solo/file-icons))))))

  (define-ibuffer-column icon
    (:name " ")
    (emacs-solo/ibuffer-icon-for-buffer buffer))

  ;; Update ibuffer formats
  (setq ibuffer-formats
        '((mark modified read-only locked " "
                (icon 2 2 :left) " "
                (name 30 30 :left :elide) " "
                (size 9 -1 :right) " "
                (mode 16 16 :left :elide) " "
                filename-and-process))))

(provide 'emacs-solo-icons-ibuffer)
;;; emacs-solo-icons-ibuffer.el ends here
