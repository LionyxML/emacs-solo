;;; emacs-solo-icons.el --- File type icon definitions for Emacs Solo  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: faces, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Defines file type icon mappings (emoji and nerd-font variants)
;; used by other Emacs Solo features (dired, eshell, ibuffer).

;;; Code:

(use-package emacs-solo-icons
  :if emacs-solo-enabled-icons
  :ensure nil
  :no-require t
  :defer t
  :init
  ;; TODO: make this a single list of lists for each icon set
  (let ((emoji-icons
         '(("el" . "📜")       ("rb" . "💎")       ("js" . "⚙️")      ("ts" . "⚙️")
           ("json" . "🗂️")     ("md" . "📝")       ("txt" . "📝")     ("html" . "🌐")
           ("css" . "🎨")      ("scss" . "🎨")     ("png" . "🖼️")     ("jpg" . "🖼️")
           ("jpeg" . "🖼️")     ("gif" . "🖼️")      ("svg" . "🖼️")     ("pdf" . "📄")
           ("zip" . "📦")      ("tar" . "📦")      ("gz" . "📦")      ("bz2" . "📦")
           ("7z" . "📦")       ("org" . "🦄")      ("sh" . "💻")      ("c" . "🅲")
           ("h" . "📘")        ("cpp" . "🅲")      ("hpp" . "📘")     ("py" . "🐍")
           ("java" . "☕")    ("go" . "🌍")       ("rs" . "💨")      ("php" . "🐘")
           ("pl" . "🐍")       ("lua" . "🎮")      ("ps1" . "🔧")     ("exe" . "⚡")
           ("dll" . "🔌")      ("bat" . "⚡")     ("yaml" . "⚙️")    ("toml" . "⚙️")
           ("ini" . "⚙️")      ("csv" . "📊")      ("xls" . "📊")     ("xlsx" . "📊")
           ("sql" . "🗄️")      ("log" . "📝")      ("apk" . "📱")     ("dmg" . "💻")
           ("iso" . "💿")      ("torrent" . "🧲")  ("bak" . "🗃️")     ("tmp" . "⚠️")
           ("desktop" . "🖥️")  ("md5" . "🔐")      ("sha256" . "🔐")  ("pem" . "🔐")
           ("sqlite" . "🗄️")   ("db" . "🗄️")       ("gpg" . "🔐")     ("hash" . "#️⃣")
           ("mp3" . "🎶")      ("wav" . "🎶")      ("flac" . "🎶" )  ("mail" . "📧")
           ("ogg" . "🎶")      ("m4a" . "🎶")      ("mp4" . "🎬")     ("avi" . "🎬")
           ("mov" . "🎬")      ("mkv" . "🎬")      ("webm" . "🎬")    ("flv" . "🎬")
           ("ico" . "🖼️")      ("ttf" . "🔠")      ("otf" . "🔠")     ("eot" . "🔠")
           ("woff" . "🔠")     ("woff2" . "🔠")    ("epub" . "📚")    ("mobi" . "📚")
           ("azw3" . "📚")     ("fb2" . "📚")      ("chm" . "📚")     ("tex" . "📚")
           ("bib" . "📚")      ("apk" . "📱")      ("rar" . "📦")     ("xz" . "📦")
           ("zst" . "📦")      ("tar.xz" . "📦")   ("tar.zst" . "📦") ("tar.gz" . "📦")
           ("tgz" . "📦")      ("bz2" . "📦")      ("mpg" . "🎬")     ("webp" . "🖼️")
           ("flv" . "🎬")      ("3gp" . "🎬")      ("ogv" . "🎬")     ("srt" . "🔠")
           ("vtt" . "🔠")      ("cue" . "📀")      ("terminal" . "💻") ("info" . "ℹ️")
           ("direddir" . "📁") ("diredfile" . "📄") ("wranch" . "🔧") ("news" . "📰")))
        (nerd-icons
         '(("el" . "")       ("rb" . "")       ("js" . "")      ("ts" . "")
           ("json" . "")     ("md" . "")       ("txt" . "")     ("html" . "")
           ("css" . "")      ("scss" . "")     ("png" . "")     ("jpg" . "")
           ("jpeg" . "")     ("gif" . "")      ("svg" . "")     ("pdf" . "")
           ("zip" . "")      ("tar" . "")      ("gz" . "")      ("bz2" . "")
           ("7z" . "")       ("org" . "")      ("sh" . "")      ("c" . "")
           ("h" . "")        ("cpp" . "")      ("hpp" . "")     ("py" . "")
           ("java" . "")    ("go" . "")       ("rs" . "")      ("php" . "")
           ("pl" . "")       ("lua" . "")      ("ps1" . "")     ("exe" . "")
           ("dll" . "")      ("bat" . "")     ("yaml" . "")    ("toml" . "")
           ("ini" . "")      ("csv" . "")      ("xls" . "")     ("xlsx" . "")
           ("sql" . "")      ("log" . "")      ("apk" . "")     ("dmg" . "")
           ("iso" . "")      ("torrent" . "")  ("bak" . "")     ("tmp" . "")
           ("desktop" . "")  ("md5" . "")      ("sha256" . "")  ("pem" . "")
           ("sqlite" . "")   ("db" . "")       ("gpg" . "")     ("hash" . "")
           ("mp3" . "")      ("wav" . "")      ("flac" . "" )   ("mail" . "")
           ("ogg" . "")      ("m4a" . "")      ("mp4" . "")     ("avi" . "")
           ("mov" . "")      ("mkv" . "")      ("webm" . "")    ("flv" . "")
           ("ico" . "")      ("ttf" . "")      ("otf" . "")     ("eot" . "")
           ("woff" . "")     ("woff2" . "")    ("epub" . "")    ("mobi" . "")
           ("azw3" . "")     ("fb2" . "")      ("chm" . "")     ("tex" . "")
           ("bib" . "")      ("rar" . "")     ("xz" . "")
           ("zst" . "")      ("tar.xz" . "")   ("tar.zst" . "") ("tar.gz" . "")
           ("tgz" . "")      ("bz2" . "")      ("mpg" . "")     ("webp" . "")
           ("flv" . "")      ("3gp" . "")      ("ogv" . "")     ("srt" . "")
           ("vtt" . "")      ("cue" . "")      ("terminal" . "") ("info" . "ℹ")
           ("direddir" . "") ("diredfile" . "") ("wranch" . "") ("news" . ""))))

    (defvar emacs-solo/file-icons
      (mapcar
       '(lambda (p)
          (if (char-displayable-p (string-to-char (cdr p)))
              p
            (cons (car p) "")))
       (cond
        ;; If nerd icons are enabled, use them.
        ((memq 'nerd emacs-solo-enabled-icons)
         nerd-icons)

        ;; If on kitty terminal AND NOT using nerd icons, use blank icons
        ;; to prevent emoji rendering issues.
        '((string= (getenv "TERM") "xterm-kitty")
          (mapcar (lambda (p) (cons (car p) "")) emoji-icons))

        ;; Otherwise, use the default emoji icons if displayable.
        (t
         emoji-icons)))
      "Icons for specific file extensions in Dired, Eshell and Ibuffer.")))

(provide 'emacs-solo-icons)
;;; emacs-solo-icons.el ends here
