;;; emacs-solo-themes.el --- Custom color themes based on Modus  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "31.1"))
;; Keywords: faces, themes
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Custom color themes providing Catppuccin Mocha, SystemCrafters,
;; Kusanagi (Ghost in the Shell), and Matrix palettes.
;;
;; Standalone themes (one file each in this directory), built on the
;; modus-themes >= 5 infrastructure (bundled with Emacs 31+):
;; emacs-solo-catppuccin-mocha-theme.el, emacs-solo-crafters-theme.el,
;; emacs-solo-kusanagi-theme.el, emacs-solo-matrix-theme.el.  Selected
;; with `emacs-solo-use-custom-theme'.

;;; Code:

;;;  Standalone themes (proper Modus >= 5 derived themes)
;;
;; Self-contained: options like italic/bold constructs are baked into
;; the theme files, they can be toggled with `disable-theme', and used
;; outside emacs-solo with a plain `load-theme'.
(when-let* ((theme (pcase emacs-solo-use-custom-theme
                     ('catppuccin 'emacs-solo-catppuccin-mocha)
                     ('crafters 'emacs-solo-crafters)
                     ('kusanagi 'emacs-solo-kusanagi)
                     ('matrix 'emacs-solo-matrix))))
  (add-to-list 'custom-theme-load-path
               (expand-file-name "lisp" user-emacs-directory))
  (load-theme theme t))

;;;  nil theme: reset all custom face overrides set by other themes
;;
;; When no emacs-solo theme is selected, any faces previously saved to
;; custom-vars.el by a theme's `custom-set-faces' call will persist across
;; restarts.  This block explicitly clears them so Emacs falls back to its
;; default/built-in face definitions.
(when (null emacs-solo-use-custom-theme)
  (dolist (face '(change-log-acknowledgment
                  change-log-date
                  change-log-name
                  diff-context
                  diff-file-header
                  diff-header
                  diff-hunk-header
                  flymake-note
                  flymake-warning
                  gnus-button
                  gnus-group-mail-3
                  gnus-group-mail-3-empty
                  gnus-header-content
                  gnus-header-from
                  gnus-header-name
                  gnus-header-subject
                  link
                  log-view-message
                  match
                  modus-themes-search-current
                  modus-themes-search-lazy
                  newsticker-extra-face
                  newsticker-feed-face
                  newsticker-treeview-face
                  newsticker-treeview-selection-face
                  tab-bar
                  tab-bar-tab
                  tab-bar-tab-group-current
                  tab-bar-tab-group-inactive
                  tab-bar-tab-inactive
                  vc-dir-file
                  vc-dir-header-value))
    ;; Clear the 'user theme entry that custom-set-faces wrote — it has
    ;; higher priority than defface and would otherwise override the reset.
    (put face 'customized-face nil)
    (custom-push-theme 'theme-face face 'user 'reset)
    (face-spec-recalc face (selected-frame))))

(provide 'emacs-solo-themes)
;;; emacs-solo-themes.el ends here
