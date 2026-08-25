;;; emacs-solo-catppuccin-mocha-theme.el --- Catppuccin Mocha theme built on Modus  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Version: 0.1.0
;; Package-Requires: ((emacs "31.1") (modus-themes "5.0.0"))
;; Keywords: faces, themes
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Catppuccin Mocha colors on top of the Modus themes infrastructure
;; (version 5+), using `modus-vivendi' as its base palette.
;;
;; Follows: https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md
;; Colors:  https://github.com/catppuccin/catppuccin (Mocha)
;;
;; Usage:
;;
;;     (add-to-list 'custom-theme-load-path "/path/to/this/directory")
;;     (load-theme 'emacs-solo-catppuccin-mocha t)

;;; Code:

(unless (require 'modus-themes nil :noerror)
  ;; Fall back to the copy bundled with Emacs (etc/themes is not in
  ;; `load-path', so a plain `require' cannot find it).
  (require-theme 'modus-themes))

;;;; User customization options

(defgroup emacs-solo-catppuccin-mocha-theme ()
  "Catppuccin Mocha theme built on the Modus themes infrastructure."
  :group 'modus-themes
  :link '(url-link :tag "GitHub" "https://github.com/LionyxML/emacs-solo")
  :prefix "emacs-solo-catppuccin-mocha-"
  :tag "Catppuccin Mocha")

(defcustom emacs-solo-catppuccin-mocha-palette-user nil
  "Like `emacs-solo-catppuccin-mocha-palette' for user-defined entries.
This is meant to extend the palette with custom named colors and/or
semantic palette mappings.  Those may then be used in combination with
palette overrides (also see `modus-themes-common-palette-overrides' and
`emacs-solo-catppuccin-mocha-palette-overrides')."
  :group 'emacs-solo-catppuccin-mocha-theme
  :type '(repeat (list symbol (choice symbol string)))
  :link '(info-link "(modus-themes) Option to extend the palette for use with overrides"))

(defcustom emacs-solo-catppuccin-mocha-palette-overrides nil
  "Overrides for `emacs-solo-catppuccin-mocha-palette'.
Mirror the elements of the aforementioned palette, overriding
their value.

For overrides that are shared across all of the Modus themes,
refer to `modus-themes-common-palette-overrides'.

Theme-specific overrides take precedence over shared overrides."
  :group 'emacs-solo-catppuccin-mocha-theme
  :type '(repeat (list symbol (choice symbol string)))
  :link '(info-link "(modus-themes) Palette overrides"))

;;;; Palette
;;
;; Entries here take precedence over `modus-themes-vivendi-palette',
;; which provides every named color and semantic mapping not listed.

(defconst emacs-solo-catppuccin-mocha-palette
  (append
   '(
     ;; Basic values

     (bg-main "#1e1e2e")            ; base
     (fg-main "#cdd6f4")            ; text

     ;; Catppuccin Mocha named colors (official palette names)

     (ctp-rosewater "#f5e0dc")
     (ctp-pink      "#f5c2e7")
     (ctp-mauve     "#cba6f7")
     (ctp-red       "#f38ba8")
     (ctp-peach     "#fab387")
     (ctp-yellow    "#f9e2af")
     (ctp-green     "#a6e3a1")
     (ctp-teal      "#94e2d5")
     (ctp-sky       "#89dceb")
     (ctp-sapphire  "#74c7ec")
     (ctp-blue      "#89b4fa")
     (ctp-lavender  "#b4befe")
     (ctp-subtext1  "#bac2de")
     (ctp-subtext0  "#a6adc8")
     (ctp-overlay2  "#9399b2")
     (ctp-overlay1  "#7f849c")
     (ctp-overlay0  "#6c7086")
     (ctp-surface2  "#585b70")
     (ctp-surface1  "#45475a")
     (ctp-surface0  "#313244")
     (ctp-mantle    "#181825")
     (ctp-crust     "#11111b")

     ;; Special purpose

     (bg-completion ctp-surface1)
     (bg-hl-line "#2a2b3d")
     (bg-region ctp-surface2)
     (fg-region fg-main)
     (bg-hover-secondary ctp-surface2)

     ;; Mode-line

     (bg-mode-line-active       ctp-mantle)
     (fg-mode-line-active       ctp-subtext1)
     (border-mode-line-active   unspecified)
     (bg-mode-line-inactive     ctp-mantle)
     (fg-mode-line-inactive     ctp-surface2)
     (border-mode-line-inactive unspecified)

     ;; Tab bar

     (bg-tab-bar     bg-main)
     (bg-tab-current bg-main)
     (bg-tab-other   ctp-mantle)

     ;; Diffs

     (bg-added          "#364144")
     (bg-added-refine   "#4a5457")
     (bg-changed        "#3e4b6c")
     (bg-changed-refine "#515d7b")
     (bg-removed        "#443245")
     (bg-removed-refine "#574658")

     ;; General mappings

     (cursor ctp-rosewater)
     (name ctp-blue)
     (identifier ctp-mauve)
     (fringe bg-main)

     (err ctp-red)
     (warning ctp-yellow)
     (info ctp-teal)

     (bg-active bg-main)
     (bg-prominent-err bg-removed)
     (fg-prominent-err ctp-red)

     ;; Code mappings

     (builtin ctp-blue)
     (comment ctp-overlay2)
     (constant ctp-red)
     (docstring ctp-subtext0)
     (fnname ctp-blue)
     (keyword ctp-mauve)
     (number ctp-peach)
     (property ctp-blue)
     (string ctp-green)
     (type ctp-yellow)
     (variable ctp-peach)

     ;; Accent mappings

     (accent-0 ctp-blue)
     (accent-1 ctp-sky)

     ;; Completion mappings

     (bg-completion-match-0 bg-main)
     (bg-completion-match-1 bg-main)
     (bg-completion-match-2 bg-main)
     (bg-completion-match-3 bg-main)
     (fg-completion-match-0 ctp-blue)
     (fg-completion-match-1 ctp-red)
     (fg-completion-match-2 ctp-green)
     (fg-completion-match-3 ctp-peach)

     ;; Date mappings

     (date-weekday ctp-blue)
     (date-weekend ctp-peach)

     ;; Line number mappings

     (bg-line-number-active unspecified)
     (bg-line-number-inactive bg-main)
     (fg-line-number-active ctp-lavender)
     (fg-line-number-inactive ctp-overlay1)

     ;; Link mappings

     (fg-link ctp-blue)

     ;; Mark mappings

     (bg-mark-delete bg-removed)
     (fg-mark-delete ctp-red)
     (bg-mark-select bg-changed)
     (fg-mark-select ctp-blue)

     ;; Prompt mappings

     (bg-prompt unspecified)
     (fg-prompt ctp-mauve)

     ;; Prose mappings

     (bg-prose-block-contents ctp-surface0)
     (bg-prose-block-delimiter bg-prose-block-contents)
     (fg-prose-block-delimiter ctp-overlay2)
     (fg-prose-verbatim ctp-green)

     ;; Search mappings
     ;; Catppuccin defaults are not that visible, so current match is
     ;; red on crust instead.

     (bg-search-current ctp-red)
     (fg-search-current ctp-crust)
     (bg-search-lazy "#3e5768")
     (fg-search-lazy "#cdd6f5")
     (bg-search-static bg-search-lazy)
     (fg-search-static fg-search-lazy)

     ;; Heading mappings

     (fg-heading-0 ctp-red)
     (fg-heading-1 ctp-peach)
     (fg-heading-2 ctp-yellow)
     (fg-heading-3 ctp-green)
     (fg-heading-4 ctp-sapphire))
   modus-themes-vivendi-palette)
  "The entire palette of the `emacs-solo-catppuccin-mocha' theme.

This palette is based on `modus-themes-vivendi-palette' with the
Catppuccin Mocha colors taking precedence (palette lookup returns the
first match).

Named colors have the form (COLOR-NAME HEX-VALUE) with the former
as a symbol and the latter as a string.

Semantic color mappings have the form (MAPPING-NAME COLOR-NAME)
with both as symbols.  The latter is a named color that already
exists in the palette and is associated with a HEX-VALUE.")

;;;; Custom face overrides
;;
;; Faces whose styling cannot be expressed through palette mappings
;; alone (sizes, slants, or faces the Modus themes do not map).

(defconst emacs-solo-catppuccin-mocha-faces
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
    `(change-log-acknowledgment ((,c :foreground ,ctp-lavender)))
    `(change-log-date ((,c :foreground ,ctp-green)))
    `(change-log-name ((,c :foreground ,ctp-peach)))
    `(log-view-message ((,c :foreground ,ctp-lavender)))
;;;;; completion
    `(modus-themes-completion-selected ((,c :background ,bg-completion :foreground ,fg-main)))
;;;;; diff-mode
    `(diff-context ((,c :foreground ,ctp-blue)))
    `(diff-file-header ((,c :foreground ,ctp-pink)))
    `(diff-header ((,c :foreground ,ctp-blue)))
    `(diff-hunk-header ((,c :foreground ,ctp-peach)))
;;;;; gnus
    `(gnus-button ((,c :foreground "#8aadf4")))
    `(gnus-group-mail-3 ((,c :foreground "#8aadf4")))
    `(gnus-group-mail-3-empty ((,c :foreground "#8aadf4")))
    `(gnus-header-content ((,c :foreground "#7dc4e4")))
    `(gnus-header-from ((,c :foreground ,ctp-mauve)))
    `(gnus-header-name ((,c :foreground ,ctp-green)))
    `(gnus-header-subject ((,c :foreground "#8aadf4")))
;;;;; newsticker
    `(newsticker-extra-face ((,c :foreground ,ctp-overlay2 :height 0.8 :slant italic)))
    `(newsticker-feed-face ((,c :foreground ,ctp-red :height 1.2 :weight bold)))
    `(newsticker-treeview-face ((,c :foreground ,fg-main)))
    `(newsticker-treeview-selection-face ((,c :background "#3e5768" :foreground "#cdd6f5")))
;;;;; tab-bar
    ;; :box nil is load-bearing: the built-in `tab-bar-tab' defface sets a
    ;; `released-button' box on dark displays, and `tab-bar-tab-inactive'
    ;; inherits it.  This standalone theme drops modus's own tab specs, so
    ;; without :box nil the defface box leaks through and every tab renders
    ;; highlighted.
    `(tab-bar ((,c :background ,ctp-mantle :foreground ,ctp-subtext1 :box nil)))
    `(tab-bar-tab ((,c :background ,ctp-mantle :foreground ,ctp-subtext1 :underline nil :box nil)))
    `(tab-bar-tab-inactive ((,c :background ,ctp-mantle :foreground ,ctp-overlay0 :box nil)))
    `(tab-bar-tab-group-current ((,c :background ,ctp-mantle :foreground ,ctp-subtext1 :box nil)))
    `(tab-bar-tab-group-inactive ((,c :background ,bg-main :foreground ,ctp-overlay2 :box nil)))
;;;;; vc-dir
    `(vc-dir-file ((,c :foreground ,ctp-blue)))
    `(vc-dir-header-value ((,c :foreground ,ctp-lavender))))
  "Custom face overrides for the `emacs-solo-catppuccin-mocha' theme.")

(defconst emacs-solo-catppuccin-mocha-custom-variables nil
  "Custom variable overrides for the `emacs-solo-catppuccin-mocha' theme.")

;;;; Instantiate the theme

(modus-themes-theme
 'emacs-solo-catppuccin-mocha
 'emacs-solo-catppuccin-mocha
 "Catppuccin Mocha theme.
Built on the Modus themes infrastructure (modus-vivendi base) with
the official Catppuccin Mocha palette."
 'dark
 'emacs-solo-catppuccin-mocha-palette
 'emacs-solo-catppuccin-mocha-palette-user
 'emacs-solo-catppuccin-mocha-palette-overrides
 'emacs-solo-catppuccin-mocha-faces
 'emacs-solo-catppuccin-mocha-custom-variables)

(provide 'emacs-solo-catppuccin-mocha-theme)
;;; emacs-solo-catppuccin-mocha-theme.el ends here
