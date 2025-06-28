;;; init.el --- Emacs Solo (no external packages) Configuration --- Init  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: config
;; SPDX-License-Identifier: GPL-3.0-or-later
;;

;;; Commentary:
;;  Init configuration for Emacs Solo
;;

;;; Code:

;;; -------------------- EMACS SOLO CUSTOM OPTIONS
;;
;;  Some features Emacs Solo provides you can turn on/off
(defcustom emacs-solo-enable-transparency nil
  "Enable `emacs-solo-transparency'."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-enable-dired-icons t
  "Enable `emacs-solo-dired-icons'."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-enable-dired-gutter t
  "Enable `emacs-solo-enable-dired-gutter'."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-enable-highlight-keywords t
  "Enable `emacs-solo-enable-highlight-keywords'."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-enable-rainbown-delimiters t
  "Enable `emacs-solo-enable-rainbown-delimiters'."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-enable-buffer-gutter t
  "Enable `emacs-solo-enable-gutter'."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-enable-custom-orderless nil
  "Enable `emacs-solo-completions-box'."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-enable-eldoc-box t
  "Enable `emacs-solo-eldoc-box'."
  :type 'boolean
  :group 'emacs-solo)

;;; -------------------- GENERAL EMACS CONFIG
;;; EMACS
(use-package emacs
  :ensure nil
  :bind
  (("M-o" . other-window)
   ("M-j" . duplicate-dwim)
   ("M-g r" . recentf)
   ("M-s g" . grep)
   ("C-x ;" . comment-line)
   ("M-s f" . find-name-dired)
   ("C-x C-b" . ibuffer)
   ("C-x w t"  . window-layout-transpose)            ; EMACS-31
   ("C-x w r"  . window-layout-rotate-clockwise)     ; EMACS-31
   ("C-x w f h"  . window-layout-flip-leftright)     ; EMACS-31
   ("C-x w f v"  . window-layout-flip-topdown)       ; EMACS-31
   ("C-x 5 l"  . select-frame-by-name)
   ("C-x 5 s"  . set-frame-name)
   ("RET" . newline-and-indent)
   ("C-z" . nil)
   ("C-x C-z" . nil)
   ("C-x C-k RET" . nil))
  :custom
  (ad-redefinition-action 'accept)
  (column-number-mode nil)
  (line-number-mode nil)
  (line-spacing nil)
  (completion-ignore-case t)
  (completions-detailed t)
  (delete-by-moving-to-trash t)
  (display-line-numbers-width 3)
  (display-line-numbers-widen t)
  (display-fill-column-indicator-warning nil) ; EMACS-31
  (delete-selection-mode 1)
  (enable-recursive minibuffers t)
  (find-ls-option '("-exec ls -ldh {} +" . "-ldh"))  ; find-dired results with human readable sizes
  (frame-resize-pixelwise t)
  (global-auto-revert-non-file-buffers t)
  (help-window-select t)
  (history-length 300)
  (inhibit-startup-message t)
  (initial-scratch-message "")
  (ibuffer-human-readable-size t) ; EMACS-31
  (ispell-dictionary "en_US")
  (kill-do-not-save-duplicates t)
  (kill-region-dwim 'emacs-word)  ; EMACS-31
  (create-lockfiles nil)   ; No backup files
  (make-backup-files nil)  ; No backup files
  (backup-inhibited t)     ; No backup files
  (pixel-scroll-precision-mode t)
  (pixel-scroll-precision-use-momentum nil)
  (ring-bell-function 'ignore)
  (read-answer-short t)
  (recentf-max-saved-items 300) ; default is 20
  (recentf-max-menu-items 15)
  (recentf-auto-cleanup (if (daemonp) 300 'never))
  (recentf-exclude (list "^/\\(?:ssh\\|su\\|sudo\\)?:"))
  (register-use-preview t)
  (remote-file-name-inhibit-delete-by-moving-to-trash t)
  (remote-file-name-inhibit-auto-save t)
  (remote-file-name-inhibit-locks t)
  (remote-file-name-inhibit-auto-save-visited t)
  (tramp-use-scp-direct-remote-copying t)
  (tramp-copy-size-limit (* 2 1024 1024)) ;; 2MB
  (tramp-verbose 2)
  (resize-mini-windows 'grow-only)
  (scroll-conservatively 8)
  (scroll-margin 5)
  (savehist-save-minibuffer-history t)    ; t is default
  (savehist-additional-variables
   '(kill-ring                            ; clipboard
     register-alist                       ; macros
     mark-ring global-mark-ring           ; marks
     search-ring regexp-search-ring))     ; searches
  (save-place-file (expand-file-name "saveplace" user-emacs-directory))
  (save-place-limit 600)
  (set-mark-command-repeat-pop t) ; So we can use C-u C-SPC C-SPC C-SPC... instead of C-u C-SPC C-u C-SPC...
  (split-width-threshold 170)     ; So vertical splits are preferred
  (split-height-threshold nil)
  (shr-use-colors nil)
  (switch-to-buffer-obey-display-actions t)
  (tab-always-indent 'complete)
  (tab-width 4)
  (treesit-font-lock-level 4)
  (truncate-lines t)
  (undo-limit (* 13 160000))
  (undo-strong-limit (* 13 240000))
  (undo-outer-limit (* 13 24000000))
  (use-dialog-box nil)
  (use-file-dialog nil)
  (use-package-hook-name-suffix nil)
  (use-short-answers t)
  (visible-bell nil)
  (window-combination-resize t)
  (window-resize-pixelwise nil)
  (xref-search-program 'ripgrep)
  (zone-programs '[zone-pgm-rat-race])
  (grep-command "rg -nS --no-heading ")
  (grep-find-ignored-directories
   '("SCCS" "RCS" "CVS" "MCVS" ".src" ".svn" ".jj" ".git" ".hg" ".bzr" "_MTN" "_darcs" "{arch}" "node_modules" "build" "dist"))
  :config
  ;; Makes everything accept utf-8 as default, so buffers with tsx and so
  ;; won't ask for encoding (because undecided-unix) every single keystroke
  (modify-coding-system-alist 'file "" 'utf-8)

  (set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 105)

  (when (eq system-type 'darwin)
    (setq insert-directory-program "gls")
    (setq mac-command-modifier 'meta)
    (set-face-attribute 'default nil :family "Menlo" :height 120)
    (set-fontset-font t '(#x1f000 . #x1faff)
                      (font-spec :family "Apple Color Emoji" :size 10)))

  ;; Save manual customizations to other file than init.el
  (setq custom-file (locate-user-emacs-file "custom-vars.el"))
  (load custom-file 'noerror 'nomessage)

  ;; For OSC 52 compatible terminals support
  (setq xterm-extra-capabilities '(getSelection setSelection modifyOtherKeys))

  ;; TRAMP specific HACKs
  ;; See https://coredumped.dev/2025/06/18/making-tramp-go-brrrr./
  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))

  (connection-local-set-profiles
   '(:application tramp :protocol "scp")
   'remote-direct-async-process)

  (with-eval-after-load 'tramp
    (with-eval-after-load 'compile
    (remove-hook 'compilation-mode-hook #'tramp-compile-disable-ssh-controlmaster-options)))


  ;; Set line-number-mode with relative numbering
  (setq display-line-numbers-type 'relative)
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (add-hook 'text-mode-hook #'display-line-numbers-mode)

  ;; Starts `completion-preview-mode' automatically in some modes
  (add-hook 'prog-mode-hook #'completion-preview-mode)
  (add-hook 'text-mode-hook #'completion-preview-mode)
  (add-hook 'rcirc-mode-hook #'completion-preview-mode)

  ;; A Protesilaos life savier HACK
  ;; Add option "d" to whenever using C-x s or C-x C-c, allowing a quick preview
  ;; of the diff (if you choose `d') of what you're asked to save.
  (add-to-list 'save-some-buffers-action-alist
               (list "d"
                     (lambda (buffer) (diff-buffer-with-file (buffer-file-name buffer)))
                     "show diff between the buffer and its file"))

  ;; On Terminal: changes the vertical separator to a full vertical line
  ;;              and truncation symbol to a right arrow
  (set-display-table-slot standard-display-table 'vertical-border ?\u2502)
  (set-display-table-slot standard-display-table 'truncation ?\u2192)

  ;; Ibuffer filters
  (setq ibuffer-saved-filter-groups
        '(("default"
           ("org"     (or
                       (mode . org-mode)
                       (name . "^\\*Org Src")
                       (name . "^\\*Org Agenda\\*$")))
           ("tramp"   (name . "^\\*tramp.*"))
           ("emacs"   (or
                       (name . "^\\*scratch\\*$")
                       (name . "^\\*Messages\\*$")
                       (name . "^\\*Warnings\\*$")
                       (name . "^\\*Shell Command Output\\*$")
                       (name . "^\\*Async-native-compile-log\\*$")))
           ("ediff"   (name . "^\\*[Ee]diff.*"))
           ("vc"      (name . "^\\*vc-.*"))
           ("dired"   (mode . dired-mode))
           ("terminal" (or
                        (mode . term-mode)
                        (mode . shell-mode)
                        (mode . eshell-mode)))
           ("help"    (or
                       (name . "^\\*Help\\*$")
                       (name . "^\\*info\\*$")))
           ("news"    (name . "^\\*Newsticker.*"))
           ("gnus"    (or
                       (mode . message-mode)
                       (mode . gnus-group-mode)
                       (mode . gnus-summary-mode)
                       (mode . gnus-article-mode)
                       (name . "^\\*Group\\*")
                       (name . "^\\*Summary\\*")
                       (name . "^\\*Article\\*")
                       (name . "^\\*BBDB\\*")))
           ("chat"    (or
                       (mode . rcirc-mode)
                       (mode . erc-mode)
                       (name . "^\\*rcirc.*")
                       (name . "^\\*ERC.*"))))))

  (add-hook 'ibuffer-mode-hook
            (lambda ()
              (ibuffer-switch-to-saved-filter-groups "default")))
  (setq ibuffer-show-empty-filter-groups nil) ; don't show empty groups


  ;; So eshell git commands open an instance of THIS config of Emacs
  (setenv "GIT_EDITOR" (format "emacs --init-dir=%s " (shell-quote-argument user-emacs-directory)))
  (setenv "EDITOR" (format "emacs --init-dir=%s " (shell-quote-argument user-emacs-directory)))
  ;; So rebase from eshell opens with a bit of syntax highlight
  (add-to-list 'auto-mode-alist '("/git-rebase-todo\\'" . conf-mode))


  ;; Runs 'private.el' after Emacs inits
  (add-hook 'after-init-hook
            (lambda ()
              (let ((private-file (expand-file-name "private.el" user-emacs-directory)))
                (when (file-exists-p private-file)
                  (load private-file)))))

  :init
  (set-window-margins (selected-window) 2 0)

  (when (>= emacs-major-version 31)
    (tty-tip-mode nil))   ;; EMACS-31
  (tooltip-mode nil)

  (select-frame-set-input-focus (selected-frame))
  (global-auto-revert-mode 1)
  (recentf-mode 1)
  (repeat-mode 1)
  (savehist-mode 1)
  (save-place-mode 1)
  (winner-mode)
  (xterm-mouse-mode 1)
  (file-name-shadow-mode 1) ; allows us to type a new path without having to delete the current one

  (with-current-buffer (get-buffer-create "*scratch*")
    (insert (format ";;
;; ███████╗███╗   ███╗ █████╗  ██████╗███████╗    ███████╗ ██████╗ ██╗      ██████╗
;; ██╔════╝████╗ ████║██╔══██╗██╔════╝██╔════╝    ██╔════╝██╔═══██╗██║     ██╔═══██╗
;; █████╗  ██╔████╔██║███████║██║     ███████╗    ███████╗██║   ██║██║     ██║   ██║
;; ██╔══╝  ██║╚██╔╝██║██╔══██║██║     ╚════██║    ╚════██║██║   ██║██║     ██║   ██║
;; ███████╗██║ ╚═╝ ██║██║  ██║╚██████╗███████║    ███████║╚██████╔╝███████╗╚██████╔╝
;; ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝    ╚══════╝ ╚═════╝ ╚══════╝ ╚═════╝
;;
;;   Loading time : %s
;;   Packages     : %s
;;
"
                    (emacs-init-time)
                    (number-to-string (length package-activated-list)))))

  (message (emacs-init-time)))


;;; AUTH-SOURCE
(use-package auth-source
  :ensure nil
  :defer t
  :config
  (setq auth-sources
        (list (expand-file-name ".authinfo.gpg" user-emacs-directory)))
  (setq user-full-name "Rahul Martim Juliato"
        user-mail-address "rahul.juliato@gmail.com")

  ;; Use `pass` as an auth-source
  (when (file-exists-p "~/.password-store")
    (auth-source-pass-enable)))


;;; CONF
(use-package conf-mode
  :ensure nil
  :mode ("\\.env\\..*\\'" "\\.env\\'")
  :init
  (add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode)))


;;; COMPILATION
(use-package compile
  :ensure nil
  :custom
  (compilation-always-kill t)
  (compilation-scroll-output t)
  (ansi-color-for-compilation-mode t)
  :config
  ;; Not ideal, but I do not want this poluting the mode-line
  (defun emacs-solo/ignore-compilation-status (&rest _)
    (setq compilation-in-progress nil))
  (advice-add 'compilation-start :after #'emacs-solo/ignore-compilation-status)

  (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter))


;;; WINDOW
(use-package window
  :ensure nil
  :custom
  (display-buffer-alist
   '(("\\*\\(Backtrace\\|Warnings\\|Compile-Log\\|Messages\\|Bookmark List\\|Occur\\|eldoc\\)\\*"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 0))
     ("\\*\\([Hh]elp\\)\\*"
      (display-buffer-in-side-window)
      (window-width . 75)
      (side . right)
      (slot . 0))
     ("\\*\\(Ibuffer\\)\\*"
      (display-buffer-in-side-window)
      (window-width . 100)
      (side . right)
      (slot . 1))
     ("\\*\\(Flymake diagnostics\\|xref\\|Completions\\)"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 1))
     ("\\*\\(grep\\|find\\)\\*"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 2))
     ("\\*\\(M3U Playlist\\)"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 3))
     )))


;;; TAB-BAR
(use-package tab-bar
  :ensure nil
  :defer t
  :bind
  (("C-x t <left>" . tab-bar-history-back)
   ("C-x t <right>" . tab-bar-history-forward)
   ("C-x t P" . #'emacs-solo/tab-group-from-project)
   ("C-x t g" . #'emacs-solo/tab-switch-to-group))
  :custom
  (tab-bar-new-tab-choice "*scratch*")
  (tab-bar-close-button-show nil)
  (tab-bar-new-button-show nil)
  (tab-bar-tab-hints t)
  (tab-bar-auto-width nil)
  (tab-bar-separator " ")
  (tab-bar-format '(tab-bar-format-tabs-groups
                    Tab-bar-format-tabs tab-bar-separator
                    tab-bar-format-add-tab))
  :init
  ;;; --- OPTIONAL INTERNAL FN OVERRIDES TO DECORATE NAMES
  (defun tab-bar-tab-name-format-hints (name _tab i)
      (if tab-bar-tab-hints (concat (format "»%d«" i) "") name))

  (defun tab-bar-tab-group-format-default (tab _i &optional current-p)
    (propertize
     (concat (funcall tab-bar-tab-group-function tab))
     'face (if current-p 'tab-bar-tab-group-current 'tab-bar-tab-group-inactive)))


  ;;; --- UTILITIES FUNCTIONS
  (defun emacs-solo/tab-group-from-project ()
    "Call `tab-group` with the current project name as the group."
    (interactive)
    (when-let* ((proj (project-current))
                (name (file-name-nondirectory
                       (directory-file-name (project-root proj)))))
      (tab-group (format "[%s]" name))))

  (defun emacs-solo/tab-switch-to-group ()
  "Prompt for a tab group and switch to its first tab.
Uses position instead of index field."
  (interactive)
  (let* ((tabs (funcall tab-bar-tabs-function)))
    (let* ((groups (delete-dups (mapcar (lambda (tab)
                                          (funcall tab-bar-tab-group-function tab))
                                        tabs)))
           (group (completing-read "Switch to group: " groups nil t)))
      (let ((i 1) (found nil))
        (dolist (tab tabs)
          (let ((tab-group (funcall tab-bar-tab-group-function tab)))
            (when (and (not found)
                       (string= tab-group group))
              (setq found t)
              (tab-bar-select-tab i)))
          (setq i (1+ i)))))))

  ;;; --- TURNS ON BY DEFAULT
  (tab-bar-mode 1)
  (tab-bar-history-mode 1))


;;; RCIRC
(use-package rcirc
  :ensure nil
  :custom
  (rcirc-debug t)
  (rcirc-default-nick "Lionyx")
  (rcirc-default-user-name "Lionyx")
  (rcirc-default-full-name "Lionyx")
  (rcirc-server-alist
   '(("irc.libera.chat"
      :port 6697
      :encryption tls
      :channels ("#emacs" "#systemcrafters"))))
  (rcirc-reconnect-delay 5)
  (rcirc-fill-column 100)
  (rcirc-track-ignore-server-buffer-flag t)
  :config
  (setq rcirc-authinfo
        `(("irc.libera.chat"
           certfp
           ,(expand-file-name "cert.pem" user-emacs-directory)
           ,(expand-file-name "cert.pem" user-emacs-directory)))))


;;; ERC
(use-package erc
  :ensure nil
  :defer t
  :custom
  (erc-join-buffer 'window)
  (erc-hide-list '("JOIN" "PART" "QUIT"))
  (erc-timestamp-format "[%H:%M]")
  (erc-autojoin-channels-alist '((".*\\.libera\\.chat" "#emacs" "#systemcrafters")))
  :init
  (with-eval-after-load 'erc
    (add-to-list 'erc-modules 'sasl))

  (setopt erc-sasl-mechanism 'external)

  (defun erc-liberachat ()
    (interactive)
    (erc-tls :server "irc.libera.chat"
             :port 6697
             :user "Lionyx"
             :password ""
             :client-certificate
             (list
              (expand-file-name "cert.pem" user-emacs-directory)
              (expand-file-name "cert.pem" user-emacs-directory)))))


;;; ICOMPLETE
(use-package icomplete
  :bind (:map icomplete-minibuffer-map
              ("C-n" . icomplete-forward-completions)
              ("C-p" . icomplete-backward-completions)
              ("C-v" . icomplete-vertical-toggle)
              ("RET" . icomplete-force-complete-and-exit)
              ("C-j" . exit-minibuffer)) ;; So we can exit commands like `multi-file-replace-regexp-as-diff'
  :hook
  (after-init-hook . (lambda ()
                       (fido-mode -1)
                       (icomplete-vertical-mode 1)))
  :config
  (setq icomplete-delay-completions-threshold 0)
  (setq icomplete-compute-delay 0)
  (setq icomplete-show-matches-on-no-input t)
  (setq icomplete-hide-common-prefix nil)
  (setq icomplete-prospects-height 10)
  (setq icomplete-separator " . ")
  (setq icomplete-with-completion-tables t)
  (setq icomplete-in-buffer t)
  (setq icomplete-max-delay-chars 0)
  (setq icomplete-scroll t)

  ;; EMACS-31
  (when (and (>= emacs-major-version 31)
             (boundp 'icomplete-vertical-in-buffer-adjust-list))

    (setq icomplete-vertical-in-buffer-adjust-list t)
    (setq icomplete-vertical-render-prefix-indicator t)
    ;; (setq icomplete-vertical-selected-prefix-indicator   " @ ")
    ;; (setq icomplete-vertical-unselected-prefix-indicator "   ")
    )

  (if icomplete-in-buffer
      (advice-add 'completion-at-point
                  :after #'minibuffer-hide-completions))

  ;; https://lists.gnu.org/archive/html/bug-gnu-emacs/2025-03/msg02638.html
  ;;
  ;; I'm currently proposing these features on bug#75784 (bug-gnu-emacs).
  ;; If they get accepted we can get rid of this giant block.
  ;;
  ;; === FIXME: I'm reviewing it to the icomplete PATCH

  ;; EMACS-31
  (when (or (< emacs-major-version 31)
            (not (boundp 'icomplete-vertical-in-buffer-adjust-list)))

    (defface icomplete-vertical-selected-prefix-indicator-face
      '((t :inherit font-lock-keyword-face :weight bold :foreground "cyan"))
      "Face used for the prefix set by `icomplete-vertical-selected-prefix-indicator'."
      :group 'icomplete
      :version "31.1")

    (defface icomplete-vertical-unselected-prefix-indicator-face
      '((t :inherit font-lock-keyword-face :weight normal :foreground "gray"))
      "Face used for the prefix set by `icomplete-vertical-unselected-prefix-indicator'."
      :group 'icomplete
      :version "31.1")

    (defcustom icomplete-vertical-in-buffer-adjust-list t
      "Control whether in-buffer completion should align the cursor position.
If this is t and `icomplete-in-buffer' is t, and `icomplete-vertical-mode'
is activated, the in-buffer vertical completions are shown aligned to the
cursor position when the completion started, not on the first column, as
the default behaviour."
      :type 'boolean
      :group 'icomplete
      :version "31.1")

    (defcustom icomplete-vertical-render-prefix-indicator t
      "Control whether a indicator is added as a prefix to each candidate.
If this is t and `icomplete-vertical-mode' is activated, a indicator,
controlled by `icomplete-vertical-selected-prefix-indicator' is shown
as a prefix to the current under selection candidate, while the
remaining of the candidates will receive the indicator controlled
by `icomplete-vertical-unselected-prefix-indicator'."
      :type 'boolean
      :group 'icomplete
      :version "31.1")

    (defcustom icomplete-vertical-selected-prefix-indicator "» "
      "Prefix string used to mark the selected completion candidate.
If `icomplete-vertical-render-prefix-indicator' is t, the string
defined here is used as a prefix of the currently selected entry in the
list.  It can be further customized by the face
`icomplete-vertical-selected-prefix-indicator-face'."
      :type 'string
      :group 'icomplete
      :version "31.1")

    (defcustom icomplete-vertical-unselected-prefix-indicator "  "
      "Prefix string used on the unselected completion candidates.
If `icomplete-vertical-render-prefix-indicator' is t, the string
defined here is used as a prefix for all unselected entries in the list.
list.  It can be further customized by the face
`icomplete-vertical-unselected-prefix-indicator-face'."
      :type 'string
      :group 'icomplete
      :version "31.1")

    ;; FIXME: make this into PATCH - OK
    (defun icomplete-vertical--adjust-lines-for-column (lines buffer data)
      "Adjust the LINES to align with the column in BUFFER based on DATA."
      (if icomplete-vertical-in-buffer-adjust-list
          (let* ((column (current-column))
                 (prefix-indicator-width
                  (if icomplete-vertical-render-prefix-indicator
                      (max (length icomplete-vertical-selected-prefix-indicator)
                           (length icomplete-vertical-unselected-prefix-indicator))
                    0))
                 (wrapped-line (with-current-buffer buffer
                                 (save-excursion
                                   (goto-char (car data))
                                   (beginning-of-line)
                                   (count-screen-lines (point) (car data)))))
                 (window-width (+ (window-hscroll) (window-body-width)))
                 (longest-line-width (apply #'max (mapcar #'length lines)))
                 (spaces-to-add
                  (if (> wrapped-line 1)
                      (- column (* (- wrapped-line 1) (- window-width 5)))
                    column))
                 (spaces-to-add-avoiding-scrolling
                  (if (>= (+ spaces-to-add longest-line-width prefix-indicator-width) window-width)
                      (- spaces-to-add longest-line-width)
                    spaces-to-add)))

            (mapcar (lambda (line)
                      (concat (make-string spaces-to-add-avoiding-scrolling ?\s) line))
                    lines))
        lines))

    ;; FIXME: what to demo/test:
    ;;
    ;; This patch provides two more new features, which improves icomplete-vertical-mode, 1 and 2,
    ;; explained below:
    ;;
    ;;
    ;; 1.) Improve feature provided by `icomplete-in-buffer'.
    ;;     If user, besides setting `icomplete-in-buffer' to t, also set the
    ;;     new `icomplete-vertical-in-buffer-adjust-list' to t, the following are fixed/ improved:
    ;;
    ;; Without the new `icomplete-vertical-in-buffer-adjust-list':
    ;; - [ ] wrapped lines   - completion candidates on different columns always shows candidates at column 0
    ;; - [ ] wrapped lines   - completion candidates on different lines always shows candidates at column 0
    ;; - [ ] wrapped lines   - completion candidates close to the end of buffer won't be printed
    ;; - [ ] truncated lines - completion candidates on different columns always shows candidates at column 0
    ;; - [ ] truncated lines - completion candidates on horizontally scrolled windows won't appear on buffer
    ;;                         as they're on column 0
    ;; - [ ] truncated lines - completion candidates close to the end of buffer wont be shown
    ;;
    ;;
    ;; With the new `icomplete-vertical-in-buffer-adjust-list':
    ;; - [ ] wrapped lines   - fix    : completion candidates on different columns will always be printed
    ;;                                  under the cursor
    ;; - [ ] wrapped lines   - feature: completion candidates on different columns close to the end
    ;;                                  of the buffer will adjust so they stay visible
    ;; - [ ] wrapped lines   - fix:   : completion candidates on different lines always be printed under
    ;;                                  the cursor
    ;; - [ ] wrapped lines   - fix    : if icomplete-prospects-height won't fit from current line to the
    ;;                                  end of vertical space, our window will be scrolled so we have at
    ;;                                  least this amount of lines. This ensures our candidates list is
    ;;                                  always visible
    ;; - [ ] truncated lines - fix    : completion candidates on different columns will always be printed
    ;;                                  under the cursor
    ;; - [ ] truncated lines - feature: completion candidates on different columns close to the end
    ;;                                  of the buffer will adjust so they stay visible even when we scroll
    ;;                                  horizontally
    ;; - [ ] truncated lines - feature: completion candidates on horizontally scrolled windows will be
    ;;                                  printed under the cursor
    ;; - [ ] wrapped lines   - feature: if icomplete-prospects-height won't fit from current line to the
    ;;                                  end of vertical space, our window will be scrolled so we have at
    ;;                                  least this amount of lines. This ensures our candidates list is
    ;;                                  always visible
    ;; - [ ] from wrapped    - feature: if we are on wrapped lines and manually horiontal scroll, the lines
    ;;       to truncated               will become automatically truncated, in this case, all the features
    ;;                                  above still works from either mode (wrapped or truncated).
    ;;
    ;;
    ;; 2.) Implements new feature which provides customizable prefix indicators
    ;;
    ;; Setting `icomplete-vertical-render-prefix-indicator' to t will provide a prefix indicator
    ;; to indicate the current selected candidate, by default "» ".
    ;;
    ;; This prefix is customizable through the variable `icomplete-vertical-selected-prefix-indicator'
    ;; and de face `icomplete-vertical-selected-prefix-indicator-face'.
    ;;
    ;; Users can also customize an indicator to the not selected candidates trhough the use of
    ;; the variable `icomplete-vertical-unselected-prefix-indicator', by default: "  ", and the face
    ;; `icomplete-vertical-unselected-prefix-indicator-face'.
    ;;


    ;; FIXME: remove this after patch
    (defun icomplete-vertical--ensure-visible-lines-inside-buffer ()
      "Ensure the completion list is visible in regular buffers only.
Scrolls the screen to be at least `icomplete-prospects-height' real lines
away from the bottom.  Counts wrapped lines as real lines."
      (unless (minibufferp)
        (let* ((window-height (window-body-height))
               (current-line (count-screen-lines (window-start) (point)))
               (lines-to-bottom (- window-height current-line)))
          (when (< lines-to-bottom icomplete-prospects-height)
            (scroll-up (- icomplete-prospects-height lines-to-bottom))))))


    (defun icomplete-vertical--add-indicator-to-selected (comp)
      "Add indicators to the selected/unselected COMP completions."
      (if (and icomplete-vertical-render-prefix-indicator
               (get-text-property 0 'icomplete-selected comp))
          (concat (propertize icomplete-vertical-selected-prefix-indicator
                              'face 'icomplete-vertical-selected-prefix-indicator-face)
                  comp)
        (concat (propertize icomplete-vertical-unselected-prefix-indicator
                            'face 'icomplete-vertical-unselected-prefix-indicator-face)
                comp)))


    (cl-defun icomplete--render-vertical
        (comps md &aux scroll-above scroll-below
               (total-space ; number of mini-window lines available
                (1- (min
                     icomplete-prospects-height
                     (truncate (max-mini-window-lines) 1)))))
      ;; Welcome to loopapalooza!
      ;;
      ;; First, be mindful of `icomplete-scroll' and manual scrolls.  If
      ;; `icomplete--scrolled-completions' and `icomplete--scrolled-past'
      ;; are:
      ;;
      ;; - both nil, there is no manual scroll;
      ;; - both non-nil, there is a healthy manual scroll that doesn't need
      ;;   to be readjusted (user just moved around the minibuffer, for
      ;;   example);
      ;; - non-nil and nil, respectively, a refiltering took place and we
      ;;   may need to readjust them to the new filtered `comps'.
      (when (and icomplete-scroll                                    ;; FIXME: remove this after patch
                 (not icomplete--scrolled-completions)
                 (not icomplete--scrolled-past))
        (icomplete-vertical--ensure-visible-lines-inside-buffer))
      (when (and icomplete-scroll
                 icomplete--scrolled-completions
                 (null icomplete--scrolled-past))
        (icomplete-vertical--ensure-visible-lines-inside-buffer)     ;; FIXME: remove this after patch
        (cl-loop with preds
                 for (comp . rest) on comps
                 when (equal comp (car icomplete--scrolled-completions))
                 do
                 (setq icomplete--scrolled-past preds
                       comps (cons comp rest))
                 (completion--cache-all-sorted-completions
                  (icomplete--field-beg)
                  (icomplete--field-end)
                  comps)
                 and return nil
                 do (push comp preds)
                 finally (setq icomplete--scrolled-completions nil)))
      ;; Then, in this pretty ugly loop, collect completions to display
      ;; above and below the selected one, considering scrolling
      ;; positions.
      (cl-loop with preds = icomplete--scrolled-past
               with succs = (cdr comps)
               with space-above = (- total-space
                                     1
                                     (cl-loop for (_ . r) on comps
                                              repeat (truncate total-space 2)
                                              while (listp r)
                                              count 1))
               repeat total-space
               for neighbor = nil
               if (and preds (> space-above 0)) do
               (push (setq neighbor (pop preds)) scroll-above)
               (cl-decf space-above)
               else if (consp succs) collect
               (setq neighbor (pop succs)) into scroll-below-aux
               while neighbor
               finally (setq scroll-below scroll-below-aux))
      ;; Halfway there...
      (let* ((selected (propertize (car comps) 'icomplete-selected t))
             (chosen (append scroll-above (list selected) scroll-below))
             (tuples (icomplete--augment md chosen))
             max-prefix-len max-comp-len lines nsections)
        (add-face-text-property 0 (length selected)
                                'icomplete-selected-match 'append selected)
        ;; Figure out parameters for horizontal spacing
        (cl-loop
         for (comp prefix) in tuples
         maximizing (length prefix) into max-prefix-len-aux
         maximizing (length comp) into max-comp-len-aux
         finally (setq max-prefix-len max-prefix-len-aux
                       max-comp-len max-comp-len-aux))
        ;; Serialize completions and section titles into a list
        ;; of lines to render
        (cl-loop
         for (comp prefix suffix section) in tuples
         when section
         collect (propertize section 'face 'icomplete-section) into lines-aux
         and count 1 into nsections-aux
         for comp = (icomplete-vertical--add-indicator-to-selected comp)
         when (get-text-property 0 'icomplete-selected comp)
         do (add-face-text-property 0 (length comp)
                                    'icomplete-selected-match 'append comp)
         collect (concat prefix
                         (make-string (max 0 (- max-prefix-len (length prefix))) ? )
                         (completion-lazy-hilit comp)
                         (make-string (max 0 (- max-comp-len (length comp))) ? )
                         suffix)
         into lines-aux
         finally (setq lines lines-aux
                       nsections nsections-aux))
        ;; Kick out some lines from the beginning due to extra sections.
        ;; This hopes to keep the selected entry more or less in the
        ;; middle of the dropdown-like widget when `icomplete-scroll' is
        ;; t.  Funky, but at least I didn't use `cl-loop'
        (setq lines
              (nthcdr
               (cond ((<= (length lines) total-space) 0)
                     ((> (length scroll-above) (length scroll-below)) nsections)
                     (t (min (ceiling nsections 2) (length scroll-above))))
               lines))
        (when icomplete--in-region-buffer
          (setq lines (icomplete-vertical--adjust-lines-for-column
                       lines icomplete--in-region-buffer completion-in-region--data)))
        ;; At long last, render final string return value.  This may still
        ;; kick out lines at the end.
        (concat " \n"
                (cl-loop for l in lines repeat total-space concat l concat "\n")))))

  ;; end use-package
  )

;;; DIRED
(use-package dired
  :ensure nil
  :bind
  (("M-i" . emacs-solo/window-dired-vc-root-left))
  :custom
  (dired-dwim-target t)
  (dired-guess-shell-alist-user
   '(("\\.\\(png\\|jpe?g\\|tiff\\)" "feh" "xdg-open" "open")
     ("\\.\\(mp[34]\\|m4a\\|ogg\\|flac\\|webm\\|mkv\\)" "mpv" "xdg-open" "open")
     (".*" "xdg-open" "open")))
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-listing-switches "-alh --group-directories-first")
  (dired-omit-files "^\\.")                                ; with dired-omit-mode (C-x M-o)
  (dired-hide-details-hide-absolute-location t)            ; EMACS-31
  :init
  (add-hook 'dired-mode-hook (lambda () (dired-omit-mode 1))) ;; Turning this ON also sets the C-x M-o binding.

  (defun emacs-solo/dired-rsync-copy (dest)
    "Copy marked files in Dired to DEST using rsync async, with real-time processing of output."
    (interactive
     (list (expand-file-name (read-file-name "rsync to: "
                                             (dired-dwim-target-directory)))))
    (let* ((files (dired-get-marked-files nil current-prefix-arg))
           (dest-original dest)
           (dest-rsync
            (if (file-remote-p dest)
                (let ((vec (tramp-dissect-file-name dest)))
                  (concat (tramp-file-name-user vec)
                          "@"
                          (tramp-file-name-host vec)
                          ":"
                          (tramp-file-name-localname vec)))
              dest))
           (files-rsync
            (mapcar
             (lambda (f)
               (if (file-remote-p f)
                   (let ((vec (tramp-dissect-file-name f)))
                     (concat (tramp-file-name-user vec)
                             "@"
                             (tramp-file-name-host vec)
                             ":"
                             (tramp-file-name-localname vec)))
                 f))
             files))
           (command (append '("rsync" "-hPur") files-rsync (list dest-rsync)))
           (buffer (get-buffer-create "*rsync*")))

      (message "[rsync] original dest: %s" dest-original)
      (message "[rsync] converted dest: %s" dest-rsync)
      (message "[rsync] source files: %s" files-rsync)
      (message "[rsync] command: %s" (string-join command " "))

      (with-current-buffer buffer
        (erase-buffer)
        (insert "Running rsync...\n"))

      (defun rsync-process-filter (proc string)
        (with-current-buffer (process-buffer proc)
          (goto-char (point-max))
          (insert string)
          (goto-char (point-max))
          (while (re-search-backward "\r" nil t)
            (replace-match "\n" nil nil))))

      (make-process
       :name "dired-rsync"
       :buffer buffer
       :command command
       :filter 'rsync-process-filter
       :sentinel
       (lambda (_proc event)
         (when (string-match-p "finished" event)
           (with-current-buffer buffer
             (goto-char (point-max))
             (insert "\n* rsync done *\n"))
           (dired-revert)))
       :stderr buffer)

      (display-buffer buffer)
      (message "rsync started...")))


  (defun emacs-solo/window-dired-vc-root-left (&optional directory-path)
    "Creates *Dired-Side* like an IDE side explorer"
    (interactive)
    (add-hook 'dired-mode-hook 'dired-hide-details-mode)

    (let ((dir (if directory-path
                   (dired-noselect directory-path)
                 (if (eq (vc-root-dir) nil)
                     (dired-noselect default-directory)
                   (dired-noselect (vc-root-dir))))))

      (display-buffer-in-side-window
       dir `((side . left)
             (slot . 0)
             (window-width . 30)
             (window-parameters . ((no-other-window . t)
                                   (no-delete-other-windows . t)
                                   (mode-line-format . (" "
                                                        "%b"))))))
      (with-current-buffer dir
        (let ((window (get-buffer-window dir)))
          (when window
            (select-window window)
            (rename-buffer "*Dired-Side*")
            )))))

  (defun emacs-solo/window-dired-open-directory ()
    "Open the current directory in *Dired-Side* side window."
    (interactive)
    (emacs-solo/window-dired-vc-root-left (dired-get-file-for-visit)))

  (defun emacs-solo/window-dired-open-directory-back ()
    "Open the parent directory in *Dired-Side* side window and refresh it."
    (interactive)
    (emacs-solo/window-dired-vc-root-left "../")
    (when (get-buffer "*Dired-Side*")
      (with-current-buffer "*Dired-Side*"
        (revert-buffer t t))))

  (eval-after-load 'dired
    '(progn
       ;; Users should navigate with p/n, enter new directories with =, go back with q,
       ;; quit with several q's, only use - to access stuff up on the tree from inicial
       ;; directory.
       (define-key dired-mode-map (kbd "=") 'emacs-solo/window-dired-open-directory)
       (define-key dired-mode-map (kbd "-") 'emacs-solo/window-dired-open-directory-back)
       )))


;;; WDIRED
(use-package wdired
  :ensure nil
  :commands (wdired-change-to-wdired-mode)
  :config
  (setq wdired-allow-to-change-permissions t)
  (setq wdired-create-parent-directories t))


;;; ESHELL
(use-package eshell
  :ensure nil
  :bind
  (("C-c e" . eshell))
  :defer t
  :config
  (setopt eshell-banner-message
          (concat
           (propertize " ✨ Welcome to the Emacs Solo Shell ✨\n\n" 'face '(:weight bold :foreground "#f9e2af"))
           (propertize " C-c t" 'face '(:foreground "#89b4fa" :weight bold)) " - toggles between prompts (full / minimum)\n"
           (propertize " C-c T" 'face '(:foreground "#89b4fa" :weight bold)) " - toggles between full prompts (lighter / heavier)\n"
           (propertize " C-c l" 'face '(:foreground "#89b4fa" :weight bold)) " - searches history\n"
           (propertize " C-l  " 'face '(:foreground "#89b4fa" :weight bold)) " - clears scrolling\n\n"))


  ;; DISABLE SCROLLING CONSERVATIVELY ON ESHELL
  ;;
  (defun emacs-solo/reset-scrolling-vars-for-term ()
    "Locally reset scrolling behavior in term-like buffers."
    (setq-local scroll-conservatively 0)
    (setq-local scroll-margin 0))
  (add-hook 'eshell-mode-hook #'emacs-solo/reset-scrolling-vars-for-term)


  ;; FIXME should e have a use-package term section?
  (defun emacs-solo/disable-global-scrolling-in-ansi-term ()
    "Disable global scrolling behavior in ansi-term buffers."
    (when (and (eq major-mode 'term-mode)
               (string-prefix-p "*ansi-term" (buffer-name)))
      (setq-local scroll-conservatively 0)
      (setq-local scroll-margin 0)
      (setq-local scroll-step 0)))
  (add-hook 'term-mode-hook #'emacs-solo/disable-global-scrolling-in-ansi-term)


  ;; MAKES C-c l GIVE AN ICOMPLETE LIKE SEARCH TO HISTORY COMMANDS
  ;;
  (defun emacs-solo/eshell-pick-history ()
    "Show Eshell history combining memory and file persistence."
    (interactive)
    ;; Write current session's history to file so it's always fresh
    (when (bound-and-true-p eshell-history-ring)
      (eshell-write-history))
    ;; Then read the history from file
    (let* ((history-file (expand-file-name "eshell/history" user-emacs-directory))
           (history-entries (when (file-exists-p history-file)
                              (with-temp-buffer
                                (insert-file-contents history-file)
                                (split-string (buffer-string) "\n" t))))
           (selection (completing-read "Eshell History: " history-entries)))
      (when selection
        (insert selection))))


  ;; GIVES SYNTAX HIGHLIGHTING TO CAT
  ;;
  (defun eshell/cat-with-syntax-highlighting (filename)
    "Like cat(1) but with syntax highlighting.
  Stole from aweshell"
    (let ((existing-buffer (get-file-buffer filename))
          (buffer (find-file-noselect filename)))
      (eshell-print
       (with-current-buffer buffer
         (if (fboundp 'font-lock-ensure)
             (font-lock-ensure)
           (with-no-warnings
             (font-lock-fontify-buffer)))
         (let ((contents (buffer-string)))
           (remove-text-properties 0 (length contents) '(read-only nil) contents)
           contents)))
      (unless existing-buffer
        (kill-buffer buffer))
      nil))
  (advice-add 'eshell/cat :override #'eshell/cat-with-syntax-highlighting)


  ;; LOCAL ESHELL BINDINGS
  ;;
  (add-hook 'eshell-mode-hook
            (lambda ()
              (local-set-key (kbd "C-c l") #'emacs-solo/eshell-pick-history)
              (local-set-key (kbd "C-c t") #'emacs-solo/toggle-eshell-prompt)
              (local-set-key (kbd "C-c T") #'emacs-solo/toggle-eshell-prompt-resource-intensive)
              (local-set-key (kbd "C-l")
                             (lambda ()
                               (interactive)
                               (eshell/clear 1)))))


  ;; CUSTOM ESHELL PROMPT
  ;;
  (require 'vc)
  (require 'vc-git)

  (defvar emacs-solo/eshell-full-prompt t
    "When non-nil, show the full Eshell prompt. When nil, show minimal prompt.

The minimal version shows only the `emacs-solo/eshell-lambda-symbol', like:
 𝛌

The full version shows something like:

 🟢 0 🧙 user  💻 hostname  🕒 23:03:12  📁 ~/Projects/emacs-solo 
  main 

There is also `emacs-solo/eshell-full-prompt-resource-intensive' which will
print some extra `expensive' information, like conflicts, remote status, and
more, like:

 🟢 0 🧙 user  💻 hostname  🕒 23:03:12  📁 ~/Projects/emacs-solo 
  main ✏️2 ✨1 ")

  (defvar emacs-solo/eshell-full-prompt-resource-intensive nil
    "When non-nil, and emacs-solo/eshell-full-prompt t. Also show slower operations.
Check `emacs-solo/eshell-full-prompt' for more info.")

  (defvar emacs-solo/eshell-lambda-symbol "  $ "
    "Symbol used for the minimal Eshell prompt.")

  (defun emacs-solo/toggle-eshell-prompt ()
    "Toggle between full and minimal Eshell prompt."
    (interactive)
    (setq emacs-solo/eshell-full-prompt (not emacs-solo/eshell-full-prompt))
    (message "Eshell prompt: %s"
             (if emacs-solo/eshell-full-prompt "full" "minimal"))
    (when (derived-mode-p 'eshell-mode)
      (eshell-reset)))

  (defun emacs-solo/toggle-eshell-prompt-resource-intensive ()
    "Toggle between full and minimal Eshell prompt."
    (interactive)
    (setq emacs-solo/eshell-full-prompt-resource-intensive
          (not emacs-solo/eshell-full-prompt-resource-intensive))
    (message "Eshell prompt: %s"
             (if emacs-solo/eshell-full-prompt-resource-intensive "lighter" "heavier"))
    (when (derived-mode-p 'eshell-mode)
      (eshell-reset)))

  (setopt eshell-prompt-function
          (lambda ()
            (if emacs-solo/eshell-full-prompt
                ;; Full-blown prompt
                (concat
                 (propertize "" 'face `(:foreground "#212234"))

                 (propertize
                  (if (> eshell-last-command-status 0) " 🔴 " " 🟢 ")
                  'face `(:background "#212234"))

                 (propertize (concat (number-to-string eshell-last-command-status) " ")
                             'face `(:background "#212234"))

                 (propertize "" 'face `(:foreground "#212234" :background "#45475A"))

                 (propertize
                  (let ((remote-user (file-remote-p default-directory 'user))
                        (is-remote (file-remote-p default-directory)))
                    (concat
                     (if is-remote "👽 " "🧙 ")
                     (or remote-user (user-login-name))
                     " "))
                  'face `(:foreground "#89b4fa" :background "#45475A"))

                 (propertize "" 'face `(:foreground "#45475A" :background "#212234"))

                 (let ((remote-host (file-remote-p default-directory 'host))
                       (is-remote (file-remote-p default-directory)))
                   (propertize
                    (concat (if is-remote " 🌐 " " 💻 ")
                            (or remote-host (system-name))
                            " ")
                    'face `(:background "#212234" :foreground "#b4befe")))

                 (propertize "" 'face `(:foreground "#212234" :background "#45475A"))

                 (propertize
                  (concat " 🕒 " (format-time-string "%H:%M:%S" (current-time)) " ")
                  'face `(:foreground "#89b4fa" :background "#45475A"))

                 (propertize "" 'face `(:foreground "#45475A" :background "#212234"))

                 (propertize
                  (concat " 📁 " (if (>= (length (eshell/pwd)) 40)
                                     (concat "…" (car (last (butlast (split-string (eshell/pwd) "/") 0))))
                                   (abbreviate-file-name (eshell/pwd))) " ")
                  'face `(:background "#212234" :foreground "#A6E3A1"))

                 (propertize "\n" 'face `(:foreground "#212234"))

                 (when (and (fboundp 'vc-git-root) (vc-git-root default-directory))
                   (concat
                    (propertize "" 'face `(:foreground "#212234"))
                    (propertize
                     (concat
                      "  " (car (vc-git-branches))

                      (when emacs-solo/eshell-full-prompt-resource-intensive
                        (let* ((branch (car (vc-git-branches)))
                               (behind (string-to-number
                                        (shell-command-to-string
                                         (format "git rev-list --count origin/%s..HEAD" branch))))
                               (ahead (string-to-number
                                       (shell-command-to-string
                                        (format "git rev-list --count HEAD..origin/%s" branch)))))
                          (concat
                           (when (> ahead 0) (format " ⬇️%d" ahead))

                           (when (> behind 0) (format " ⬆️%d" behind))

                           (when (and (> ahead 0) (> behind 0)) "  🔀")))

                        (let ((modified (length (split-string
                                                 (shell-command-to-string "git ls-files --modified")
                                                 "\n" t)))
                              (untracked (length (split-string
                                                  (shell-command-to-string
                                                   "git ls-files --others --exclude-standard")
                                                  "\n" t)))
                              (conflicts (length (split-string
                                                  (shell-command-to-string
                                                   "git diff --name-only --diff-filter=U")
                                                  "\n" t))))
                          (concat
                           (if (> modified 0) (format " ✏️%d" modified))
                           (if (> untracked 0) (format " ✨%d" untracked))
                           (if (> conflicts 0) (format " ⚔️%d" conflicts)))))

                      " ")
                     'face `(:background "#212234" :foreground "#F9E2AF"))

                    (propertize "\n" 'face `(:foreground "#212234"))))

                 (propertize emacs-solo/eshell-lambda-symbol 'face font-lock-keyword-face))

              ;; Minimal prompt
              (propertize emacs-solo/eshell-lambda-symbol 'face font-lock-keyword-face))))

  (setq eshell-prompt-regexp emacs-solo/eshell-lambda-symbol)


  ;; SET TERM ENV SO MOST PROGRAMS WON'T COMPLAIN
  ;;
  (add-hook 'eshell-mode-hook (lambda () (setenv "TERM" "xterm-256color")))


  ;; LIST OF VISUAL COMMANDS TO RUN IN A SEPARATED ANSI-TERM
  ;;
  (with-eval-after-load 'em-term
    (add-to-list 'eshell-visual-subcommands '("jj" "resolve"))
    (add-to-list 'eshell-visual-subcommands '("jj" "squash")))

  (setq eshell-visual-commands
        '("vi" "screen" "top"  "htop" "btm" "less" "more" "lynx" "ncftp" "pine" "tin" "trn"
          "elm" "irssi" "nmtui-connect" "nethack" "vim" "alsamixer" "nvim" "w3m" "psql"
          "lazygit" "lazydocker" "ncmpcpp" "newsbeuter" "nethack" "mutt" "neomutt" "tmux"
          "docker" "podman" "jqp")))


;;; ISEARCH
(use-package isearch
  :ensure nil
  :config
  (setq isearch-lazy-count t)
  (setq lazy-count-prefix-format "(%s/%s) ")
  (setq lazy-count-suffix-format nil)
  (setq search-whitespace-regexp ".*?")

  (defun isearch-copy-selected-word ()
    "Copy the current `isearch` selection to the kill ring."
    (interactive)
    (when isearch-other-end
      (let ((selection (buffer-substring-no-properties isearch-other-end (point))))
        (kill-new selection)
        (isearch-exit))))

  ;; Bind `M-w` in isearch to copy the selected word, so M-s M-. M-w
  ;; does a great job of 'copying the current word under cursor'.
  (define-key isearch-mode-map (kbd "M-w") 'isearch-copy-selected-word))


;;; VC
(use-package vc
  :ensure nil
  :defer t
  :config
  (setopt
   vc-git-diff-switches '("--patch-with-stat" "--histogram")  ;; add stats to `git diff'
   vc-git-log-switches '("--stat")                            ;; add stats to `git log'
   vc-git-log-edit-summary-target-len 50
   vc-git-log-edit-summary-max-len 70
   vc-git-print-log-follow t
   vc-git-revision-complete-only-branches nil
   vc-annotate-display-mode 'scale
   add-log-keep-changes-together t
   vc-dir-hide-up-to-date-on-revert t ;; EMACS-31
   vc-make-backup-files nil)                                  ;; Do not backup version controlled files

  (with-eval-after-load 'vc-annotate
    (setopt vc-annotate-color-map
            '((20 . "#c3e88d")
              (40 . "#89DDFF")
              (60 . "#82aaff")
              (80 . "#676E95")
              (100 . "#c792ea")
              (120 . "#f78c6c")
              (140 . "#79a8ff")
              (160 . "#f5e0dc")
              (180 . "#a6e3a1")
              (200 . "#94e2d5")
              (220 . "#89dceb")
              (240 . "#74c7ec")
              (260 . "#82aaff")
              (280 . "#b4befe")
              (300 . "#b5b0ff")
              (320 . "#8c9eff")
              (340 . "#6a81ff")
              (360 . "#5c6bd7"))))

  ;; This one is for editing commit messages
  (require 'log-edit)
  (setopt log-edit-confirm 'changed
          log-edit-keep-buffer nil
          log-edit-require-final-newline t
          log-edit-setup-add-author nil)

  ;; Removes the bottom window with modified files list
  (remove-hook 'log-edit-hook #'log-edit-show-files)

  (with-eval-after-load 'vc-dir
    ;; In vc-git and vc-dir for git buffers, make (C-x v) a run git add, u run git
    ;; reset, and r run git reset and checkout from head.
    (defun emacs-solo/vc-git-command (verb fn)
      "Execute a Git command with VERB as action description and FN as operation on files."
      (let* ((fileset (vc-deduce-fileset t)) ;; Deduce fileset
             (backend (car fileset))
             (files (nth 1 fileset)))
        (if (eq backend 'Git)
            (progn
              (funcall fn files)
              (message "%s %d file(s)." verb (length files)))
          (message "Not in a VC Git buffer."))))

    (defun emacs-solo/vc-git-add (&optional revision vc-fileset comment)
      (interactive "P")
      (emacs-solo/vc-git-command "Staged" 'vc-git-register))

    (defun emacs-solo/vc-git-reset (&optional revision vc-fileset comment)
      (interactive "P")
      (emacs-solo/vc-git-command "Unstaged"
                                 (lambda (files) (vc-git-command nil 0 files "reset" "-q" "--"))))


    ;; Bind S and U in vc-dir-mode-map
    (define-key vc-dir-mode-map (kbd "S") #'emacs-solo/vc-git-add)
    (define-key vc-dir-mode-map (kbd "U") #'emacs-solo/vc-git-reset)

    ;; Bind S and U in vc-prefix-map for general VC usage
    (define-key vc-prefix-map (kbd "S") #'emacs-solo/vc-git-add)
    (define-key vc-prefix-map (kbd "U") #'emacs-solo/vc-git-reset)

    ;; Bind g to hide up to date files after refreshing in vc-dir
    ;; NOTE: this won't be needed once EMACS-31 gets released: vc-dir-hide-up-to-date-on-revert does that
    (define-key vc-dir-mode-map (kbd "g")
                (lambda () (interactive) (vc-dir-refresh) (vc-dir-hide-up-to-date)))


    (defun emacs-solo/vc-git-visualize-status ()
      "Show the Git status of files in the `vc-log` buffer."
      (interactive)
      (let* ((fileset (vc-deduce-fileset t))
             (backend (car fileset))
             (files (nth 1 fileset)))
        (if (eq backend 'Git)
            (let ((output-buffer "*Git Status*"))
              (with-current-buffer (get-buffer-create output-buffer)
                (read-only-mode -1)
                (erase-buffer)
                ;; Capture the raw output including colors using 'git status --color=auto'
                (call-process "git" nil output-buffer nil "status" "-v")
                (pop-to-buffer output-buffer)))
          (message "Not in a VC Git buffer."))))

    (define-key vc-dir-mode-map (kbd "V") #'emacs-solo/vc-git-visualize-status)
    (define-key vc-prefix-map (kbd "V") #'emacs-solo/vc-git-visualize-status))

  (defun emacs-solo/vc-git-reflog ()
    "Show git reflog in a new buffer with ANSI colors and custom keybindings."
    (interactive)
    (let* ((root (vc-root-dir)) ;; Capture VC root before creating buffer
           (buffer (get-buffer-create "*vc-git-reflog*")))
      (with-current-buffer buffer
        (setq-local vc-git-reflog-root root) ;; Store VC root as a buffer-local variable
        (let ((inhibit-read-only t))
          (erase-buffer)
          (vc-git-command buffer nil nil
                          "reflog"
                          "--color=always"
                          "--pretty=format:%C(yellow)%h%Creset %C(auto)%d%Creset %Cgreen%gd%Creset %s %Cblue(%cr)%Creset")
          (goto-char (point-min))
          (ansi-color-apply-on-region (point-min) (point-max)))

        (let ((map (make-sparse-keymap)))
          (define-key map (kbd "/") #'isearch-forward)
          (define-key map (kbd "p") #'previous-line)
          (define-key map (kbd "n") #'next-line)
          (define-key map (kbd "q") #'kill-buffer-and-window)

          (use-local-map map))

        (setq buffer-read-only t)
        (setq mode-name "Git-Reflog")
        (setq major-mode 'special-mode))
      (pop-to-buffer buffer)))
  (global-set-key (kbd "C-x v R") 'emacs-solo/vc-git-reflog)


  (defun emacs-solo/vc-pull-merge-current-branch ()
    "Pull the latest change from origin for the current branch and display output in a buffer."
    (interactive)
    (let* ((branch (vc-git--symbolic-ref "HEAD"))
           (buffer (get-buffer-create "*Git Pull Output*"))
           (command (format "git pull origin %s" branch)))
      (if branch
          (progn
            (with-current-buffer buffer
              (erase-buffer)
              (insert (format "$ %s\n\n" command))
              (call-process-shell-command command nil buffer t))
            (display-buffer buffer))
        (message "Could not determine current branch."))))


  (defun emacs-solo/vc-browse-remote (&optional current-line)
    "Open the repository's remote URL in the browser.
If CURRENT-LINE is non-nil, point to the current branch, file, and line.
Otherwise, open the repository's main page."
    (interactive "P")
    (let* ((remote-url (string-trim (vc-git--run-command-string nil "config" "--get" "remote.origin.url")))
           (branch (string-trim (vc-git--run-command-string nil "rev-parse" "--abbrev-ref" "HEAD")))
           (file (string-trim (file-relative-name (buffer-file-name) (vc-root-dir))))
           (line (line-number-at-pos)))
      (message "Opening remote on browser: %s" remote-url)
      (if (and remote-url (string-match "\\(?:git@\\|https://\\)\\([^:/]+\\)[:/]\\(.+?\\)\\(?:\\.git\\)?$" remote-url))
          (let ((host (match-string 1 remote-url))
                (path (match-string 2 remote-url)))
            ;; Convert SSH URLs to HTTPS (e.g., git@github.com:user/repo.git -> https://github.com/user/repo)
            (when (string-prefix-p "git@" host)
              (setq host (replace-regexp-in-string "^git@" "" host)))
            ;; Construct the appropriate URL based on CURRENT-LINE
            (browse-url
             (if current-line
                 (format "https://%s/%s/blob/%s/%s#L%d" host path branch file line)
               (format "https://%s/%s" host path))))
        (message "Could not determine repository URL"))))
  (global-set-key (kbd "C-x v B") 'emacs-solo/vc-browse-remote)
  (global-set-key (kbd "C-x v o")
                  '(lambda () (interactive) (emacs-solo/vc-browse-remote 1)))


  (defun emacs-solo/vc-diff-on-current-hunk ()
    "Show the diff for the current file and jump to the hunk containing the current line."
    (interactive)
    (let ((current-line (line-number-at-pos)))
      (message "Current line in file: %d" current-line)
      (vc-diff) ; Generate the diff buffer
      (with-current-buffer "*vc-diff*"
        (goto-char (point-min))
        (let ((found-hunk nil))
          (while (and (not found-hunk)
                      (re-search-forward "^@@ -\\([0-9]+\\), *[0-9]+ \\+\\([0-9]+\\), *\\([0-9]+\\) @@" nil t))
            (let* ((start-line (string-to-number (match-string 2)))
                   (line-count (string-to-number (match-string 3)))
                   (end-line (+ start-line line-count)))
              (message "Found hunk: %d to %d" start-line end-line)
              (when (and (>= current-line start-line)
                         (<= current-line end-line))
                (message "Current line %d is within hunk range %d to %d" current-line start-line end-line)
                (setq found-hunk t)
                (goto-char (match-beginning 0))))) ; Jump to the beginning of the hunk
          (unless found-hunk
            (message "Current line %d is not within any hunk range." current-line)
            (goto-char (point-min)))))))
  (global-set-key (kbd "C-x v =") 'emacs-solo/vc-diff-on-current-hunk))

;;; SMERGE
(use-package smerge-mode
  :ensure nil
  :bind (:map smerge-mode-map
              ("C-c ^ u" . smerge-keep-upper)
              ("C-c ^ l" . smerge-keep-lower)
              ("C-c ^ n" . smerge-next)
              ("C-c ^ p" . smerge-previous)))

;;; DIFF
(use-package diff-mode
  :ensure nil
  :defer t
  :config
  (setq diff-default-read-only t)
  (setq diff-advance-after-apply-hunk t)
  (setq diff-update-on-the-fly t)
  (setq diff-font-lock-syntax 'hunk-also)
  (setq diff-font-lock-prettify nil))

;;; EDIFF
(use-package ediff
  :ensure nil
  :commands (ediff-buffers ediff-files ediff-buffers3 ediff-files3)
  :init
  (setq ediff-split-window-function 'split-window-horizontally)
  (setq ediff-window-setup-function 'ediff-setup-windows-plain)
  :config
  (setq ediff-keep-variants nil)
  (setq ediff-make-buffers-readonly-at-startup nil)
  (setq ediff-show-clashes-only t))

;;; ELDOC
(use-package eldoc
  :ensure nil
  :custom
  (eldoc-help-at-pt t) ;; EMACS-31
  :init
  (global-eldoc-mode))

;;; EGLOT
(use-package eglot
  :ensure nil
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0)
  (eglot-events-buffer-config '(:size 0 :format full))
  (eglot-prefer-plaintext nil)
  (jsonrpc-event-hook nil)
  (eglot-code-action-indications nil) ;; EMACS-31 -- annoying as hell
  :init
  (fset #'jsonrpc--log-event #'ignore)

  (setq-default eglot-workspace-configuration (quote
                                               (:gopls (:hints (:parameterNames t)))))

  (defun emacs-solo/eglot-setup ()
    "Setup eglot mode with specific exclusions."
    (unless (eq major-mode 'emacs-lisp-mode)
      (eglot-ensure)))

  (add-hook 'prog-mode-hook #'emacs-solo/eglot-setup)

  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs '((ruby-mode ruby-ts-mode) "ruby-lsp")))

  :bind (:map
         eglot-mode-map
         ("C-c l a" . eglot-code-actions)
         ("C-c l o" . eglot-code-action-organize-imports)
         ("C-c l r" . eglot-rename)
         ("C-c l i" . eglot-inlay-hints-mode)
         ("C-c l f" . eglot-format)))

;;; FLYMAKE
(use-package flymake
  :ensure nil
  :defer t
  :hook (prog-mode-hook . flymake-mode)
  :bind (:map flymake-mode-map
              ("M-8" . flymake-goto-next-error)
              ("M-7" . flymake-goto-prev-error)
              ("C-c ! n" . flymake-goto-next-error)
              ("C-c ! p" . flymake-goto-prev-error)
              ("C-c ! l" . flymake-show-buffer-diagnostics)
              ("C-c ! t" . toggle-flymake-diagnostics-at-eol))
  :custom
  (flymake-show-diagnostics-at-end-of-line nil)
  ;; (flymake-show-diagnostics-at-end-of-line 'short)
  (flymake-indicator-type 'margins)
  (flymake-margin-indicators-string
   `((error "!" compilation-error)      ;; Alternatives: », E, W, i, !, ?, ⚠️)
     (warning "?" compilation-warning)
     (note "i" compilation-info)))
  :config
  ;; Define the toggle function
  (defun toggle-flymake-diagnostics-at-eol ()
    "Toggle the display of Flymake diagnostics at the end of the line
and restart Flymake to apply the changes."
    (interactive)
    (setq flymake-show-diagnostics-at-end-of-line
          (not flymake-show-diagnostics-at-end-of-line))
    (flymake-mode -1) ;; Disable Flymake
    (flymake-mode 1)  ;; Re-enable Flymake
    (message "Flymake diagnostics at end of line: %s"
             (if flymake-show-diagnostics-at-end-of-line
                 "Enabled" "Disabled"))))


;;; WHITESPACE
(use-package whitespace
  :ensure nil
  :defer t
  :hook (before-save-hook . whitespace-cleanup)
  ;; if we wanna remove this hook at any time, eval:
  ;; (remove-hook 'before-save-hook #'whitespace-cleanup)
  )


;;; GNUS
(use-package gnus
  :ensure nil
  :defer t
  :custom
  (gnus-init-file (concat user-emacs-directory ".gnus.el"))
  (gnus-startup-file (concat user-emacs-directory ".newsrc"))
  (gnus-init-file (concat user-emacs-directory ".newsrc.eld"))
  (gnus-activate-level 3)
  (gnus-message-archive-group nil)
  (gnus-check-new-newsgroups nil)
  (gnus-check-bogus-newsgroups nil)
  (gnus-show-threads nil)
  (gnus-use-cross-reference nil)
  (gnus-nov-is-evil nil)
  (gnus-group-line-format "%1M%5y  : %(%-50,50G%)\12")
  (gnus-logo-colors '("#2fdbde" "#c0c0c0"))
  (gnus-permanently-visible-groups ".*")
  (gnus-summary-insert-entire-threads t)
  (gnus-thread-sort-functions
   '(gnus-thread-sort-by-most-recent-number
     gnus-thread-sort-by-subject
     (not gnus-thread-sort-by-total-score)
     gnus-thread-sort-by-most-recent-date))
  (gnus-summary-line-format "%U %R %z : %[%d%] %4{🫂 %-34,34n%} %3{📧  %}%(%1{%B%}%s%)\12")
  (gnus-user-date-format-alist '((t . "%d-%m-%Y %H:%M")))
  (gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references)
  (gnus-sum--tree-indent " ")
  (gnus-sum-thread-tree-indent " ")
  (gnus-sum-thread-tree-false-root "○ ")
  (gnus-sum-thread-tree-single-indent "◎ ")
  (gnus-sum-thread-tree-leaf-with-other "├► ")
  (gnus-sum-thread-tree-root "● ")
  (gnus-sum-thread-tree-single-leaf "╰► ")
  (gnus-sum-thread-tree-vertical "│)")
  (gnus-select-method '(nnnil nil))
  (gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")
  (gnus-secondary-select-methods
   '((nntp "news.gwene.org"))))


;;; MAN
(use-package man
  :ensure nil
  :commands (man)
  :config
  (setq Man-notify-method 'pushy)) ; does not obey `display-buffer-alist'


;;; MINIBUFFER
(use-package minibuffer
  :ensure nil
  :custom
  (completion-styles '(partial-completion flex initials)) ;;  NOTE: for minibuffer we can use emacs-solo-enable-custom-orderless custom
  (completion-ignore-case t)
  (completion-show-help t)
  ;; (completion-auto-select t) ;; NOTE: only turn this on if not using icomplete, can also be 'second-tab
  (completions-max-height 20)
  (completions-format 'one-column)
  (enable-recursive-minibuffers t)
  (read-file-name-completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  :config
  (defun emacs-solo/setup-simple-orderless ()
    (defun simple-orderless-completion (string table pred point)
      "Enhanced orderless completion with better partial matching.
As seen on: https://emacs.dyerdwelling.family/emacs/20250604085817-emacs--building-your-own-orderless-style-completion-in-emacs-lisp/"
      (let* ((words (split-string string "[-, ]+"))
             (patterns (mapcar (lambda (word)
                                 (concat "\\b.*" (regexp-quote word) ".*"))
                               words))
             (full-regexp (mapconcat 'identity patterns "")))
        (if (string-empty-p string)
            (all-completions "" table pred)
          (cl-remove-if-not
           (lambda (candidate)
             (let ((case-fold-search completion-ignore-case))
               (and (cl-every (lambda (word)
                                (string-match-p
                                 (concat "\\b.*" (regexp-quote word))
                                 candidate))
                              words)
                    t)))
           (all-completions "" table pred)))))

    (add-to-list 'completion-styles-alist
                 '(simple-orderless simple-orderless-completion
                                    simple-orderless-completion))

    (defun setup-minibuffer-completion-styles ()
      "Use orderless completion in minibuffer, regular completion elsewhere."
      ;; For minibuffer: use orderless first, then fallback to flex and basic
      (setq-local completion-styles '(basic simple-orderless flex substring)))

    (add-hook 'minibuffer-setup-hook #'setup-minibuffer-completion-styles)
    (message ">>> emacs-solo: simple orderless loaded!"))

  (when emacs-solo-enable-custom-orderless
    (emacs-solo/setup-simple-orderless))


  ;; Makes C-g behave (as seen on https://emacsredux.com/blog/2025/06/01/let-s-make-keyboard-quit-smarter/)
  (define-advice keyboard-quit
      (:around (quit) quit-current-context)
    "Quit the current context.

When there is an active minibuffer and we are not inside it close
it.  When we are inside the minibuffer use the regular
`minibuffer-keyboard-quit' which quits any active region before
exiting.  When there is no minibuffer `keyboard-quit' unless we
are defining or executing a macro."
    (if (active-minibuffer-window)
        (if (minibufferp)
            (minibuffer-keyboard-quit)
          (abort-recursive-edit))
      (unless (or defining-kbd-macro
                  executing-kbd-macro)
        (funcall-interactively quit))))

  ;; Keep the cursor out of the read-only portions of the.minibuffer
  (setq minibuffer-prompt-properties
        '(read-only t intangible t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Keep minibuffer lines unwrapped, long lines like on M-y will be truncated
  (add-hook 'minibuffer-setup-hook
            (lambda () (setq truncate-lines t)))

  (minibuffer-depth-indicate-mode 1)
  (minibuffer-electric-default-mode 1))


;;; NEWSTICKER
(use-package newsticker
  :ensure nil
  :defer t
  :custom
  (newsticker-treeview-treewindow-width 40)
  :hook
  (newsticker-treeview-mode-hook . (lambda ()
                                     (define-key newsticker-treeview-mode-map
                                                 (kbd "C")
                                                 'emacs-solo/fetch-yt-captions-to-buffer)
                                     (define-key newsticker-treeview-list-mode-map
                                                 (kbd "C")
                                                 'emacs-solo/fetch-yt-captions-to-buffer)
                                     (define-key newsticker-treeview-item-mode-map
                                                 (kbd "C")
                                                 'emacs-solo/fetch-yt-captions-to-buffer)
                                     (define-key newsticker-treeview-mode-map
                                                 (kbd "V")
                                                 'emacs-solo/newsticker-play-yt-video-from-buffer)
                                     (define-key newsticker-treeview-list-mode-map
                                                 (kbd "V")
                                                 'emacs-solo/newsticker-play-yt-video-from-buffer)
                                     (define-key newsticker-treeview-item-mode-map
                                                 (kbd "V")
                                                 'emacs-solo/newsticker-play-yt-video-from-buffer)
                                     (define-key newsticker-treeview-mode-map
                                                 (kbd "E")
                                                 #'emacs-solo/newsticker-eww-current-article)
                                     (define-key newsticker-treeview-list-mode-map
                                                 (kbd "E")
                                                 #'emacs-solo/newsticker-eww-current-article)
                                     (define-key newsticker-treeview-item-mode-map
                                                 (kbd "E")
                                                 #'emacs-solo/newsticker-eww-current-article)))
  :init
  (defun emacs-solo/clean-subtitles (buffer-name)
    "Clean SRT subtitles while perfectly preserving ^M in text (unless at line end)."
    (with-current-buffer (get-buffer-create buffer-name)
      ;; First: Remove SRT metadata (sequence numbers + timestamps)
      (goto-char (point-min))
      (while (re-search-forward "^[0-9]+\n[0-9:,]+ --> [0-9:,]+\n" nil t)
        (replace-match ""))

      ;; Second: Remove empty/whitespace-only lines (including ^M)
      (goto-char (point-min))
      (while (re-search-forward "^[ \t\r]*\n" nil t)
        (replace-match ""))

      ;; Third: Remove lines ending with ^M (carriage return)
      (goto-char (point-min))
      (while (re-search-forward ".*\r$" nil t)
        (replace-match ""))

      ;; Fourth: Remove duplicate consecutive lines
      (let ((prev-line nil))
        (goto-char (point-min))
        (while (not (eobp))
          (let* ((bol (line-beginning-position))
                 (eol (line-end-position))
                 (current-line (buffer-substring bol eol)))
            (if (equal current-line prev-line)
                (delete-region bol (line-beginning-position 2))
              (setq prev-line current-line)
              (forward-line 1)))))

      ;; Final cleanup: Remove leading/trailing blank lines
      (goto-char (point-min))
      (when (looking-at "\n+")
        (delete-region (point) (match-end 0)))))

  (defun emacs-solo/fetch-yt-captions-to-buffer ()
    "Fetch YouTube captions with original auto-subs and display in buffer."
    (interactive)
    (let ((window (get-buffer-window "*Newsticker Item*" t)))
      (if window
          (progn
            (select-window window)
            (save-excursion
              (goto-char (point-min))
              (when (re-search-forward "^\\* videoId: \\(\\w+\\)" nil t)
                (let* ((video-id (match-string 1))
                       (video-url (format "https://www.youtube.com/watch?v=%s" video-id))
                       (temp-dir (make-temp-file "emacs-yt-subs-" t "/"))
                       (buffer-name (format "*YT Captions: %s*" video-id)))

                  ;; Create temp directory and buffer
                  (make-directory temp-dir t)
                  (with-current-buffer (get-buffer-create buffer-name)
                    (erase-buffer)
                    (special-mode)
                    (setq buffer-read-only t)
                    (setq-local truncate-lines t)
                    (let ((map (make-sparse-keymap)))
                      (set-keymap-parent map special-mode-map)
                      (define-key map (kbd "q") #'quit-window)
                      (define-key map (kbd "n") #'forward-line)
                      (define-key map (kbd "p") #'previous-line)
                      (use-local-map map)))

                  ;; Run yt-dlp process
                  (make-process
                   :name "yt-dlp-fetch-subs"
                   :buffer nil
                   :command `("yt-dlp"
                              "--write-auto-subs"
                              "--sub-lang" ".*-orig"
                              "--convert-subs" "srt"
                              "--skip-download"
                              "--no-clean-infojson"
                              "-o" ,(concat temp-dir "temp.%(ext)s")
                              ,video-url)
                   :sentinel
                   (lambda (process _event)
                     (when (eq (process-status process) 'exit)
                       (if (zerop (process-exit-status process))
                           (let ((subs-file (car (directory-files temp-dir t ".*-orig.*"))))
                             (if (and subs-file (file-exists-p subs-file))
                                 (with-current-buffer (get-buffer-create buffer-name)
                                   (let ((inhibit-read-only t))
                                     (erase-buffer)
                                     (insert-file-contents subs-file)
                                     (emacs-solo/clean-subtitles buffer-name))
                                   (switch-to-buffer-other-window (current-buffer))
                                   (message "Loaded subtitles: %s" (file-name-nondirectory subs-file))
                                   (delete-directory temp-dir t))
                               (message "No -orig subtitles found in %s" temp-dir)
                               (delete-directory temp-dir t)))
                         (message "Failed to fetch subtitles")
                         (delete-directory temp-dir t))))))))
            (message "No *Newsticker Item* buffer found.")))))



  (defun emacs-solo/newsticker-play-yt-video-from-buffer ()
    "Focus the window showing '*Newsticker Item*' and play the video."
    (interactive)
    (let ((window (get-buffer-window "*Newsticker Item*" t)))
      (if window
          (progn
            (select-window window)
            (save-excursion
              (goto-char (point-min))
              (when (re-search-forward "^\\* videoId: \\(\\w+\\)" nil t)
                (let ((video-id (match-string 1)))
                  (start-process "mpv-video" nil "mpv" (format "https://www.youtube.com/watch?v=%s" video-id))
                  (message "Playing with mpv: %s" video-id))))))
      (message "No window showing *Newsticker Item* buffer.")))

  (defun emacs-solo/newsticker-eww-current-article ()
    "Open the news item at point in EWW in the same window."
    (interactive)
    (with-current-buffer (newsticker--treeview-list-buffer)
      (let ((url (get-text-property (point) :nt-link)))
        (when url
          (eww url)
          (switch-to-buffer (get-buffer "*eww*")))))))


;;; ELEC_PAIR
(use-package elec-pair
  :ensure nil
  :defer
  :hook (after-init-hook . electric-pair-mode))

;;; PAREN
(use-package paren
  :ensure nil
  :hook (after-init-hook . show-paren-mode)
  :custom
  (show-paren-delay 0)
  (show-paren-style 'mixed)
  (show-paren-context-when-offscreen t)) ;; show matches within window splits

;;; PROCED
(use-package proced
  :ensure nil
  :defer t
  :custom
  (proced-enable-color-flag t)
  (proced-tree-flag t)
  (proced-auto-update-flag 'visible)
  (proced-auto-update-interval 1)
  (proced-descent t)
  (proced-filter 'user) ;; We can change interactively with `s'
  :config
  (add-hook 'proced-mode-hook
            (lambda ()
              (proced-toggle-auto-update 1))))

;;; ORG
(use-package org
  :ensure nil
  :defer t
  :mode ("\\.org\\'" . org-mode)
  :config
  (setq
   ;; Start collapsed for speed
   org-startup-folded t

   ;; Edit settings
   org-auto-align-tags nil
   org-tags-column 0
   org-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t

   ;; Org styling, hide markup etc.
   org-hide-emphasis-markers t
   org-pretty-entities t

   ;; Agenda styling
   org-agenda-tags-column 0
   org-agenda-block-separator ?─
   org-agenda-time-grid
   '((daily today require-timed)
     (800 1000 1200 1400 1600 1800 2000)
     " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
   org-agenda-current-time-string
   "◀── now ─────────────────────────────────────────────────")

  ;; Ellipsis styling
  (setq org-ellipsis " ▼ ")
  (set-face-attribute 'org-ellipsis nil :inherit 'default :box nil))


;;; SPEEDBAR
;;
(use-package speedbar
  :ensure nil
  :bind
  (("M-I" . (lambda () ;; Toggles / focuses speedbar on side window
              (interactive)
              (speedbar-window)       ;; EMACS-31
              (let ((win (get-buffer-window speedbar-buffer)))
                (when win
                  (select-window win))))))
  :custom
  (speedbar-window-default-width 25)  ;; EMACS-31
  (speedbar-window-max-width 25)      ;; EMACS-31
  (speedbar-show-unknown-files t)
  (speedbar-directory-unshown-regexp "^$")
  (speedbar-indentation-width 2)
  (speedbar-use-images t)
  :config
  (setq speedbar-expand-image-button-alist
        '(("<+>" . ezimage-directory) ;; previously ezimage-directory-plus
          ("<->" . ezimage-directory-minus)
          ("< >" . ezimage-directory)
          ("[+]" . ezimage-page-plus)
          ("[-]" . ezimage-page-minus)
          ("[?]" . ezimage-page)
          ("[ ]" . ezimage-page)
          ("{+}" . ezimage-directory-plus) ;; previously ezimage-box-plus
          ("{-}" . ezimage-directory-minus) ;; previously ezimage-box-minus
          ("<M>" . ezimage-mail)
          ("<d>" . ezimage-document-tag)
          ("<i>" . ezimage-info-tag)
          (" =>" . ezimage-tag)
          (" +>" . ezimage-tag-gt)
          (" ->" . ezimage-tag-v)
          (">"   . ezimage-tag)
          ("@"   . ezimage-tag-type)
          ("  @" . ezimage-tag-type)
          ("*"   . ezimage-checkout)
          ("#"   . ezimage-object)
          ("!"   . ezimage-object-out-of-date)
          ("//"  . ezimage-label)
          ("%"   . ezimage-lock))))

;;; TIME
(use-package time
  :ensure nil
  ;; :hook (after-init-hook . display-time-mode) ;; If we'd like to see it on the mode-line
  :custom
  (world-clock-time-format "%A %d %B %r %Z")
  (display-time-day-and-date t)
  (display-time-default-load-average nil)
  (display-time-mail-string "")
  (zoneinfo-style-world-list                ; use `M-x worldclock RET' to see it
   '(("America/Los_Angeles" "Los Angeles")
     ("America/Vancouver" "Vancouver")
     ("Canada/Pacific" "Canada/Pacific")
     ("America/Chicago" "Chicago")
     ("America/Toronto" "Toronto")
     ("America/New_York" "New York")
     ("Canada/Atlantic" "Canada/Atlantic")
     ("Brazil/East" "Brasília")
     ("America/Sao_Paulo" "São Paulo")
     ("UTC" "UTC")
     ("Europe/Lisbon" "Lisbon")
     ("Europe/Brussels" "Brussels")
     ("Europe/Athens" "Athens")
     ("Asia/Riyadh" "Riyadh")
     ("Asia/Tehran" "Tehran")
     ("Asia/Tbilisi" "Tbilisi")
     ("Asia/Yekaterinburg" "Yekaterinburg")
     ("Asia/Kolkata" "Kolkata")
     ("Asia/Singapore" "Singapore")
     ("Asia/Shanghai" "Shanghai")
     ("Asia/Seoul" "Seoul")
     ("Asia/Tokyo" "Tokyo")
     ("Asia/Vladivostok" "Vladivostok")
     ("Australia/Brisbane" "Brisbane")
     ("Australia/Sydney" "Sydney")
     ("Pacific/Auckland" "Auckland"))))


;;; UNIQUIFY
(use-package uniquify
  :ensure nil
  :config
  (setq uniquify-buffer-name-style 'forward)
  (setq uniquify-strip-common-suffix t)
  (setq uniquify-after-kill-buffer-p t))


;;; WHICH-KEY
(use-package which-key
  :defer t
  :ensure nil
  :hook
  (after-init-hook . which-key-mode)
  :config
  (setq which-key-separator " ")
  (setq which-key-prefix-prefix "… ")
  (setq which-key-max-display-columns 3)
  (setq which-key-idle-delay 1)
  (setq which-key-idle-secondary-delay 0.25)
  (setq which-key-add-column-padding 1)
  (setq which-key-max-description-length 40)

  ;; Inspired by: https://gist.github.com/mmarshall540/a12f95ab25b1941244c759b1da24296d
  ;;
  ;; By default, Which-key doesn't give much help for prefix-keys. It
  ;; either shows the generic description, "+prefix", or the name of a
  ;; prefix-command, which usually isn't as descriptive as we'd like.
  ;;
  ;; Here are some descriptions for the default bindings in `global-map'
  ;; and `org-mode-map'.
  (which-key-add-key-based-replacements
    "<f1> 4" "help-other-win"
    "<f1>" "help"
    "<f2>" "2column"
    "C-c" "mode-and-user"
    "C-c !" "flymake"
    "C-c g" "git-gutter"
    "C-h 4" "help-other-win"
    "C-h" "help"
    "C-x 4" "other-window"
    "C-x 5" "other-frame"
    "C-x 6" "2-column"
    "C-x 8" "insert-special"
    "C-x 8 ^" "superscript (⁰, ¹, ², …)"
    "C-x 8 _" "subscript (₀, ₁, ₂, …)"
    "C-x 8 a" "arrows & æ (←, →, ↔, æ)"
    "C-x 8 e" "emojis (🫎, 🇧🇷, 🇮🇹, …)"
    "C-x 8 *" "common symbols ( , ¡, €, …)"
    "C-x 8 =" "macron (Ā, Ē, Ḡ, …)"
    "C-x 8 N" "macron (№)"
    "C-x 8 O" "macron (œ)"
    "C-x 8 ~" "tilde (~, ã, …)"
    "C-x 8 /" "stroke (÷, ≠, ø, …)"
    "C-x 8 ." "dot (·, ż)"
    "C-x 8 ," "cedilla (¸, ç, ą, …)"
    "C-x 8 '" "acute (á, é, í, …)"
    "C-x 8 `" "grave (à, è, ì, …)"
    "C-x 8 \"" "quotation/dieresis (\", ë, ß, …)"
    "C-x 8 1" "†, 1/…"
    "C-x 8 2" "‡"
    "C-x 8 3" "3/…"
    "C-x C-k C-q" "kmacro-counters"
    "C-x C-k C-r a" "kmacro-add"
    "C-x C-k C-r" "kmacro-register"
    "C-x C-k" "keyboard-macros"
    "C-x RET" "encoding/input"
    "C-x a i" "abbrevs-inverse-add"
    "C-x a" "abbrevs"
    "C-x n" "narrowing"
    "C-x p" "projects"
    "C-x r" "reg/rect/bkmks"
    "C-x t ^" "tab-bar-detach"
    "C-x t" "tab-bar"
    "C-x v M" "vc-mergebase"
    "C-x v b" "vc-branch"
    "C-x v" "version-control"
    "C-x w ^" "window-detach"
    "C-x w" "window-extras"
    "C-x x" "buffer-extras"
    "C-x" "extra-commands"
    "M-g" "goto-map"
    "M-s h" "search-highlight"
    "M-s" "search-map")

  ;; Upon loading, the built-in `page-ext' package turns "C-x C-p" into
  ;; a prefix-key. If you know of other built-in packages that have
  ;; this behavior, please let me know, so I can add them.
  (with-eval-after-load 'page-ext
    (which-key-add-key-based-replacements
      "C-x C-p" "page-extras"))

  ;; Org-mode provides some additional prefix-keys in `org-mode-map'.
  (with-eval-after-load 'org
    (which-key-add-keymap-based-replacements org-mode-map
      "C-c \"" "org-plot"
      "C-c C-v" "org-babel"
      "C-c C-x" "org-extra-commands")))


;;; WEBJUMP
(use-package webjump
  :defer t
  :ensure nil
  :bind ("C-x /" . webjump)
  :custom
  (webjump-sites
   '(("DuckDuckGo" . [simple-query "www.duckduckgo.com" "www.duckduckgo.com/?q=" ""])
     ("Google" . [simple-query "www.google.com" "www.google.com/search?q=" ""])
     ("YouTube" . [simple-query "www.youtube.com/feed/subscriptions" "www.youtube.com/results?search_query=" ""])
     ("ChatGPT" . [simple-query "https://chatgpt.com" "https://chatgpt.com/?q=" ""]))))


;;; THEMES
(use-package modus-themes
  :ensure nil
  :defer t
  :custom
  (modus-themes-italic-constructs t)
  (modus-themes-bold-constructs t)
  (modus-themes-mixed-fonts nil)
  (modus-themes-prompts '(bold intense))
  (modus-themes-common-palette-overrides
   `((bg-main "#292D3E")
     (bg-active bg-main)
     (fg-main "#EEFFFF")
     (fg-active fg-main)
     (fg-mode-line-active "#A6Accd")
     (bg-mode-line-active "#232635")
     (fg-mode-line-inactive "#676E95")
     (bg-mode-line-inactive "#282c3d")
     ;; (border-mode-line-active "#676E95")
     ;; (border-mode-line-inactive bg-dim)
     (border-mode-line-active nil)
     (border-mode-line-inactive nil)
     (bg-tab-bar      "#242837")
     (bg-tab-current  bg-main)
     (bg-tab-other    "#242837")
     (fg-prompt "#c792ea")
     (bg-prompt unspecified)
     (bg-hover-secondary "#676E95")
     (bg-completion "#2f447f")
     (fg-completion white)
     (bg-region "#3C435E")
     (fg-region white)

     (fg-line-number-active fg-main)
     (fg-line-number-inactive "gray50")
     (bg-line-number-active unspecified)
     (bg-line-number-inactive "#292D3E")
     (fringe "#292D3E")

     (fg-heading-0 "#82aaff")
     (fg-heading-1 "#82aaff")
     (fg-heading-2 "#c792ea")
     (fg-heading-3 "#bb80b3")
     (fg-heading-4 "#a1bfff")

     (fg-prose-verbatim "#c3e88d")
     (bg-prose-block-contents "#232635")
     (fg-prose-block-delimiter "#676E95")
     (bg-prose-block-delimiter bg-prose-block-contents)

     (accent-1 "#79a8ff")

     (keyword "#89DDFF")
     (builtin "#82aaff")
     (comment "#676E95")
     (string "#c3e88d")
     (fnname "#82aaff")
     (type "#c792ea")
     (variable "#c792ea")
     (docstring "#8d92af")
     (constant "#f78c6c")))
  :config
  (modus-themes-with-colors
    (custom-set-faces
     `(tab-bar
       ((,c
         :background "#232635"
         :foreground "#A6Accd"
         ;; :box (:line-width 1 :color "#676E95")
         )))
     `(tab-bar-tab
       ((,c
         :background "#232635"
         :underline t
         ;; :box (:line-width 1 :color "#676E95")
         )))
     `(tab-bar-tab-inactive
       ((,c
         ;; :background "#232635"
         ;; :box (:line-width 1 :color "#676E95")
         )))
     `(tab-bar-tab-group-current
       ((,c
         ;; :background "#232635"
         ;; :box (:line-width 1 :color "#676E95")
         :background "#232635"
         :foreground "#A6Accd"
         :underline t
         )))
     `(tab-bar-tab-group-inactive
       ((,c
         ;; :background "#232635"
         ;; :box (:line-width 1 :color "#676E95")
         :background "#232635"
         :foreground "#777"
         )))))
  :init
  (load-theme 'modus-vivendi-tinted t))


;;; -------------------- NON TREESITTER AREA
;;; SASS-MODE
(use-package scss-mode
  :mode "\\.sass\\'"
  :hook
  ((scss-mode-hook . (lambda ()
                       (setq indent-tabs-mode nil))))
  :defer t)


;;; -------------------- TREESITTER AREA
;;; RUBY-TS-MODE
(use-package ruby-ts-mode
  :ensure nil
  :mode "\\.rb\\'"
  :mode "Rakefile\\'"
  :mode "Gemfile\\'"
  :custom
  (add-to-list 'treesit-language-source-alist '(ruby "https://github.com/tree-sitter/tree-sitter-ruby" "master" "src"))
  (ruby-indent-level 2)
  (ruby-indent-tabs-mode nil))


;;; JS-TS-MODE
(use-package js-ts-mode
  :ensure js ;; I care about js-base-mode but it is locked behind the feature "js"
  :mode "\\.jsx?\\'"
  :defer t
  :hook
  ((js-ts-mode-hook . (lambda ()
                        (setq indent-tabs-mode nil)
                        (add-hook 'after-save-hook #'emacs-solo-movements/format-current-file nil t))))
  :custom
  (js-indent-level 2)
  :config
  (add-to-list 'treesit-language-source-alist '(javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src"))
  (add-to-list 'treesit-language-source-alist '(jsdoc "https://github.com/tree-sitter/tree-sitter-jsdoc" "master" "src")))


;;; TYPESCRIPT-TS-MODE
(defun emacs-solo/add-jsdoc-in-typescript-ts-mode ()
  "Add jsdoc treesitter rules to typescript as a host language.
As seen on: https://www.reddit.com/r/emacs/comments/1kfblch/need_help_with_adding_jsdoc_highlighting_to"
  ;; I copied this code from js.el (js-ts-mode), with minimal modifications.
  (when (treesit-ready-p 'typescript)
    (when (treesit-ready-p 'jsdoc t)
      (setq-local treesit-range-settings
                  (treesit-range-rules
                   :embed 'jsdoc
                   :host 'typescript
                   :local t
                   `(((comment) @capture (:match ,(rx bos "/**") @capture)))))
      (setq c-ts-common--comment-regexp (rx (or "comment" "line_comment" "block_comment" "description")))

      (defvar my/treesit-font-lock-settings-jsdoc
        (treesit-font-lock-rules
         :language 'jsdoc
         :override t
         :feature 'document
         '((document) @font-lock-doc-face)

         :language 'jsdoc
         :override t
         :feature 'keyword
         '((tag_name) @font-lock-constant-face)

         :language 'jsdoc
         :override t
         :feature 'bracket
         '((["{" "}"]) @font-lock-bracket-face)

         :language 'jsdoc
         :override t
         :feature 'property
         '((type) @font-lock-type-face)

         :language 'jsdoc
         :override t
         :feature 'definition
         '((identifier) @font-lock-variable-face)))
      (setq-local treesit-font-lock-settings
                  (append treesit-font-lock-settings my/treesit-font-lock-settings-jsdoc)))))

(use-package typescript-ts-mode
  :mode "\\.ts\\'"
  :defer t
  :hook
  ((typescript-ts-mode-hook .
                            (lambda ()
                              (setq indent-tabs-mode nil)
                              (add-hook 'after-save-hook #'emacs-solo-movements/format-current-file nil t)
                              (emacs-solo/add-jsdoc-in-typescript-ts-mode))))
  :custom
  (typescript-indent-level 2)
  :config
  (add-to-list 'treesit-language-source-alist '(typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src"))
  (unbind-key "M-." typescript-ts-base-mode-map))


(use-package tsx-ts-mode
  :mode "\\.tsx\\'"
  :defer t
  :hook
  ((tsx-ts-mode-hook .
                     (lambda ()
                       (setq indent-tabs-mode nil)
                       (add-hook 'after-save-hook #'emacs-solo-movements/format-current-file nil t)
                       (emacs-solo/add-jsdoc-in-typescript-ts-mode))))
  :custom
  (typescript-indent-level 2)
  :config
  (add-to-list 'treesit-language-source-alist '(tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src"))
  (unbind-key "M-." typescript-ts-base-mode-map))


;;; RUST-TS-MODE
(use-package rust-ts-mode
  :ensure rust-ts-mode
  :mode "\\.rs\\'"
  :defer t
  :custom
  (rust-indent-level 2)
  :config
  (add-to-list 'treesit-language-source-alist '(rust "https://github.com/tree-sitter/tree-sitter-rust" "master" "src")))


;;; TOML-TS-MODE
(use-package toml-ts-mode
  :ensure toml-ts-mode
  :mode "\\.toml\\'"
  :defer t
  :config
  (add-to-list 'treesit-language-source-alist '(toml "https://github.com/ikatyang/tree-sitter-toml" "master" "src")))


;;; MARKDOWN-TS-MODE - EMACS-31
;;  As I first proposed here:
;;  https://lists.gnu.org/archive/html/emacs-devel/2025-02/msg00810.html
(use-package markdown-ts-mode
  :ensure nil
  :mode "\\.md\\'"
  :defer t
  :config
  ;; (add-to-list 'major-mode-remap-alist '(markdown-mode . markdown-ts-mode))
  (add-to-list 'treesit-language-source-alist '(markdown "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown/src"))
  (add-to-list 'treesit-language-source-alist '(markdown-inline "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown-inline/src")))


;;; YAML-TS-MODE
(use-package yaml-ts-mode
  :ensure yaml-ts-mode
  :mode "\\.ya?ml\\'"
  :defer t
  :config
  (add-to-list 'treesit-language-source-alist '(yaml "https://github.com/tree-sitter-grammars/tree-sitter-yaml" "master" "src")))


;;; DOCKERFILE-TS-MODE
(use-package dockerfile-ts-mode
  :ensure dockerfile-ts-mode
  :mode "\\Dockerfile.*\\'"
  :defer t
  :config
  (add-to-list 'treesit-language-source-alist '(dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile" "main" "src")))


;;; GO-TS-MODE
(use-package go-ts-mode
  :ensure t
  :mode "\\.go\\'"
  :hook
  ((go-ts-mode-hook . (lambda ()
                        (add-hook 'before-save-hook #'eglot-format)
                        (setq indent-tabs-mode t)  ; Use tabs, go likes tabs, go figure
                        (setq tab-width 4)         ; Tabs *display* as 4 spaces
                        (setq-local go-ts-mode-indent-offset tab-width))))
  :defer t)

;;; ------------------- EMACS-SOLO CUSTOMS
;;; EMACS-SOLO-HOOKS
;;
(use-package emacs-solo-hooks
  :ensure nil
  :no-require t
  :defer t
  :init

  (defun emacs-solo/prefer-spaces ()
    "Disable indent-tabs-mode to prefer spaces over tabs."
    (interactive)
    (setq indent-tabs-mode nil))

  ;; Only override where necessary
  (add-hook 'emacs-lisp-mode-hook #'emacs-solo/prefer-spaces))


;;; EMACS-SOLO-MOVEMENTS
;;
;;  Functions to better move around text and Emacs
;;
(use-package emacs-solo-movements
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/rename-buffer-and-move-to-new-window ()
    "Promotes a side window buffer to a new regular window."
    (interactive)
    (let ((temp-name (make-temp-name "temp-buffer-")))
      (rename-buffer temp-name t)
      (delete-window)
      (split-window-right)
      (switch-to-buffer temp-name)))

  (global-set-key (kbd "C-x x x") 'emacs-solo/rename-buffer-and-move-to-new-window)


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
  (global-set-key (kbd "M-v") #'emacs-solo-movements/scroll-up-centralize)


  (defun emacs-solo-movements/format-current-file (&optional manual)
    "Format the current file using biome or prettier if available.
If MANUAL is non-nil, the function was called interactively."
    (interactive (list t)) ;; sets manual to t if called via M-x
    (let* ((file (buffer-file-name))
           (project-root (locate-dominating-file file "node_modules"))
           (biome-config (and project-root (file-exists-p (expand-file-name "biome.json" project-root))))
           (local-biome (and project-root (expand-file-name "node_modules/.bin/biome" project-root)))
           (global-biome (executable-find "biome"))
           (local-prettier (and project-root (expand-file-name "node_modules/.bin/prettier" project-root)))
           (global-prettier (executable-find "prettier"))
           (formatter nil)
           (source nil)
           (command nil)
           (start-time (float-time))) ;; Capture the start time
      (cond
       ;; Use Biome if biome.json exists
       ((and biome-config local-biome (file-executable-p local-biome))
        (setq formatter local-biome)
        (setq source "biome (local)")
        (setq command (format "%s format --write %s" formatter (shell-quote-argument file))))
       ((and biome-config global-biome)
        (setq formatter global-biome)
        (setq source "biome (global)")
        (setq command (format "%s format --write %s" formatter (shell-quote-argument file))))

       ;; Fall back to Prettier if no biome.json
       ((and local-prettier (file-executable-p local-prettier))
        (setq formatter local-prettier)
        (setq source "prettier (local)")
        (setq command (format "%s --write %s" formatter (shell-quote-argument file))))
       ((and global-prettier)
        (setq formatter global-prettier)
        (setq source "prettier (global)")
        (setq command (format "%s --write %s" formatter (shell-quote-argument file)))))
      (if command
          (progn
            (when manual
              (save-buffer))
            (shell-command command)
            (revert-buffer t t t)
            (let ((elapsed-time (* 1000 (- (float-time) start-time)))) ;; Calculate elapsed time in ms
              (message "Formatted with %s - %.2f ms" source elapsed-time)))
        (message "No formatter found (biome or prettier)"))))


  (defun emacs-solo-movements/format-current-file-manual ()
    "Manually invoke format for current file."
    (interactive)
    (emacs-solo-movements/format-current-file t))

  (global-set-key (kbd "C-c p") #'emacs-solo-movements/format-current-file-manual)
  (global-set-key (kbd "C-c C-p") #'emacs-solo-movements/format-current-file-manual)


  (defun emacs-solo/transpose-split ()
    "Transpose a horizontal split into a vertical split, or vice versa."
    (interactive)
    (if (> (length (window-list)) 2)
        (user-error "More than two windows present")
      (let* ((this-win (selected-window))
             (other-win (next-window))
             (this-buf (window-buffer this-win))
             (other-buf (window-buffer other-win))
             (this-edges (window-edges this-win))
             (other-edges (window-edges other-win))
             (this-left (car this-edges))
             (other-left (car other-edges))
             (split-horizontally (not (= this-left other-left))))
        (delete-other-windows)
        (if split-horizontally
            (split-window-vertically)
          (split-window-horizontally))
        (set-window-buffer (selected-window) this-buf)
        (set-window-buffer (next-window) other-buf)
        (select-window this-win))))

  (global-set-key (kbd "C-x 4 t") #'emacs-solo/transpose-split))


;;; EMACS-SOLO-TRANSPARENCY
;;
;;  Custom functions to set/unset transparency
;;
(use-package emacs-solo-transparency
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/clear-terminal-background-color (&optional frame)
    "Unsets the background color in terminal mode, including line-number face."
    (interactive)
    (or frame (setq frame (selected-frame)))
    (unless (display-graphic-p frame)
      ;; Set the terminal to a transparent version of the background color
      (send-string-to-terminal
       (format "\033]11;[90]%s\033\\"
               (face-attribute 'default :background)))
      (set-face-background 'default "unspecified-bg" frame)
      (set-face-background 'line-number "unspecified-bg" frame)
      (set-face-background 'line-number-current-line "unspecified-bg" frame)))

  (defun emacs-solo/transparency-set (&optional frame)
    "Set frame transparency. If FRAME is nil, applies to all existing frames."
    (interactive)
    (unless (display-graphic-p frame)
      (emacs-solo/clear-terminal-background-color)
      (add-hook 'window-setup-hook 'emacs-solo/clear-terminal-background-color)
      (add-hook 'ef-themes-post-load-hook 'emacs-solo/clear-terminal-background-color))

    (if frame
        (progn
          (when (eq system-type 'darwin)
            (set-frame-parameter frame 'alpha '(90 90)))
          (set-frame-parameter frame 'alpha-background 85))

      ;; Apply to all frames if no frame is passed
      (dolist (frm (frame-list))
        (when (eq system-type 'darwin)
          (set-frame-parameter frm 'alpha '(90 90)))
        (set-frame-parameter frm 'alpha-background 85))))

  (defun emacs-solo/transparency-unset ()
    "Unset frame transparency (Graphical Mode)."
    (interactive)
    (when (eq system-type 'darwin)
      (set-frame-parameter (selected-frame) 'alpha '(100 100)))
    (dolist (frame (frame-list))
      (set-frame-parameter frame 'alpha-background 100)))

  (when emacs-solo-enable-transparency

    (add-hook 'after-init-hook #'emacs-solo/transparency-set)
    (add-hook 'after-make-frame-functions #'emacs-solo/transparency-set)))


;;; EMACS-SOLO-MODE-LINE
;;
;;  Customizations to the mode-line
;;
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
                  (:propertize "𝛌  " face font-lock-keyword-face)

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


;;; EMACS-SOLO-EXEC-PATH-FROM-SHELL
;;
;;  Loads users default shell PATH settings into Emacs. Usefull
;;  when calling Emacs directly from GUI systems.
;;
(use-package emacs-solo-exec-path-from-shell
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/set-exec-path-from-shell-PATH ()
    "Set up Emacs' `exec-path' and PATH environment the same as the user's shell.
This works with bash, zsh, or fish)."
    (interactive)
    (let* ((shell (getenv "SHELL"))
           (shell-name (file-name-nondirectory shell))
           (command
            (cond
             ((string= shell-name "fish")
              "fish -c 'string join : $PATH'")
             ((string= shell-name "zsh")
              "zsh -i -c 'printenv PATH'")
             ((string= shell-name "bash")
              "bash --login -c 'echo $PATH'")
             (t nil))))
      (if (not command)
          (message "emacs-solo: Unsupported shell: %s" shell-name)
        (let ((path-from-shell
               (replace-regexp-in-string
                "[ \t\n]*$" ""
                (shell-command-to-string command))))
          (when (and path-from-shell (not (string= path-from-shell "")))
            (setenv "PATH" path-from-shell)
            (setq exec-path (split-string path-from-shell path-separator))
            (message ">>> emacs-solo: PATH loaded from %s" shell-name))))))

  (defun emacs-solo/fix-asdf-path ()
    "Ensure asdf shims and active Node.js version's bin directory are first in PATH."
    (interactive)
    (let* ((asdf-shims (expand-file-name "~/.asdf/shims"))
           (node-bin (string-trim (shell-command-to-string "asdf where nodejs 2>/dev/null")))
           (new-paths (list asdf-shims)))

      ;; If Node.js is installed, add its bin path
      (when (file-directory-p node-bin)
        (push (concat node-bin "/bin") new-paths))

      ;; Remove old asdf-related paths from PATH and exec-path
      (setq exec-path (seq-remove (lambda (p) (string-match-p "/\\.asdf/" p)) exec-path))
      (setenv "PATH" (string-join (seq-remove (lambda (p) (string-match-p "/\\.asdf/" p))
                                              (split-string (getenv "PATH") ":"))
                                  ":"))

      ;; Add the new paths to exec-path and PATH
      (dolist (p (reverse new-paths))
        (unless (member p exec-path) (push p exec-path))
        (unless (member p (split-string (getenv "PATH") ":"))
          (setenv "PATH" (concat p ":" (getenv "PATH")))))))

  (add-hook 'find-file-hook #'emacs-solo/fix-asdf-path)
  (add-hook 'eshell-mode-hook #'emacs-solo/fix-asdf-path)
  (add-hook 'eshell-pre-command-hook #'emacs-solo/fix-asdf-path)
  (add-hook 'eshell-directory-change-hook #'emacs-solo/fix-asdf-path)

  (add-hook 'after-init-hook #'emacs-solo/set-exec-path-from-shell-PATH)
  (add-hook 'after-init-hook #'emacs-solo/fix-asdf-path))


;;; EMACS-SOLO-RAINBOW-DELIMITERS
;;
;;  Colorizes matching delimiters
;;
;;  FIXME: Make it play nice with treesitter modes
;;
(use-package emacs-solo-rainbow-delimiters
  :if emacs-solo-enable-rainbown-delimiters
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/rainbow-delimiters ()
    "Apply simple rainbow coloring to parentheses, brackets, and braces in the current buffer.
Opening and closing delimiters will have matching colors."
    (interactive)
    (let ((colors '(font-lock-keyword-face
                    font-lock-type-face
                    font-lock-function-name-face
                    font-lock-variable-name-face
                    font-lock-constant-face
                    font-lock-builtin-face
                    font-lock-string-face
                    )))
      (font-lock-add-keywords
       nil
       `((,(rx (or "(" ")" "[" "]" "{" "}"))
          (0 (let* ((char (char-after (match-beginning 0)))
                    (depth (save-excursion
                             ;; Move to the correct position based on opening/closing delimiter
                             (if (member char '(?\) ?\] ?\}))
                                 (progn
                                   (backward-char) ;; Move to the opening delimiter
                                   (car (syntax-ppss)))
                               (car (syntax-ppss)))))
                    (face (nth (mod depth ,(length colors)) ',colors)))
               (list 'face face)))))))
    (font-lock-flush)
    (font-lock-ensure))

  (add-hook 'prog-mode-hook #'emacs-solo/rainbow-delimiters))


;;; EMACS-SOLO-PROJECT-SELECT
;;
;;  Interactively finds a project in a Projects folder and sets it
;;  to current `project.el' project.
;;
(use-package emacs-solo-project-select
  :ensure nil
  :no-require t
  :init
  (defvar emacs-solo-default-projects-folder "~/Projects"
    "Default folder to search for projects.")

  (defvar emacs-solo-default-projects-input ""
    "Default input to use when finding a project.")

  (defun emacs-solo/find-projects-and-switch (&optional directory)
    "Find and switch to a project directory from ~/Projects."
    (interactive)
    (let* ((d (or directory emacs-solo-default-projects-folder))
           ;; (find-command (concat "fd --type d --max-depth 4 . " d))           ; with fd
           (find-command (concat "find " d " -mindepth 1 -maxdepth 4 -type d"))  ; with find
           (project-list (split-string (shell-command-to-string find-command) "\n" t))
           (initial-input emacs-solo-default-projects-input))
      (let ((selected-project
             (completing-read
              "Search project folder: "
              project-list
              nil nil
              initial-input)))
        (when (and selected-project (file-directory-p selected-project))
          (project-switch-project selected-project)))))

  :bind (:map project-prefix-map
              ("P" . emacs-solo/find-projects-and-switch)))


;;; EMACS-SOLO-VIPER-EXTENSIONS
;;
;;  Better VIM (and not VI) bindings for viper-mode
;;
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
  (define-key viper-vi-global-user-map (kbd "SPC m p") 'emacs-solo-movements/format-current-file)
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



;;; EMACS-SOLO-HIGHLIGHT-KEYWORDS-MODE
;;
;;  Highlights a list of words like TODO, FIXME...
;;  Code borrowed from `alternateved'
;;
(use-package emacs-solo-highlight-keywords-mode
  :if emacs-solo-enable-highlight-keywords
  :ensure nil
  :no-require t
  :defer t
  :init
  (defcustom +highlight-keywords-faces
    '(("TODO" . error)
      ("FIXME" . error)
      ("HACK" . warning)
      ("NOTE" . warning)
      ("HERE" . compilation-info)
      ("EMACS-31" . compilation-info))
    "Alist of keywords to highlight and their face."
    :group '+highlight-keywords
    :type '(alist :key-type (string :tag "Keyword")
                  :value-type (symbol :tag "Face"))
    :set (lambda (sym val)
           (dolist (face (mapcar #'cdr val))
             (unless (facep face)
               (error "Invalid face: %s" face)))
           (set-default sym val)))

  (defvar +highlight-keywords--keywords
    (when +highlight-keywords-faces
      (let ((keywords (mapcar #'car +highlight-keywords-faces)))
        `((,(regexp-opt keywords 'words)
           (0 (when (nth 8 (syntax-ppss))
                (cdr (assoc (match-string 0) +highlight-keywords-faces)))
              prepend)))))
    "Keywords and corresponding faces for `emacs-solo/highlight-keywords-mode'.")

  (defun emacs-solo/highlight-keywords-mode-on ()
    (when (not (string-match-p "^\\*" (buffer-name))) ; avoid *scratch*, etc.
      (font-lock-add-keywords nil +highlight-keywords--keywords t)
      (font-lock-flush)))

  (defun emacs-solo/highlight-keywords-mode-off ()
    (font-lock-remove-keywords nil +highlight-keywords--keywords)
    (font-lock-flush))

  (define-minor-mode emacs-solo/highlight-keywords-mode
    "Highlight TODO and similar keywords in comments and strings."
    :lighter " +HL"
    :group '+highlight-keywords
    (if emacs-solo/highlight-keywords-mode
        (emacs-solo/highlight-keywords-mode-on)
      (emacs-solo/highlight-keywords-mode-off)))

  :hook
  (prog-mode-hook .
                  (lambda ()
                    (when (and buffer-file-name ; only if it's visiting a file
                               (not (string-match-p "^\\*" (buffer-name)))) ; avoid *scratch*, etc.
                      (message "[emacs-solo-highlight-keywords-mode]: running on buffer %s" (buffer-name))
                      (run-with-idle-timer 1 nil #'emacs-solo/highlight-keywords-mode-on)))))


;;; EMACS-SOLO-GUTTER
;;
;;  A **HIGHLY** `experimental' and slow and buggy git gutter like.
;;
(use-package emacs-solo-gutter
  :if emacs-solo-enable-buffer-gutter
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/goto-next-hunk ()
    "Jump cursor to the closest next hunk."
    (interactive)
    (let* ((current-line (line-number-at-pos))
           (line-numbers (mapcar #'car git-gutter-diff-info))
           (sorted-line-numbers (sort line-numbers '<))
           (next-line-number
            (if (not (member current-line sorted-line-numbers))
                ;; If the current line is not in the list, find the next closest line number
                (cl-find-if (lambda (line) (> line current-line)) sorted-line-numbers)
              ;; If the current line is in the list, find the next line number that is not consecutive
              (let ((last-line nil))
                (cl-loop for line in sorted-line-numbers
                         when (and (> line current-line)
                                   (or (not last-line)
                                       (/= line (1+ last-line))))
                         return line
                         do (setq last-line line))))))

      (when next-line-number
        (goto-line next-line-number))))

  (defun emacs-solo/goto-previous-hunk ()
    "Jump cursor to the closest previous hunk."
    (interactive)
    (let* ((current-line (line-number-at-pos))
           (line-numbers (mapcar #'car git-gutter-diff-info))
           (sorted-line-numbers (sort line-numbers '<))
           (previous-line-number
            (if (not (member current-line sorted-line-numbers))
                ;; If the current line is not in the list, find the previous closest line number
                (cl-find-if (lambda (line) (< line current-line)) (reverse sorted-line-numbers))
              ;; If the current line is in the list, find the previous line number that has no direct predecessor
              (let ((previous-line nil))
                (dolist (line sorted-line-numbers)
                  (when (and (< line current-line)
                             (not (member (1- line) line-numbers)))
                    (setq previous-line line)))
                previous-line))))

      (when previous-line-number
        (goto-line previous-line-number))))


  (defun emacs-solo/git-gutter-process-git-diff ()
    "Process git diff for adds/mods/removals.
Marks lines as added, deleted, or changed."
    (interactive)
    (setq-local result '())
    (let* ((file-path (buffer-file-name))
           (grep-command "rg -Po")                         ; for rgrep
           ;; (grep-command (if (eq system-type 'darwin)   ; for grep / ggrep
           ;;                   "ggrep -Po"
           ;;                 "grep -Po"))
           (output (shell-command-to-string
                    (format
                     "git diff --unified=0 %s | %s '^@@ -[0-9]+(,[0-9]+)? \\+\\K[0-9]+(,[0-9]+)?(?= @@)'"
                     file-path
                     grep-command))))
      (setq-local lines (split-string output "\n"))
      (dolist (line lines)
        (if (string-match "\\(^[0-9]+\\),\\([0-9]+\\)\\(?:,0\\)?$" line)
            (let ((num (string-to-number (match-string 1 line)))
                  (count (string-to-number (match-string 2 line))))
              (if (= count 0)
                  (add-to-list 'result (cons (+ 1 num) "deleted"))
                (dotimes (i count)
                  (add-to-list 'result (cons (+ num i) "changed")))))
          (if (string-match "\\(^[0-9]+\\)$" line)
              (add-to-list 'result (cons (string-to-number line) "added"))))
        (setq-local git-gutter-diff-info result))
      result))


  (defun emacs-solo/git-gutter-add-mark (&rest args)
    "Add symbols to the left margin based on Git diff statuses.
   - '+' for added lines (lightgreen)
   - '~' for changed lines (yellowish)
   - '-' for deleted lines (tomato)."
    (interactive)
    (set-window-margins (selected-window) 2 0) ;; change to 1,2,3 if you want more columns
    (remove-overlays (point-min) (point-max) 'emacs-solo--git-gutter-overlay t)
    (let ((lines-status (or (emacs-solo/git-gutter-process-git-diff) '())))
      (save-excursion
        (dolist (line-status lines-status)
          (let ((line-num (car line-status))
                (status (cdr line-status)))
            (when (and line-num status)
              (goto-char (point-min))
              (forward-line (1- line-num))
              (let ((overlay (make-overlay (point-at-bol) (point-at-bol))))
                (overlay-put overlay 'emacs-solo--git-gutter-overlay t)
                (overlay-put overlay 'before-string
                             (propertize " "
                                         'display
                                         `((margin left-margin)
                                           ,(propertize
                                             (cond                              ;; Alternatives:
                                              ((string= status "added")   "│")  ;; +  │ ▏┃
                                              ((string= status "changed") "│")  ;; ~
                                              ((string= status "deleted") "│")) ;; _
                                             'face
                                             `(:foreground
                                               ,(cond
                                                 ((string= status "added") "lightgreen")
                                                 ((string= status "changed") "gold")
                                                 ((string= status "deleted") "tomato"))))))))))))))

  (defun emacs-solo/timed-git-gutter-on()
    (run-at-time 0.1 nil #'emacs-solo/git-gutter-add-mark))

  (defun emacs-solo/git-gutter-off ()
    "Remove all `emacs-solo--git-gutter-overlay' marks and other overlays."
    (interactive)
    (set-window-margins (selected-window) 2 0)
    (remove-overlays (point-min) (point-max) 'emacs-solo--git-gutter-overlay t)
    (remove-hook 'find-file-hook #'emacs-solo-git-gutter-on)
    (remove-hook 'after-save-hook #'emacs-solo/git-gutter-add-mark))

  (defun emacs-solo/git-gutter-on ()
    (interactive)
    (add-hook 'find-file-hook #'emacs-solo/timed-git-gutter-on)
    (add-hook 'after-save-hook #'emacs-solo/git-gutter-add-mark)
    (when (not (string-match-p "^\\*" (buffer-name))) ; avoid *scratch*, etc.
      (emacs-solo/git-gutter-add-mark)))

  (global-set-key (kbd "M-9") 'emacs-solo/goto-previous-hunk)
  (global-set-key (kbd "M-0") 'emacs-solo/goto-next-hunk)
  (global-set-key (kbd "C-c g p") 'emacs-solo/goto-previous-hunk)
  (global-set-key (kbd "C-c g r") 'emacs-solo/git-gutter-off)
  (global-set-key (kbd "C-c g g") 'emacs-solo/git-gutter-on)
  (global-set-key (kbd "C-c g n") 'emacs-solo/goto-next-hunk)

  (add-hook 'after-init-hook #'emacs-solo/git-gutter-on))


;;; EMACS-SOLO-ACE-WINDOW
;;
;;  Based on: https://www.reddit.com/r/emacs/comments/1h0zjvq/comment/m0uy3bo/?context=3
;;
;;  TODO: implement ace-swap like feature
(use-package emacs-solo-ace-window
  :ensure nil
  :no-require t
  :defer t
  :init
  (defvar emacs-solo-ace-window/quick-window-overlays nil
    "List of overlays used to temporarily display window labels.")

  (defun emacs-solo-ace-window/quick-window-jump ()
    "Jump to a window by typing its assigned character label.
Windows are labeled starting from the top-left window and proceeding top to bottom, then left to right."
    (interactive)
    (let* ((window-list (emacs-solo-ace-window/get-windows))
           (window-keys (seq-take '("1" "2" "3" "4" "5" "6" "7" "8")
                                  (length window-list)))
           (window-map (cl-pairlis window-keys window-list)))
      (emacs-solo-ace-window/add-window-key-overlays window-map)
      (let ((key (read-key (format "Select window [%s]: " (string-join window-keys ", ")))))
        (emacs-solo-ace-window/remove-window-key-overlays)
        (if-let* ((selected-window (cdr (assoc (char-to-string key) window-map))))
            (select-window selected-window)
          (message "No window assigned to key: %c" key)))))

  (defun emacs-solo-ace-window/get-windows ()
    "Return a list of windows in the current frame, ordered from top to bottom, left to right."
    (sort (window-list nil 'no-mini)
          (lambda (w1 w2)
            (let ((edges1 (window-edges w1))
                  (edges2 (window-edges w2)))
              (or (< (car edges1) (car edges2)) ; Compare top edges
                  (and (= (car edges1) (car edges2)) ; If equal, compare left edges
                       (< (cadr edges1) (cadr edges2))))))))

  (defun emacs-solo-ace-window/add-window-key-overlays (window-map)
    "Add temporary overlays to windows with their assigned key labels from WINDOW-MAP."
    (setq emacs-solo-ace-window/quick-window-overlays nil)
    (dolist (entry window-map)
      (let* ((key (car entry))
             (window (cdr entry))
             (start (window-start window))
             (overlay (make-overlay start start (window-buffer window))))
        (overlay-put overlay 'after-string
                     (propertize (format " [%s] " key)
                                 'face '(:foreground "#c3e88d"
                                                     :background "#232635"
                                                     :weight bold
                                                     :height default)))
        (overlay-put overlay 'window window)
        (push overlay emacs-solo-ace-window/quick-window-overlays))))

  (defun emacs-solo-ace-window/remove-window-key-overlays ()
    "Remove all temporary overlays used to display key labels in windows."
    (mapc 'delete-overlay emacs-solo-ace-window/quick-window-overlays)
    (setq emacs-solo-ace-window/quick-window-overlays nil))

  (global-set-key (kbd "M-O") #'emacs-solo-ace-window/quick-window-jump))


;;; EMACS-SOLO-OLIVETTI
;;
(use-package emacs-solo-olivetti
  :ensure nil
  :no-require t
  :defer t
  :init
  (defvar emacs-solo-center-document-desired-width 120
    "The desired width of a document centered in the window.")

  (defun emacs-solo/center-document--adjust-margins ()
    ;; Reset margins first before recalculating
    (set-window-parameter nil 'min-margins nil)
    (set-window-margins nil nil)

    ;; Adjust margins if the mode is on
    (when emacs-solo/center-document-mode
      (let ((margin-width (max 0
                               (truncate
                                (/ (- (window-width)
                                      emacs-solo-center-document-desired-width)
                                   2.0)))))
        (when (> margin-width 0)
          (set-window-parameter nil 'min-margins '(0 . 0))
          (set-window-margins nil margin-width margin-width)))))

  (define-minor-mode emacs-solo/center-document-mode
    "Toggle centered text layout in the current buffer."
    :lighter " Centered"
    :group 'editing
    (if emacs-solo/center-document-mode
        (add-hook 'window-configuration-change-hook #'emacs-solo/center-document--adjust-margins 'append 'local)
      (remove-hook 'window-configuration-change-hook #'emacs-solo/center-document--adjust-margins 'local))
    (emacs-solo/center-document--adjust-margins))


  (add-hook 'org-mode-hook #'emacs-solo/center-document-mode)
  (add-hook 'gnus-group-mode-hook #'emacs-solo/center-document-mode)
  (add-hook 'gnus-summary-mode-hook #'emacs-solo/center-document-mode)
  (add-hook 'gnus-article-mode-hook #'emacs-solo/center-document-mode)

  ;; (add-hook 'newsticker-treeview-list-mode-hook 'emacs-solo/timed-center-visual-fill-on)
  ;; (add-hook 'newsticker-treeview-item-mode-hook 'emacs-solo/timed-center-visual-fill-on)
  )


;;; EMACS-SOLO-0x0
;;
;; Inspired by: https://codeberg.org/daviwil/dotfiles/src/branch/master/Emacs.org#headline-28
(use-package emacs-solo-0x0
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/0x0-upload-text ()
    (interactive)
    (let* ((contents (if (use-region-p)
                         (buffer-substring-no-properties (region-beginning) (region-end))
                       (buffer-string)))
           (temp-file (make-temp-file "0x0" nil ".txt" contents)))
      (message "Sending %s to 0x0.st..." temp-file)
      (let ((url (string-trim-right
                  (shell-command-to-string
                   (format "curl -A 'curl/7.68.8' -s -F'file=@%s' https://0x0.st" temp-file)))))
        (message "The URL is %s" url)
        (kill-new url)
        (delete-file temp-file))))

  (defun emacs-solo/0x0-upload-file (file-path)
    (interactive "fSelect a file to upload: ")
    (message "Sending %s to 0x0.st..." file-path)
    (let ((url (string-trim-right
                (shell-command-to-string
                 (format "curl -A 'curl/7.68.8' -s -F'file=@%s' https://0x0.st" (expand-file-name file-path))))))
      (message "The URL is %s" url)
      (kill-new url))))


;;; EMACS-SOLO-SUDO-EDIT
;;
;; Inspired by: https://codeberg.org/daviwil/dotfiles/src/branch/master/Emacs.org#headline-28
(use-package emacs-solo-sudo-edit
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/sudo-edit (&optional arg)
    "Edit currently visited file as root.
With a prefix ARG prompt for a file to visit.
Will also prompt for a file to visit if current
buffer is not visiting a file."
    (interactive "P")
    (if (or arg (not buffer-file-name))
        (find-file (concat "/sudo:root@localhost:"
                           (completing-read "Find file(as root): ")))
      (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name)))))


;;; EMACS-SOLO-REPLACE-AS-DIFF
;;
(use-package emacs-solo/replace-regexp-as-diff
  :ensure nil
  :no-require t
  :defer t
  :init

  ;; NOTE: improvements wrappers over `multi-file-replace-regexp-as-diff', so
  ;;       we can:
  ;;       1.) Use it with glob pattern matching in files, including inside
  ;;           subfolders (`emacs-solo/multi-file-replace-regexp-as-diff-with-glob')
  ;;       2.) Use it with marked files and or directories in dired
  ;;           (`emacs-solo/dired-do-replace-regexp-as-diff')


  ;; `M-x emacs-solo/multi-file-replace-regexp-as-diff-with-glob RET'
  ;;
  ;; A wrapper for `multi-file-replace-regexp-as-diff' that extends its functionality
  ;; to support glob patterns for file matching. It recursively searches all files
  ;; in the specified directory (including subdirectories) that match the given glob
  ;; pattern (e.g., `*.js`), and displays the replacements as diffs in the
  ;; `*replace-diff*` buffer. This allows for easy review and application of changes
  ;; across multiple files.
  (defun emacs-solo/multi-file-replace-regexp-as-diff-with-glob (dir regexp to-string &optional delimited glob-pattern)
    "Wrapper for `multi-file-replace-regexp-as-diff` that accepts a directory and a glob pattern.
DIR is the directory to search recursively.
REGEXP is the regular expression to replace.
TO-STRING is the replacement string.
DELIMITED is an optional argument passed to `multi-file-replace-regexp-as-diff`.
GLOB-PATTERN is the glob pattern to match files (e.g., \"*.el\")."
    (interactive
     (let ((dir (file-truename (read-directory-name "Directory: ")))
           (common (query-replace-read-args
                    (concat "Replace"
                            (if current-prefix-arg " word" "")
                            " regexp as diff in files")
                    t t))
           (glob-pattern (read-string "Glob pattern (e.g., *.el): " "*")))
       (list dir (nth 0 common) (nth 1 common) (nth 2 common) glob-pattern)))

    (let* ((glob-regexp (wildcard-to-regexp glob-pattern))
           ;; file-expand-wildcards instead of directory-files-recursively, would
           ;; not allow us to traverse directories
           (files (directory-files-recursively dir glob-regexp)))

      (if files
          (multi-file-replace-regexp-as-diff files regexp to-string delimited)
        (message "No files found for glob-pattern: %s" glob-pattern))))


  ;; `M-x dired RET' mark files and/or directories then
  ;; `M-x emacs-solo/multi-file-replace-regexp-as-diff-with-glob RET'
  ;;
  ;; A version of `dired-do-replace-regexp-as-diff' that adds support for selected
  ;; directories in Dired. When directories are marked, it recursively includes all
  ;; files within them (and their subdirectories) in the replacement operation.
  ;; The replacements are displayed as diffs in the `*replace-diff*` buffer, allowing
  ;; for review and application of changes across multiple files and directories.
  (defun emacs-solo/expand-directories (items)
    "Expand ITEMS to include all files within directories (recursively).
Directories themselves are excluded from the final list."
    (cl-loop for item in items
             if (file-directory-p item)
             append (let ((files (directory-files-recursively item ".*" t)))
                      (cl-remove-if #'file-directory-p files))
             else if (file-regular-p item) ; Ensure only regular files are included
             collect item))

  (defun emacs-solo/dired-do-replace-regexp-as-diff (from to &optional delimited)
    "Do `replace-regexp' of FROM with TO as diff, on all marked files and directories.
If a marked item is a directory, all files within it (recursively) are included.
Third arg DELIMITED (prefix arg) means replace only word-delimited matches.
The replacements are displayed in the buffer *replace-diff* that
you can later apply as a patch after reviewing the changes."
    (interactive
     (let ((common
            (query-replace-read-args
             "Replace regexp as diff in marked files and directories" t t t)))
       (list (nth 0 common) (nth 1 common) (nth 2 common))))
    (dired-post-do-command)
    (let* ((marked-items (dired-get-marked-files)) ; Include directories in the list
           (files (emacs-solo/expand-directories marked-items)))
      (if files
          (progn
            (multi-file-replace-regexp-as-diff files from to delimited))
        (message "No files found in marked items.")))))

;;; EMACS-SOLO-WEATHER
;;
(use-package emacs-solo-weather
  :ensure nil
  :no-require t
  :defer t
  :init
  (setq emacs-solo-weather-city "Indaiatuba")

  (defun emacs-solo/weather-buffer ()
    "Open a new Emacs buffer and asynchronously fetch wttr.in weather data."
    (interactive)
    (let* ((city (shell-quote-argument emacs-solo-weather-city))
           (buffer (get-buffer-create "*Weather*"))
           (url1 (format "curl -s 'wttr.in/%s?format'" city))
           (url2 (format "curl -s 'v2d.wttr.in/%s?format'" city)))
      (with-current-buffer buffer
        (read-only-mode -1)
        (erase-buffer)
        (insert "Fetching weather data...\n")
        (read-only-mode 1))
      (switch-to-buffer buffer)
      ;; Fetch both asynchronously
      (emacs-solo--fetch-weather url1 buffer)
      (emacs-solo--fetch-weather url2 buffer t)))

  (defun emacs-solo--fetch-weather (cmd buffer &optional second)
    "Run CMD asynchronously and insert results into BUFFER.
If SECOND is non-nil, separate the results with a newline."
    (make-process
     :name "weather-fetch"
     :buffer (generate-new-buffer " *weather-temp*")
     :command (list "sh" "-c" cmd)
     :sentinel
     (lambda (proc _event)
       (when (eq (process-status proc) 'exit)
         (let ((output (with-current-buffer (process-buffer proc)
                         (buffer-string))))
           (kill-buffer (process-buffer proc))
           (setq output (replace-regexp-in-string "^Follow.*\n" ""
                                                  (replace-regexp-in-string "[\x0f]" "" output)))
           (with-current-buffer buffer
             (read-only-mode -1)
             (when second (insert "\n\n"))
             (insert output)
             (ansi-color-apply-on-region (point-min) (point-max))
             (goto-char (point-min))
             (read-only-mode 1))))))))


;;; EMACS-SOLO-OLLAMA
;;
(use-package emacs-solo-ollama
  :ensure nil
  :no-require t
  :defer t
  :init
  (defun emacs-solo/ollama-run-model ()
    "Run `ollama list`, let the user choose a model, and open it in `ansi-term`.
Asks for a prompt when run. If none is passed (RET), starts it interactive.
If a region is selected, prompt for additional input and pass it as a query."
    (interactive)
    (let* ((output (shell-command-to-string "ollama list"))
           (models (let ((lines (split-string output "\n" t)))
                     (mapcar (lambda (line) (car (split-string line))) (cdr lines))))
           (selected (completing-read "Select Ollama model: " models nil t))
           (region-text (when (use-region-p)
                          (shell-quote-argument
                           (replace-regexp-in-string "\n" " "
                                                     (buffer-substring-no-properties
                                                      (region-beginning)
                                                      (region-end))))))
           (prompt (read-string "Ollama Prompt (leave it blank for interactive): " nil nil nil)))
      (when (and selected (not (string-empty-p selected)))
        (ansi-term "/bin/sh")
        (sit-for 1)
        (let ((args (list (format "ollama run %s"
                                  selected))))
          (when (and prompt (not (string-empty-p prompt)))
            (setq args (append args (list (format "\"%s\"" prompt)))))
          (when region-text
            (setq args (append args (list (format "\"%s\"" region-text)))))

          (term-send-raw-string (string-join args " "))
          (term-send-raw-string "\n"))))))


;;; EMACS-SOLO-DIRED-GUTTER
;;
(use-package emacs-solo-dired-gutter
  :if emacs-solo-enable-dired-gutter
  :ensure nil
  :no-require t
  :defer t
  :init
  (setq emacs-solo-dired-gutter-enabled t)

  (defvar emacs-solo/dired-git-status-overlays nil
    "List of active overlays in Dired for Git status.")

  (defun emacs-solo/dired--git-status-face (code)
    "Return a cons cell (STATUS . FACE) for a given Git porcelain CODE."
    (let* ((git-status-untracked "??")
           (git-status-modified " M")
           (git-status-modified-alt "M ")
           (git-status-deleted "D ")
           (git-status-added "A ")
           (git-status-renamed "R ")
           (git-status-copied "C ")
           (git-status-ignored "!!")
           (status (cond
                    ((string-match-p "\\?\\?" code) git-status-untracked)
                    ((string-match-p "^ M" code) git-status-modified)
                    ((string-match-p "^M " code) git-status-modified-alt)
                    ((string-match-p "^D" code) git-status-deleted)
                    ((string-match-p "^A" code) git-status-added)
                    ((string-match-p "^R" code) git-status-renamed)
                    ((string-match-p "^C" code) git-status-copied)
                    ((string-match-p "\\!\\!" code) git-status-ignored)
                    (t "  ")))
           (face (cond
                  ((string= status git-status-ignored) 'shadow)
                  ((string= status git-status-untracked) 'warning)
                  ((string= status git-status-modified) 'font-lock-function-name-face)
                  ((string= status git-status-modified-alt) 'font-lock-function-name-face)
                  ((string= status git-status-deleted) 'error)
                  ((string= status git-status-added) 'success)
                  (t 'font-lock-keyword-face))))
      (cons status face)))

  (defun emacs-solo/dired-git-status-overlay ()
    "Overlay Git status indicators on the first column in Dired."
    (interactive)
    (require 'vc-git)
    (let ((git-root (ignore-errors (vc-git-root default-directory))))
      (when (and git-root
                 (not (file-remote-p default-directory))
                 emacs-solo-dired-gutter-enabled)
        (setq git-root (expand-file-name git-root))
        (let* ((git-status (vc-git--run-command-string nil "status" "--porcelain" "--ignored" "--untracked-files=normal"))
               (status-map (make-hash-table :test 'equal)))
          (mapc #'delete-overlay emacs-solo/dired-git-status-overlays)
          (setq emacs-solo/dired-git-status-overlays nil)

          (dolist (line (split-string git-status "\n" t))
            (when (string-match "^\\(..\\) \\(.+\\)$" line)
              (let* ((code (match-string 1 line))
                     (file (match-string 2 line))
                     (fullpath (expand-file-name file git-root))
                     (status-face (emacs-solo/dired--git-status-face code)))
                (puthash fullpath status-face status-map))))

          (save-excursion
            (goto-char (point-min))
            (while (not (eobp))
              (let* ((file (ignore-errors (expand-file-name (dired-get-filename nil t)))))
                (when file
                  (setq file (if (file-directory-p file) (concat file "/") file))
                  (let* ((status-face (gethash file status-map (cons "  " 'font-lock-keyword-face)))
                         (status (car status-face))
                         (face (cdr status-face))
                         (status-str (propertize (format " %s " status) 'face face))
                         (ov (make-overlay (line-beginning-position) (1+ (line-beginning-position)))))
                    (overlay-put ov 'before-string status-str)
                    (push ov emacs-solo/dired-git-status-overlays))))
              (forward-line 1)))))))

  (add-hook 'dired-after-readin-hook #'emacs-solo/dired-git-status-overlay))


;;; EMACS-SOLO-DIRED-ICONS
;;
(use-package emacs-solo-dired-icons
  :if emacs-solo-enable-dired-icons
  :ensure nil
  :no-require t
  :defer t
  :init
  (defvar emacs-solo/dired-icons-file-icons
    '(("el" . "📜")      ("rb" . "💎")      ("js" . "⚙️")      ("ts" . "⚙️")
      ("json" . "🗂️")    ("md" . "📝")      ("txt" . "📝")     ("html" . "🌐")
      ("css" . "🎨")     ("scss" . "🎨")    ("png" . "🖼️")    ("jpg" . "🖼️")
      ("jpeg" . "🖼️")   ("gif" . "🖼️")    ("svg" . "🖼️")    ("pdf" . "📄")
      ("zip" . "📦")     ("tar" . "📦")     ("gz" . "📦")      ("bz2" . "📦")
      ("7z" . "📦")      ("org" . "📝")    ("sh" . "💻")      ("c" . "🔧")
      ("h" . "📘")       ("cpp" . "➕")     ("hpp" . "📘")     ("py" . "🐍")
      ("java" . "☕")    ("go" . "🌍")      ("rs" . "💨")      ("php" . "🐘")
      ("pl" . "🐍")      ("lua" . "🎮")     ("ps1" . "🔧")     ("exe" . "⚡")
      ("dll" . "🔌")     ("bat" . "⚡")      ("yaml" . "⚙️")    ("toml" . "⚙️")
      ("ini" . "⚙️")     ("csv" . "📊")     ("xls" . "📊")     ("xlsx" . "📊")
      ("sql" . "🗄️")    ("log" . "📝")     ("apk" . "📱")     ("dmg" . "💻")
      ("iso" . "💿")     ("torrent" . "⏳") ("bak" . "🗃️")    ("tmp" . "⚠️")
      ("desktop" . "🖥️") ("md5" . "🔐")     ("sha256" . "🔐")  ("pem" . "🔐")
      ("sqlite" . "🗄️")  ("db" . "🗄️")
      ("mp3" . "🎶")     ("wav" . "🎶")     ("flac" . "🎶")
      ("ogg" . "🎶")     ("m4a" . "🎶")     ("mp4" . "🎬")     ("avi" . "🎬")
      ("mov" . "🎬")     ("mkv" . "🎬")     ("webm" . "🎬")    ("flv" . "🎬")
      ("ico" . "🖼️")     ("ttf" . "🔠")     ("otf" . "🔠")     ("eot" . "🔠")
      ("woff" . "🔠")    ("woff2" . "🔠")   ("epub" . "📚")    ("mobi" . "📚")
      ("azw3" . "📚")    ("fb2" . "📚")     ("chm" . "📚")     ("tex" . "📚")
      ("bib" . "📚")     ("apk" . "📱")     ("rar" . "📦")     ("xz" . "📦")
      ("zst" . "📦")     ("tar.xz" . "📦")  ("tar.zst" . "📦") ("tar.gz" . "📦")
      ("tgz" . "📦")     ("bz2" . "📦")     ("mpg" . "🎬")     ("webp" . "🖼️")
      ("flv" . "🎬")     ("3gp" . "🎬")     ("ogv" . "🎬")     ("srt" . "🔠")
      ("vtt" . "🔠")     ("cue" . "📀")
      ("direddir" . "📁") ("diredfile" . "📄"))
    "Icons for specific file extensions in Dired.")

  (defun emacs-solo/dired-icons-icon-for-file (file)
    (if (file-directory-p file)
        (assoc-default "direddir" emacs-solo/dired-icons-file-icons)
      (let* ((ext (file-name-extension file))
             (icon (and ext (assoc-default (downcase ext) emacs-solo/dired-icons-file-icons))))
        (or icon (assoc-default "diredfile" emacs-solo/dired-icons-file-icons)))))

  (defun emacs-solo/dired-icons-icons-regexp ()
    "Return a regexp that matches any icon we use."
    (let ((icons (mapcar #'cdr emacs-solo/dired-icons-file-icons)))
      (concat "^\\(" (regexp-opt (cons "📁" icons)) "\\) ")))

  (defun emacs-solo/dired-icons-add-icons ()
    "Add icons to filenames in Dired buffer."
    (when (derived-mode-p 'dired-mode)
      (let ((inhibit-read-only t)
            (icon-regex (emacs-solo/dired-icons-icons-regexp)))
        (save-excursion
          (goto-char (point-min))
          (while (not (eobp))
            (condition-case nil
                (when-let* ((file (dired-get-filename nil t)))
                  (dired-move-to-filename)
                  (unless (looking-at-p icon-regex)
                    (insert (concat (emacs-solo/dired-icons-icon-for-file file) " "))))
              (error nil))  ;; gracefully skip invalid lines
            (forward-line 1))))))

  (add-hook 'dired-after-readin-hook #'emacs-solo/dired-icons-add-icons))


;;; EMACS-SOLO-CONTAINER
;;
;;  A proto 'control panel' for basic container management (docker and podman based)
;;
(use-package emacs-solo-container
  :ensure nil
  :no-require t
  :defer t
  :init
  (require 'transient)
  (require 'project)

  (defvar container-backend 'podman
    "Current container backend. Either 'docker or 'podman.")

  (defvar container-profile 'dev
    "Current profile: either 'prod or 'dev.")

  (defconst container-buffer-name "*container*"
    "Buffer name for container command output.")

  (defvar container--process nil)

  (defun container-toggle-backend ()
    "Toggle between Docker and Podman."
    (interactive)
    (setq container-backend (if (eq container-backend 'docker) 'podman 'docker))
    (message "Switched to backend: %s" container-backend))

  (defun container-toggle-profile ()
    "Toggle between prod and dev profiles."
    (interactive)
    (setq container-profile (if (eq container-profile 'prod) 'dev 'prod))
    (message "Switched to profile: %s (%s)" container-profile
             (if (eq container-profile 'prod)
                 "Dockerfile / docker-compose.yml"
               "Dockerfile.dev / docker-compose-dev.yml")))

  (defun container--command ()
    "Return the container backend command."
    (pcase container-backend
      ('docker "docker")
      ('podman "podman")
      (_ (error "Unknown backend: %s" container-backend))))

  (defun container--compose-command ()
    "Return the container backend compose command."
    (pcase container-backend
      ('docker "docker compose")
      ('podman "podman compose")
      (_ (error "Unknown backend: %s" container-backend))))

  (defun container--project-name ()
    "Return the base name of the current project or buffer."
    (let* ((project (project-current))
           (name (if project
                     (file-name-nondirectory (directory-file-name (project-root project)))
                   (file-name-base (or buffer-file-name default-directory)))))
      (downcase name)))

  (defun container--dockerfile ()
    "Return the appropriate Dockerfile path based on profile and context."
    (let ((base (container--project-name)))
      (pcase container-profile
        ('prod (or (car (file-expand-wildcards (format "%s.Dockerfile" base))) "Dockerfile"))
        ('dev  (or (car (file-expand-wildcards (format "%s.Dockerfile.dev" base))) "Dockerfile.dev")))))

  (defun container--compose-file ()
    "Return the appropriate docker-compose file path based on profile and context."
    (let ((project-root (or (project-root (project-current)) default-directory))  ;; Get the project root
          (base (container--project-name)))
      (pcase container-profile
        ('prod (or (car (file-expand-wildcards (format "%s.docker-compose.yml" base))) (concat project-root "docker-compose.yml")))
        ('dev  (or (car (file-expand-wildcards (format "%s.docker-compose-dev.yml" base))) (concat project-root "docker-compose-dev.yml"))))))

  (defun container--run-to-buffer (cmd-template)
    "Build CMD-TEMPLATE string, prompt user to edit it, then run it in *container* buffer."
    (interactive)
    (let* ((final-cmd (read-shell-command "Running command: " cmd-template)))
      (let ((buf (get-buffer-create "*container*")))
        (with-current-buffer buf
          (setq buffer-read-only nil)
          (erase-buffer)
          (comint-mode)
          (ansi-color-for-comint-mode-on))
        (setq container--process
              (start-process-shell-command "container" buf final-cmd))
        (set-process-filter container--process 'comint-output-filter)
        (display-buffer buf)
        (select-window (get-buffer-window buf))
        (delete-other-windows))))

  (defun container--run (args)
    "Run a container command with ARGS."
    (container--run-to-buffer (format "%s %s" (container--command) args)))

  (defun container--run-compose (args)
    "Run a compose command with ARGS using profile-specific file."
    (container--run-to-buffer
     (format "%s -f %s %s"
             (container--compose-command)
             (container--compose-file)
             args)))

  (defun container--run-interactive (prompt action)
    "Prompt for a container/image name and run ACTION with it."
    (let ((name (read-string prompt)))
      (container--run (format "%s %s" action name))))

  ;; === Container actions ===
  (defun container-list () (interactive) (container--run "ps -a "))
  (defun container-start () (interactive) (container--run "run -it --rm --platform linux/amd64 -p 3500:3500 "))
  (defun container-stop () (interactive) (container--run "stop "))
  (defun container-restart () (interactive) (container--run "restart "))
  (defun container-remove () (interactive) (container--run "rm "))
  (defun container-logs () (interactive) (container--run "logs "))

  ;; === Image actions ===
  (defun container-list-images () (interactive) (container--run "images"))
  (defun container-pull-image () (interactive) (container--run "pull "))

  (defun container-build-image ()
    (interactive)
    (let ((image "TAG")
          (file (container--dockerfile)))
      (container--run-to-buffer
       (format "%s build -f %s -t %s ." (container--command) file image))))

  ;; === Compose actions ===
  (defun container-compose-up () (interactive) (container--run-compose "up -d"))
  (defun container-compose-down () (interactive) (container--run-compose "down"))
  (defun container-compose-logs () (interactive) (container--run-compose "logs"))
  (defun container-compose-ps () (interactive) (container--run-compose "ps"))
  (defun container-compose-build () (interactive) (container--run-compose "build"))
  (defun container-compose-restart () (interactive) (container--run-compose "restart"))

  (defun container-kill-buffer ()
    "Kill the *container* buffer."
    (interactive)
    (let ((buf (get-buffer container-buffer-name)))
      (when buf
        (kill-buffer buf))))

  ;; === Transient menu ===
  (transient-define-prefix container-menu ()
    "Container and Compose management menu."
    [["Backend/Profile"
      ("b" (lambda () (format "Toggle backend (%s)" container-backend))
       container-toggle-backend :transient t)
      ("p" (lambda () (format "Toggle profile (%s)" container-profile))
       container-toggle-profile :transient t)
      ("q" "Kill output buffer" container-kill-buffer :transient t)]
     ["Containers"
      ("l" "List containers" container-list :transient t)
      ("s" "Start container" container-start :transient t)
      ("t" "Stop container" container-stop :transient t)
      ("r" "Restart container" container-restart :transient t)
      ("R" "Remove container" container-remove :transient t)
      ("L" "Logs" container-logs :transient t)]
     ["Images"
      ("i" "List images" container-list-images :transient t)
      ("P" "Pull image" container-pull-image :transient t)
      ("B" "Build image" container-build-image :transient t)]
     ["Compose"
      ("u" "Compose up" container-compose-up :transient t)
      ("d" "Compose down" container-compose-down :transient t)
      ("c" "Compose ps" container-compose-ps :transient t)
      ("C" "Compose build" container-compose-build :transient t)
      ("x" "Compose restart" container-compose-restart :transient t)
      ("g" "Compose logs" container-compose-logs :transient t)]
     ])

  (global-set-key (kbd "C-c d") #'container-menu))


;;; EMACS-SOLO-MPV-PLAYER
;;
;; TLDR: M-x dired
;;       mark files with `m'
;;       C-c m to to open the music player with the selected files
;;
(use-package emacs-solo-mpv-player
  :ensure nil
  :no-require t
  :defer t
  :init
  (defvar emacs-solo/mpv-process nil
    "Process object for the currently running mpv instance.")

  (defvar emacs-solo/mpv-ipc-socket "/tmp/mpv-socket"
    "Path to mpv's IPC UNIX domain socket.")

  (defun emacs-solo/mpv-play-files ()
    "Play marked files in Dired using mpv with IPC."
    (interactive)
    (unless (derived-mode-p 'dired-mode)
      (user-error "Not in a Dired buffer"))
    (let ((files (dired-get-marked-files)))
      (when (file-exists-p emacs-solo/mpv-ipc-socket)
        (delete-file emacs-solo/mpv-ipc-socket))
      (when (process-live-p emacs-solo/mpv-process)
        (kill-process emacs-solo/mpv-process))
      (setq emacs-solo/mpv-process
            (apply #'start-process
                   "mpv" "*mpv*"
                   "mpv"
                   "--force-window=yes"
                   (concat "--input-ipc-server=" emacs-solo/mpv-ipc-socket)
                   files))))

  (defun emacs-solo/mpv-stop ()
    "Stop mpv playback."
    (interactive)
    (when (process-live-p emacs-solo/mpv-process)
      (kill-process emacs-solo/mpv-process)
      (setq emacs-solo/mpv-process nil)))

  (defun emacs-solo/mpv-send-command (json-cmd)
    "Send JSON-CMD to mpv's IPC socket directly."
    (let ((socket emacs-solo/mpv-ipc-socket))
      (if (file-exists-p socket)
          (let ((proc (make-network-process
                       :name "mpv-ipc"
                       :family 'local
                       :service socket
                       :nowait t)))
            (process-send-string proc (concat json-cmd "\n"))
            (delete-process proc))
        (message "❌ mpv IPC socket not found at %s" socket))))


  (defun emacs-solo/mpv-show-playlist ()
    "Show the current mpv playlist in a readable buffer."
    (interactive)
    (let ((buf (get-buffer-create "*mpv-playlist*"))
          (socket emacs-solo/mpv-ipc-socket)
          (output ""))
      (if (file-exists-p socket)
          (let ((proc
                 (make-network-process
                  :name "mpv-ipc-playlist"
                  :family 'local
                  :service socket
                  :nowait nil
                  :filter (lambda (_proc chunk)
                            (setq output (concat output chunk))))))
            (process-send-string proc
                                 "{\"command\": [\"get_property\", \"playlist\"]}\n")
            (sleep-for 0.1)
            (delete-process proc)

            (with-current-buffer buf
              (let ((inhibit-read-only t)
                    (json-object-type 'alist)
                    (json-array-type 'list)
                    (json-key-type 'symbol))
                (erase-buffer)
                (let* ((json-data (ignore-errors (json-read-from-string output)))
                       (playlist (alist-get 'data json-data)))
                  (if playlist
                      (progn
                        (insert "🎵 MPV Playlist:\n\n")
                        (cl-loop for i from 0
                                 for entry in playlist do
                                 (insert
                                  (format "%s %s. %s\n"
                                          (if (eq (alist-get 'current entry) t)
                                              "now playing ➡️ " "")
                                          (1+ i)
                                          (alist-get 'filename entry)
                                          ))))
                    (insert "❌ Failed to parse playlist or playlist is empty."))))
              (special-mode)
              (goto-char (point-min)))
            (display-buffer buf))
        (message "❌ mpv IPC socket not found at %s" socket))))

  (require 'transient)

  (transient-define-prefix emacs-solo/mpv-transient ()
    "🎵 MPV Controls"
    [[" 🔅 Controls"
      ("p" "⏸️ Pause/Resume"
       (lambda () (interactive)
         (emacs-solo/mpv-send-command
          "{\"command\": [\"cycle\", \"pause\"]}")))
      ("x" "⏹️ Stop" emacs-solo/mpv-stop)
      ("n" "⏭️ Next"
       (lambda () (interactive)
         (emacs-solo/mpv-send-command
          "{\"command\": [\"playlist-next\"]}")))
      ("b" "⏮️ Previous"
       (lambda () (interactive)
         (emacs-solo/mpv-send-command
          "{\"command\": [\"playlist-prev\"]}")))
      ("l" "🔁 Loop"
       (lambda () (interactive)
         (emacs-solo/mpv-send-command
          "{\"command\": [\"cycle\", \"loop\"]}")))]
     [" 🎧 Playback"
      ("RET" "▶️ Play marked" emacs-solo/mpv-play-files)
      ("L"   "▶️ List playlist" emacs-solo/mpv-show-playlist)]])

  (defun emacs-solo/mpv-dired-setup ()
    (global-set-key (kbd "C-c m") #'emacs-solo/mpv-transient))

  (add-hook 'dired-mode-hook #'emacs-solo/mpv-dired-setup))


;;; EMACS-SOLO-M3U-VISUALIZER (& Online Radio Player)
;;
;; TLDR: C-c r (select an online radio list to download)
;;       RET - play with mpv
;;       x   - stop with mpv
;;
(use-package emacs-solo-m3u-visualizer
  :ensure nil
  :no-require t
  :defer t
  :init
  (defvar emacs-solo/m3u-radio-sources
    '(("Full List" . "https://raw.githubusercontent.com/junguler/m3u-radio-music-playlists/refs/heads/main/---everything-full.m3u")
      ("60s" . "https://raw.githubusercontent.com/junguler/m3u-radio-music-playlists/refs/heads/main/60s.m3u")
      ("70s" . "https://raw.githubusercontent.com/junguler/m3u-radio-music-playlists/refs/heads/main/70s.m3u")
      ("80s" . "https://raw.githubusercontent.com/junguler/m3u-radio-music-playlists/refs/heads/main/80s.m3u")
      ("90s" . "https://raw.githubusercontent.com/junguler/m3u-radio-music-playlists/refs/heads/main/90s.m3u"))
    "Alist of named M3U radio sources.")

  (defun emacs-solo/get-online-radio-list-m3u ()
    "Select and download M3U playlist, then visualize it using `m3u-visualizer-mode'."
    (interactive)
    (let* ((choice (completing-read "Choose your Online Radio playlist: " emacs-solo/m3u-radio-sources))
           (url (cdr (assoc choice emacs-solo/m3u-radio-sources)))
           (dest-buffer (get-buffer-create "*M3U Radio List*")))
      (url-retrieve
       url
       (lambda (_status)
         (goto-char (point-min))
         (when (re-search-forward "\n\n" nil t)
           (let* ((body-start (point))
                  (raw (buffer-substring-no-properties body-start (point-max)))
                  (decoded (decode-coding-string raw 'utf-8)))
             (with-current-buffer dest-buffer
               (let ((inhibit-read-only t))
                 (erase-buffer)
                 (insert decoded)
                 (goto-char (point-min))
                 (m3u-visualize-buffer)))))
         (kill-buffer (current-buffer))))))

  (global-set-key (kbd "C-c r") #'emacs-solo/get-online-radio-list-m3u)


  (defvar m3u-visualizer-mode-map
    (let ((map (make-sparse-keymap)))
      (define-key map (kbd "n") #'m3u-visualizer-next)
      (define-key map (kbd "p") #'m3u-visualizer-prev)
      (define-key map (kbd "RET") #'m3u-visualizer-play-current)
      (define-key map (kbd "x") #'m3u-visualizer-stop-mpv)

      map)
    "Keymap for `m3u-visualizer-mode'.")

  (define-derived-mode m3u-visualizer-mode special-mode "M3U-Visualizer"
    "Major mode for viewing M3U playlist as a styled table."
    (buffer-disable-undo)
    (setq truncate-lines t))

  (defvar-local m3u-visualizer--entries nil
    "List of parsed entries (title group logo url).")

  (defvar m3u-visualizer--mpv-process nil
    "Holds the current mpv process instance.")

  (defun m3u-visualizer--format-entry (entry)
    "Return a propertized string for ENTRY."
    (let ((title (propertize (truncate-string-to-width (nth 0 entry) 50 nil ?\s)
                             'face 'font-lock-function-name-face))
          (group (propertize (truncate-string-to-width (nth 1 entry) 20 nil ?\s)
                             'face 'font-lock-keyword-face))
          (logo (propertize (truncate-string-to-width (nth 2 entry) 40 nil ?\s)
                            'face 'font-lock-string-face))
          (url   (propertize (nth 3 entry) 'face 'font-lock-comment-face)))
      (format "%s  %s  %s  %s" title group logo url)))

  (defun m3u-visualizer--collect-entries ()
    "Return parsed entries from the current buffer."
    (let ((entries '()))
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward
                ;; Match lines like: #EXTINF:-1 [optional attributes], Title
                "^#EXTINF:-1\\(?:\\s-+\\([^,]+\\)\\)?[ \t]*,[ \t]*\\(.*?\\)[ \t]*[\r\n]+\\(http[^\r\n]+\\)"
                nil t)
          (let* ((attr-str (match-string 1))
                 (title (match-string 2))
                 (url (match-string 3))
                 (logo "")
                 (group ""))
            ;; Optionally extract logo and group-title from attributes
            (when attr-str
              (when (string-match "tvg-logo=\"\\([^\"]*\\)\"" attr-str)
                (setq logo (match-string 1 attr-str)))
              (when (string-match "group-title=\"\\([^\"]*\\)\"" attr-str)
                (setq group (match-string 1 attr-str))))
            (push (list title group logo url) entries))))
      (reverse entries)))

  (defun m3u-visualize-buffer ()
    "Visualize current M3U playlist in a formatted buffer."
    (interactive)
    (let ((entries (m3u-visualizer--collect-entries)))
      (with-current-buffer (get-buffer-create "*M3U Playlist*")
        (let ((inhibit-read-only t))
          (erase-buffer)
          (setq m3u-visualizer--entries entries)
          (dolist (entry entries)
            (insert (m3u-visualizer--format-entry entry) "\n"))
          (goto-char (point-min))
          (m3u-visualizer-mode))
        (pop-to-buffer (current-buffer)))))

  (defun m3u-visualizer-current-url ()
    "Extract the actual stream URL from the current line (last column)."
    (save-excursion
      (beginning-of-line)
      (let ((line (buffer-substring (line-beginning-position)
                                    (line-end-position))))
        ;; Match last http URL in line
        (when (string-match "\\(http[^\s]+\\)$" line)
          (match-string 1 line)))))

  (defun m3u-visualizer-play-current ()
    "Play the stream URL at point using mpv asynchronously.
If a stream is already playing, kill it before starting a new one."
    (interactive)
    (let ((url (m3u-visualizer-current-url)))
      (if url
          (progn
            (when (and m3u-visualizer--mpv-process
                       (process-live-p m3u-visualizer--mpv-process))
              (kill-process m3u-visualizer--mpv-process)
              (message "Stopped previous mpv stream."))
            (setq m3u-visualizer--mpv-process
                  (start-process "mpv-stream" "*mpv*" "mpv" url))
            (message "Playing stream: %s" url))
        (message "No stream URL on this line."))))

  (defun m3u-visualizer-stop-mpv ()
    "Stop the currently playing mpv process."
    (interactive)
    (if (and m3u-visualizer--mpv-process
             (process-live-p m3u-visualizer--mpv-process))
        (progn
          (kill-process m3u-visualizer--mpv-process)
          (setq m3u-visualizer--mpv-process nil)
          (message "Stopped mpv."))
      (message "No mpv process running.")))

  (defun m3u-visualizer-next ()
    "Go to next entry line."
    (interactive)
    (forward-line 1))

  (defun m3u-visualizer-prev ()
    "Go to previous entry line."
    (interactive)
    (forward-line -1)))


;;; EMACS-SOLO-CLIPBOARD
;;
;;  Allows proper copy/pasting on terminals
;;
(use-package emacs-solo-clipboard
  :ensure nil
  :no-require t
  :defer t
  :init
  (cond
   ;; macOS: use pbcopy/pbpaste
   ((eq system-type 'darwin)
    (setq interprogram-cut-function
          (lambda (text &optional _)
            (let ((process-connection-type nil))
              (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
                (process-send-string proc text)
                (process-send-eof proc)))))
    (setq interprogram-paste-function
          (lambda ()
            (shell-command-to-string "pbpaste"))))

   ;; WSL (Windows Subsystem for Linux): Use clip.exe for copy and powershell.exe for paste
   ((and (eq system-type 'gnu/linux)
         (getenv "WSLENV"))
    (setq interprogram-cut-function
          (lambda (text &optional _)
            (let ((process-connection-type nil))
              (let ((proc (start-process "clip.exe" "*Messages*" "clip.exe")))
                (process-send-string proc text)
                (process-send-eof proc)))))
    (setq interprogram-paste-function
          (lambda ()
            (string-trim (shell-command-to-string "powershell.exe -command Get-Clipboard")))))

   ;; Linux with wl-copy/wl-paste (Wayland)
   ((and (eq system-type 'gnu/linux) (executable-find "wl-copy"))
    (setq interprogram-cut-function
          (lambda (text &optional _)
            (let ((process-connection-type nil))
              (let ((proc (start-process "wl-copy" "*Messages*" "wl-copy")))
                (process-send-string proc text)
                (process-send-eof proc)))))
    (setq interprogram-paste-function
          (lambda ()
            (shell-command-to-string "wl-paste -n"))))

   ;; Linux with xclip (X11)
   ((and (eq system-type 'gnu/linux) (executable-find "xclip"))
    (setq interprogram-cut-function
          (lambda (text &optional _)
            (let ((process-connection-type nil))
              (let ((proc (start-process "xclip" "*Messages*" "xclip" "-selection" "clipboard")))
                (process-send-string proc text)
                (process-send-eof proc)))))
    (setq interprogram-paste-function
          (lambda ()
            (shell-command-to-string "xclip -selection clipboard -o"))))))


;;; EMACS-SOLO-ELDOC-BOX
;;
;;  A hacky eldoc-box inspired by the famous casouri package
;;
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



(provide 'init)
;;; init.el ends here
