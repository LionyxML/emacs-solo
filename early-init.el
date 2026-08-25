;;; early-init.el --- Emacs Solo (no external packages) Configuration --- Early Init  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "31.1"))
;; Keywords: config
;; SPDX-License-Identifier: GPL-3.0-or-later
;;

;;; Commentary:
;;  Early init configuration for Emacs Solo
;;

;;; Code:

;; Load customizations as early as possible so user settings
;; (e.g. emacs-solo-avoid-flash-options) take effect before they are used.
(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)

(defcustom emacs-solo-avoid-flash-options
  '((enabled    . t)
    (mask-color . "black"))
  "Options to avoid flash of light on Emacs startup.
- `enabled`: Whether to apply the workaround.
- `mask-color`: Color to paint the initial frame with (default \"black\").

The initial frame is masked with `mask-color' so no white flash shows while
Emacs boots.  After startup the default face is recomputed, so whichever theme
was loaded (or Emacs' built-in default, when none is) repaints it."
  :type '(alist :key-type symbol :value-type (choice boolean string))
  :group 'emacs-solo)


;;; -------------------- PERFORMANCE & HACKS
;; HACK: inscrease startup speed

;; Delay garbage collection while Emacs is booting
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Schedule garbage collection sensible defaults for after booting
(add-hook 'after-init-hook
          (lambda ()
            (setq gc-cons-threshold (* 100 1024 1024)
                  gc-cons-percentage 0.1)))

;; HACK: Skip the file-name-handler regexp matching on every file load
;;       while booting, then restore it afterwards
(defvar emacs-solo--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'after-init-hook
          (lambda ()
            (setq file-name-handler-alist emacs-solo--file-name-handler-alist)))

;; Single VC backend inscreases booting speed
(setq vc-handled-backends '(Git))

;; Do not native compile if on battery power
(setopt native-comp-async-on-battery-power nil)

;; HACK: avoid being flashbanged
(defvar emacs-solo--masked-mode-line-format nil
  "Value of `mode-line-format' saved before the startup mask hid it.")

(defun emacs-solo/avoid-initial-flash-of-light ()
  "Avoid flash of light when starting Emacs, based on `emacs-solo-avoid-flash-options`."
  (when (and initial-window-system  ;; TTYs never flash
             (alist-get 'enabled emacs-solo-avoid-flash-options))
    ;; `mode-line-format' is buffer-local in every buffer, so a plain
    ;; `setq' here would only touch *scratch* (and be killed by its
    ;; major mode anyway).
    (setq emacs-solo--masked-mode-line-format (default-value 'mode-line-format))
    (setq-default mode-line-format nil)
    (let ((color (alist-get 'mask-color emacs-solo-avoid-flash-options)))
      (set-face-attribute 'default nil :background color :foreground color))))

(defun emacs-solo/reset-default-colors ()
  "Undo the startup mask so the loaded theme (or default) repaints it."
  (when (and initial-window-system  ;; TTYs never flash
             (alist-get 'enabled emacs-solo-avoid-flash-options))
    ;; Only put the old mode line back if nothing set one meanwhile,
    ;; so we never clobber the mode line built during init.
    (when (null (default-value 'mode-line-format))
      (setq-default mode-line-format emacs-solo--masked-mode-line-format))
    (set-face-attribute 'default nil
                        :background 'unspecified :foreground 'unspecified)
    ;; Masking `default' also stored the mask color as the
    ;; background-color/foreground-color of `default-frame-alist', and
    ;; setting the face back to `unspecified' does not remove it, so
    ;; every new frame (C-x 5 2) would still be born masked.
    (let ((color (alist-get 'mask-color emacs-solo-avoid-flash-options)))
      (dolist (param '(background-color foreground-color))
        (when (equal (alist-get param default-frame-alist) color)
          (setq default-frame-alist
                (assq-delete-all param default-frame-alist)))))
    (custom-theme-recalc-face 'default)))

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
              (concat "Emacs - [p] " (project-name project))
              (concat "Emacs - " (buffer-name))))))

(when (eq system-type 'darwin)
  (setq ns-use-proxy-icon nil))

(setq inhibit-compacting-font-caches t)

;; Disables unused UI Elements
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'tooltip-mode) (tooltip-mode -1))
(if (fboundp 'fringe-mode) (fringe-mode -1))


;; Avoid raising the *Messages* buffer if anything is still without
;; lexical bindings
(setq warning-minimum-level :error)
(setq warning-suppress-types '((lexical-binding)))


;; Optional user overrides, loaded only if present
(load (locate-user-emacs-file "private-early-init") 'noerror 'nomessage)


(provide 'early-init)
;;; early-init.el ends here
