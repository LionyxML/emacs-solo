;;; emacs-solo-viper-extensions.el --- Vim-like keybindings and text objects for Viper  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: emulations, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Extends Viper mode with Vim-like text objects (di(, yi", ciw,
;; etc.), visual selection, window management (C-w splits), and
;; common navigation bindings (gg, G, dd, yy).

;;; Code:

(use-package emacs-solo-viper-extensions
  :ensure nil
  :no-require t
  :defer t
  :after viper
  :init
  (defun viper-operate-inside-delimiters (open close op)
    "Perform OP inside delimiters OPEN and CLOSE (e.g., (), {}, '', or \"\")."
    (save-excursion
      (search-backward (char-to-string open) nil t)
      (forward-char) ;; Move past the opening delimiter
      (let ((start (point)))
        (search-forward (char-to-string close) nil t)
        (backward-char) ;; Move back before the closing delimiter
        (pulse-momentary-highlight-region start (point))
        (funcall op start (point)))))

  ;; FIXME: works for most common cases, misses (  bla bla (bla) |cursor-here| )
  (defun viper-delete-inside-delimiters (open close)
    "Delete text inside delimiters OPEN and CLOSE, saving it to the kill ring."
    (interactive "cEnter opening delimiter: \ncEnter closing delimiter: ")
    (viper-operate-inside-delimiters open close 'kill-region))

  (defun viper-yank-inside-delimiters (open close)
    "Copy text inside delimiters OPEN and CLOSE to the kill ring."
    (interactive "cEnter opening delimiter: \ncEnter closing delimiter: ")
    (viper-operate-inside-delimiters open close 'kill-ring-save))

  (defun viper-delete-line-or-region ()
    "Delete the current line or the selected region in Viper mode.
The deleted text is saved to the kill ring."
    (interactive)
    (if (use-region-p)
        ;; If a region is active, delete it
        (progn
          (pulse-momentary-highlight-region (region-beginning) (region-end))
          (run-at-time 0.1 nil 'kill-region (region-beginning) (region-end)))
      ;; Otherwise, delete the current line including its newline character
      (pulse-momentary-highlight-region (line-beginning-position) (line-beginning-position 2))
      (run-at-time 0.1 nil 'kill-region (line-beginning-position) (line-beginning-position 2))))

  (defun viper-yank-line-or-region ()
    "Yank the current line or the selected region and highlight the region."
    (interactive)
    (if (use-region-p)
        ;; If a region is selected, yank it
        (progn
          (kill-ring-save (region-beginning) (region-end))  ;; Yank the region
          (pulse-momentary-highlight-region (region-beginning) (region-end)))
      ;; Otherwise, yank the current line
      (let ((start (line-beginning-position))
            (end (line-end-position)))
        (kill-ring-save start end)  ;; Yank the current line
        (pulse-momentary-highlight-region start end))))

  (defun viper-visual-select ()
    "Start visual selection from the current position."
    (interactive)
    (set-mark (point)))

  (defun viper-visual-select-line ()
    "Start visual selection from the beginning of the current line."
    (interactive)
    (set-mark (line-beginning-position)))

  (defun viper-delete-inner-word ()
    "Delete the current word under the cursor, handling edge cases."
    (interactive)
    (let ((bounds (bounds-of-thing-at-point 'word)))
      (if bounds
          (kill-region (car bounds) (cdr bounds))
        (message "No word under cursor"))))

  (defun viper-change-inner-word ()
    "Change the current word under the cursor, handling edge cases."
    (interactive)
    (viper-delete-inner-word)
    (viper-insert nil))

  (defun viper-yank-inner-word ()
    "Yank (copy) the current word under the cursor, handling edge cases."
    (interactive)
    (let ((bounds (bounds-of-thing-at-point 'word)))
      (pulse-momentary-highlight-region (car bounds) (cdr bounds))
      (if bounds
          (kill-ring-save (car bounds) (cdr bounds))
        (message "No word under cursor"))))

  (defun viper-delete-inner-compound-word ()
    "Delete the entire compound word under the cursor, including `-` and `_`."
    (interactive)
    (let ((bounds (viper-compound-word-bounds)))
      (if bounds
          (kill-region (car bounds) (cdr bounds))
        (message "No compound word under cursor"))))

  (defun viper-change-inner-compound-word ()
    "Change the entire compound word under the cursor, including `-` and `_`."
    (interactive)
    (viper-delete-inner-compound-word)
    (viper-insert nil))

  (defun viper-yank-inner-compound-word ()
    "Yank the entire compound word under the cursor into the kill ring."
    (interactive)
    (let ((bounds (viper-compound-word-bounds)))
      (pulse-momentary-highlight-region (car bounds) (cdr bounds))
      (if bounds
          (kill-ring-save (car bounds) (cdr bounds))
        (message "No compound word under cursor"))))

  (defun viper-compound-word-bounds ()
    "Get the bounds of a compound word under the cursor.
A compound word includes letters, numbers, `-`, and `_`."
    (save-excursion
      (let* ((start (progn
                      (skip-chars-backward "a-zA-Z0-9_-")
                      (point)))
             (end (progn
                    (skip-chars-forward "a-zA-Z0-9_-")
                    (point))))
        (when (< start end) (cons start end)))))

  (defun viper-go-to-nth-or-first-line (arg)
    "Go to the first line of the document, or the ARG-nth."
    (interactive "P")
    (if arg
        (viper-goto-line arg)
      (viper-goto-line 1))
    (pulse-momentary-highlight-region
     (line-beginning-position) (line-beginning-position 2)))

  (defun viper-go-to-last-line ()
    "Go to the last line of the document."
    (interactive)
    (goto-char (point-max)))

  (defun viper-window-split-horizontally ()
    "Split the window horizontally (mimics Vim's `C-w s`)."
    (interactive)
    (split-window-below)
    (other-window 1))

  (defun viper-window-split-vertically ()
    "Split the window vertically (mimics Vim's `C-w v`)."
    (interactive)
    (split-window-right)
    (other-window 1))

  (defun viper-window-close ()
    "Close the current window (mimics Vim's `C-w c`)."
    (interactive)
    (delete-window))

  (defun viper-window-maximize ()
    "Maximize the current window (mimics Vim's `C-w o`)."
    (interactive)
    (delete-other-windows))

  ;; Delete inside delimiters
  (define-key viper-vi-global-user-map (kbd "di(") (lambda () (interactive) (viper-delete-inside-delimiters ?\( ?\))))
  (define-key viper-vi-global-user-map (kbd "dib") (lambda () (interactive) (viper-delete-inside-delimiters ?\( ?\))))
  (define-key viper-vi-global-user-map (kbd "di{") (lambda () (interactive) (viper-delete-inside-delimiters ?{ ?})))
  (define-key viper-vi-global-user-map (kbd "di\"") (lambda () (interactive) (viper-delete-inside-delimiters ?\" ?\")))
  (define-key viper-vi-global-user-map (kbd "di'") (lambda () (interactive) (viper-delete-inside-delimiters ?' ?')))

  ;; Yank inside delimiters
  (define-key viper-vi-global-user-map (kbd "yi(") (lambda () (interactive) (viper-yank-inside-delimiters ?\( ?\))))
  (define-key viper-vi-global-user-map (kbd "yi{") (lambda () (interactive) (viper-yank-inside-delimiters ?{ ?})))
  (define-key viper-vi-global-user-map (kbd "yi\"") (lambda () (interactive) (viper-yank-inside-delimiters ?\" ?\")))
  (define-key viper-vi-global-user-map (kbd "yi'") (lambda () (interactive) (viper-yank-inside-delimiters ?' ?')))

  ;; Delete/Yank current word
  (define-key viper-vi-global-user-map (kbd "diw") 'viper-delete-inner-word)
  (define-key viper-vi-global-user-map (kbd "yiw") 'viper-yank-inner-word)
  (define-key viper-vi-global-user-map (kbd "ciw") 'viper-change-inner-word)
  (define-key viper-vi-global-user-map (kbd "diW") 'viper-delete-inner-compound-word)
  (define-key viper-vi-global-user-map (kbd "yiW") 'viper-yank-inner-compound-word)
  (define-key viper-vi-global-user-map (kbd "ciW") 'viper-change-inner-compound-word)

  ;; Beginning/End buffer
  (define-key viper-vi-global-user-map (kbd "G") 'viper-go-to-last-line)
  (define-key viper-vi-global-user-map (kbd "g") nil)
  (define-key viper-vi-global-user-map (kbd "gg") 'viper-go-to-nth-or-first-line)

  ;; Vertically position to center
  (define-key viper-vi-global-user-map (kbd "zz") 'recenter-top-bottom)

  ;; Delete/Yank current line or region
  (define-key viper-vi-global-user-map (kbd "dd") 'viper-delete-line-or-region)
  (define-key viper-vi-global-user-map (kbd "yy") 'viper-yank-line-or-region)

  ;; Visual mode is actually marking
  (define-key viper-vi-global-user-map (kbd "v") 'viper-visual-select)
  (define-key viper-vi-global-user-map (kbd "V") 'viper-visual-select-line)

  ;; Movements by references and LSP
  (define-key viper-vi-global-user-map (kbd "gd") 'xref-find-references)
  (define-key viper-vi-global-user-map (kbd "SPC c a") 'eglot-code-actions)
  (define-key viper-vi-global-user-map (kbd "SPC s g") 'project-find-regexp)
  (define-key viper-vi-global-user-map (kbd "SPC s f") 'project-find-file)
  (define-key viper-vi-global-user-map (kbd "SPC m p") 'emacs-solo-formatter/format-current-file-manual)
  (global-set-key (kbd "C-o") 'xref-go-back)

  ;; Map `C-w` followed by specific keys to window commands in Viper
  (define-key viper-vi-global-user-map (kbd "C-w s") 'viper-window-split-horizontally)
  (define-key viper-vi-global-user-map (kbd "C-w v") 'viper-window-split-vertically)
  (define-key viper-vi-global-user-map (kbd "C-w c") 'viper-window-close)
  (define-key viper-vi-global-user-map (kbd "C-w o") 'viper-window-maximize)

  ;; Add navigation commands to mimic Vim's `C-w hjkl`
  (define-key viper-vi-global-user-map (kbd "C-w h") 'windmove-left)
  (define-key viper-vi-global-user-map (kbd "C-w l") 'windmove-right)
  (define-key viper-vi-global-user-map (kbd "C-w k") 'windmove-up)
  (define-key viper-vi-global-user-map (kbd "C-w j") 'windmove-down)

  ;; Indent region
  (define-key viper-vi-global-user-map (kbd "==") 'indent-region)

  ;; Word spelling
  (define-key viper-vi-global-user-map (kbd "z=") 'ispell-word)

  ;; Keybindings for buffer navigation and switching in Viper mode
  (define-key viper-vi-global-user-map (kbd "] b") 'next-buffer)
  (define-key viper-vi-global-user-map (kbd "[ b") 'previous-buffer)
  (define-key viper-vi-global-user-map (kbd "b l") 'switch-to-buffer)
  (define-key viper-vi-global-user-map (kbd "SPC SPC") 'switch-to-buffer)

  ;; Tabs (like in tmux tabs, not vscode tabs)
  (define-key viper-vi-global-user-map (kbd "C-w t") 'tab-bar-new-tab)
  (define-key viper-vi-global-user-map (kbd "] t") 'tab-next)
  (define-key viper-vi-global-user-map (kbd "[ t") 'tab-previous)

  ;; Flymake
  (define-key viper-vi-global-user-map (kbd "SPC x x") 'flymake-show-buffer-diagnostics)
  (define-key viper-vi-global-user-map (kbd "] d") 'flymake-goto-next-error)
  (define-key viper-vi-global-user-map (kbd "[ d") 'flymake-goto-prev-error)
  (define-key viper-vi-global-user-map (kbd "SPC t i") 'toggle-flymake-diagnostics-at-eol)

  ;; Gutter
  (define-key viper-vi-global-user-map (kbd "] c") 'emacs-solo/goto-next-hunk)
  (define-key viper-vi-global-user-map (kbd "[ c") 'emacs-solo/goto-previous-hunk))

(provide 'emacs-solo-viper-extensions)
;;; emacs-solo-viper-extensions.el ends here
