;;; emacs-solo-kusanagi-theme.el --- Ghost in the Shell inspired dark theme built on Modus  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Version: 0.1.0
;; Package-Requires: ((emacs "31.1") (modus-themes "5.0.0"))
;; Keywords: faces, themes
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Kusanagi is a dark cyberpunk theme inspired by Ghost in the Shell:
;; neon cyan and hot pink accents diving through a deep-space blue
;; background, with comments receding into the noise like static on
;; the net.
;;
;; It is a proper derivative theme built on the Modus themes
;; infrastructure (version 5+), using `modus-vivendi' as its base
;; palette.  It therefore inherits the full face coverage of the
;; Modus themes while applying the Kusanagi palette on top.
;;
;; Usage:
;;
;;     (add-to-list 'custom-theme-load-path "/path/to/this/directory")
;;     (load-theme 'emacs-solo-kusanagi t)

;;; Code:

(unless (require 'modus-themes nil :noerror)
  ;; Fall back to the copy bundled with Emacs (etc/themes is not in
  ;; `load-path', so a plain `require' cannot find it).
  (require-theme 'modus-themes))

;;;; User customization options

(defgroup emacs-solo-kusanagi-theme ()
  "Ghost in the Shell inspired dark theme.
Built on the Modus themes infrastructure."
  :group 'modus-themes
  :link '(url-link :tag "GitHub" "https://github.com/LionyxML/emacs-solo")
  :prefix "emacs-solo-kusanagi-"
  :tag "Kusanagi")

(defcustom emacs-solo-kusanagi-palette-user nil
  "Like `emacs-solo-kusanagi-palette' for user-defined entries.
This is meant to extend the palette with custom named colors and/or
semantic palette mappings.  Those may then be used in combination with
palette overrides (also see `modus-themes-common-palette-overrides' and
`emacs-solo-kusanagi-palette-overrides')."
  :group 'emacs-solo-kusanagi-theme
  :type '(repeat (list symbol (choice symbol string)))
  :link '(info-link "(modus-themes) Option to extend the palette for use with overrides"))

(defcustom emacs-solo-kusanagi-palette-overrides nil
  "Overrides for `emacs-solo-kusanagi-palette'.
Mirror the elements of the aforementioned palette, overriding
their value.

For overrides that are shared across all of the Modus themes,
refer to `modus-themes-common-palette-overrides'.

Theme-specific overrides take precedence over shared overrides."
  :group 'emacs-solo-kusanagi-theme
  :type '(repeat (list symbol (choice symbol string)))
  :link '(info-link "(modus-themes) Palette overrides"))

;;;; Palette
;;
;; Entries here take precedence over `modus-themes-vivendi-palette',
;; which provides every named color and semantic mapping not listed.

(defconst emacs-solo-kusanagi-palette
  (append
   '(
     ;; Basic values (only bg-main/fg-main bg-dim/fg-dim/fg-alt, which
     ;; feed shadow, metadata, etc.)

     (bg-main "#050810")            ; deep space
     (fg-main "#68b8cc")            ; teal-grey

     ;; Kusanagi named colors

     (bg-deep    "#080c16")
     (teal-soft  "#8ecede")
     (teal-dark  "#2a4a5a")
     (neon-cyan  "#00e5ff")
     (cyan-soft  "#00c5dd")
     (cyan-deep  "#00b8cc")
     (neon-green "#00cc77")
     (hot-pink   "#ff0044")
     (pink-soft  "#ff4466")
     (amber      "#ffaa00")
     (orange     "#ff8800")
     (purple     "#cc55ff")
     (teal-faint "#1a3a50")
     (teal-dim   "#2d5a70")         ; recedes like noise
     (teal-mid   "#4a7a8a")

     ;; Special purpose

     (bg-completion      "#0a1a2a")
     (bg-hl-line         "#0d1e2e")
     (bg-region          "#0d2840")
     (fg-region          teal-soft)
     (bg-hover-secondary "#0d2030")

     ;; Mode-line

     (bg-mode-line-active       "#0a1628")
     (fg-mode-line-active       teal-soft)
     (border-mode-line-active   unspecified)
     (bg-mode-line-inactive     bg-deep)
     (fg-mode-line-inactive     teal-dark)
     (border-mode-line-inactive unspecified)

     ;; Tab bar

     (bg-tab-bar     bg-main)
     (bg-tab-current bg-deep)
     (bg-tab-other   bg-main)

     ;; Diffs

     (bg-added          "#0a2018")
     (bg-added-refine   "#143a22")
     (bg-changed        "#0a1e38")
     (bg-changed-refine "#142840")
     (bg-removed        "#2a0a14")
     (bg-removed-refine "#3a1020")

     ;; General mappings

     (cursor neon-cyan)
     (name neon-cyan)
     (identifier purple)
     (fringe bg-main)

     (err hot-pink)
     (warning amber)
     (info neon-green)

     (bg-active bg-main)
     (bg-prominent-err bg-removed)
     (fg-prominent-err hot-pink)

     ;; Code mappings

     (builtin neon-cyan)
     (comment teal-dim)
     (constant pink-soft)
     (docstring teal-mid)
     (fnname cyan-soft)
     (keyword purple)
     (number amber)
     (property cyan-deep)
     (string neon-green)
     (type amber)
     (variable orange)

     ;; Accent mappings

     (accent-0 neon-cyan)
     (accent-1 hot-pink)

     ;; Completion mappings

     (bg-completion-match-0 bg-main)
     (bg-completion-match-1 bg-main)
     (bg-completion-match-2 bg-main)
     (bg-completion-match-3 bg-main)
     (fg-completion-match-0 neon-cyan)
     (fg-completion-match-1 hot-pink)
     (fg-completion-match-2 neon-green)
     (fg-completion-match-3 amber)

     ;; Date mappings

     (date-weekday neon-cyan)
     (date-weekend amber)

     ;; Line number mappings

     (bg-line-number-active unspecified)
     (bg-line-number-inactive bg-main)
     (fg-line-number-active neon-cyan)
     (fg-line-number-inactive teal-faint)

     ;; Link mappings

     (fg-link neon-cyan)

     ;; Mark mappings

     (bg-mark-delete bg-removed)
     (fg-mark-delete hot-pink)
     (bg-mark-select bg-changed)
     (fg-mark-select neon-cyan)

     ;; Prompt mappings

     (bg-prompt unspecified)
     (fg-prompt purple)

     ;; Prose mappings

     (bg-prose-block-contents "#0d1628")
     (bg-prose-block-delimiter bg-prose-block-contents)
     (fg-prose-block-delimiter teal-faint)
     (fg-prose-verbatim neon-green)

     ;; Search mappings

     (bg-search-current hot-pink)
     (fg-search-current bg-main)
     (bg-search-lazy bg-region)
     (fg-search-lazy teal-soft)
     (bg-search-static bg-region)
     (fg-search-static teal-soft)

     ;; Heading mappings

     (fg-heading-0 hot-pink)
     (fg-heading-1 pink-soft)
     (fg-heading-2 amber)
     (fg-heading-3 neon-green)
     (fg-heading-4 neon-cyan))
   modus-themes-vivendi-palette)
  "The entire palette of the `emacs-solo-kusanagi' theme.

This palette is based on `modus-themes-vivendi-palette' with the
Kusanagi colors taking precedence (palette lookup returns the first
match).

Named colors have the form (COLOR-NAME HEX-VALUE) with the former
as a symbol and the latter as a string.

Semantic color mappings have the form (MAPPING-NAME COLOR-NAME)
with both as symbols.  The latter is a named color that already
exists in the palette and is associated with a HEX-VALUE.")

;;;; Custom face overrides
;;
;; Faces whose styling cannot be expressed through palette mappings
;; alone (sizes, slants, or faces the Modus themes do not map).

(defconst emacs-solo-kusanagi-faces
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
    `(change-log-acknowledgment ((,c :foreground ,neon-cyan)))
    `(change-log-date ((,c :foreground ,neon-green)))
    `(change-log-name ((,c :foreground ,amber)))
    `(log-view-message ((,c :foreground ,neon-cyan)))
;;;;; completion
    `(modus-themes-completion-selected ((,c :background ,bg-completion :foreground ,teal-soft)))
;;;;; diff-mode
    `(diff-context ((,c :foreground ,teal-faint)))
    `(diff-file-header ((,c :foreground ,pink-soft)))
    `(diff-header ((,c :foreground ,neon-cyan)))
    `(diff-hunk-header ((,c :foreground ,amber)))
;;;;; gnus / message
    `(gnus-button ((,c :foreground ,neon-cyan)))
    `(gnus-group-mail-3 ((,c :foreground ,neon-cyan)))
    `(gnus-group-mail-3-empty ((,c :foreground ,neon-cyan)))
    `(gnus-header-content ((,c :foreground ,fg-main)))
    `(gnus-header-from ((,c :foreground ,purple)))
    `(gnus-header-name ((,c :foreground ,neon-green)))
    `(gnus-header-subject ((,c :foreground ,neon-cyan)))
    `(message-signature-separator ((,c :foreground ,neon-cyan)))
    `(message-separator ((,c :foreground ,teal-dim)))
;;;;; newsticker
    `(newsticker-extra-face ((,c :foreground ,teal-faint :height 0.8 :slant italic)))
    `(newsticker-feed-face ((,c :foreground ,hot-pink :height 1.2 :weight bold)))
    `(newsticker-treeview-face ((,c :foreground ,fg-main)))
    `(newsticker-treeview-selection-face ((,c :background ,bg-region :foreground ,teal-soft)))
;;;;; tab-bar
    ;; :box nil is load-bearing: the built-in `tab-bar-tab' defface sets a
    ;; `released-button' box on dark displays, and `tab-bar-tab-inactive'
    ;; inherits it.  Unlike the hacked-modus variant (which had modus-vivendi
    ;; enabled to supply a flat same-color box), this standalone theme drops
    ;; modus's own tab specs, so without :box nil the defface box leaks through
    ;; and every tab renders highlighted.
    `(tab-bar ((,c :background ,bg-main :foreground ,teal-dark :box nil)))
    `(tab-bar-tab ((,c :background ,bg-main :foreground ,teal-soft :underline nil :box nil)))
    `(tab-bar-tab-inactive ((,c :background ,bg-main :foreground ,teal-dim :box nil)))
    `(tab-bar-tab-group-current ((,c :background ,bg-main :foreground ,teal-soft :box nil)))
    `(tab-bar-tab-group-inactive ((,c :background ,bg-main :foreground ,teal-dark :box nil)))
;;;;; vc-dir
    ;; vc-dir-file already follows the `name' mapping (neon cyan)
    `(vc-dir-header-value ((,c :foreground ,fg-main))))
  "Custom face overrides for the `emacs-solo-kusanagi' theme.")

(defconst emacs-solo-kusanagi-custom-variables nil
  "Custom variable overrides for the `emacs-solo-kusanagi' theme.")

;;;; Instantiate the theme

(modus-themes-theme
 'emacs-solo-kusanagi
 'emacs-solo-kusanagi
 "Ghost in the Shell inspired dark cyberpunk theme.
Built on the Modus themes infrastructure (modus-vivendi base) with
neon cyan and hot pink accents against a deep-space blue background."
 'dark
 'emacs-solo-kusanagi-palette
 'emacs-solo-kusanagi-palette-user
 'emacs-solo-kusanagi-palette-overrides
 'emacs-solo-kusanagi-faces
 'emacs-solo-kusanagi-custom-variables)

(provide 'emacs-solo-kusanagi-theme)
;;; emacs-solo-kusanagi-theme.el ends here
