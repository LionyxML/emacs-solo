;;; emacs-solo-crafters-theme.el --- SystemCrafters/Palenight theme built on Modus  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Version: 0.1.0
;; Package-Requires: ((emacs "31.1") (modus-themes "5.0.0"))
;; Keywords: faces, themes
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; A SystemCrafters-style theme (Material Palenight colors) on top of
;; the Modus themes infrastructure (version 5+), using
;; `modus-vivendi-tinted' as its base palette.
;;
;; Usage:
;;
;;     (add-to-list 'custom-theme-load-path "/path/to/this/directory")
;;     (load-theme 'emacs-solo-crafters t)

;;; Code:

(unless (require 'modus-themes nil :noerror)
  ;; Fall back to the copy bundled with Emacs (etc/themes is not in
  ;; `load-path', so a plain `require' cannot find it).
  (require-theme 'modus-themes))

;;;; User customization options

(defgroup emacs-solo-crafters-theme ()
  "SystemCrafters/Palenight theme built on the Modus themes infrastructure."
  :group 'modus-themes
  :link '(url-link :tag "GitHub" "https://github.com/LionyxML/emacs-solo")
  :prefix "emacs-solo-crafters-"
  :tag "Crafters")

(defcustom emacs-solo-crafters-palette-user nil
  "Like `emacs-solo-crafters-palette' for user-defined entries.
This is meant to extend the palette with custom named colors and/or
semantic palette mappings.  Those may then be used in combination with
palette overrides (also see `modus-themes-common-palette-overrides' and
`emacs-solo-crafters-palette-overrides')."
  :group 'emacs-solo-crafters-theme
  :type '(repeat (list symbol (choice symbol string)))
  :link '(info-link "(modus-themes) Option to extend the palette for use with overrides"))

(defcustom emacs-solo-crafters-palette-overrides nil
  "Overrides for `emacs-solo-crafters-palette'.
Mirror the elements of the aforementioned palette, overriding
their value.

For overrides that are shared across all of the Modus themes,
refer to `modus-themes-common-palette-overrides'.

Theme-specific overrides take precedence over shared overrides."
  :group 'emacs-solo-crafters-theme
  :type '(repeat (list symbol (choice symbol string)))
  :link '(info-link "(modus-themes) Palette overrides"))

;;;; Palette
;;
;; Entries here take precedence over
;; `modus-themes-vivendi-tinted-palette', which provides every named
;; color and semantic mapping not listed.

(defconst emacs-solo-crafters-palette
  (append
   '(
     ;; Basic values
     ;; (only bg-main/fg-main: the old crafters overrides never
     ;; touched bg-dim/fg-dim/fg-alt, which feed shadow, metadata, etc.)

     (bg-main "#292d3e")
     (fg-main "#eeffff")

     ;; Material Palenight named colors

     (mat-dark   "#232635")
     (mat-blue   "#82aaff")
     (mat-cyan   "#89ddff")
     (mat-green  "#c3e88d")
     (mat-orange "#f78c6c")
     (mat-red    "#ff5370")
     (mat-purple "#c792ea")
     (mat-violet "#bb80b3")
     (mat-yellow "#ffcb6b")
     (mat-gray   "#676e95")
     (mat-silver "#8d92af")
     (mat-steel  "#a6accd")
     (periwinkle "#a1bfff")

     ;; Special purpose

     (bg-completion "#2f447f")
     (bg-hl-line "#30344a")
     (bg-region "#3c435e")
     (fg-region "white")
     (bg-hover-secondary mat-gray)

     ;; Mode-line

     (bg-mode-line-active       mat-dark)
     (fg-mode-line-active       mat-steel)
     (border-mode-line-active   unspecified)
     (bg-mode-line-inactive     "#282c3d")
     (fg-mode-line-inactive     mat-gray)
     (border-mode-line-inactive unspecified)

     ;; Tab bar

     (bg-tab-bar     mat-dark)
     (bg-tab-current bg-main)
     (bg-tab-other   mat-dark)

     ;; Diffs

     (bg-added          "#2a3b2e")
     (bg-added-refine   "#384c3f")
     (bg-changed        "#3c435e")
     (bg-changed-refine "#4f5875")
     (bg-removed        "#4d2d2d")
     (bg-removed-refine "#603939")

     ;; General mappings

     (cursor fg-main)
     (name mat-blue)
     (identifier mat-purple)
     (fringe bg-main)

     (err mat-red)
     (warning mat-yellow)
     (info mat-cyan)

     (bg-active bg-main)
     (bg-prominent-err bg-removed)
     (fg-prominent-err mat-red)

     ;; Code mappings

     (builtin mat-blue)
     (comment mat-gray)
     (constant mat-orange)
     (docstring mat-silver)
     (fnname mat-blue)
     (keyword mat-cyan)
     (number mat-orange)
     (property mat-blue)
     (string mat-green)
     (type mat-purple)
     (variable mat-purple)

     ;; Accent mappings

     (accent-0 periwinkle)
     (accent-1 "#79a8ff")

     ;; Completion mappings

     (bg-completion-match-0 bg-main)
     (bg-completion-match-1 bg-main)
     (bg-completion-match-2 bg-main)
     (bg-completion-match-3 bg-main)
     (fg-completion-match-0 mat-blue)
     (fg-completion-match-1 mat-red)
     (fg-completion-match-2 mat-green)
     (fg-completion-match-3 mat-orange)

     ;; Date mappings

     (date-weekday mat-blue)
     (date-weekend mat-orange)

     ;; Line number mappings

     (bg-line-number-active unspecified)
     (bg-line-number-inactive bg-main)
     (fg-line-number-active fg-main)
     (fg-line-number-inactive "gray50")

     ;; Link mappings

     (fg-link mat-blue)

     ;; Mark mappings

     (bg-mark-delete bg-removed)
     (fg-mark-delete mat-red)
     (bg-mark-select bg-changed)
     (fg-mark-select mat-blue)

     ;; Prompt mappings

     (bg-prompt unspecified)
     (fg-prompt mat-purple)

     ;; Prose mappings

     (bg-prose-block-contents mat-dark)
     (bg-prose-block-delimiter bg-prose-block-contents)
     (fg-prose-block-delimiter mat-gray)
     (fg-prose-verbatim mat-green)

     ;; Search mappings

     (bg-search-current mat-red)
     (fg-search-current bg-main)
     (bg-search-lazy bg-region)
     (fg-search-lazy fg-main)
     (bg-search-static bg-region)
     (fg-search-static fg-main)

     ;; Heading mappings

     (fg-heading-0 mat-blue)
     (fg-heading-1 mat-blue)
     (fg-heading-2 mat-purple)
     (fg-heading-3 mat-violet)
     (fg-heading-4 periwinkle))
   modus-themes-vivendi-tinted-palette)
  "The entire palette of the `emacs-solo-crafters' theme.

This palette is based on `modus-themes-vivendi-tinted-palette' with the
Material Palenight colors taking precedence (palette lookup returns the
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

(defconst emacs-solo-crafters-faces
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
    `(change-log-acknowledgment ((,c :foreground ,periwinkle)))
    `(change-log-date ((,c :foreground ,mat-green)))
    `(change-log-name ((,c :foreground ,mat-orange)))
    `(log-view-message ((,c :foreground ,periwinkle)))
;;;;; completion
    `(modus-themes-completion-selected ((,c :background ,bg-completion :foreground "white")))
;;;;; diff-mode
    `(diff-context ((,c :foreground ,mat-blue)))
    `(diff-file-header ((,c :foreground ,mat-violet)))
    `(diff-header ((,c :foreground ,mat-blue)))
    `(diff-hunk-header ((,c :foreground ,mat-orange)))
;;;;; gnus / message
    `(gnus-button ((,c :foreground ,mat-blue)))
    `(gnus-group-mail-3 ((,c :foreground ,mat-blue)))
    `(gnus-group-mail-3-empty ((,c :foreground ,mat-blue)))
    `(gnus-header-content ((,c :foreground ,mat-cyan)))
    `(gnus-header-from ((,c :foreground ,mat-purple)))
    `(gnus-header-name ((,c :foreground ,mat-green)))
    `(gnus-header-subject ((,c :foreground ,mat-blue)))
    `(gnus-header-subject ((,c :foreground ,mat-blue)))
    `(message-signature-separator ((,c :foreground ,mat-blue)))
    `(message-separator ((,c :foreground ,mat-gray)))
;;;;; newsticker
    `(newsticker-extra-face ((,c :foreground ,mat-silver :height 0.8 :slant italic)))
    `(newsticker-feed-face ((,c :foreground ,mat-red :height 1.2 :weight bold)))
    `(newsticker-treeview-face ((,c :foreground ,fg-main)))
    `(newsticker-treeview-selection-face ((,c :background ,bg-region :foreground ,fg-main)))
;;;;; tab-bar
    ;; :box nil is load-bearing: the built-in `tab-bar-tab' defface sets a
    ;; `released-button' box on dark displays, and `tab-bar-tab-inactive'
    ;; inherits it.  This standalone theme drops modus's own tab specs, so
    ;; without :box nil the defface box leaks through and every tab renders
    ;; highlighted.
    `(tab-bar ((,c :background ,mat-dark :foreground ,mat-steel :box nil)))
    `(tab-bar-tab ((,c :background ,mat-dark :foreground ,mat-steel :underline nil :box nil)))
    `(tab-bar-tab-inactive ((,c :background ,mat-dark :foreground ,mat-gray :box nil)))
    `(tab-bar-tab-group-current ((,c :background ,mat-dark :foreground ,mat-steel :box nil)))
    `(tab-bar-tab-group-inactive ((,c :background ,mat-dark :foreground "#777" :box nil)))
;;;;; vc-dir
    `(vc-dir-file ((,c :foreground ,mat-blue)))
    `(vc-dir-header-value ((,c :foreground ,periwinkle))))
  "Custom face overrides for the `emacs-solo-crafters' theme.")

(defconst emacs-solo-crafters-custom-variables nil
  "Custom variable overrides for the `emacs-solo-crafters' theme.")

;;;; Instantiate the theme

(modus-themes-theme
 'emacs-solo-crafters
 'emacs-solo-crafters
 "SystemCrafters/Palenight theme.
Built on the Modus themes infrastructure (modus-vivendi-tinted base)
with Material Palenight colors."
 'dark
 'emacs-solo-crafters-palette
 'emacs-solo-crafters-palette-user
 'emacs-solo-crafters-palette-overrides
 'emacs-solo-crafters-faces
 'emacs-solo-crafters-custom-variables)

(provide 'emacs-solo-crafters-theme)
;;; emacs-solo-crafters-theme.el ends here
