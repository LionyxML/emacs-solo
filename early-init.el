;;; early-init.el --- Emacs-Solo (no external packages) Configuration  -*- lexical-binding: t; -*-
;;
;;; Commentary:
;;  Early init configuration for Emacs-Solo
;;
;;; Code:

;; HACK: inscrease startup speed
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6
      vc-handled-backends '(Git))


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


;; Better Window Management handling
(setq frame-resize-pixelwise t
      frame-inhibit-implied-resize t
      frame-title-format '("Emacs"))

(setq inhibit-compacting-font-caches t)


;; Disables unused UI Elements
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'tooltip-mode) (tooltip-mode -1))


;; Resizing the Emacs frame can be a terribly expensive part of changing the
;; font. By inhibiting this, we easily halve startup times with fonts that are
;; larger than the system default.
(setq frame-inhibit-implied-resize t
      frame-resize-pixelwise t)


(provide 'early-init)
;;; early-init.el ends here
