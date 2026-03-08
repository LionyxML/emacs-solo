;;; emacs-solo-mode-line.el --- Custom mode-line format and configuration  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: faces, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Customizes the mode-line format with a compact layout including
;; shortened VC branch names, project info, and hidden minor modes.

;;; Code:

(use-package emacs-solo-mode-line
  :ensure nil
  :no-require t
  :defer t
  :init
  ;; Shorten big branches names
  (defun emacs-solo/shorten-vc-mode (vc)
    "Shorten VC string to at most 20 characters.
Replacing `Git-' with a branch symbol."
    (let* ((vc (replace-regexp-in-string "^ Git[:-]"
                                         (if (char-displayable-p ?) "  " "Git: ")
                                         vc))) ;; Options:   ᚠ ⎇
      (if (> (length vc) 20)
          (concat (substring vc 0 20)
                  (if (char-displayable-p ?…) "…" "..."))
        vc)))

  ;; Formats mode-line
  (setq-default mode-line-format
                '("%e" "  "
                  ;; (:propertize " " display (raise +0.1)) ;; Top padding
                  ;; (:propertize " " display (raise -0.1)) ;; Bottom padding
                  (:propertize
                   (if (char-displayable-p ?λ) "λ  " "   ") face font-lock-keyword-face)

                  (:propertize
                   ("" mode-line-mule-info mode-line-client mode-line-modified mode-line-remote))

                  mode-line-frame-identification
                  mode-line-buffer-identification
                  "   "
                  mode-line-position
                  mode-line-format-right-align
                  "  "
                  (project-mode-line project-mode-line-format)
                  "  "
                  (vc-mode (:eval (emacs-solo/shorten-vc-mode vc-mode)))
                  "  "
                  mode-line-modes
                  mode-line-misc-info
                  "  ")
                project-mode-line t
                mode-line-buffer-identification '(" %b")
                mode-line-position-column-line-format '(" %l:%c"))

  (setq mode-line-modes-delimiters '("" . ""))  ;; EMACS-31

  ;; EMACS-31
  (setq mode-line-collapse-minor-modes
        '(abbrev-mode
          auto-revert-mode
          eldoc-mode
          flyspell-mode
          smooth-scroll-mode
          outline-minor-mode
          completion-preview-mode
          which-key-mode))

  (defvar emacs-solo-hidden-minor-modes mode-line-collapse-minor-modes)

  (defun emacs-solo/purge-minor-modes ()
    (interactive)
    (dolist (x emacs-solo-hidden-minor-modes nil)
      (let ((trg (cdr (assoc x minor-mode-alist))))
        (when trg
          (setcar trg "")))))

  (if (< emacs-major-version 31)
      (add-hook 'after-change-major-mode-hook 'emacs-solo/purge-minor-modes)))

(provide 'emacs-solo-mode-line)
;;; emacs-solo-mode-line.el ends here
