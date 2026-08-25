;;; emacs-solo-matrix-theme.el --- Matrix green-on-black theme built on Modus  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Version: 0.1.0
;; Package-Requires: ((emacs "31.1") (modus-themes "5.0.0"))
;; Keywords: faces, themes
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; The Matrix: phosphor greens raining down a vampire-black terminal.
;; Everything is green — there is no red pill in this palette.
;;
;; Built on the Modus themes infrastructure (version 5+), using
;; `modus-vivendi' as its base palette.
;;
;; Usage:
;;
;;     (add-to-list 'custom-theme-load-path "/path/to/this/directory")
;;     (load-theme 'emacs-solo-matrix t)

;;; Code:

(unless (require 'modus-themes nil :noerror)
  ;; Fall back to the copy bundled with Emacs (etc/themes is not in
  ;; `load-path', so a plain `require' cannot find it).
  (require-theme 'modus-themes))

;;;; User customization options

(defgroup emacs-solo-matrix-theme ()
  "Matrix green-on-black theme built on the Modus themes infrastructure."
  :group 'modus-themes
  :link '(url-link :tag "GitHub" "https://github.com/LionyxML/emacs-solo")
  :prefix "emacs-solo-matrix-"
  :tag "Matrix")

(defcustom emacs-solo-matrix-palette-user nil
  "Like `emacs-solo-matrix-palette' for user-defined entries.
This is meant to extend the palette with custom named colors and/or
semantic palette mappings.  Those may then be used in combination with
palette overrides (also see `modus-themes-common-palette-overrides' and
`emacs-solo-matrix-palette-overrides')."
  :group 'emacs-solo-matrix-theme
  :type '(repeat (list symbol (choice symbol string)))
  :link '(info-link "(modus-themes) Option to extend the palette for use with overrides"))

(defcustom emacs-solo-matrix-palette-overrides nil
  "Overrides for `emacs-solo-matrix-palette'.
Mirror the elements of the aforementioned palette, overriding
their value.

For overrides that are shared across all of the Modus themes,
refer to `modus-themes-common-palette-overrides'.

Theme-specific overrides take precedence over shared overrides."
  :group 'emacs-solo-matrix-theme
  :type '(repeat (list symbol (choice symbol string)))
  :link '(info-link "(modus-themes) Palette overrides"))

;;;; Palette
;;
;; Entries here take precedence over `modus-themes-vivendi-palette',
;; which provides every named color and semantic mapping not listed.

(defconst emacs-solo-matrix-palette
  (append
   '(
     ;; Basic values

     (bg-main "#0d0208")            ; vampire black
     (fg-main malachite)

     ;; Matrix named colors

     (malachite    "#00ff41")
     (spring-green "#00ff71")
     (green-bright "#00c738")
     (green-mid    "#00a52a")
     (green-deep   "#008f11")       ; islamic green
     (green-dark   "#005a00")
     (green-dim    "#006600")
     (bg-pine      "#001900")
     (bg-forest    "#003b00")

     ;; Special purpose

     (bg-completion bg-main)
     (bg-hl-line "#002200")
     (bg-region bg-forest)
     (fg-region malachite)
     (bg-hover-secondary bg-forest)

     ;; Mode-line

     (bg-mode-line-active       bg-pine)
     (fg-mode-line-active       green-bright)
     (border-mode-line-active   unspecified)
     (bg-mode-line-inactive     bg-pine)
     (fg-mode-line-inactive     green-dark)
     (border-mode-line-inactive unspecified)

     ;; Tab bar

     (bg-tab-bar     bg-pine)
     (bg-tab-current bg-main)
     (bg-tab-other   bg-pine)

     ;; Diffs

     (bg-added          bg-forest)
     (bg-added-refine   "#005a00")
     (bg-changed        "#004800")
     (bg-changed-refine "#006600")
     (bg-removed        "#190a10")
     (bg-removed-refine "#2b1520")

     ;; General mappings

     (cursor malachite)
     (name malachite)
     (identifier green-bright)
     (fringe bg-main)

     ;; Red is NOT in the Matrix palette — brighter green for contrast.
     (err spring-green)
     (warning green-mid)
     (info malachite)

     (bg-active bg-main)
     (bg-prominent-err bg-removed)
     (fg-prominent-err spring-green)

     ;; Code mappings

     (builtin malachite)
     (comment green-dark)
     (constant malachite)
     (docstring green-bright)
     (fnname malachite)
     (keyword green-bright)
     (number green-deep)
     (property malachite)
     (string green-bright)
     (type green-mid)
     (variable green-deep)

     ;; Accent mappings

     (accent-0 malachite)
     (accent-1 green-deep)

     ;; Completion mappings

     (bg-completion-match-0 bg-main)
     (bg-completion-match-1 bg-main)
     (bg-completion-match-2 bg-main)
     (bg-completion-match-3 bg-main)
     (fg-completion-match-0 malachite)
     (fg-completion-match-1 spring-green)
     (fg-completion-match-2 green-bright)
     (fg-completion-match-3 green-deep)

     ;; Date mappings

     (date-weekday malachite)
     (date-weekend green-deep)

     ;; Line number mappings

     (bg-line-number-active unspecified)
     (bg-line-number-inactive bg-main)
     (fg-line-number-active malachite)
     (fg-line-number-inactive green-dim)

     ;; Link mappings

     (fg-link malachite)

     ;; Mark mappings

     (bg-mark-delete bg-removed)
     (fg-mark-delete spring-green)
     (bg-mark-select bg-forest)
     (fg-mark-select malachite)

     ;; Prompt mappings

     (bg-prompt unspecified)
     (fg-prompt malachite)

     ;; Prose mappings

     (bg-prose-block-contents "#001600")
     (bg-prose-block-delimiter bg-prose-block-contents)
     (fg-prose-block-delimiter green-dim)
     (fg-prose-verbatim green-bright)

     ;; Search mappings

     (bg-search-current malachite)
     (fg-search-current bg-main)
     (bg-search-lazy bg-forest)
     (fg-search-lazy malachite)
     (bg-search-static bg-forest)
     (fg-search-static malachite)

     ;; Heading mappings: bright -> dark green gradient

     (fg-heading-0 malachite)
     (fg-heading-1 green-bright)
     (fg-heading-2 green-mid)
     (fg-heading-3 green-deep)
     (fg-heading-4 green-dark))
   modus-themes-vivendi-palette)
  "The entire palette of the `emacs-solo-matrix' theme.

This palette is based on `modus-themes-vivendi-palette' with the
Matrix greens taking precedence (palette lookup returns the first
match).

Named colors have the form (COLOR-NAME HEX-VALUE) with the former
as a symbol and the latter as a string.

Semantic color mappings have the form (MAPPING-NAME COLOR-NAME)
with both as symbols.  The latter is a named color that already
exists in the palette and is associated with a HEX-VALUE.")

;;;; Custom face overrides
;;
;; Faces whose styling cannot be expressed through palette mappings
;; alone (sizes, slants, underline colors, or faces the Modus themes
;; do not map).

(defconst emacs-solo-matrix-faces
  '(
;;;;; modus option equivalents
    ;; Bake in what the modus user options would produce, so the theme
    ;; is self-contained and does not depend on the caller setting
    ;; `modus-themes-italic-constructs', `modus-themes-bold-constructs',
    ;; or `modus-themes-prompts' (those are shared across all modus
    ;; themes, so setting them here as variables would leak).
    `(modus-themes-bold ((,c :inherit bold)))
    `(modus-themes-slant ((,c :inherit italic)))
    `(modus-themes-prompt ((,c :inherit bold :background ,bg-prompt :foreground ,fg-prompt)))
;;;;; change-log and log-view (also vc-print-log)
    `(change-log-acknowledgment ((,c :foreground ,green-bright)))
    `(change-log-date ((,c :foreground ,green-deep)))
    `(change-log-name ((,c :foreground ,green-mid)))
    `(log-view-message ((,c :foreground ,green-bright)))
;;;;; completion
    `(modus-themes-completion-selected ((,c :background ,bg-completion :foreground ,fg-main)))
;;;;; diff-mode
    `(diff-context ((,c :foreground ,malachite)))
    `(diff-file-header ((,c :foreground ,green-bright)))
    `(diff-header ((,c :foreground ,malachite)))
    `(diff-hunk-header ((,c :foreground ,green-deep)))
;;;;; flymake
    `(flymake-warning ((,c :foreground ,green-mid :underline (:color ,green-mid :style wave))))
    `(flymake-note ((,c :foreground ,malachite :underline (:color ,malachite :style wave))))
;;;;; gnus / message
    `(gnus-button ((,c :foreground ,malachite)))
    `(gnus-group-mail-3 ((,c :foreground ,malachite)))
    `(gnus-group-mail-3-empty ((,c :foreground ,malachite)))
    `(gnus-header-content ((,c :foreground ,green-bright)))
    `(gnus-header-from ((,c :foreground ,green-deep)))
    `(gnus-header-name ((,c :foreground ,green-bright)))
    `(gnus-header-subject ((,c :foreground ,malachite)))
    `(message-signature-separator ((,c :foreground ,malachite)))
    `(message-separator ((,c :foreground ,green-dark)))
;;;;; link
    `(link ((,c :foreground ,malachite :underline (:color ,malachite :style line))))
;;;;; newsticker
    `(newsticker-extra-face ((,c :foreground ,green-dark :height 0.8 :slant italic)))
    `(newsticker-feed-face ((,c :foreground ,green-mid :height 1.2 :weight bold)))
    `(newsticker-treeview-face ((,c :foreground ,malachite)))
    `(newsticker-treeview-selection-face ((,c :background ,bg-forest :foreground ,malachite)))
;;;;; tab-bar
    ;; :box nil is load-bearing: the built-in `tab-bar-tab' defface sets a
    ;; `released-button' box on dark displays, and `tab-bar-tab-inactive'
    ;; inherits it.  This standalone theme drops modus's own tab specs, so
    ;; without :box nil the defface box leaks through and every tab renders
    ;; highlighted.
    `(tab-bar ((,c :background ,bg-pine :foreground ,green-bright :box nil)))
    `(tab-bar-tab ((,c :background ,bg-main :foreground ,green-bright :underline nil :box nil)))
    `(tab-bar-tab-inactive ((,c :background ,bg-main :foreground ,green-deep :box nil)))
    `(tab-bar-tab-group-current ((,c :background ,bg-main :foreground ,green-bright :box nil)))
    `(tab-bar-tab-group-inactive ((,c :background ,bg-main :foreground ,green-dark :box nil)))
;;;;; vc-dir
    `(vc-dir-file ((,c :foreground ,malachite)))
    `(vc-dir-header-value ((,c :foreground ,green-bright))))
  "Custom face overrides for the `emacs-solo-matrix' theme.")

(defconst emacs-solo-matrix-custom-variables nil
  "Custom variable overrides for the `emacs-solo-matrix' theme.")

;;;; Instantiate the theme

(modus-themes-theme
 'emacs-solo-matrix
 'emacs-solo-matrix
 "Matrix green-on-black theme.
Built on the Modus themes infrastructure (modus-vivendi base) with
phosphor greens on a vampire-black background."
 'dark
 'emacs-solo-matrix-palette
 'emacs-solo-matrix-palette-user
 'emacs-solo-matrix-palette-overrides
 'emacs-solo-matrix-faces
 'emacs-solo-matrix-custom-variables)

(provide 'emacs-solo-matrix-theme)
;;; emacs-solo-matrix-theme.el ends here
