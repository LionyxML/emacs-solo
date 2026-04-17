;;; init.el --- Emacs Solo (no external packages) Configuration --- Init  -*- lexical-binding: t; byte-compile-warnings: (not free-vars unresolved make-local); -*-
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

;;; Welcome to:
;;; ┌─────────────────────────────────────────────────────────────────────────┐
;;; │ ███████╗███╗   ███╗ █████╗  ██████╗███████╗                             │
;;; │ ██╔════╝████╗ ████║██╔══██╗██╔════╝██╔════╝                             │
;;; │ █████╗  ██╔████╔██║███████║██║     ███████╗                             │
;;; │ ██╔══╝  ██║╚██╔╝██║██╔══██║██║     ╚════██║                             │
;;; │ ███████╗██║ ╚═╝ ██║██║  ██║╚██████╗███████║                             │
;;; │ ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝                             │
;;; │                                                                         │
;;; │                                      ███████╗ ██████╗ ██╗      ██████╗  │
;;; │                                      ██╔════╝██╔═══██╗██║     ██╔═══██╗ │
;;; │                                      ███████╗██║   ██║██║     ██║   ██║ │
;;; │                                      ╚════██║██║   ██║██║     ██║   ██║ │
;;; │                                      ███████║╚██████╔╝███████╗╚██████╔╝ │
;;; │                                      ╚══════╝ ╚═════╝ ╚══════╝ ╚═════╝  │
;;; └─────────────────────────────────────────────────────────────────────────┘

;;; ┌─────────────────────────────────────────────────────────────────────────┐
;;; │                       HELP, WHERE IS MY CONFIG?                         │
;;; ├─────────────────────────────────────────────────────────────────────────┤
;;; │ If you're opening this file inside Emacs Solo, it's likely collapsed    │
;;; │ by default to help you better navigate its structure.  Use outline-mode │
;;; │ keybindings to explore sections as needed:                              │
;;; │                                                                         │
;;; │   C-c @ C-a -> Show all sections                                        │
;;; │   C-c @ C-q -> Hide all sections                                        │
;;; │   C-c @ C-c -> Toggle section at point                                  │
;;; │                                                                         │
;;; │ If you're viewing this file on a code forge (e.g., GitHub, Codeberg)    │
;;; │ or in another editor, you might see it fully expanded.  For the best    │
;;; │ viewing and navigation experience, use Emacs Solo.                      │
;;; │                                                                         │
;;; │ To disable automatic folding on load, set:                              │
;;; │   (setq emacs-solo-enable-outline-init nil)                             │
;;; └─────────────────────────────────────────────────────────────────────────┘


;;; Code:

;;; ┌──────────────────── EMACS SOLO CUSTOM OPTIONS
;;
;;  Some features Emacs Solo provides you can turn on/off
(defcustom emacs-solo-enable-outline-init t
  "Enable init.el starting all collapsed."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-enable-transparency nil
  "Enable `emacs-solo-transparency'."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-icon-modules
  '(dired eshell ibuffer)
  "List of Emacs Solo icon modules to enable.
Controls which modules display file type icons.

Valid values (combine in a list):
- \\='dired: Show file type icons in Dired buffers
- \\='eshell: Show file type icons in Eshell prompts
- \\='ibuffer: Show buffer type icons in Ibuffer
- \\='nerd: Prefer Nerd Font glyphs over Emojis
- nil: Disable all icons

Default is \\='(dired eshell ibuffer), which uses Emoji icons.
Add \\='nerd to the list to use Nerd Font glyphs instead."
  :type '(set :tag "Emacs Solo icon modules"
              (const :tag "Use icons on Dired" dired)
              (const :tag "Use icons on Eshell" eshell)
              (const :tag "Use icons on Ibuffer" ibuffer)
              (const :tag "Prefer Nerd Fonts icons over Emojis" nerd))
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
  "Enable `emacs-solo-simple-orderless'."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-enable-eldoc-box t
  "Enable `emacs-solo-eldoc-box'."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-use-custom-theme 'crafters
  "Select which emacs-solo customization theme to use.

Valid values are:
- \\='catppuccin
- \\='crafters
- \\='gits
- \\='matrix
- nil: Disable custom theme

IMPORTANT NOTE: If you disable this or choose another theme, also check
\\='emacs-solo-avoid-flash-options to ensure compatibility."
  :type '(choice
          (const :tag "Disabled" nil)
          (const :tag "Catppuccin" catppuccin)
          (const :tag "Crafters" crafters)
          (const :tag "Matrix" matrix)
          (const :tag "GITS" gits))
  :group 'emacs-solo)

(defcustom emacs-solo-enable-preferred-font t
  "Enable `emacs-solo-enable-preferred-font'."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-preferred-font-name "JetBrainsMono Nerd Font"
  "The name of the font to be used.
Examples: `Maple Mono NF' or `JetBrainsMono Nerd Font'."
  :type 'string
  :group 'emacs-solo)

(defcustom emacs-solo-preferred-font-sizes '(130 105)
  "List of default font sizes (first for macOS, second for GNU/Linux)."
  :type '(repeat integer)
  :group 'emacs-solo)

(defcustom emacs-solo-ai-scratch-path nil
  "If non-nil, AI commands run from this directory.
This allows using a specific environment or scratch context."
  :type '(choice (const :tag "Disabled" nil)
                 (directory :tag "AI Scratch Directory"))
  :group 'emacs-solo)

(defcustom emacs-solo-enable-erc-image t
  "Whether to enable inline image support in ERC buffers.
This is enabled by default and allows displaying images directly from
URLs posted in ERC channels."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-enable-auto-formatter t
  "Whether to automatically enable format-on-save for files.
Respects the `emacs-solo-formatter-alist'.  When non-nil, opening a file whose
extension has a registered formatter will add format-on-save to the
buffer's `after-save-hook'."
  :type 'boolean
  :group 'emacs-solo)

(defcustom emacs-solo-enable-flymake-eslint nil
  "Whether to enable Flymake integration using ESLint.
This is disabled by default, since nowadays we tend to use LSP servers
for ESLint."
  :type 'boolean
  :group 'emacs-solo)

;;; ├──────────────────── CACHE PATHS
;;
;;  Single source of truth for every path Emacs Solo stores in its
;;  cache.  `emacs-solo-cache-directory' is the base; each entry in
;;  `emacs-solo-cache-paths' maps a key (usually the Emacs variable
;;  that should hold the resolved path) to a path relative to that
;;  base.  A trailing slash means the value is a directory and will be
;;  created as-is; otherwise the value is a file and only its parent
;;  directory is created.
;;
;;  To wire a variable: use (emacs-solo--cache-path 'KEY) inside a
;;  use-package :custom block (or wherever the value is needed).

(defcustom emacs-solo-cache-directory
  (expand-file-name "cache/" user-emacs-directory)
  "Base directory for Emacs Solo cache files.
All entries in `emacs-solo-cache-paths' are resolved relative to this
directory.  Choose one of the presets or supply any custom directory path.
Changes take effect after restarting Emacs."
  :type `(choice
          (const     :tag "Inside Emacs config  (cache/ in user-emacs-directory)"
                     ,(expand-file-name "cache/" user-emacs-directory))
          (const     :tag "System temp          (/tmp/emacs-cache/)" "/tmp/emacs-cache/")
          (directory :tag "Custom directory"))
  :group 'emacs-solo)

;; custom-file is already set and loaded in early-init.el, but reload it here
;; so any M-x customize changes saved mid-session before restart also apply
;; to cache paths and other init.el settings.
(load custom-file 'noerror 'nomessage)

(defvar emacs-solo-cache-paths
  '(;; Files:
    (bookmark-file               . "bookmarks")
    (ielm-history-file-name      . "ielm-history.eld")
    (project-list-file           . "projects")
    (recentf-save-file           . "recentf")
    (savehist-file               . "history")
    (save-place-file             . "saveplace")
    (transient-history-file      . "transient/history.el")
    (transient-levels-file       . "transient/levels.el")
    (transient-values-file       . "transient/values.el")
    (tramp-persistency-file-name . "tramp")
    (viper-custom-file-name      . "viper")
    (nsm-settings-file           . "network-security.data")
    ;; Directories:
    (auto-saves                  . "auto-saves/")
    (auto-saves-sessions         . "auto-saves/sessions/")
    (shared-game-score-directory . "games/")
    (multisession-directory      . "multisession/")
    (url-configuration-directory . "url/")
    (rcirc-log-directory         . "rcirc/logs/")
    (erc-log-channels-directory  . "erc/logs/")
    (erc-image-cache-directory   . "erc/images/")
    (image-dired-dir             . "image-dired/")
    (newsticker-dir              . "newsticker/")
    (yt-subs                     . "yt-subs"))
  "Alist of (KEY . RELATIVE-PATH) for Emacs Solo cache locations.
RELATIVE-PATH is resolved against `emacs-solo-cache-directory'.
A trailing slash on RELATIVE-PATH marks the entry as a directory.")

(defun emacs-solo--cache-path (key)
  "Return the absolute path for KEY in `emacs-solo-cache-paths'."
  (let ((rel (cdr (assq key emacs-solo-cache-paths))))
    (unless rel
      (error "emacs-solo--cache-path: Unknown key %S" key))
    (expand-file-name rel emacs-solo-cache-directory)))

(defun emacs-solo--ensure-cache-dirs ()
  "Create every directory referenced by `emacs-solo-cache-paths'.
Entries ending in `/' are created directly; other entries have their
parent directory created."
  (dolist (entry emacs-solo-cache-paths)
    (let* ((abs (emacs-solo--cache-path (car entry)))
           (dir (if (directory-name-p abs)
                    abs
                  (file-name-directory abs))))
      (make-directory dir t))))

(emacs-solo--ensure-cache-dirs)

;;; ├──────────────────── GENERAL EMACS CONFIG
;;; │ EMACS
(use-package emacs
  :ensure nil
  :bind                                              ; NOTE: M-x describe-personal-bindings (for all use-packge binds)
  (("M-o" . other-window)
   ("M-g r" . recentf)
   ("M-s g" . grep)
   ("C-x ;" . comment-line)
   ("M-s f" . find-name-dired)
   ("C-x C-b" . ibuffer)
   ("C-x p l". project-list-buffers)
   ("C-x w t"  . window-layout-transpose)            ; EMACS-31
   ("C-x w r"  . window-layout-rotate-clockwise)     ; EMACS-31
   ("C-x w f h"  . window-layout-flip-leftright)     ; EMACS-31
   ("C-x w f v"  . window-layout-flip-topdown)       ; EMACS-31
   ("C-x 5 l"  . select-frame-by-name)
   ("C-x 5 s"  . set-frame-name)
   ("RET" . newline-and-indent)
   ("C-z" . nil)
   ("C-x C-z" . nil)
   ("C-M-z" . delete-pair)
   ("C-x C-k RET" . nil)
   ("M-@" . emacs-solo/copy-whole-word)
   ("M-J" . duplicate-dwim)                          ; As suggest on r/emacs by the_cecep:
   ("M-K" . kill-paragraph)                          ; Expands M-k for kill-sentence
   ("M-Z" . zap-up-to-char)                          ; Expands M-z for zap-to-char
   ("M-F" . forward-to-word)                         ; Expands M-f to jump to beginning of next word
   ("M-B" . backward-to-word)                        ; Expands M-b to jump to end of previous word
   ("M-M" . end-of-line)                             ; Expands M-m to jump to end line, useful for paragraphs
   ("M-T" . transpose-sentences)                     ; Expands M-t for transposing words
   ("C-x M-t" . transpose-paragraphs)                ; Expands C-x C-t for transposing lines
   ([remap capitalize-word] . capitalize-dwim)       ; Make M-c work on regions
   ([remap downcase-word] . downcase-dwim)           ; Make M-l work on regions
   ([remap upcase-word] . upcase-dwim)               ; Make M-u work on regions
   ([remap kill-buffer] . kill-current-buffer)       ; C-x k stops prompting for buffer to kill
   ([remap delete-horizontal-space] . cycle-spacing) ; M-\. Called twice, cycle-spacing has same effect and its default binding (M-SPC) is problematic in macOS
   )
  :custom
  (ad-redefinition-action 'accept)
  (auto-save-default t)
  (bookmark-file (emacs-solo--cache-path 'bookmark-file))
  (shared-game-score-directory (emacs-solo--cache-path 'shared-game-score-directory)) ; FIXME: is this even working?
  (calendar-latitude 42.36)                   ;; These are needed
  (calendar-longitude -42.36)                 ;; for M-x `sunrise-sunset'
  (calendar-location-name "Cambridge, MA")
  (column-number-mode t)
  (line-number-mode t)
  (line-spacing nil)
  (completion-ignore-case t)
  (completions-detailed t)
  (doc-view-resolution 200)
  (delete-by-moving-to-trash t)
  (delete-pair-blink-delay 0)
  (delete-pair-push-mark t)                   ; EMACS-31 for easy subsequent C-x C-x
  (display-line-numbers-width 4)
  (display-line-numbers-widen t)
  (display-fill-column-indicator-warning nil) ; EMACS-31
  (delete-selection-mode t)
  (enable-recursive minibuffers t)
  (ffap-machine-p-known 'reject)
  (find-ls-option '("-exec ls -ldh {} +" . "-ldh"))  ; find-dired results with human readable sizes
  (frame-resize-pixelwise t)
  (global-goto-address-mode t)                            ;     C-c RET on URLs open in default browser
  (browse-url-secondary-browser-function 'eww-browse-url) ; C-u C-c RET on URLs open in EWW
  (help-window-select t)
  (history-length 300)
  (inhibit-startup-message t)
  (initial-scratch-message "")
  (ibuffer-human-readable-size t) ; EMACS-31
  (ielm-history-file-name (emacs-solo--cache-path 'ielm-history-file-name)) ; EMACS-31
  (kill-do-not-save-duplicates t)
  (kill-region-dwim 'emacs-word)  ; EMACS-31
  (create-lockfiles nil)   ; No lock files
  (make-backup-files nil)  ; No backup files
  (multisession-directory (emacs-solo--cache-path 'multisession-directory))
  (nsm-settings-file (emacs-solo--cache-path 'nsm-settings-file))
  (native-comp-async-on-battery-power nil)  ; No compilations when on battery EMACS-31
  (pixel-scroll-precision-mode t)
  (pixel-scroll-precision-use-momentum nil)
  (project-list-file (emacs-solo--cache-path 'project-list-file))
  (project-vc-extra-root-markers '("Cargo.toml" "package.json" "go.mod" "*.asd")) ; Excelent for mono repos with multiple langs, makes Eglot happy
  (ring-bell-function 'ignore)
  (read-answer-short t)
  (read-process-output-max (* 4 1024 1024)) ; 4MB
  (redisplay-skip-fontification-on-input t)
  (recentf-max-saved-items 300) ; default is 20
  (recentf-max-menu-items 15)
  (recentf-auto-cleanup (if (daemonp) 300 'never))
  (recentf-exclude (list "^/\\(?:ssh\\|su\\|sudo\\)?:"))
  (recentf-save-file (emacs-solo--cache-path 'recentf-save-file))
  (register-use-preview t)
  (remote-file-name-inhibit-delete-by-moving-to-trash t)
  (remote-file-name-inhibit-auto-save t)
  (remote-file-name-inhibit-locks t)
  (remote-file-name-inhibit-auto-save-visited t)
  (tramp-copy-size-limit (* 2 1024 1024)) ;; 2MB
  (tramp-use-scp-direct-remote-copying t)
  (tramp-verbose 2)
  (resize-mini-windows 'grow-only)
  (scroll-conservatively 8)
  (scroll-margin 5)
  (save-interprogram-paste-before-kill t)
  (savehist-save-minibuffer-history t)    ; t is default
  (savehist-additional-variables
   '(kill-ring                            ; clipboard
     register-alist                       ; macros
     mark-ring global-mark-ring           ; marks
     search-ring regexp-search-ring))     ; searches
  (savehist-file (emacs-solo--cache-path 'savehist-file))
  (save-place-file (emacs-solo--cache-path 'save-place-file))
  (save-place-limit 600)
  (set-mark-command-repeat-pop t) ; So we can use C-u C-SPC C-SPC C-SPC... instead of C-u C-SPC C-u C-SPC...
  (split-width-threshold 170)     ; So vertical splits are preferred
  (split-height-threshold nil)
  (shr-use-colors nil)
  (switch-to-buffer-obey-display-actions t)
  (tab-always-indent 'complete)
  (tab-width 4)
  (transient-history-file (emacs-solo--cache-path 'transient-history-file))
  (transient-levels-file (emacs-solo--cache-path 'transient-levels-file))
  (transient-values-file (emacs-solo--cache-path 'transient-values-file))
  (treesit-font-lock-level 4)
  (treesit-auto-install-grammar t) ; EMACS-31
  (treesit-enabled-modes t)        ; EMACS-31
  (truncate-lines t)
  (undo-limit (* 13 160000))
  (undo-strong-limit (* 13 240000))
  (undo-outer-limit (* 13 24000000))
  (url-configuration-directory (emacs-solo--cache-path 'url-configuration-directory))
  (use-dialog-box nil)
  (use-file-dialog nil)
  (use-package-hook-name-suffix nil)
  (use-short-answers t)
  (visible-bell nil)
  (view-lossage-auto-refresh t)  ; EMACS-31 auto updates C-h l usefull when teaching/debugging
  (window-combination-resize t)
  (window-resize-pixelwise nil)
  (xref-search-program 'ripgrep)
  (zone-all-frames t)            ; EMACS-31
  (zone-all-windows-in-frame t)  ; EMACS-31
  (zone-programs '[zone-pgm-rat-race])
  (grep-command "rg -nS --no-heading ")
  (grep-find-ignored-directories
   '("SCCS" "RCS" "CVS" "MCVS" ".src" ".svn" ".jj" ".git" ".hg" ".bzr" "_MTN" "_darcs" "{arch}" "node_modules" "build" "dist"))
  :config
  ;; Sets outline-mode for the `init.el' file
  (defun emacs-solo/outline-init-file ()
    (when (and (buffer-file-name)
               (string-match-p "init\\.el\\'" (buffer-file-name)))
      (outline-minor-mode 1)
      (declare-function outline-hide-sublevels "")
      (outline-hide-sublevels 1)))
  (when emacs-solo-enable-outline-init
    (declare-function emacs-solo/outline-init-file "")
    (add-hook 'emacs-lisp-mode-hook #'emacs-solo/outline-init-file))

  ;; Make C-x 5 o repeatable
  (defvar-keymap frame-repeat-map
    :repeat t
    "o" #'other-frame
    "n" #'make-frame
    "d" #'delete-frame)
  (put 'other-frame 'repeat-map 'frame-repeat-map)

  ;; Makes everything accept utf-8 as default, so buffers with tsx and so
  ;; won't ask for encoding (because undecided-unix) every single keystroke
  (modify-coding-system-alist 'file "" 'utf-8)

  ;; Setup preferred fonts when present on System
  (declare-function emacs-solo/setup-font "")
  (defun emacs-solo/setup-font ()
    (let* ((emacs-solo-have-default-font (find-font (font-spec :family emacs-solo-preferred-font-name)))
           (size (nth (if (eq system-type 'darwin) 0 1)
                      emacs-solo-preferred-font-sizes)))
      (set-face-attribute 'default nil
                          :family (when emacs-solo-have-default-font
                                    emacs-solo-preferred-font-name)
                          :height size)

      ;; macOS specific fine-tuning
      (when (and (eq system-type 'darwin) emacs-solo-have-default-font)
        ;; Glyphs for powerline/icons
        (set-fontset-font t '(#xe0b0 . #xe0bF) (font-spec :family emacs-solo-preferred-font-name))
        ;; Emojis
        (set-fontset-font t 'emoji (font-spec :family "Apple Color Emoji") nil 'append)
        (add-to-list 'face-font-rescale-alist '("Apple Color Emoji" . 0.8)))))

  ;; Load Preferred Font Setup
  (when emacs-solo-enable-preferred-font
    (emacs-solo/setup-font))

  ;; MacOS specific customizations
  (when (eq system-type 'darwin)
    (setq insert-directory-program "gls")
    (setq mac-command-modifier 'meta))

  ;; We want auto-save, but no #file# cluterring, so everything goes under our config cache/
  ;; (Directories are pre-created by `emacs-solo--ensure-cache-dirs'.)
  (setq auto-save-list-file-prefix (emacs-solo--cache-path 'auto-saves-sessions)
        auto-save-file-name-transforms `((".*" ,(emacs-solo--cache-path 'auto-saves) t)))

  ;; For OSC 52 compatible terminals support
  (defvar xterm-extra-capabilities)
  (setq xterm-extra-capabilities '(getSelection setSelection modifyOtherKeys))

  ;; TERMs should use the entire window space
  (declare-function emacs-solo/disable-global-scrolling-in-ansi-term "")
  (defun emacs-solo/disable-global-scrolling-in-ansi-term ()
    "Disable global scrolling behavior in ansi-term buffers."
    (setq-local scroll-conservatively 101)
    (setq-local scroll-margin 0)
    (setq-local scroll-step 0))
  (add-hook 'term-mode-hook #'emacs-solo/disable-global-scrolling-in-ansi-term)

  (with-eval-after-load 'term
    (define-key term-raw-map (kbd "M-v") 'term-paste))

  ;; TRAMP specific HACKs
  ;; See https://coredumped.dev/2025/06/18/making-tramp-go-brrrr./
  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))

  (connection-local-set-profiles
   '(:application tramp :protocol "scp")
   'remote-direct-async-process)

  (declare-function tramp-compile-disable-ssh-controlmaster-options "")
  (with-eval-after-load 'tramp
    (with-eval-after-load 'compile
      (remove-hook 'compilation-mode-hook #'tramp-compile-disable-ssh-controlmaster-options)))

  (setopt tramp-persistency-file-name (emacs-solo--cache-path 'tramp-persistency-file-name))

  (setopt viper-custom-file-name (emacs-solo--cache-path 'viper-custom-file-name))

  ;; Set line-number-mode with relative numbering
  (setq display-line-numbers-type 'relative)
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (add-hook 'text-mode-hook #'display-line-numbers-mode)

  ;; Starts `completion-preview-mode' automatically in some modes
  (add-hook 'prog-mode-hook #'completion-preview-mode)
  (add-hook 'text-mode-hook #'completion-preview-mode)
  (add-hook 'rcirc-mode-hook #'completion-preview-mode)
  (add-hook 'erc-mode-hook #'completion-preview-mode)

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
                       (mode  . org-mode)
                       (name  . "^\\*Org Src")
                       (name  . "^\\*Org Agenda\\*$")))
           ("tramp"   (name   . "^\\*tramp.*"))
           ("emacs"   (or
                       (name  . "^\\*scratch\\*$")
                       (name  . "^\\*Messages\\*$")
                       (name  . "^\\*Warnings\\*$")
                       (name  . "^\\*Shell Command Output\\*$")
                       (name  . "^\\*Async-native-compile-log\\*$")))
           ("ediff"   (name   . "^\\*[Ee]diff.*"))
           ("vc"      (name   . "^\\*vc-.*"))
           ("dired"   (mode   . dired-mode))
           ("terminal" (or
                        (mode . term-mode)
                        (mode . shell-mode)
                        (mode . eshell-mode)))
           ("help"    (or
                       (name  . "^\\*Help\\*$")
                       (name  . "^\\*info\\*$")))
           ("news"    (name   . "^\\*Newsticker.*"))
           ("gnus"    (or
                       (mode  . message-mode)
                       (mode  . gnus-group-mode)
                       (mode  . gnus-summary-mode)
                       (mode  . gnus-article-mode)
                       (name  . "^\\*Group\\*")
                       (name  . "^\\*Summary\\*")
                       (name  . "^\\*Article\\*")
                       (name  . "^\\*BBDB\\*")))
           ("chat"    (or
                       (mode  . rcirc-mode)
                       (mode  . erc-mode)
                       (name  . "^\\*rcirc.*")
                       (name  . "^\\*ERC.*"))))))

  (add-hook 'ibuffer-mode-hook
            (lambda ()
              (ibuffer-switch-to-saved-filter-groups "default")))
  (setq ibuffer-show-empty-filter-groups nil) ; don't show empty groups


  (defun emacs-solo/filtered-project-buffer-completer (project files-only)
    "A function that filters special buffers and uses `completing-read`."
    (let* ((project-buffers (project-buffers project))
           (filtered-buffers
            (cl-remove-if
             (lambda (buffer)
               (let* ((name (buffer-name buffer))
                      (trimmed-name (string-trim name)))
                 (or
                  (and (> (length trimmed-name) 1)
                       (string-prefix-p "*" trimmed-name)
                       (string-suffix-p "*" trimmed-name))
                  (and files-only (not (buffer-file-name buffer))))))
             project-buffers)))

      (if filtered-buffers
          (let* ((buffer-names (mapcar #'buffer-name filtered-buffers))
                 (selection (completing-read "Switch to project buffer: " buffer-names nil t)))
            (when selection
              (switch-to-buffer selection)))
        (message "No suitable project buffers to switch to."))))
  ;; Tell project.el filter out *special buffers* on `C-x p C-b'
  (setq project-buffers-viewer 'emacs-solo/filtered-project-buffer-completer)


  ;; So eshell git commands open an instance of THIS config of Emacs
  (setenv "GIT_EDITOR" (format "emacs --init-dir=%s " (shell-quote-argument user-emacs-directory)))
  (setenv "JJ_EDITOR" (format "emacs --init-dir=%s " (shell-quote-argument user-emacs-directory)))
  (setenv "EDITOR" (format "emacs --init-dir=%s " (shell-quote-argument user-emacs-directory)))
  (setenv "PAGER" "cat")
  ;; So rebase from eshell opens with a bit of syntax highlight
  (add-to-list 'auto-mode-alist '("/git-rebase-todo\\'" . conf-mode))

  ;; Mute NPM loglevel so it wont interfer with other issued commands like grep
  (setenv "NPM_CONFIG_LOGLEVEL" "silent")

  ;; EMACS-31 Remove this, since new emacs will come with 'e' for editing xref buffers.
  ;; Reference: https://debbugs.gnu.org/cgi/bugreport.cgi?bug=80616
  ;;
  ;; Makes any xref buffer "exportable" to a grep buffer with "E" so you can edit it with "e".
  (defun emacs-solo/xref-to-grep-compilation ()
    "Export the current Xref results to a grep-like buffer (Emacs 30+)."
    (interactive)
    (unless (derived-mode-p 'xref--xref-buffer-mode)
      (user-error "Not in an Xref buffer"))

    (let* ((items (and (boundp 'xref--fetcher)
                       (funcall xref--fetcher)))
           (buf-name "*xref→grep*")
           (grep-buf (get-buffer-create buf-name)))
      (unless items
        (user-error "No xref items found"))

      (with-current-buffer grep-buf
        (let ((inhibit-read-only t))
          (erase-buffer)
          (insert (format "-*- mode: grep; default-directory: %S -*-\n\n"
                          default-directory))
          (dolist (item items)
            (let* ((loc (xref-item-location item))
                   (file (xref-file-location-file loc))
                   (line (xref-file-location-line loc))
                   (summary (xref-item-summary item)))
              (insert (format "%s:%d:%s\n" file line summary)))))
        (grep-mode))
      (pop-to-buffer grep-buf)))
  (with-eval-after-load 'xref
    (define-key xref--xref-buffer-mode-map (kbd "E")
                #'emacs-solo/xref-to-grep-compilation))

  ;; ELISP evaluations show results in an overlay
  (defun emacs-solo/eval-last-sexp-overlay (arg)
    "Eval last sexp and show result inline as overlay.
With prefix ARG, insert the result inline instead.
Use ⇒ if displayable, otherwise fallback to =>."
    (interactive "P")
    (let ((arrow (if (char-displayable-p ?⇒) " ; ⇒ " " ; => ")))
      (if arg
          (let ((value (elisp--eval-last-sexp nil)))
            (insert arrow (format "%S" value)))
        (let* ((value (elisp--eval-last-sexp nil))
               (str (concat arrow (format "%S" value)))
               (ov (make-overlay (point) (point))))
          (overlay-put ov 'after-string
                       (propertize str 'face 'font-lock-comment-face))
          (run-with-timer
           3 nil
           (lambda (o) (delete-overlay o))
           ov)))))
  (global-set-key (kbd "C-x C-e") #'emacs-solo/eval-last-sexp-overlay)

  (defun emacs-solo/copy-whole-word ()
    "Copy the symbol at point to the kill ring without moving point."
    (interactive)
    (let ((bounds (bounds-of-thing-at-point 'symbol)))
      (when bounds
        (kill-ring-save (car bounds) (cdr bounds)))))


  ;; TODO: move this to an emacs-lisp use-package section
  (defun emacs-solo/prefer-spaces ()
    "Disable indent-tabs-mode to prefer spaces over tabs."
    (interactive)
    (setq indent-tabs-mode nil))

  ;; Only override where necessary
  (add-hook 'emacs-lisp-mode-hook #'emacs-solo/prefer-spaces)


  ;; Recenter after save-place restore
  ;; Reference: https://emacsredux.com/blog/2026/04/07/stealing-from-the-best-emacs-configs/
  (advice-add 'save-place-find-file-hook :after
            (lambda (&rest _)
              (when buffer-file-name (ignore-errors (recenter)))))


  ;; Runs 'private.el' after Emacs inits
  (add-hook 'after-init-hook
            (lambda ()
              (let ((private-file (expand-file-name "private.el" user-emacs-directory)))
                (when (file-exists-p private-file)
                  (load private-file)))))

  :init
  ;; Keep margins from automatic resizing
  (defun emacs-solo/set-default-window-margins ()
    "Set default left and right margins for all windows.
Unless the buffer uses `emacs-solo/center-document-mode`
or is an ERC buffer."
    (interactive)
    (dolist (window (window-list))
      (with-current-buffer (window-buffer window)
        (unless (or (bound-and-true-p emacs-solo/center-document-mode)
                    (derived-mode-p 'erc-mode))
          (set-window-margins window 2 0))))) ;; (LEFT RIGHT)

  (add-hook 'window-configuration-change-hook #'emacs-solo/set-default-window-margins)

  (when (>= emacs-major-version 31)
    (tty-tip-mode nil))   ;; EMACS-31
  (tooltip-mode nil)

  (select-frame-set-input-focus (selected-frame))
  (blink-cursor-mode 0)
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


;;; │ ABBREV
;;
;;  A nice resource about it: https://www.rahuljuliato.com/posts/abbrev-mode
(use-package abbrev
  :ensure nil
  :custom
  (save-abbrevs nil)
  :config
  (defun emacs-solo/abbrev--replace-placeholders ()
    "Replace placeholders ###1###, ###2###, ... with minibuffer input.
If ###@### is found, remove it and place point there at the end."
    (let ((cursor-pos nil)) ;; to store where to place point
      (save-excursion
        (goto-char (point-min))
        (let ((loop 0)
              (values (make-hash-table :test 'equal)))
          (while (re-search-forward "###\\([0-9]+\\|@\\)###" nil t)
            (setq loop (1+ loop))
            (let* ((index (match-string 1))
                   (start (match-beginning 0))
                   (end (match-end 0)))
              (cond
               ((string= index "@")
                (setq cursor-pos start)
                (delete-region start end))
               (t
                (let* ((key (format "###%s###" index))
                       (val (or (gethash key values)
                                (let ((input (read-string (format "Value for %s: " key))))
                                  (puthash key input values)
                                  input))))
                  (goto-char start)
                  (delete-region start end)
                  (insert val)
                  (goto-char (+ start (length val))))))))))
      (when cursor-pos
        (goto-char cursor-pos))))

  (define-abbrev-table 'global-abbrev-table
    '(;; Arrows
      ("ra" "→")
      ("la" "←")
      ("ua" "↑")
      ("da" "↓")

      ;; Emojis for context markers
      ("todo"  "👷 TODO:")
      ("fixme" "🔥 FIXME:")
      ("note"  "📎 NOTE:")
      ("hack"  "👾 HACK:")
      ("pinch"  "🤌")
      ("smile"  "😄")
      ("party" "🎉")
      ("up"  "☝️")
      ("applause" "👏")
      ("manyapplauses" "👏👏👏👏👏👏👏👏")
      ("heart" "❤️")

      ;; NerdFonts
      ("nerdfolder" " ")
      ("nerdgit" "")
      ("nerdemacs" "")

      ;; HTML
      ("nb" "&nbsp;")
      ("lt" "&lt;")      ;; <
      ("gt" "&gt;")      ;; >
      ("le" "&le;")      ;; ≤
      ("ge" "&ge;")      ;; ≥
      ("ap" "&apos;")    ;; '
      ("laa" "&laquo;")  ;; «
      ("raa" "&raquo;")  ;; »
      ("co" "&copy;")    ;; ©
      ("tm" "&trade;")   ;; ™
      ("em" "&mdash;")   ;; —
      ("en" "&ndash;")   ;; –
      ("dq" "&quot;")    ;; "
      ("html" "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n  <meta charset=\"UTF-8\">\n  <title>Document</title>\n</head>\n<body>\n\n</body>\n</html>")

      ;; Utils
      ("isodate" ""
       (lambda () (insert (format "%s" (format-time-string "%Y-%m-%dT%H:%M:%S")))))

      ("uuid" ""
       (lambda () (insert (org-id-uuid))))

      ;; Markdown
      ("cb" "```@\n\n```"
       (lambda () (search-backward "@") (delete-char 1)))

      ;; ORG
      ("ocb" "#+BEGIN_SRC @\n\n#+END_SRC"
       (lambda () (search-backward "@") (delete-char 1)))
      ("oheader" "#+TITLE: ###1###\n#+AUTHOR: ###2###\n#+EMAIL: ###3###\n#+OPTIONS: toc:nil\n"
       emacs-solo/abbrev--replace-placeholders)

      ;; JS/TS snippets
      ("imp" "import { ###1### } from '###2###';"
       emacs-solo/abbrev--replace-placeholders)
      ("fn" "function ###1### () {\n ###@### ;\n};"
       emacs-solo/abbrev--replace-placeholders)
      ("clog" "console.log(\">>> LOG:\", { ###@### })"
       emacs-solo/abbrev--replace-placeholders)
      ("cwarn" "console.warn(\">>> WARN:\", { ###@### })"
       emacs-solo/abbrev--replace-placeholders)
      ("cerr" "console.error(\">>> ERR:\", { ###@### })"
       emacs-solo/abbrev--replace-placeholders)
      ("afn" "async function() {\n  \n}"
       (lambda () (search-backward "}") (forward-line -1) (end-of-line)))
      ("ife" "(function() {\n  \n})();"
       (lambda () (search-backward ")();") (forward-line -1) (end-of-line)))
      ("esdeps" "// eslint-disable-next-line react-hooks/exhaustive-deps"
       (lambda () (search-backward ")();") (forward-line -1) (end-of-line)))
      ("eshooks" "// eslint-disable-next-line react-hooks/rules-of-hooks"
       (lambda () (search-backward ")();") (forward-line -1) (end-of-line)))

      ;; React/JSX
      ("rfc" "const ###1### = () => {\n  return (\n    <div>###2###</div>\n  );\n};"
       emacs-solo/abbrev--replace-placeholders))))


;;; │ AUTH-SOURCE
(use-package auth-source
  :ensure nil
  :defer t
  :config
  (setq epg-pinentry-mode 'loopback)
  (setq auth-sources
        (list (expand-file-name ".authinfo.gpg" user-emacs-directory)))
  (setq user-full-name "User Name and Surnames"
        user-mail-address "user@mail.com")

  ;; Use `pass` as an auth-source
  (when (file-exists-p "~/.password-store")
    (auth-source-pass-enable)))


;;; │ AUTO-REVERT
(use-package autorevert
  :ensure nil
  :hook (emacs-startup-hook . global-auto-revert-mode)
  :custom
  (auto-revert-remote-files nil)   ;; t makes tramp slow
  (auto-revert-verbose t)
  (auto-revert-avoid-polling t)
  (global-auto-revert-non-file-buffers t))


;;; │ CONF
(use-package conf-mode
  :ensure nil
  :mode ("\\.env\\..*\\'" "\\.env\\'")
  :init
  (add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode)))


;;; │ COMPILATION
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


;;; │ WINDOW
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
     ("\\*\\(claude:\\|opencode:\\).*\\*"
      (display-buffer-in-side-window)
      (window-width . 100)
      (side . right)
      (slot . 1))
     ("\\*\\(Flymake diagnostics\\|Completions\\)"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 2))
     ("\\*\\(grep\\|xref\\|find\\)\\*"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 1))
     ("\\*\\(M3U Playlist\\)"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 3))
     )))


;;; │ TAB-BAR
(use-package tab-bar
  :ensure nil
  :defer t
  :bind
  (("C-x t <left>" . tab-bar-history-back)
   ("C-x t <right>" . tab-bar-history-forward)
   ("C-x t P" . #'emacs-solo/tab-group-from-project)
   ("C-x t g" . #'emacs-solo/tab-switch-to-group)
   ("C-x t RET" . #'emacs-solo/tab-select-by-number))
  :custom
  (tab-bar-new-tab-choice "*scratch*")
  (tab-bar-close-button-show nil)
  (tab-bar-new-button-show nil)
  (tab-bar-tab-hints t)
  (tab-bar-auto-width nil)
  (tab-bar-separator "")
  (tab-bar-format '(tab-bar-format-tabs-groups
                    tab-bar-separator
                    tab-bar-format-align-right
                    tab-bar-format-global))
  :init
  ;;; --- OPTIONAL INTERNAL FN OVERRIDES TO DECORATE NAMES
  (defun tab-bar-tab-name-format-hints (name tab i)
    (if tab-bar-tab-hints
        (if (eq (car tab) 'current-tab)
        (concat (format "  *%d*  " i) "")
        (concat (format "   %d   " i) ""))
      name))

  (defun tab-bar-tab-group-format-default (tab _i &optional current-p)
    (propertize
     (concat (funcall tab-bar-tab-group-function tab))
     'face (if current-p 'tab-bar-tab-group-current 'tab-bar-tab-group-inactive)))

  (defun emacs-solo/tab-bar-toggle-time ()
    "Enable `display-time-mode' when `tab-bar-mode' is on, disable it otherwise."
    (setq display-time-format "%a. %d %b %H:%M")
    (if tab-bar-mode
        (display-time-mode 1)
      (display-time-mode -1)))

  (add-hook 'tab-bar-mode-hook #'emacs-solo/tab-bar-toggle-time)

  (defun emacs-solo/tab-select-by-number ()
    "Switch to a tab by its hint number."
    (interactive)
    (let ((num (read-number "Tab number: ")))
      (tab-bar-select-tab num)))

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


;;; │ RCIRC
(use-package rcirc
  :ensure nil
  :custom
  (rcirc-debug t)
  (rcirc-default-nick "Lionyx")
  (rcirc-default-user-name "Lionyx")
  (rcirc-log-directory (emacs-solo--cache-path 'rcirc-log-directory))
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


;;; │ ERC
(use-package erc
  :ensure nil
  :defer t
  :custom
  (erc-join-buffer 'window)
  (erc-hide-list '("JOIN" "PART" "QUIT"))
  (erc-timestamp-format "[%H:%M]")
  (erc-autojoin-channels-alist '((".*\\.libera\\.chat" "#emacs" "#systemcrafters")))
  (erc-server-reconnect-attempts 10)
  (erc-server-reconnect-timeout 3)
  (erc-fill-function 'erc-fill-wrap)
  (erc-log-channels-directory (emacs-solo--cache-path 'erc-log-channels-directory))
  (erc-log-insert-log-on-open 'erc-log-new-target-buffer-p) ;; EMACS-31 and or needs https://debbugs.gnu.org/cgi/bugreport.cgi?bug=79665 patch
  (erc-save-buffer-on-part t)
  (erc-save-queries-on-quit t)
  (erc-log-write-after-send t)
  (erc-log-write-after-insert t)
  (erc-spelling-dictionaries '(("Libera.Chat" "en_US")))
  :config
  (defun emacs-solo/erc-get-color-for-nick (nick)
    "Return a Catppuccin Mocha Like color string for NICK based on its hash."
    (let* ((colors '("#f38ba8" "#a6e3a1" "#f9e2af" "#89b4fa"
                     "#cba6f7" "#fab387" "#b4befe" "#eba0ac"
                     "#f5c2e7"))
           (hash (mod (abs (sxhash nick)) (length colors))))
      (nth hash colors)))

  (defun emacs-solo/erc-colorize-nick ()
    "Colorize nicknames in ERC buffer."
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "\\(<\\)\\([^ >]+\\)\\(>\\)" nil t)
        (let* ((nick (match-string 2))
               (color (emacs-solo/erc-get-color-for-nick nick)))
          (put-text-property (match-beginning 2) (match-end 2)
                             'face `(:foreground ,color :weight bold))))))
  (add-hook 'erc-insert-modify-hook #'emacs-solo/erc-colorize-nick)

  (add-to-list 'erc-modules 'log)
  (erc-spelling-mode 1)
  :init
  (with-eval-after-load 'erc

    ;; EMACS-31 (no more dependency between scrolltobottom and erc-fill-wrap THX!!!)
    (when (< emacs-major-version 31)
      (add-to-list 'erc-modules 'scrolltobottom)))

  (setopt erc-sasl-mechanism 'external)

  (defun erc-liberachat ()
    (interactive)

    (with-eval-after-load 'erc
      (add-to-list 'erc-modules 'sasl))

    (let ((buf (erc-tls :server "irc.libera.chat"
                        :port 6697
                        :user "Lionyx"
                        :password ""
                        :client-certificate
                        (list
                         (expand-file-name "cert.pem" user-emacs-directory)
                         (expand-file-name "cert.pem" user-emacs-directory)))))
      (when (bufferp buf)
        (pop-to-buffer buf)))))


;;; │ ICOMPLETE
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
  ;; Patch is now part of EMACS-31 bug#75784 (bug-gnu-emacs).
  ;;
  ;; FIXME: Delete this giant block when new emacs becomes the current
  ;; release
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

    ;; FIXME: make this into PATCH
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
        (with-no-warnings
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
                         nsections nsections-aux)))
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

;;; │ DIRED
(use-package dired
  :ensure nil
  :bind
  (("M-i" . emacs-solo/window-dired-vc-root-left))
  :custom
  (dired-auto-revert-buffer t)
  (dired-dwim-target t)
  (dired-guess-shell-alist-user
   `(("\\.\\(png\\|jpe?g\\|tiff\\)" ,(if (eq system-type 'darwin) "open" "xdg-open"))
     ("\\.\\(mp[34]\\|m4a\\|ogg\\|flac\\|webm\\|mkv\\)" "mpv")
     (".*" ,(if (eq system-type 'darwin) "open" "xdg-open"))))
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-listing-switches "-alh --group-directories-first")
  (dired-omit-files "^\\.")                                ; with dired-omit-mode (C-x M-o)
  (dired-hide-details-hide-absolute-location t)            ; EMACS-31
  (image-dired-dir (emacs-solo--cache-path 'image-dired-dir))
  :init
  (add-hook 'dired-mode-hook (lambda () (dired-omit-mode 1))) ;; Turning this ON also sets the C-x M-o binding.

  (defun emacs-solo/dired-rsync-copy (dest)
    "Copy marked files in Dired to DEST using rsync in an async shell buffer."
    (interactive
     (list (expand-file-name (read-file-name "rsync to: "
                                             (dired-dwim-target-directory)))))
    (let* ((files (dired-get-marked-files nil current-prefix-arg))
           (dest-original dest)
           (dest-rsync
            (if (file-remote-p dest)
                (let* ((vec (tramp-dissect-file-name dest))
                       (user (tramp-file-name-user vec))
                       (host (tramp-file-name-host vec))
                       (path (tramp-file-name-localname vec)))
                  (concat (if user (concat user "@") "")
                          host
                          ":"
                          path))
              dest))
           (files-rsync
            (mapcar
             (lambda (f)
               (if (file-remote-p f)
                   (let ((vec (tramp-dissect-file-name f)))
                     (let ((user (tramp-file-name-user vec))
                           (host (tramp-file-name-host vec))
                           (path (tramp-file-name-localname vec)))
                       (concat (if user (concat user "@") "")
                               host
                               ":"
                               path)))
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
       :filter #'rsync-process-filter
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

  (defun emacs-solo/dired-run-async-on-marked-files (command)
    "Run COMMAND asynchronously on marked files in Dired.
Ex: mpv file1 file2 file3 file4..."
    (interactive "sCommand: ")
    (let ((files (dired-get-marked-files)))
      (start-process-shell-command command nil (format "%s %s" command (mapconcat 'shell-quote-argument files " ")))))


  (eval-after-load 'dired
    '(progn
       ;; Users should navigate with p/n, enter new directories with =, go back with q,
       ;; quit with several q's, only use - to access stuff up on the tree from inicial
       ;; directory.
       (define-key dired-mode-map (kbd "=") 'emacs-solo/window-dired-open-directory)
       (define-key dired-mode-map (kbd "-") 'emacs-solo/window-dired-open-directory-back)
       (define-key dired-mode-map (kbd "#") 'emacs-solo/dired-run-async-on-marked-files)

       ;; A better "BACK" keybiding
       (define-key dired-mode-map (kbd "b") 'dired-up-directory))))


;;; │ WDIRED
(use-package wdired
  :ensure nil
  :commands (wdired-change-to-wdired-mode)
  :config
  (setq wdired-allow-to-change-permissions t)
  (setq wdired-create-parent-directories t))


;;; │ ESHELL
(use-package eshell
  :ensure nil
  :bind
  (("C-c e" . eshell))
  :defer t
  :config
  (setq eshell-history-size 100000)
  (setq eshell-hist-ignoredups t)


  ;; MAKE ALL INSTANCES OF ESHELL SHARE/MERGE ITS COMMAND HISTORY
  ;;
  (defun emacs-solo/eshell--collect-all-history ()
    "Return a list of all eshell history entries from all buffers and disk."
    (let ((history-from-buffers
           (cl-loop for buf in (buffer-list)
                    when (with-current-buffer buf (derived-mode-p 'eshell-mode))
                    append (with-current-buffer buf
                             (when (boundp 'eshell-history-ring)
                               (ring-elements eshell-history-ring)))))
          (history-from-file
           (when (file-exists-p eshell-history-file-name)
             (with-temp-buffer
               (insert-file-contents eshell-history-file-name)
               (split-string (buffer-string) "\n" t)))))
      (seq-uniq (append history-from-buffers history-from-file))))

  (defun emacs-solo/eshell--save-merged-history ()
    "Save all eshell buffer histories merged into `eshell-history-file-name`."
    (let ((all-history (emacs-solo/eshell--collect-all-history)))
      (with-temp-file eshell-history-file-name
        (insert (mapconcat #'identity all-history "\n")))))

  (add-hook 'kill-emacs-hook #'emacs-solo/eshell--save-merged-history)

  (add-hook 'eshell-mode-hook
            (lambda ()
              (eshell-read-history)))


  ;; CUSTOM WELCOME BANNER
  ;;
  (setopt eshell-banner-message
          (concat
           (propertize "   Welcome to the Emacs Solo Shell  \n\n" 'face '(:weight bold :foreground "#f9e2af"))
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


  ;; MAKES C-c l GIVE AN ICOMPLETE LIKE SEARCH TO HISTORY COMMANDS
  ;;
  (defun emacs-solo/eshell-pick-history ()
    "Show a unified and unique Eshell history from all open sessions + history file.
Pre-fills the minibuffer with current Eshell input (from prompt to point)."
    (interactive)
    (unless (derived-mode-p 'eshell-mode)
      (user-error "This command must be called from an Eshell buffer"))
    (let* (;; Safely get current input from prompt to point
           (bol (save-excursion (eshell-bol) (point)))
           (eol (point))
           (current-input (buffer-substring-no-properties bol eol))

           ;; Path to Eshell history file
           (history-file (expand-file-name eshell-history-file-name
                                           eshell-directory-name))

           ;; Read from history file
           (history-from-file
            (when (file-exists-p history-file)
              (with-temp-buffer
                (insert-file-contents-literally history-file)
                (split-string (buffer-string) "\n" t))))

           ;; Read from in-memory Eshell buffers
           (history-from-rings
            (cl-loop for buf in (buffer-list)
                     when (with-current-buffer buf (derived-mode-p 'eshell-mode))
                     append (with-current-buffer buf
                              (when (bound-and-true-p eshell-history-ring)
                                (ring-elements eshell-history-ring)))))

           ;; Deduplicate and sort
           (all-history (reverse
                         (seq-uniq
                          (seq-filter (lambda (s) (and s (not (string-empty-p s))))
                                      (append history-from-rings history-from-file)))))

           ;; Prompt user with current input as initial suggestion
           (selection (completing-read "Eshell History: " all-history
                                       nil t current-input)))

      (when selection
        ;; Replace current input with selected history entry
        (delete-region bol eol)
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

If any special glyph it not displayable, like when on tty, those will
not be rendered.

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

  (defvar emacs-solo/eshell-lambda-symbol (if (char-displayable-p ?λ) "  λ " "  $ ")
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
             (if emacs-solo/eshell-full-prompt-resource-intensive "heavier" "lighter"))
    (when (derived-mode-p 'eshell-mode)
      (eshell-reset)))

  (defvar eshell-solo/color-bg-dark
    (if (eq emacs-solo-use-custom-theme 'catppuccin) "#363a4f" "#212234"))
  (defvar eshell-solo/color-bg-mid
    (if (eq emacs-solo-use-custom-theme 'catppuccin) "#494d64" "#45475a"))
  (defvar eshell-solo/color-fg-user                            "#89b4fa")
  (defvar eshell-solo/color-fg-host                            "#b4befe")
  (defvar eshell-solo/color-fg-dir                             "#a6e3a1")
  (defvar eshell-solo/color-fg-git                             "#f9e2af")

  (defvar emacs-solo/eshell-prompt-glyphs
    '((arrow-left   :noicons ""      :nerd ""  :emoji "")
      (arrow-right  :noicons ""      :nerd ""  :emoji "")
      (success      :noicons "1"     :nerd ""  :emoji "🟢")
      (failure      :noicons "0"     :nerd ""  :emoji "🔴")
      (user-local   :noicons ""      :nerd ""  :emoji "🧙")
      (user-remote  :noicons ""      :nerd ""  :emoji "👽")
      (host-local   :noicons ""      :nerd ""  :emoji "💻")
      (host-remote  :noicons ""      :nerd ""  :emoji "🌐")
      (time         :noicons ""      :nerd ""  :emoji "🕒")
      (folder       :noicons ""      :nerd ""  :emoji "📁")
      (branch       :noicons "Git:"  :nerd ""  :emoji "")
      (modified     :noicons "M"     :nerd " " :emoji "✏️")
      (untracked    :noicons "U"     :nerd " " :emoji "✨")
      (conflict     :noicons "X"     :nerd " " :emoji "⚔️")
      (git-diverged :noicons "D"     :nerd " " :emoji "🔀")
      (git-ahead    :noicons "A"     :nerd " " :emoji "⬆️")
      (git-behind   :noicons "B"     :nerd " " :emoji "⬇️"))
    "Alist of glyphs used in the Eshell prompt, keyed by style.")

  (defun emacs-solo/glyph (name)
    "Look up glyph NAME in `emacs-solo/eshell-prompt-glyphs'.
For the current icon style."
    (let* ((row (assq name emacs-solo/eshell-prompt-glyphs))
           (style (cond
                   ((not (memq 'eshell emacs-solo-icon-modules)) :noicons)
                   ((memq 'nerd emacs-solo-icon-modules)         :nerd)
                   (t                                             :emoji)))
           (val (plist-get (cdr row) style)))
      (if (char-displayable-p (string-to-char val))
          val "")))

  (defvar emacs-solo/git-cache nil)
  (defvar emacs-solo/git-cache-dir nil)
  (defvar emacs-solo/git-cache-time 0)

  (defun emacs-solo/git-info ()
    "Return cached Git info."
    (let ((root (ignore-errors (vc-git-root default-directory)))
          (now (float-time)))
      (if (or (not root)
              (not (numberp emacs-solo/git-cache-time))
              (not emacs-solo/git-cache)
              (not (equal root emacs-solo/git-cache-dir))
              (> (- now (or emacs-solo/git-cache-time 0)) 2)) ;; Only run this once every X secs
          (progn
            (setq emacs-solo/git-cache-time now
                  emacs-solo/git-cache-dir root)
            (setq emacs-solo/git-cache
                  (when root
                    (let* ((out
                            (with-temp-buffer
                              (when (zerop
                                     (process-file
                                      "git" nil (current-buffer) nil
                                      "status" "--porcelain=v2" "--branch"))
                                (buffer-string))))
                           (lines (split-string out "\n" t))
                           (ahead 0)
                           (behind 0)
                           (modified 0)
                           (untracked 0)
                           (conflicts 0)
                           (branch nil))
                      (dolist (l lines)
                        (cond
                         ((string-match "^#? *branch\\.head \\(.+\\)" l)
                          (setq branch (match-string 1 l)))
                         ((string-match "^#? *branch\\.ab \\+\\([0-9]+\\) -\\([0-9]+\\)" l)
                          (setq ahead (string-to-number (match-string 1 l))
                                behind (string-to-number (match-string 2 l))))
                         ((string-match "^1 " l) (cl-incf modified))
                         ((string-match "^\\?" l) (cl-incf untracked))
                         ((string-match "^u " l) (cl-incf conflicts))))
                      (list :branch (or branch "HEAD")
                            :ahead ahead
                            :behind behind
                            :modified modified
                            :untracked untracked
                            :conflicts conflicts)))))
        emacs-solo/git-cache)
      emacs-solo/git-cache))

  (setopt eshell-prompt-function
          (lambda ()
            (if emacs-solo/eshell-full-prompt
                ;; Full-blown prompt
                (concat
                 (propertize
                  (emacs-solo/glyph 'arrow-left) 'face `(:foreground ,eshell-solo/color-bg-dark))

                 (propertize
                  (if (> eshell-last-command-status 0)
                      (concat " " (emacs-solo/glyph 'failure)  " ")
                    (concat " " (emacs-solo/glyph 'success)  " "))
                  'face `(:background ,eshell-solo/color-bg-dark))

                 (propertize (concat (number-to-string eshell-last-command-status) " ")
                             'face `(:background ,eshell-solo/color-bg-dark))

                 (propertize (emacs-solo/glyph 'arrow-right)
                             'face `(:foreground ,eshell-solo/color-bg-dark :background ,eshell-solo/color-bg-mid))

                 (propertize (let ((remote-user (file-remote-p default-directory 'user))
                                   (is-remote (file-remote-p default-directory)))
                               (concat
                                (if is-remote
                                    (concat (emacs-solo/glyph 'user-remote)  " ")
                                  (concat (emacs-solo/glyph 'user-local)  " "))
                                (or remote-user (user-login-name))
                                " "))
                             'face `(:foreground ,eshell-solo/color-fg-user
                                                 :background ,eshell-solo/color-bg-mid))

                 (propertize (emacs-solo/glyph 'arrow-right) 'face
                             `(:foreground ,eshell-solo/color-bg-mid :background ,eshell-solo/color-bg-dark))

                 (let ((remote-host (file-remote-p default-directory 'host))
                       (is-remote (file-remote-p default-directory)))
                   (propertize (concat (if is-remote
                                           (concat " " (emacs-solo/glyph 'host-remote)  " ")
                                         (concat " " (emacs-solo/glyph 'host-local)  " "))
                                       (or remote-host (system-name)) " ")
                               'face `(:background ,eshell-solo/color-bg-dark  :foreground ,eshell-solo/color-fg-host)))

                 (propertize (emacs-solo/glyph 'arrow-right) 'face
                             `(:foreground ,eshell-solo/color-bg-dark :background ,eshell-solo/color-bg-mid))

                 (propertize (concat " " (emacs-solo/glyph 'time)  " "
                                     (format-time-string "%H:%M:%S" (current-time)) " ")
                             'face `(:foreground ,eshell-solo/color-fg-user :background ,eshell-solo/color-bg-mid))

                 (propertize (emacs-solo/glyph 'arrow-right)
                             'face `(:foreground ,eshell-solo/color-bg-mid :background ,eshell-solo/color-bg-dark))

                 (propertize (concat " " (emacs-solo/glyph 'folder)  " "
                                     (if (>= (length (eshell/pwd)) 40)
                                         (concat "…" (car (last (butlast (split-string (eshell/pwd) "/") 0))))
                                       (abbreviate-file-name (eshell/pwd))) " ")
                             'face `(:background ,eshell-solo/color-bg-dark :foreground ,eshell-solo/color-fg-dir))

                 (propertize (concat (emacs-solo/glyph 'arrow-right) "\n")
                             'face `(:foreground ,eshell-solo/color-bg-dark))

                 (when-let* ((branch
                              (cond
                               ((fboundp 'vc-git-working-branch)  ; >= EMACS 31
                                (vc-git-working-branch))
                               ((fboundp 'vc-git--current-branch) ; < EMACS 31
                                (vc-git--current-branch)))))
                   (concat
                    (propertize (emacs-solo/glyph 'arrow-left)
                                'face `(:foreground ,eshell-solo/color-bg-dark))
                    (propertize
                     (concat
                      (concat " " (emacs-solo/glyph 'branch) " " branch " ")
                      (when emacs-solo/eshell-full-prompt-resource-intensive
                        (let* ((info (emacs-solo/git-info))
                               (ahead (plist-get info :ahead))
                               (behind (plist-get info :behind))
                               (modified (plist-get info :modified))
                               (untracked (plist-get info :untracked))
                               (conflicts (plist-get info :conflicts)))
                          (concat
                           (when (> ahead 0)
                             (format (concat " " (emacs-solo/glyph 'git-ahead) "%d") ahead))
                           (when (> behind 0)
                             (format (concat " " (emacs-solo/glyph 'git-behind) "%d") behind))
                           (when (and (> ahead 0) (> behind 0))
                             (concat " " (emacs-solo/glyph 'git-diverged)))
                           (when (> modified 0)
                             (format (concat " " (emacs-solo/glyph 'modified) "%d") modified))
                           (when (> untracked 0)
                             (format (concat " " (emacs-solo/glyph 'untracked) "%d") untracked))
                           (when (> conflicts 0)
                             (format (concat " " (emacs-solo/glyph 'conflict) "%d") conflicts))
                           " "))))
                     'face `(:background ,eshell-solo/color-bg-dark :foreground ,eshell-solo/color-fg-git))
                    (propertize (concat (emacs-solo/glyph 'arrow-right) "\n")
                                'face `(:foreground ,eshell-solo/color-bg-dark))))

                 (propertize emacs-solo/eshell-lambda-symbol 'face 'font-lock-keyword-face))

              ;; Minimal prompt
              (propertize emacs-solo/eshell-lambda-symbol 'face 'font-lock-keyword-face))))


  (setq eshell-prompt-regexp emacs-solo/eshell-lambda-symbol)


  ;; SET TERM ENV SO MOST PROGRAMS WON'T COMPLAIN
  ;;
  (add-hook 'eshell-mode-hook (lambda () (setenv "TERM" "xterm-256color")))


  (setq eshell-visual-subcommands
        '(("podman" "run" "exec" "attach" "top" "logs" "stats" "compose")
          ("docker" "run" "exec" "attach" "top" "logs" "stats" "compose")
          ("jj" "resolve" "squash" "split")))

  (setq eshell-visual-commands
        '("vi" "screen" "top"  "htop" "btm" "less" "more" "lynx" "ncftp" "pine" "tin" "trn"
          "elm" "irssi" "nmtui-connect" "nethack" "vim" "alsamixer" "nvim" "w3m" "psql"
          "lazygit" "lazydocker" "ncmpcpp" "newsbeuter" "nethack" "mutt" "neomutt" "tmux"
          "jqp")))


;;; │ ISEARCH
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


;;; │ VC
(use-package vc
  :ensure nil
  :defer nil
  :config
  (setopt
   vc-auto-revert-mode t                    ; EMACS-31
   vc-allow-rewriting-published-history t   ; EMACS-31
   vc-git-diff-switches '("--patch-with-stat" "--histogram")  ;; add stats to `git diff'
   vc-git-log-switches '("--stat")                            ;; add stats to `git log'
   vc-git-log-edit-summary-target-len 50
   vc-git-log-edit-summary-max-len 70
   vc-git-print-log-follow t
   vc-git-revision-complete-only-branches nil
   vc-git-show-stash 0                                        ;; do not polute vc-dir with stash lines
   vc-annotate-display-mode 'scale
   add-log-keep-changes-together t
   vc-dir-hide-up-to-date-on-revert t       ; EMACS-31
   vc-make-backup-files nil)                                  ;; do not backup version controlled files

  (with-eval-after-load 'vc-annotate
    (setopt vc-annotate-color-map
            '((20 . "#c3e88d")
              (40 . "#89ddff")
              (60 . "#82aaff")
              (80 . "#676e95")
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
      "Execute a Git command with VERB as action and FN as operations."
      (let* ((fileset (vc-deduce-fileset t)) ;; Deduce fileset
             (backend (car fileset))
             (files (nth 1 fileset)))
        (if (eq backend 'Git)
            (progn
              (funcall fn files)
              (message "%s %d file(s)." verb (length files)))
          (message "Not in a VC Git buffer."))))

    (defun emacs-solo/vc-git-add (&optional _revision _vc-fileset _comment)
      (interactive "P")
      (emacs-solo/vc-git-command "Staged" 'vc-git-register))

    (defun emacs-solo/vc-git-reset (&optional _revision _vc-fileset _comment)
      (interactive "P")
      (emacs-solo/vc-git-command "Unstaged"
                                 (lambda (files) (vc-git-command nil 0 files "reset" "-q" "--")))))


  (defun emacs-solo/vc-git-visualize-status ()
    "Show the Git status of files in the `vc-log` buffer."
    (interactive)
    (let* ((fileset (vc-deduce-fileset t))
           (backend (car fileset)))
      (if (eq backend 'Git)
          (let ((output-buffer "*Git Status*"))
            (with-current-buffer (get-buffer-create output-buffer)
              (read-only-mode -1)
              (erase-buffer)
              ;; Capture the raw output including colors using 'git status --color=auto'
              (call-process "git" nil output-buffer nil "status" "-v")
              (pop-to-buffer output-buffer)))
        (message "Not in a VC Git buffer."))))


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


  (defun emacs-solo/vc-pull-merge-current-branch ()
    "Pull the from origin for the current branch and display output in a buffer."
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


  (defun emacs-solo/vc-diff-on-current-hunk ()
    "Open diff jumping to the current hunk."
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


  (defun emacs-solo/switch-git-status-buffer ()
    "Switch to a buffer visiting a modified or renamed file in the current Git repo.
The completion candidates include the Git status of each file."
    (interactive)
    (require 'vc-git)
    (let ((repo-root (vc-git-root default-directory)))
      (if (not repo-root)
          (message "Not inside a Git repository.")
        (let* ((expanded-root (expand-file-name repo-root))
               (cmd-output (vc-git--run-command-string nil "status" "--porcelain=v1"))
               (target-files
                (let (files)
                  (dolist (line (split-string cmd-output "\n" t) (nreverse files))
                    (when (>= (length line) 3)
                      (let ((status (substring line 0 2))
                            (path-info (substring line 3)))
                        (cond
                         ;; Renamed files
                         ((string-prefix-p "R" status)
                          (let* ((paths (split-string path-info " -> " t))
                                 (new-path (cadr paths)))
                            (when new-path
                              (push (cons (format "R %s" new-path) new-path) files))))
                         ;; Modified or untracked
                         ((or (string-match "M" status)
                              (string-match "\\?\\?" status))
                          (push (cons (format "%s %s" status path-info) path-info) files)))))))))
          (if (null target-files)
              (message "No modified or renamed files found.")
            (let* ((candidates target-files)
                   (selection (completing-read "Switch to buffer (Git modified): "
                                               (mapcar #'car candidates) nil t)))
              (when selection
                (let ((file-path (cdr (assoc selection candidates))))
                  (when file-path
                    (find-file (expand-file-name file-path expanded-root)))))))))))


  ;; For *vc-dir* buffer:
  (with-eval-after-load 'vc-dir
    (define-key vc-dir-mode-map (kbd "S") #'emacs-solo/vc-git-add)
    (define-key vc-dir-mode-map (kbd "U") #'emacs-solo/vc-git-reset)
    (define-key vc-dir-mode-map (kbd "V") #'emacs-solo/vc-git-visualize-status)
    ;; Bind g to hide up to date files after refreshing in vc-dir

    ;; NOTE: this won't be needed once EMACS-31 gets released: vc-dir-hide-up-to-date-on-revert does that
    (define-key vc-dir-mode-map (kbd "g")
                (lambda () (interactive) (vc-dir-refresh) (vc-dir-hide-up-to-date))))


  ;; For C-x v ... bindings:
  (define-key vc-prefix-map (kbd "S") #'emacs-solo/vc-git-add)
  (define-key vc-prefix-map (kbd "U") #'emacs-solo/vc-git-reset)
  (define-key vc-prefix-map (kbd "V") #'emacs-solo/vc-git-visualize-status)
  (define-key vc-prefix-map (kbd "R") #'emacs-solo/vc-git-reflog)
  (define-key vc-prefix-map (kbd "B") #'emacs-solo/vc-browse-remote)
  (define-key vc-prefix-map (kbd "o") #'(lambda () (interactive) (emacs-solo/vc-browse-remote 1)))
  (define-key vc-prefix-map (kbd "=") #'emacs-solo/vc-diff-on-current-hunk)

  ;; Switch-buffer between modified files
  (global-set-key (kbd "C-x C-g") 'emacs-solo/switch-git-status-buffer))


;;; │ SMERGE
(use-package smerge-mode
  :ensure nil
  :bind (:map smerge-mode-map
              ("C-c C-s C-u" . smerge-keep-upper)
              ("C-c C-s C-l" . smerge-keep-lower)
              ("C-c C-s C-n" . smerge-next)
              ("C-c C-s C-p" . smerge-prev)))

;;; │ DIFF
(use-package diff-mode
  :ensure nil
  :defer t
  :bind (:map diff-mode-map
              ("M-o" . other-window))
  :config
  (setq diff-default-read-only t)
  (setq diff-advance-after-apply-hunk t)
  (setq diff-update-on-the-fly t)
  (setq diff-font-lock-syntax 'hunk-also)
  (setq diff-font-lock-prettify nil))

;;; │ EDIFF
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

;;; │ ELDOC
(use-package eldoc
  :ensure nil
  :custom
  (eldoc-help-at-pt t) ;; EMACS-31
  (eldoc-echo-area-use-multiline-p nil)
  (eldoc-echo-area-prefer-doc-buffer t)
  (eldoc-documentation-strategy 'eldoc-documentation-compose)
  :init
  (global-eldoc-mode))

;;; │ EGLOT
(use-package eglot
  :ensure nil
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0) ;; EMACS-31 -- do we still need it?
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
    (unless (memq major-mode '(emacs-lisp-mode lisp-mode))
      (eglot-ensure)))

  (add-hook 'prog-mode-hook #'emacs-solo/eglot-setup)

  (with-eval-after-load 'eglot
    (add-to-list
     'eglot-server-programs
     '((ruby-mode ruby-ts-mode) "ruby-lsp")))

  (with-eval-after-load 'eglot
    (add-to-list
     'eglot-server-programs
     '((tsx-ts-mode typescript-ts-mode js-mode js-jsx-mode js-ts-mode)
       . ("rass"
          "--"
          "typescript-language-server" "--stdio"
          "--"
          "eslint-lsp" "--stdio"
          "--"
          "tailwindcss-language-server" "--stdio"))))

  :bind (:map
         eglot-mode-map
         ("C-c l a" . eglot-code-actions)
         ("C-c l o" . eglot-code-action-organize-imports)
         ("C-c l r" . eglot-rename)
         ("C-c l i" . eglot-inlay-hints-mode)
         ("C-c l f" . eglot-format)))

;;; │ FLYMAKE
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


;;; │ FLYSPELL
(use-package flyspell
  :ensure nil
  :defer t
  :config
  (setq ispell-program-name "aspell")
  (setq ispell-dictionary "en_US")
  (ispell-set-spellchecker-params)
  ;; :hook
  ;; ((text-mode-hook . flyspell-mode)
  ;;  (prog-mode-hook . flyspell-prog-mode))
  )


;;; │ WHITESPACE
(use-package whitespace
  :ensure nil
  :defer t
  :hook (before-save-hook . whitespace-cleanup)
  :init
  (defun emacs-solo/toggle-whitespace-cleanup-on-save ()
    "Toggle whitespace-cleanup on save."
    (interactive)
    (if (memq #'whitespace-cleanup before-save-hook)
        (progn
          (remove-hook 'before-save-hook #'whitespace-cleanup)
          (message "Whitespace cleanup on save turned OFF"))
      (add-hook 'before-save-hook #'whitespace-cleanup)
      (message "Whitespace cleanup on save turned ON")))
  (global-set-key (kbd "C-c t w") #'emacs-solo/toggle-whitespace-cleanup-on-save))


;;; │ GNUS
(use-package gnus
  :ensure nil
  :defer t
  :custom
  (gnus-mode-line-logo nil)
  (gnus-init-file (concat user-emacs-directory ".gnus.el"))
  (gnus-startup-file (concat user-emacs-directory ".newsrc"))
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
  (gnus-summary-line-format "%U %R %z : %[%d%] %4{ %-34,34n%} %3{ %}%(%1{%B%}%s%)\12")
  (gnus-user-date-format-alist '((t . "%d-%m-%Y %H:%M")))
  (gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references)
  (gnus-sum--tree-indent " ")
  (gnus-sum-thread-tree-indent " ")
  (gnus-sum-thread-tree-false-root "○ ")
  (gnus-sum-thread-tree-single-indent "◎ ")
  (gnus-sum-thread-tree-leaf-with-other "├► ")
  (gnus-sum-thread-tree-root "● ")
  (gnus-sum-thread-tree-single-leaf "╰► ")
  (gnus-sum-thread-tree-vertical "│")
  (gnus-select-method '(nnnil nil))
  (gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")
  (gnus-secondary-select-methods
   '((nntp "news.gwene.org")))
  :hook
  (gnus-group-mode-hook . gnus-topic-mode)
  :init
  (run-at-time 1 nil (lambda () (setq gnus-logo-colors '("#676e95")))))


;;; │ MAN
(use-package man
  :ensure nil
  :commands (man)
  :config
  (setq Man-notify-method 'pushy)) ; does not obey `display-buffer-alist'


;;; │ MINIBUFFER
(use-package minibuffer
  :ensure nil
  :custom
  (completion-auto-help t)
  (completion-auto-select 'second-tab)
  (completion-eager-update t)               ;; EMACS-31
  (completion-eager-display 'auto)          ;; EMACS-31 (if not using icomplete, t is way cooler)
  (minibuffer-visible-completions 'up-down) ;; EMACS-31
  (completion-ignore-case t)
  (completion-show-help nil)
  (completion-styles '(partial-completion flex initials))
  (completions-format 'one-column)
  (completions-max-height nil)
  (completions-sort 'historical)
  (enable-recursive-minibuffers t)
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case t)
  :config
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

  ;; Keep the cursor out of the read-only portions of theminibuffer
  (setq minibuffer-prompt-properties
        '(read-only t intangible t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Keep minibuffer lines unwrapped, long lines like on M-S-y will be truncated
  (add-hook 'minibuffer-setup-hook
            (lambda () (setq truncate-lines t)))


  (defun emacs-solo/setup-simple-orderless ()
    (defun simple-orderless-completion (string table pred _point)
      "Enhanced orderless completion with better partial matching.
As seen on: https://emacs.dyerdwelling.family/emacs/20250604085817-emacs--building-your-own-orderless-style-completion-in-emacs-lisp/"
      (let* ((words (split-string string "[-, ]+")))
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


  (minibuffer-depth-indicate-mode 1)
  (minibuffer-electric-default-mode 1))


;;; │ NEWSTICKER

;; NOTE: I dislike the default icons, so I override them with this:
;;
;; 1. Globally disable images for all tree-widgets.
;; This forces the widget to use the text-based :tag for icons.
(setq tree-widget-image-enable nil)

;; 2. Redefine the widgets to use your desired text tags.
;; This code will run after the respective files are loaded,
;; replacing the default definitions.
(eval-after-load 'tree-widget
  '(progn
     (define-widget 'tree-widget-open-icon 'tree-widget-icon
       "Icon for an expanded tree-widget node (customized)."
       :tag        "▼ ")
     (define-widget 'tree-widget-close-icon 'tree-widget-icon
       "Icon for a collapsed tree-widget node (customized)."
       :tag        "▶ ")
     (define-widget 'tree-widget-empty-icon 'tree-widget-icon
       "Icon for an expanded tree-widget node with no child."
       :tag        "▼ ")
     (define-widget 'tree-widget-leaf-icon 'tree-widget-icon
       "Icon for a tree-widget leaf node."
       :tag        "")
     (define-widget 'tree-widget-guide 'item
       "Vertical guide line."
       :tag       " "
       :format    "%t")
     (define-widget 'tree-widget-nohandle-guide 'item
       "Vertical guide line, when there is no handle."
       :tag       " "
       :format    "%t")
     (define-widget 'tree-widget-end-guide 'item
       "End of a vertical guide line."
       :tag       " "
       :format    "%t")
     (define-widget 'tree-widget-no-guide 'item
       "Invisible vertical guide line."
       :tag       "  "
       :format    "%t")
     (define-widget 'tree-widget-handle 'item
       "Horizontal guide line that joins a vertical guide line to a node."
       :tag       ""
       :format    "%t")
     (define-widget 'tree-widget-no-handle 'item
       "Invisible handle."
       :tag       " "
       :format    "%t")))

(eval-after-load 'newst-treeview
  '(define-widget 'newsticker--tree-widget-leaf-icon 'tree-widget-icon
     "Icon for a newsticker leaf node (customized)."
     :tag (if (memq 'nerd emacs-solo-icon-modules) "  " "> ")))


;; FIXME: There's a bug on newsticker when using newsticker-treeview,
;;        you hit 'f' and the focus is on the tree, while the
;;        newsticker--treeview-render-text receives positions from
;;        another buffer, this way it fails to try to render html.
;;        As this is harmless, we are silently ignoring it.
(with-eval-after-load 'newst-treeview
  (defun emacs-solo/newsticker-silence-html-messages (orig-fun &rest args)
    "Silence all messages and errors from ORIG-FUN."
    (let ((inhibit-message t)      ;; no `message`
          (message-log-max nil))   ;; do not write to *Messages*
      (condition-case nil
          (apply orig-fun args)    ;; run function normally
        (error nil))))             ;; swallow any error silently
  (advice-add 'newsticker--treeview-render-text :around
              #'emacs-solo/newsticker-silence-html-messages))

(use-package newsticker
  :ensure nil
  :defer t
  :custom
  (newsticker-retrieval-interval 0) ;; Only fetches when first opening (avoids unwanted fetching/ui locking while doing other things later)
  (newsticker-treeview-treewindow-width 40)
  (newsticker-dir (emacs-solo--cache-path 'newsticker-dir))
  (newsticker-retrieval-method (if (executable-find "wget") 'extern 'intern))
  (newsticker-wget-arguments
   '("--quiet"
     "--no-hsts"
     "--output-document=-"
     "--append-output=/dev/null"))
  :hook
  (newsticker-treeview-mode-hook
   . (lambda ()
       (dolist (map '(newsticker-treeview-mode-map
                      newsticker-treeview-list-mode-map
                      newsticker-treeview-item-mode-map))
         (let ((kmap (symbol-value map)))
           (define-key kmap (kbd "X") (lambda () (interactive) (delete-process "mpv-video")))
           (define-key kmap (kbd "T") #'emacs-solo/show-yt-thumbnail)
           (define-key kmap (kbd "S") #'emacs-solo/fetch-yt-subtitles-to-buffer)
           (define-key kmap (kbd "G") #'emacs-solo/newsticker-summarize-yt-video)
           (define-key kmap (kbd "A") (lambda () (interactive) (emacs-solo/newsticker-play-yt-video-from-buffer t)))
           (define-key kmap (kbd "V") #'emacs-solo/newsticker-play-yt-video-from-buffer)
           (define-key kmap (kbd "E") #'emacs-solo/newsticker-eww-current-article)))))
  :init
  (defun emacs-solo/newsticker-clear-cache ()
    "Clears newsticker cache."
    (interactive)
    (require 'newsticker)
    (when (file-directory-p newsticker-dir)
      (delete-directory newsticker-dir t)))

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

  (defun emacs-solo/fetch-yt-subtitles-to-buffer ()
    "Fetch YouTube subtitles with original auto-subs and display in buffer."
    (interactive)
    (let ((window (get-buffer-window "*Newsticker Item*" t)))
      (if window
          (progn
            (select-window window)
            (message "Loading subtitles...")
            (save-excursion
              (goto-char (point-min))
              (when (re-search-forward "^\\* videoId: \\([^ \n]+\\)" nil t)
                (let* ((video-id (match-string 1))
                       (video-url (format "https://www.youtube.com/watch?v=%s" video-id))
                       (temp-dir (make-temp-file "emacs-yt-subs-" t "/"))
                       (buffer-name (format "*YT Subtitles: %s*" video-id)))

                  ;; Create temp directory and buffer
                  (make-directory temp-dir t)
                  (with-current-buffer (get-buffer-create buffer-name)
                    (erase-buffer)
                    (special-mode)
                    (setq buffer-read-only t)
                    (setq-local truncate-lines t)
                    (let ((map (make-sparse-keymap)))
                      (set-keymap-parent map special-mode-map)
                      (define-key map (kbd "q") (lambda ()
                                                  (interactive)
                                                  (let ((win (get-buffer-window)))
                                                    (when (window-live-p win)
                                                      (quit-window 'kill win)))))
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
                         (delete-directory temp-dir t)))))))))

        (message "No *Newsticker Item* buffer found."))))

  ;; Override this variable on your customizations to other prompts
  (setq  emacs-solo-newsticker-summarize-yt-video-prompt  "please, summarize this youtube video transcript in english")


  ;; FIXME: I'd like this to be mostly not dependent on BASH, like the "S" for Subtitles function....
  (defun emacs-solo/newsticker-summarize-yt-video ()
    "Summarize a YT video."
    (interactive)
    (let ((newsticker-buf (get-buffer "*Newsticker Item*")))
      (unless newsticker-buf
        (user-error "No *Newsticker Item* buffer found"))

      (with-current-buffer newsticker-buf
        (save-excursion
          (goto-char (point-min))
          (unless (re-search-forward "^\\* videoId: \\([^ \n]+\\)" nil t)
            (user-error "No videoId found in *Newsticker Item* buffer"))

          (let* ((video-id (match-string 1))
                 (video-url (format "https://www.youtube.com/watch?v=%s" video-id))
                 (output-buffer (get-buffer-create (format "*YT Summary: %s*" video-id)))
                 (prompt emacs-solo-newsticker-summarize-yt-video-prompt)
                 (base-path (emacs-solo--cache-path 'yt-subs))
                 (command
                  (format
                   (concat
                    ;; Use trap for robust cleanup, replacing the two `rm` commands in the original.
                    "trap 'rm -f %s*' EXIT; "
                    ;; Use the exact yt-dlp flags from the newsbeuter command (--convert-subs lrc, etc).
                    "yt-dlp --write-auto-subs --sub-lang '.*-orig' --convert-subs lrc --skip-download --no-clean-infojson -o %s %s >/dev/null 2>&1 && "
                    ;; Cat the globbed path (to find the .lrc file) and use the LRC-specific sed command.
                    "cat %s* | "
                    "sed 's/\\[[^\\]]*\\]//g' | "
                    "grep -v '^[[:space:]]*$' | "
                    "uniq | "
                    "(echo '%s'; cat -) | "
                    "claude -p --model haiku -")
                    ;; "gemini --extensions none --model \"gemini-2.5-flash\" -p -")
                   (shell-quote-argument base-path)      ;; For trap
                   (shell-quote-argument base-path)      ;; For yt-dlp's -o
                   (shell-quote-argument video-url)      ;; The video URL
                   (shell-quote-argument base-path)      ;; For cat
                   prompt)))                             ;; For the echo command

            (message "Generating summary for %s..." video-id)

            (with-current-buffer output-buffer
              (let ((inhibit-read-only t))
                (erase-buffer)
                (insert (format "* Generating summary for %s...\nThis may take a moment.\n\n\n" video-url))
                (display-buffer (current-buffer))
                (select-window (get-buffer-window (current-buffer)))
                (special-mode)
                (visual-line-mode 1)
                (when (fboundp 'markdown-ts-mode)
                  (markdown-ts-mode)
                  (display-line-numbers-mode -1)
                  (visual-line-mode 1))
                (let ((map (make-sparse-keymap)))
                  (define-key map (kbd "q")
                              (lambda ()
                                (interactive)
                                (let ((win (get-buffer-window)))
                                  (when (window-live-p win)
                                    (quit-window 'kill win)))))
                  (define-key map (kbd "n") #'forward-line)
                  (define-key map (kbd "p") #'previous-line)
                  (use-local-map map))
                (let ((shell-file-name "bash"))
                  (start-process-shell-command "yt-summary" (current-buffer) command)))))))))

  (defun emacs-solo/show-yt-thumbnail ()
    "Show YouTube thumbnail from a videoId in the current buffer."
    (interactive)
    (let ((window (get-buffer-window "*Newsticker Item*" t)))
      (if window
          (progn
            (select-window window)
            (save-excursion
              (goto-char (point-min))
              (when (re-search-forward "^\\* videoId: \\([^ \n]+\\)" nil t)
                (let* ((video-id (match-string 1))
                       (thumb-url (format "https://img.youtube.com/vi/%s/sddefault.jpg" video-id))
                       (thumb-buffer-name (format "*YT Thumbnail: %s*" video-id)))

                  ;; Try to fetch the video thumbnail
                  (url-retrieve
                   thumb-url
                   (lambda (_status)
                     (goto-char (point-min))
                     (re-search-forward "\n\n") ;; Skip headers
                     (let* ((image-data (buffer-substring (point) (point-max)))
                            (img (create-image image-data nil t :scale 1.0)))

                       ;; Create temp buffer
                       (with-current-buffer (get-buffer-create thumb-buffer-name)
                         (read-only-mode -1)
                         (erase-buffer)
                         (insert-image img)
                         (insert (format "\n\nVideo ID: %s\n" video-id))
                         (special-mode)
                         (let ((map (make-sparse-keymap)))
                           (define-key map (kbd "q")
                                       (lambda ()
                                         (interactive)
                                         (let ((win (get-buffer-window)))
                                           (when (window-live-p win)
                                             (quit-window 'kill win)))))
                           (use-local-map map))
                         (display-buffer (current-buffer))
                         (select-window (get-buffer-window (current-buffer))))))
                   nil t)))))

        (message "No *Newsticker Item* buffer found."))))


  (defun emacs-solo/newsticker-play-yt-video-from-buffer (&optional no-video)
    "Focus the window showing '*Newsticker Item*' and play the video."
    (interactive "P")
    (let ((window (get-buffer-window "*Newsticker Item*" t)))
      (if window
          (progn
            (select-window window)
            (save-excursion
              (goto-char (point-min))
              (when (re-search-forward "^\\* videoId: \\([^ \n]+\\)" nil t)
                (let ((video-id (match-string 1)))
                  (apply #'start-process "mpv-video" nil "mpv"
                         (append (if no-video
                                     '("--no-video")
                                   '("--autofit=400" "--geometry=-0+100" "--ontop"))
                                 (list (format "https://www.youtube.com/watch?v=%s" video-id))))
                  (message "Playing with mpv: %s" video-id)))))

        (message "No window showing *Newsticker Item* buffer."))))

  (defun emacs-solo/newsticker-eww-current-article ()
    "Open the news item at point in EWW in the same window."
    (interactive)
    (with-current-buffer (newsticker--treeview-list-buffer)
      (let ((url (get-text-property (point) :nt-link)))
        (when url
          (eww url)
          (switch-to-buffer (get-buffer "*eww*")))))))


;;; │ ELECTRIC-PAIR
(use-package electric-pair
  :ensure nil
  :defer
  :hook (after-init-hook . electric-pair-mode))

;;; │ PAREN
(use-package paren
  :ensure nil
  :hook (after-init-hook . show-paren-mode)
  :custom
  (show-paren-delay 0)
  (show-paren-style 'mixed)
  (show-paren-context-when-offscreen t)) ;; show matches within window splits

;;; │ PROCED
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

;;; │ ORG
(use-package org
  :ensure nil
  :defer t
  :mode ("\\.org\\'" . org-mode)
  :config
  (setopt org-export-backends '(ascii html icalendar latex odt md))
  (setq
   ;; Start collapsed for speed
   org-startup-folded t

   ;; Edit settings
   org-hide-leading-stars t
   org-auto-align-tags nil
   org-tags-column 0
   org-fold-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t

   ;; Org styling, hide markup etc.
   org-hide-emphasis-markers t
   org-pretty-entities t
   org-use-sub-superscripts nil ;; We want the above but no _ subscripts ^ superscripts

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
  (set-face-attribute 'org-ellipsis nil :inherit 'default :box nil)


  ;; Keywords
  ;; As seen in https://github.com/gregnewman/gmacs/blob/master/gmacs.org
  (setq org-todo-keywords
        (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)" "PROJECTDONE(e)")
                (sequence "WAITING(w@/!)" "SOMEDAY(s@/!)" "|" "CANCELLED(c@/!)"))))
  (setq org-todo-keyword-faces
        (quote (("TODO" :foreground "lime green" :weight bold)
                ("NEXT" :foreground "cyan" :weight bold)
                ("DONE" :foreground "dim gray" :weight bold)
                ("PROJECTDONE" :foreground "dim gray" :weight bold)
                ("WAITING" :foreground "tomato" :weight bold)
                ("SOMEDAY" :foreground "magenta" :weight bold)
                ("CANCELLED" :foreground "dim gray" :weight bold))))

  ;; Anytime a task is marked done the line states `CLOSED: [timestamp]
  (setq org-log-done 'time)

  ;; Load babel only when org loads
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((python . t)
       (js . t)
       (emacs-lisp . t)
       (org . t)
       (shell . t)))
    (setq org-confirm-babel-evaluate nil))


;;; │ SPEEDBAR
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
  (speedbar-update-flag nil)
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

;;; │ TIME
(use-package time
  :ensure nil
  ;; :hook (after-init-hook . display-time-mode) ;; If we'd like to see it on the mode-line
  :custom
  (world-clock-time-format "%A %d %B %r %Z")
  (world-clock-sort-order "%FT%T") ; EMACS-31
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


;;; │ UNIQUIFY
(use-package uniquify
  :ensure nil
  :config
  (setq uniquify-buffer-name-style 'forward)
  (setq uniquify-strip-common-suffix t)
  (with-no-warnings
    (setq uniquify-after-kill-buffer-p t)
    (setq uniquify-after-kill-buffer-flag t))) ;; EMACS-31 keep this one, delete the one above


;;; │ WHICH-KEY
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


;;; │ WEBJUMP
(use-package webjump
  :defer t
  :ensure nil
  :bind ("C-x /" . webjump)
  :custom
  (webjump-sites
   '(("DuckDuckGo" . [simple-query "https://www.duckduckgo.com" "https://www.duckduckgo.com/?q=" ""])
     ("DuckDuckAI" . [simple-query "https://duck.ai" "https://duck.ai/?q=" ""])
     ("Google"     . [simple-query "https://www.google.com" "https://www.google.com/search?q=" ""])
     ("YouTube"    . [simple-query "https://www.youtube.com/feed/subscriptions" "https://www.youtube.com/results?search_query=" ""])
     ("Claude"     . [simple-query "https://claude.ai/new" "https://claude.ai/new?q=" ""])
     ("ChatGPT"    . [simple-query "https://chatgpt.com" "https://chatgpt.com/?q=" ""]))))



;;; ├──────────────────── COMMON LISP
;;  │
;;  │ Built-in CL env (no SLY/SWANK). No debugger restarts, inspector or cross-refs.
;;  │
;;; │ INFERIOR-LISP
(use-package inf-lisp
  :ensure nil
  :defer t
  :custom
  (inferior-lisp-program "sbcl")
  :bind (:map lisp-mode-map
              ("C-c C-z" . emacs-solo/switch-to-lisp)
              ("C-c C-c" . lisp-eval-defun)
              ("C-c C-r" . lisp-eval-region)
              ("C-c C-e" . lisp-eval-last-sexp)
              ("C-c C-l" . lisp-load-file)
              ("C-c C-k" . emacs-solo/lisp-compile-file))
  :config
  (defun emacs-solo/switch-to-lisp ()
    "Switch to inferior Lisp process, starting one if needed.
Shows the REPL in a window below, keeping focus in the code buffer."
    (interactive)
    (let ((code-buffer (current-buffer)))
      (unless (and (get-process "inferior-lisp")
                   (process-live-p (get-process "inferior-lisp")))
        (run-lisp inferior-lisp-program)
        (switch-to-buffer code-buffer))
      (display-buffer "*inferior-lisp*"
                      '(display-buffer-below-selected
                        (window-height . 0.33)))))

  (defun emacs-solo/lisp-compile-file ()
    "Compile the current Common Lisp file."
    (interactive)
    (let ((file (buffer-file-name)))
      (when file
        (save-buffer)
        (lisp-eval-string (format "(compile-file \"%s\")" file))))))

;;; │ LISP-MODE
(use-package lisp-mode
  :ensure nil
  :defer t
  :bind (:map lisp-mode-map
              ("C-c d"   . emacs-solo/cl-describe-symbol)
              ("C-c h"   . emacs-solo/cl-hyperspec-lookup)
              ("C-c C-m" . emacs-solo/cl-macroexpand)
              ("C-c M-m" . emacs-solo/cl-macroexpand-all))
  :hook ((lisp-mode-hook . emacs-solo/cl-mode-setup))
  :config
  (defun emacs-solo/cl--send-and-capture (expr)
    "Send EXPR to the inferior Lisp and return the output as a string."
    (let* ((proc (get-process "inferior-lisp"))
           (buf (and proc (process-buffer proc)))
           result)
      (unless proc
        (user-error "No inferior Lisp process running.  Use C-c C-z to start one"))
      (with-current-buffer buf
        (let ((comint-preoutput-filter-functions
               (list (lambda (text) (setq result (concat result text)) ""))))
          (process-send-string proc (concat expr "\n"))
          (accept-process-output proc 1)))
      (string-trim (or result ""))))

  (defun emacs-solo/cl--symbol-at-point ()
    "Get the Common Lisp symbol at point as a string."
    (let ((sym (thing-at-point 'symbol t)))
      (when sym (upcase sym))))

  (defun emacs-solo/cl-completion-at-point ()
    "Completion-at-point function for Common Lisp using the inferior process."
    (let* ((bounds (bounds-of-thing-at-point 'symbol))
           (start (or (car bounds) (point)))
           (end (or (cdr bounds) (point)))
           (prefix (buffer-substring-no-properties start end))
           (proc (get-process "inferior-lisp")))
      (when (and proc (not (string-empty-p prefix)))
        (let* ((expr (format
                      "(let ((completions nil))
                         (do-all-symbols (s)
                           (when (and (fboundp s)
                                      (eql 0 (search \"%s\" (symbol-name s))))
                             (push (string-downcase (symbol-name s)) completions)))
                         (sort (remove-duplicates completions :test #'string=) #'string<))"
                      (upcase prefix)))
               (raw (emacs-solo/cl--send-and-capture expr))
               (cleaned (replace-regexp-in-string
                         "^[^(]*" "" (replace-regexp-in-string "\n" " " raw)))
               (candidates (and (string-match "(" cleaned)
                                (condition-case nil
                                    (car (read-from-string cleaned))
                                  (error nil)))))
          (when candidates
            (list start end candidates :exclusive 'no))))))

  (defun emacs-solo/cl-eldoc-function (callback &rest _)
    "Eldoc function for Common Lisp - shows arglist and first line of docs."
    (let* ((sym (emacs-solo/cl--symbol-at-point))
           (proc (get-process "inferior-lisp")))
      (when (and sym proc (process-live-p proc))
        (let* ((arglist-raw (emacs-solo/cl--send-and-capture
                             (format "(ignore-errors (princ-to-string (sb-introspect:function-lambda-list '%s)))" sym)))
               (doc-raw (emacs-solo/cl--send-and-capture
                         (format "(ignore-errors (documentation '%s 'function))" sym)))
               (arglist (and arglist-raw
                             (not (string-match-p "NIL\\|error\\|debugger" arglist-raw))
                             (string-trim arglist-raw)))
               (doc (and doc-raw
                         (not (string-match-p "^NIL$\\|error\\|debugger" doc-raw))
                         (car (split-string (string-trim (replace-regexp-in-string "\"" "" doc-raw)) "\n"))))
               (result (cond
                        ((and arglist doc)
                         (format "(%s %s) -- %s" (downcase sym) arglist doc))
                        (arglist
                         (format "(%s %s)" (downcase sym) arglist))
                        (doc
                         (format "%s -- %s" (downcase sym) doc))
                        (t nil))))
          (when result
            (funcall callback result))))))

  (defun emacs-solo/cl-describe-symbol ()
    "Describe the Common Lisp symbol at point."
    (interactive)
    (let ((sym (emacs-solo/cl--symbol-at-point)))
      (unless sym (user-error "No symbol at point"))
      (let ((output (emacs-solo/cl--send-and-capture
                     (format "(describe '%s)" sym))))
        (with-help-window "*CL Describe*"
          (princ output)))))

  (defun emacs-solo/cl-macroexpand ()
    "Macroexpand the form at point."
    (interactive)
    (let* ((form (thing-at-point 'list t)))
      (unless form (user-error "No form at point"))
      (let ((output (emacs-solo/cl--send-and-capture
                     (format "(pprint (macroexpand-1 '%s))" form))))
        (with-help-window "*CL Macroexpand*"
          (princ output)))))

  (defun emacs-solo/cl-macroexpand-all ()
    "Fully macroexpand the form at point."
    (interactive)
    (let* ((form (thing-at-point 'list t)))
      (unless form (user-error "No form at point"))
      (let ((output (emacs-solo/cl--send-and-capture
                     (format "(pprint (macroexpand '%s))" form))))
        (with-help-window "*CL Macroexpand*"
          (princ output)))))

  (defun emacs-solo/cl-hyperspec-lookup ()
    "Look up the symbol at point in the Common Lisp HyperSpec.
Resolve via l1sp.org redirector, then open final HTTPS URL."
    (interactive)
    (let* ((sym (emacs-solo/cl--symbol-at-point))
           (_ (unless sym (user-error "No symbol at point")))
           (probe (format "http://l1sp.org/cl/%s"
                          (url-hexify-string (downcase sym))))
           (final
            (if (executable-find "curl")
                (string-trim
                 (shell-command-to-string
                  (format "curl -sLo /dev/null -w %%{url_effective} %s"
                          (shell-quote-argument probe))))
              (with-current-buffer (url-retrieve-synchronously probe t t 5)
                (prog1
                    (if (boundp 'url-http-target-url)
                        (url-recreate-url url-http-target-url)
                      probe)
                  (kill-buffer (current-buffer)))))))
      (browse-url
       (replace-regexp-in-string "\\`http://" "https://" final))))

  (defun emacs-solo/cl-mode-setup ()
    "Setup Common Lisp enhancements for lisp-mode."
    (setq-local comment-column 40)
    (setq-local indent-tabs-mode nil)
    (add-hook 'completion-at-point-functions
              #'emacs-solo/cl-completion-at-point nil t)
    (add-hook 'eldoc-documentation-functions
              #'emacs-solo/cl-eldoc-function nil t)))

;;; ├──────────────────── NON TREESITTER AREA
;;; │ SASS-MODE
(use-package scss-mode
  :mode "\\.sass\\'"
  :hook
  ((scss-mode-hook . (lambda ()
                       (setq indent-tabs-mode nil))))
  :defer t)


;;; ├──────────────────── TREESITTER AREA
;;; │ RUBY-TS-MODE
(use-package ruby-ts-mode
  :ensure nil
  :mode "\\.rb\\'"
  :mode "Rakefile\\'"
  :mode "Gemfile\\'"
  :custom
  (add-to-list 'treesit-language-source-alist '(ruby "https://github.com/tree-sitter/tree-sitter-ruby" "master" "src"))
  (ruby-indent-level 2)
  (ruby-indent-tabs-mode nil))


;;; │ JS-TS-MODE
(use-package js-ts-mode
  :ensure js ;; I care about js-base-mode but it is locked behind the feature "js"
  :mode "\\.jsx?\\'"
  :defer t
  :hook
  ((js-ts-mode-hook . (lambda ()
                        (setq indent-tabs-mode nil))))
  :custom
  (js-indent-level 2)
  :config
  (add-to-list 'treesit-language-source-alist '(javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src"))
  (add-to-list 'treesit-language-source-alist '(jsdoc "https://github.com/tree-sitter/tree-sitter-jsdoc" "master" "src")))

;;; │ JSON-TS-MODE
(use-package json-ts-mode
  :mode "\\.json\\'"
  :defer t
  :hook
  ((json-ts-mode-hook . (lambda ()
                          (setq indent-tabs-mode nil)))))


;;; │ TYPESCRIPT-TS-MODE
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
                              (emacs-solo/add-jsdoc-in-typescript-ts-mode))))
  :custom
  (typescript-indent-level 2)
  :config
  (add-to-list 'treesit-language-source-alist '(typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src"))  ;; EMACS-31 this is now defined on mode code
  (unbind-key "M-." typescript-ts-base-mode-map))


(use-package tsx-ts-mode
  :mode "\\.tsx\\'"
  :defer t
  :hook
  ((tsx-ts-mode-hook .
                     (lambda ()
                       (setq indent-tabs-mode nil)
                       (emacs-solo/add-jsdoc-in-typescript-ts-mode))))
  :custom
  (typescript-indent-level 2)
  :config
  (add-to-list 'treesit-language-source-alist '(tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src"))  ;; EMACS-31 this is now defined on mode code
  (unbind-key "M-." typescript-ts-base-mode-map))


;;; │ BASH-TS-MODE
(use-package bash-ts-mode
  :ensure nil
  :mode "\\.\\(sh\\|bash\\)\\'"
  :defer t
  :config
  (add-to-list 'treesit-language-source-alist '(bash "https://github.com/tree-sitter/tree-sitter-bash" "master" "src")))


;;; │ RUST-TS-MODE
(use-package rust-ts-mode
  :ensure rust-ts-mode
  :mode "\\.rs\\'"
  :defer t
  :custom
  (rust-indent-level 2)
  :config
  (add-to-list 'treesit-language-source-alist '(rust "https://github.com/tree-sitter/tree-sitter-rust" "master" "src"))) ;; EMACS-31 this is now defined on mode code


;;; │ TOML-TS-MODE
(use-package toml-ts-mode
  :ensure toml-ts-mode
  :mode "\\.toml\\'"
  :defer t
  :config
  (add-to-list 'treesit-language-source-alist '(toml "https://github.com/ikatyang/tree-sitter-toml" "master" "src")))  ;; EMACS-31 this is now defined on mode code


;;; │ MARKDOWN-TS-MODE - EMACS-31
;;  As I first proposed here:
;;  https://lists.gnu.org/archive/html/emacs-devel/2025-02/msg00810.html
(use-package markdown-ts-mode
  :ensure nil
  :defer t)


;;; │ YAML-TS-MODE
(use-package yaml-ts-mode
  :ensure yaml-ts-mode
  :mode "\\.ya?ml\\'"
  :defer t
  :config
  (add-to-list 'treesit-language-source-alist '(yaml "https://github.com/tree-sitter-grammars/tree-sitter-yaml" "master" "src")))  ;; EMACS-31 this is now defined on mode code


;;; │ DOCKERFILE-TS-MODE
(use-package dockerfile-ts-mode
  :ensure dockerfile-ts-mode
  :mode "\\Dockerfile.*\\'"
  :defer t
  :config
  (add-to-list 'treesit-language-source-alist '(dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile" "main" "src"))) ;; EMACS-31 this is now defined on mode code


;;; │ GO-TS-MODE
(defun emacs-solo/go-common-setup ()
  "Common settings for Go tree-sitter modes."
  (add-hook 'before-save-hook #'eglot-format nil t) ; buffer-local
  (setq indent-tabs-mode t)                         ; Go likes tabs
  (setq tab-width 4)                                ; Tabs *display* as 4 spaces
  (when (derived-mode-p 'go-ts-mode)
    (setq-local go-ts-mode-indent-offset tab-width)))

(use-package go-ts-mode
  :ensure t
  :mode ("\\.go\\'" . go-ts-mode)
  :mode ("go\\.mod\\'" . go-mod-ts-mode)
  :hook
  ((go-ts-mode-hook . emacs-solo/go-common-setup)
   (go-mod-ts-mode-hook . emacs-solo/go-common-setup))
  :defer t)

;;; ├──────────────────── EMACS-SOLO Extra Packages
;;  │
;;  │ Self-contained modules that live under the `lisp/' directory.
;;  │ Each file is loaded here via `require'.
;;  │ See `lisp/*.el' for per-module documentation.
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'emacs-solo-themes)
(require 'emacs-solo-movements)
(require 'emacs-solo-formatter)
(require 'emacs-solo-transparency)
(require 'emacs-solo-mode-line)
(require 'emacs-solo-exec-path-from-shell)
(add-hook 'after-init-hook
          (lambda ()
            (if (executable-find "rg")
                (progn
                  (setq xref-search-program 'ripgrep)
                  (setq grep-command "rg -nS --no-heading "))
              (setq xref-search-program 'grep)
              (setq grep-command "grep -nH -r ")))
          90)
(require 'emacs-solo-rainbow-delimiters)
(require 'emacs-solo-project-select)
(require 'emacs-solo-viper-extensions)
(require 'emacs-solo-highlight-keywords)
(require 'emacs-solo-gutter)
(require 'emacs-solo-ace-window)
(require 'emacs-solo-olivetti)
(require 'emacs-solo-temp-sharing)
(require 'emacs-solo-sudo-edit)
(require 'emacs-solo-replace-as-diff)
(require 'emacs-solo-weather)
(require 'emacs-solo-rate)
(require 'emacs-solo-how-in)
(require 'emacs-solo-ai)
(require 'emacs-solo-dired-gutter)
(require 'emacs-solo-dired-mpv)
(require 'emacs-solo-icons)
(require 'emacs-solo-icons-dired)
(require 'emacs-solo-icons-ibuffer)
(require 'emacs-solo-icons-eshell)
(require 'emacs-solo-container)
(require 'emacs-solo-m3u)
(require 'emacs-solo-clipboard)
(require 'emacs-solo-eldoc-box)
(require 'emacs-solo-khard)
(require 'emacs-solo-flymake-eslint)
(require 'emacs-solo-erc-image)
(require 'emacs-solo-yt)
(require 'emacs-solo-gh)

(provide 'init)
;;; └ init.el ends here
