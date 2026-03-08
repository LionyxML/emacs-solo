;;; emacs-solo-sudo-edit.el --- Edit files as root via TRAMP  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: files, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later
;;
;; Inspired by: https://codeberg.org/daviwil/dotfiles/src/branch/master/Emacs.org#headline-28
;;
;; From EMACS-31 onwards this wont be necessary, as C-x x @ will call
;; `tramp-revert-buffer-with-sudo'.

;;; Commentary:
;;
;; Reopen the current file (or prompt for one) as root using
;; TRAMP's /sudo: method.

;;; Code:

(use-package emacs-solo-sudo-edit
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/sudo-edit (&optional arg)
    "Edit currently visited file as root.
With a prefix ARG prompt for a file to visit.
Will also prompt for a file to visit if current
buffer is not visiting a file."
    (interactive "P")
    (if (or arg (not buffer-file-name))
        (find-file (concat "/sudo:root@localhost:"
                           (read-file-name "Find file (as root): ")))
      (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name)))))

(provide 'emacs-solo-sudo-edit)
;;; emacs-solo-sudo-edit.el ends here
