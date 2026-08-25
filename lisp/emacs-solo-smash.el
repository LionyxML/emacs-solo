;;; emacs-solo-smash.el --- Shorten URLs with smash  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "31.1"))
;; Keywords: convenience, tools
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Provides a function to shorten a URL using the smash service at
;; https://smash.rahuljuliato.com.  The resulting short URL is copied
;; to the kill ring for easy pasting.
;;
;; `emacs-solo/smash-shorten-url' prompts for a URL, defaulting to the
;; URL under point (RET to accept), and shortens it.
;;
;; Requires `curl' to be available in PATH.

;;; Code:

(defun emacs-solo/smash-shorten-url (url)
  "Shorten URL with smash and copy the result to the kill ring.
Interactively, default to the URL under point (RET to accept) or
type a new one."
  (interactive
   (list (let ((default (thing-at-point 'url t)))
           (read-string (if default
                            (format "URL to shorten (default %s): " default)
                          "URL to shorten: ")
                        nil nil default))))
  (message ">>> emacs-solo: Shortening %s ..." url)
  (let* ((output (shell-command-to-string
                  (format "curl -s -X POST -d %s 'https://smash.rahuljuliato.com/register?raw'"
                          (shell-quote-argument (concat "url=" url)))))
         (short (let ((s (string-trim output)))
                  (unless (string-empty-p s) s))))
    (if short
        (progn
          (message ">>> emacs-solo: The URL is %s" short)
          (kill-new short))
      (message ">>> emacs-solo: smash returned no URL"))))

(provide 'emacs-solo-smash)
;;; emacs-solo-smash.el ends here
