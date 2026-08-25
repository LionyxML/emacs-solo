;;; emacs-solo-movements.el --- Enhanced navigation and window movement commands  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "31.1"))
;; Keywords: convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Provides enhanced scrolling with auto-centering, window
;; transposing (horizontal <-> vertical split), and buffer
;; promotion from side windows.

;;; Code:

(use-package emacs-solo-movements
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo-movements/scroll-down-centralize ()
    (interactive)
    (scroll-up-command)
    (recenter))

  (defun emacs-solo-movements/scroll-up-centralize ()
    (interactive)
    (scroll-down-command)
    (unless (= (window-start) (point-min))
      (recenter))
    (when (= (window-start) (point-min))
      (let ((midpoint (/ (window-height) 2)))
        (goto-char (window-start))
        (forward-line midpoint)
        (recenter midpoint))))

  (global-set-key (kbd "C-v") #'emacs-solo-movements/scroll-down-centralize)
  (global-set-key (kbd "M-v") #'emacs-solo-movements/scroll-up-centralize))

(provide 'emacs-solo-movements)
;;; emacs-solo-movements.el ends here
