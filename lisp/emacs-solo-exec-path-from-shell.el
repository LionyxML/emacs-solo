;;; emacs-solo-exec-path-from-shell.el --- Sync shell PATH into Emacs  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: terminals, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Loads the user's default shell PATH settings into Emacs.
;; Useful when launching Emacs directly from GUI systems.
;; Supports bash, zsh, and fish shells.

;;; Code:

(use-package emacs-solo-exec-path-from-shell
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/set-exec-path-from-shell-PATH ()
    "Set up Emacs' `exec-path' and PATH environment the same as the user's shell.
This works with bash, zsh, or fish)."
    (interactive)
    (let* ((shell (getenv "SHELL"))
           (shell-name (file-name-nondirectory shell))
           (command
            (cond
             ((string= shell-name "fish")
              "fish -c 'string join : $PATH'")
             ((string= shell-name "zsh")
              "zsh -i -c 'printenv PATH'")
             ((string= shell-name "bash")
              "bash --login -c 'echo $PATH'")
             (t nil))))
      (if (not command)
          (message "emacs-solo: Unsupported shell: %s" shell-name)
        (let ((path-from-shell
               (replace-regexp-in-string
                "[ \t\n]*$" ""
                (shell-command-to-string command))))
          (when (and path-from-shell (not (string= path-from-shell "")))
            (setenv "PATH" path-from-shell)
            (setq exec-path (split-string path-from-shell path-separator))
            (message ">>> emacs-solo: PATH loaded from %s" shell-name))))))

  (add-hook 'after-init-hook #'emacs-solo/set-exec-path-from-shell-PATH))

(provide 'emacs-solo-exec-path-from-shell)
;;; emacs-solo-exec-path-from-shell.el ends here
