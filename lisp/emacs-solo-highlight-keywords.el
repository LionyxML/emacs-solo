;;; emacs-solo-highlight-keywords.el --- Highlight TODO and similar keywords in comments  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: faces, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later
;;
;; Code borrowed from `alternateved'.

;;; Commentary:
;;
;; Highlights configurable keywords (TODO, FIXME, HACK, NOTE, etc.)
;; in comments and strings using font-lock.

;;; Code:

(use-package emacs-solo-highlight-keywords-mode
  :if emacs-solo-enable-highlight-keywords
  :ensure nil
  :no-require t
  :defer t
  :init
  (defcustom +highlight-keywords-faces
    '(("TODO" . error)
      ("FIXME" . error)
      ("HACK" . warning)
      ("NOTE" . warning)
      ("HERE" . compilation-info)
      ("EMACS-31" . compilation-info))
    "Alist of keywords to highlight and their face."
    :group '+highlight-keywords
    :type '(alist :key-type (string :tag "Keyword")
                  :value-type (symbol :tag "Face"))
    :set (lambda (sym val)
           (dolist (face (mapcar #'cdr val))
             (unless (facep face)
               (error "Invalid face: %s" face)))
           (set-default sym val)))

  (defvar +highlight-keywords--keywords
    (when +highlight-keywords-faces
      (let ((keywords (mapcar #'car +highlight-keywords-faces)))
        `((,(regexp-opt keywords 'words)
           (0 (when (nth 8 (syntax-ppss))
                (cdr (assoc (match-string 0) +highlight-keywords-faces)))
              prepend)))))
    "Keywords and corresponding faces for `emacs-solo/highlight-keywords-mode'.")

  (defun emacs-solo/highlight-keywords-mode-on ()
    (when (not (string-match-p "^\\*" (buffer-name))) ; avoid *scratch*, etc.
      (font-lock-add-keywords nil +highlight-keywords--keywords t)
      (font-lock-flush)))

  (defun emacs-solo/highlight-keywords-mode-off ()
    (font-lock-remove-keywords nil +highlight-keywords--keywords)
    (font-lock-flush))

  (define-minor-mode emacs-solo/highlight-keywords-mode
    "Highlight TODO and similar keywords in comments and strings."
    :lighter " +HL"
    :group '+highlight-keywords
    (if emacs-solo/highlight-keywords-mode
        (emacs-solo/highlight-keywords-mode-on)
      (emacs-solo/highlight-keywords-mode-off)))

  :hook
  (prog-mode-hook .
                  (lambda ()
                    (when (and buffer-file-name ; only if it's visiting a file
                               (not (string-match-p "^\\*" (buffer-name)))) ; avoid *scratch*, etc.
                      (message "[emacs-solo-highlight-keywords-mode]: running on buffer %s" (buffer-name))
                      (run-with-idle-timer 1 nil #'emacs-solo/highlight-keywords-mode-on)))))

(provide 'emacs-solo-highlight-keywords)
;;; emacs-solo-highlight-keywords.el ends here
