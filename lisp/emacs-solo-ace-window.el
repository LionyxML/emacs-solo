;;; emacs-solo-ace-window.el --- Quick window switching with labels  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "31.1"))
;; Keywords: convenience
;; SPDX-License-Identifier: GPL-3.0-or-later
;;
;; Based on: https://www.reddit.com/r/emacs/comments/1h0zjvq/comment/m0uy3bo/?context=3

;;; Commentary:
;;
;; Provides a quick window-jump command that labels visible windows
;; with number keys, allowing fast switching.  Inspired by the
;; ace-window package, with a companion command to swap the current
;; window's buffer with a labeled one.

;;; Code:

(use-package emacs-solo-ace-window
  :ensure nil
  :no-require t
  :defer t
  :init
  (defvar emacs-solo-ace-window/quick-window-overlays nil
    "List of overlays used to temporarily display window labels.")

  (defun emacs-solo-ace-window/read-window (prompt)
    "Label the visible windows and read one by its key, PROMPT-ing for it.
Returns the chosen window, or nil when the key matches none.
Windows are labeled starting from the top-left window and proceeding
top to bottom, then left to right."
    (let* ((window-list (emacs-solo-ace-window/get-windows))
           (window-keys (seq-take '("1" "2" "3" "4" "5" "6" "7" "8")
                                  (length window-list)))
           (window-map (cl-pairlis window-keys window-list)))
      (emacs-solo-ace-window/add-window-key-overlays window-map)
      (unwind-protect
          (let ((key (read-key (format "%s [%s]: " prompt
                                       (string-join window-keys ", ")))))
            (or (cdr (assoc (char-to-string key) window-map))
                (progn
                  (message ">>> emacs-solo: No window assigned to key %c" key)
                  nil)))
        (emacs-solo-ace-window/remove-window-key-overlays))))

  (defun emacs-solo-ace-window/quick-window-jump ()
    "Jump to a window by typing its assigned character label."
    (interactive)
    (when-let* ((window (emacs-solo-ace-window/read-window "Select window")))
      (select-window window)))

  (defun emacs-solo-ace-window/quick-window-swap ()
    "Swap the buffers of two labeled windows, asked as source then target.
Neither has to be the selected window.  Point and scroll position
travel with each buffer, and the selected window does not change."
    (interactive)
    (when-let* ((from (emacs-solo-ace-window/read-window "Swap from window"))
                (to (emacs-solo-ace-window/read-window "Swap to window")))
      (if (eq from to)
          (message ">>> emacs-solo: Cannot swap a window with itself")
        ;; `window-swap-states' carries the selection over with the state
        (let ((origin (selected-window)))
          (window-swap-states from to)
          (when (window-live-p origin)
            (select-window origin))))))

  (defun emacs-solo-ace-window/get-windows ()
    "Return a list of windows in the current frame.
Ordered from top to bottom, left to right."
    (sort (window-list nil 'no-mini)
          (lambda (w1 w2)
            (let ((edges1 (window-edges w1))
                  (edges2 (window-edges w2)))
              (or (< (car edges1) (car edges2)) ; Compare top edges
                  (and (= (car edges1) (car edges2)) ; If equal, compare left edges
                       (< (cadr edges1) (cadr edges2))))))))

  (defun emacs-solo-ace-window/add-window-key-overlays (window-map)
    "From WINDOW-MAP, add temporary overlays to windows.
With their assigned key labels ."
    (setq emacs-solo-ace-window/quick-window-overlays nil)
    (dolist (entry window-map)
      (let* ((key (car entry))
             (window (cdr entry))
             (start (window-start window))
             (overlay (make-overlay start start (window-buffer window))))
        (overlay-put overlay 'after-string
                     (propertize (format " [%s] " key)
                                 'face '(:inherit font-lock-keyword-face
                                                  :weight bold)))
        (overlay-put overlay 'window window)
        (push overlay emacs-solo-ace-window/quick-window-overlays))))

  (defun emacs-solo-ace-window/remove-window-key-overlays ()
    "Remove all temporary overlays used to display key labels in windows."
    (mapc 'delete-overlay emacs-solo-ace-window/quick-window-overlays)
    (setq emacs-solo-ace-window/quick-window-overlays nil))

  (global-set-key (kbd "C-c w") #'emacs-solo-ace-window/quick-window-jump)
  (global-set-key (kbd "C-c W") #'emacs-solo-ace-window/quick-window-swap))

(provide 'emacs-solo-ace-window)
;;; emacs-solo-ace-window.el ends here
