;;; early-init.el --- Emacs Solo (no external packages) Configuration --- Early Init  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: config
;; SPDX-License-Identifier: GPL-3.0-or-later
;;

;;; Commentary:
;;  Early init configuration for Emacs Solo
;;

;;; Code:

(defcustom emacs-solo-avoid-flash-options
  '((enabled . t)
    (background . "#292D3E")
    (foreground . "#292D3E")
    (reset-background . "#292D3E")
    (reset-foreground . "#EEFFFF"))
  "Options to avoid flash of light on Emacs startup.
- `enabled`: Whether to apply the workaround.
- `background`, `foreground`: Initial colors to use.
- `reset-background`, `reset-foreground`: Optional explicit colors to restore after startup.

NOTE: The default values here presented are set for the default
`emacs-solo' custom theme.  If you'd like to turn this ON with another
theme, change the background/foreground variables.

If reset values are nil, nothing is reset."
  :type '(alist :key-type symbol :value-type (choice (const nil) string))
  :group 'emacs-solo)


;;; -------------------- PERFORMANCE & HACKS
;; HACK: inscrease startup speed
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6
      vc-handled-backends '(Git))

(setopt native-comp-async-on-battery-power nil) ; EMACS-31

;; HACK: avoid being flashbanged
(defun emacs-solo/avoid-initial-flash-of-light ()
  "Avoid flash of light when starting Emacs, based on `emacs-solo-avoid-flash-options`."
  (when (alist-get 'enabled emacs-solo-avoid-flash-options)
    (setq mode-line-format nil)
    (set-face-attribute 'default nil
                        :background (alist-get 'background emacs-solo-avoid-flash-options)
                        :foreground (alist-get 'foreground emacs-solo-avoid-flash-options))))

(defun emacs-solo/reset-default-colors ()
  "Reset any explicitly defined reset values in `emacs-solo-avoid-flash-options`."
  (when (alist-get 'enabled emacs-solo-avoid-flash-options)
    (let ((bg (alist-get 'reset-background emacs-solo-avoid-flash-options))
          (fg (alist-get 'reset-foreground emacs-solo-avoid-flash-options)))
      (when bg
        (set-face-attribute 'default nil :background bg))
      (when fg
        (set-face-attribute 'default nil :foreground fg)))))

(emacs-solo/avoid-initial-flash-of-light)
(add-hook 'after-init-hook #'emacs-solo/reset-default-colors)


;; Always start Emacs and new frames maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))


;; Better Window Management handling
(setq frame-resize-pixelwise t
      frame-inhibit-implied-resize t
      frame-title-format
      '(:eval
        (let ((project (project-current)))
          (if project
              (concat "Emacs - [p] "
                      (file-name-nondirectory (directory-file-name (project-root project))))
              (concat "Emacs - " (buffer-name))))))

(setq inhibit-compacting-font-caches t)


;; Disables unused UI Elements
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'tooltip-mode) (tooltip-mode -1))


;; Avoid raising the *Messages* buffer if anything is still without
;; lexical bindings
(setq warning-minimum-level :error)
(setq warning-suppress-types '((lexical-binding)))


(provide 'early-init)
;;; early-init.el ends here
