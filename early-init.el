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

;;; -------------------- PERFORMANCE & HACKS
;; HACK: inscrease startup speed
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6
      vc-handled-backends '(Git))

(setopt native-comp-async-on-battery-power nil) ; EMACS-31

;; HACK: avoid being flashbanged
(defun emacs-solo/avoid-initial-flash-of-light ()
  "Avoid flash of light when starting Emacs."
  (setq mode-line-format nil)
  ;; These colors should match your selected theme for maximum effect
  (set-face-attribute 'default nil :background "#292D3E" :foreground "#292D3E"))

(defun emacs-solo/reset-default-foreground ()
  "Reset the foreground color of the default face."
    (set-face-attribute 'default nil :foreground (face-foreground 'default)))

(emacs-solo/avoid-initial-flash-of-light)                           ; HACK start
(add-hook 'after-init-hook #'emacs-solo/reset-default-foreground)   ; HACK undo


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
