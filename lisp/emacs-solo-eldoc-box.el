;;; emacs-solo-eldoc-box.el --- Eldoc documentation in a child frame  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: docs, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later
;;
;; Inspired by the casouri eldoc-box package.

;;; Commentary:
;;
;; Displays eldoc documentation in a child frame positioned near
;; point.  Supports syntax highlighting for several tree-sitter
;; major modes.  The frame auto-closes when point moves.

;;; Code:

(use-package emacs-solo-eldoc-box
  :if emacs-solo-enable-eldoc-box
  :ensure nil
  :no-require t
  :defer t
  :init
  ;; HOLDS CHILDFRAME
  (defvar simple-eldoc-box--child-frame nil
    "Holds the current eldoc child frame, if any.")

  ;; CREATES CHILDFRAME
  (defun simple-eldoc-box--make-frame ()
    (interactive)
    (when (frame-live-p simple-eldoc-box--child-frame)
      (delete-frame simple-eldoc-box--child-frame))
    (let* ((parent (selected-frame))
           (origin-major-mode major-mode)
           (buffer (eldoc-doc-buffer))
           (line-count (with-current-buffer buffer
                         (count-lines (point-min) (point-max))))
           (max-lines 20)
           (min-lines 0)
           (desired-lines (min max-lines (max min-lines line-count)))
           (frame (make-frame
                   `((parent-frame . ,parent)
                     (no-accept-focus . t)
                     (no-focus-on-map . t)
                     (internal-border-width . 1)
                     (undecorated . t)
                     (fullscreen . nil)
                     (left . ,(+ (window-pixel-left) (car (posn-x-y (posn-at-point)))))
                     (top . ,(+ (cdr (posn-x-y (posn-at-point)))
                                (frame-char-height)))
                     (width . 60)
                     (height . ,desired-lines)
                     (minibuffer . nil)
                     (visibility . nil)
                     (desktop-dont-save . t)
                     (right-fringe . 0)
                     (left-fringe . 0)
                     (menu-bar-lines . 0)
                     (tool-bar-lines . 0)
                     (tab-bar-lines-keep-state . 1)
                     (tab-bar-lines . 0)
                     (line-spacing . 0)
                     (unsplittable . t)
                     (cursor-type . nil)
                     (mouse-wheel-frame . nil)
                     (no-other-frame . t)
                     (inhibit-double-buffering . t)
                     (drag-internal-border . t)
                     (no-special-glyphs . t)
                     (name . "emacs-solo-eldoc-box")))))

      ;; Turn on markdown-ts-mode on some modes
      (with-current-buffer buffer
        (let ((supported-markdown-modes '(typescript-ts-mode tsx-ts-mode js-ts-mode)))
          (when (memq origin-major-mode supported-markdown-modes)
            (markdown-ts-mode)
            (font-lock-ensure)))

        (when (memq origin-major-mode '(go-ts-mode))
          (go-ts-mode)
          (font-lock-ensure))

        (when (memq origin-major-mode '(rust-ts-mode))
          (rust-ts-mode)
          (font-lock-ensure))

        (flymake-mode -1)
        (visual-line-mode 1)
        (display-line-numbers-mode -1))

      ;; Force-disable mode line in all windows of this frame
      (walk-windows
       (lambda (win)
         (when (eq (window-frame win) frame)
           (set-window-parameter win 'mode-line-format 'none)
           (set-window-parameter win 'header-line-format 'none))
         nil frame))

      (set-window-buffer (frame-root-window frame) buffer)
      (set-frame-parameter frame 'visibility t)

      ;; Darker background
      (let* ((bg (face-background 'default nil parent))
             (rgb (color-name-to-rgb bg))
             (darker (apply #'color-rgb-to-hex
                            (mapcar (lambda (c) (* 0.9 c)) rgb))))
        (set-frame-parameter frame 'background-color darker)
        (with-current-buffer buffer
          (face-remap-add-relative 'default `(:background ,darker))))

      (setq simple-eldoc-box--child-frame frame)

      (simple-eldoc-box--enable-auto-close)

      (let ((key (read-key "Eldoc Box: Press q(uit) / o(pen) doc on new window")))
        (cond
         ((equal key ?q)
          (simple-eldoc-box--delete-frame))
         ((equal key ?o)
          (simple-eldoc-box--delete-frame)
          (run-with-idle-timer 0.05 nil
                               (lambda ()
                                 (eldoc-doc-buffer t))))
         (t
          (simple-eldoc-box--delete-frame))))

      frame))

  ;; CLOSES THE BOX FRAME
  (defun simple-eldoc-box--delete-frame ()
    (interactive)
    (when (frame-live-p simple-eldoc-box--child-frame)
      (delete-frame simple-eldoc-box--child-frame)
      (setq simple-eldoc-box--child-frame nil)))

  ;; CLOSE ON NEXT "MOVE"
  (defvar simple-eldoc-box--last-point nil
    "Stores the last known position of point to detect movement.")

  (defun simple-eldoc-box--maybe-close-frame ()
    "Close the eldoc child frame if point has moved."
    (when (and simple-eldoc-box--child-frame
               (frame-live-p simple-eldoc-box--child-frame)
               (not (equal simple-eldoc-box--last-point (point))))
      (simple-eldoc-box--delete-frame)))

  (defun simple-eldoc-box--enable-auto-close ()
    "Enable automatic closing of eldoc box when point moves."
    (setq simple-eldoc-box--last-point (point))
    (add-hook 'post-command-hook #'simple-eldoc-box--maybe-close-frame))

  (defun simple-eldoc-box--disable-auto-close ()
    "Disable automatic closing of eldoc box."
    (remove-hook 'post-command-hook #'simple-eldoc-box--maybe-close-frame))

  ;; BINDINGS
  (global-set-key (kbd "C-c h") 'simple-eldoc-box--make-frame))

(provide 'emacs-solo-eldoc-box)
;;; emacs-solo-eldoc-box.el ends here
