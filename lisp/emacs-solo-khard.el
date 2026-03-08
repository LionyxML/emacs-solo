;;; emacs-solo-khard.el --- Khard contacts browser  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: comm, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Browse and search khard (vCard CLI) contacts in a tabulated
;; list buffer.  Copy contact entries as "Name <email>" to the
;; kill ring.

;;; Code:

(use-package emacs-solo-khard
  :ensure nil
  :no-require t
  :defer t
  :init
  (require 'tabulated-list)

  (defvar emacs-solo-khard-buffer "*Khard Contacts*"
    "Buffer name for displaying khard contacts.")

  (defun emacs-solo--parse-khard-output (output)
    "Parse khard OUTPUT into tabulated list entries."
    (let ((lines (split-string output "\n" t))
          entries)
      ;; Drop header lines (find where actual table starts)
      (dolist (line lines)
        (when (string-match-p "gmail\\|icloud" line)
          (let* ((cols (split-string line "\\s-\\{2,\\}" t))
                 (index (car cols)))
            (push
             (list index
                   (vector
                    (or index "")
                    (or (nth 1 cols) "")
                    (or (nth 2 cols) "")
                    (or (nth 3 cols) "")
                    (or (nth 4 cols) "")
                    (or (nth 5 cols) "")))
             entries))))
      (nreverse entries)))

  (define-derived-mode emacs-solo-khard-mode tabulated-list-mode "Khard"
    "Major mode for viewing Khard contacts."
    (setq tabulated-list-format [("Index" 5 t)
                                 ("Name" 40 t)
                                 ("Phone" 25 t)
                                 ("Email" 40 t)
                                 ("Book" 10 t)
                                 ("UID" 8 t)])
    (setq tabulated-list-padding 2)
    (tabulated-list-init-header))

  (defun emacs-solo/khard-list ()
    "Run khard and display contacts in a tabulated buffer."
    (interactive)
    (let* ((output (shell-command-to-string "khard"))
           (entries (emacs-solo--parse-khard-output output)))
      (with-current-buffer (get-buffer-create emacs-solo-khard-buffer)
        (emacs-solo-khard-mode)
        (setq tabulated-list-entries entries)
        (tabulated-list-print t)
        (switch-to-buffer (current-buffer)))))

  (defun emacs-solo/khard-search ()
    "Search khard contacts and return `Name <email>`."
    (interactive)
    (let* ((output (shell-command-to-string "khard"))
           (lines (split-string output "\n" t))
           (candidates '()))
      (dolist (line lines)
        (when (string-match-p "gmail\\|icloud" line)
          (let* ((cols (split-string line "\\s-\\{2,\\}" t))
                 (name (or (nth 1 cols) ""))
                 (email (or (nth 3 cols) "")))
            (when (and (not (string-empty-p name))
                       (not (string-empty-p email)))
              (push (cons (format "%s <%s>" name email) email) candidates)))))
      (let* ((choice (completing-read "Search on Khard: " (mapcar #'car candidates)))
             (res choice))
        (kill-new res)
        (message "Copied contact: %s" res)
        res))))

(provide 'emacs-solo-khard)
;;; emacs-solo-khard.el ends here
