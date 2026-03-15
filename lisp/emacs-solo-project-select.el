;;; emacs-solo-project-select.el --- Interactive project finder and switcher  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: project, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Interactively finds a project in a Projects folder and switches
;; to it using `project-switch-project'.

;;; Code:

(use-package emacs-solo-project-select
  :ensure nil
  :no-require t
  :init
  (defvar emacs-solo-default-projects-folder "~/Projects"
    "Default folder to search for projects.")

  (defvar emacs-solo-default-projects-input ""
    "Default input to use when finding a project.")

  (defun emacs-solo/find-projects-and-switch (&optional directory)
    "Find and switch to a project directory from ~/Projects.
Uses `fd' (macOS) or `fdfind' (Debian/Ubuntu) when available,
falling back to `find'."
    (interactive)
    (let* ((d (or directory emacs-solo-default-projects-folder))
           (fd-bin (or (executable-find "fd")
                       (executable-find "fdfind")))
           (find-command (if fd-bin
                             (concat fd-bin " --type d --max-depth 4 . " d)
                           (concat "find " d " -mindepth 1 -maxdepth 4 -type d")))
           (tool-name (if fd-bin
                          (file-name-nondirectory fd-bin)
                        "find"))
           (project-list (split-string (shell-command-to-string find-command) "\n" t))
           (initial-input emacs-solo-default-projects-input))
      (let ((selected-project
             (completing-read
              (format "Search [%s] in %s: " tool-name (abbreviate-file-name d))
              project-list
              nil nil
              initial-input)))
        (when (and selected-project (file-directory-p selected-project))
          (project-switch-project selected-project)))))

  :bind (:map project-prefix-map
              ("P" . emacs-solo/find-projects-and-switch)))

(provide 'emacs-solo-project-select)
;;; emacs-solo-project-select.el ends here
