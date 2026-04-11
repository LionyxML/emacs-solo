;;; emacs-solo-erc-image.el --- Inline images in ERC chat buffers  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: comm, multimedia
;; SPDX-License-Identifier: GPL-3.0-or-later
;;
;; Heavily based on https://github.com/kidd/erc-image.el/blob/master/erc-image.el

;;; Commentary:
;;
;; Automatically downloads and displays inline images (including
;; YouTube thumbnails) in ERC chat buffers.  Images are cached
;; locally and scaled to fit the window.

;;; Code:

(use-package emacs-solo-erc-image
  :if emacs-solo-enable-erc-image
  :ensure nil
  :no-require t
  :after erc
  :config
  (defvar erc-image-cache-directory
    ;; Prefer Emacs Solo's central cache-path registry when available,
    ;; so the directory is managed alongside every other cache dir.
    ;; Fall back to a self-contained default so this module keeps
    ;; working when copied into a config that doesn't define the
    ;; helper.
    (if (fboundp 'emacs-solo--cache-path)
        (emacs-solo--cache-path 'erc-image-cache-directory)
      (expand-file-name "cache/erc/images/" user-emacs-directory))
    "Cache directory for inline ERC images.")

  (unless (file-directory-p erc-image-cache-directory)
    (make-directory erc-image-cache-directory t))

  (defvar erc-image-max-width  300
    "Hard maximum width for inline ERC images (in pixels).")

  (defvar erc-image-max-height 300
    "Hard maximum height for inline ERC images (in pixels).")

  (require 'url-queue)

  (defun erc-image--create (file)
    (let* ((edges (window-inside-absolute-pixel-edges))
           (win-w (- (nth 2 edges) (nth 0 edges)))
           (win-h (- (nth 3 edges) (nth 1 edges)))
           (max-w (min win-w erc-image-max-width))
           (max-h (min win-h erc-image-max-height)))
      (create-image file nil nil
                    :max-width  max-w
                    :max-height max-h)))

  (defun erc-image--insert (status file marker)
    (unless (eq (car status) :error)
      (goto-char (point-min))
      (search-forward "\n\n")
      (let ((coding-system-for-write 'binary))
        (write-region (point) (point-max) file))
      (with-current-buffer (marker-buffer marker)
        (save-excursion
          (let ((inhibit-read-only t))
            ;; move to end of the message line
            (goto-char (marker-position marker))
            (end-of-line)
            (insert "\n"
                    (propertize " "
                                'display (erc-image--create file))
                    "\n"))))))

  (defvar erc-image-url-regexp
    (rx "." (or "png" "jpg" "jpeg" "gif" "webp" "bmp" "svg")
        (? (or "?" "#") (* nonl)) string-end)
    "Regexp matching URLs that look like images.")

  (defun erc-image--image-url-p (url)
    "Return non-nil if URL looks like an image."
    (and (stringp url)
         (string-match-p erc-image-url-regexp url)))

  (defun erc-image--youtube-video-id (url)
    (when (stringp url)
      (cond
       ;; youtube.com/watch?v=ID
       ((string-match "youtube\\.com/watch\\?.*v=\\([A-Za-z0-9_-]+\\)" url)
        (match-string 1 url))
       ;; youtu.be/ID
       ((string-match "youtu\\.be/\\([A-Za-z0-9_-]+\\)" url)
        (match-string 1 url))
       ;; youtube.com/shorts/ID
       ((string-match "youtube\\.com/shorts/\\([A-Za-z0-9_-]+\\)" url)
        (match-string 1 url)))))

  (defun erc-image--maybe-show ()
    (when (display-graphic-p)
      (save-excursion
        (goto-char (line-beginning-position))
        (when (search-forward "http" (line-end-position) t)
          (let* ((url (thing-at-point 'url t))
                 (yt-id (erc-image--youtube-video-id url))
                 (url (if yt-id
                          (format "https://img.youtube.com/vi/%s/hqdefault.jpg" yt-id)
                        url)))
            (when (and url
                       (erc-image--image-url-p url))
              (let ((file (make-temp-file
                           (expand-file-name "erc-img-" erc-image-cache-directory)))
                    (marker (copy-marker (line-end-position) t)))
                (url-queue-retrieve
                 url
                 (lambda (status)
                   (erc-image--insert status file marker))
                 nil
                 t))))))))

  (defun erc-image-cleanup-cache ()
    "Delete all cached ERC images."
    (interactive)
    (when (and (boundp 'erc-image-cache-directory)
               (file-directory-p erc-image-cache-directory)
               (yes-or-no-p "Delete all cached ERC images? "))
      (dolist (file (directory-files erc-image-cache-directory t "\\`[^.]"))
        (ignore-errors (delete-file file)))
      (message "ERC image cache cleared.")))

  (define-erc-module image nil
                     "Inline scaled images in ERC"
                     ((add-hook 'erc-insert-post-hook #'erc-image--maybe-show t)
                      (add-hook 'erc-send-post-hook   #'erc-image--maybe-show t))
                     ((remove-hook 'erc-insert-post-hook #'erc-image--maybe-show)
                      (remove-hook 'erc-send-post-hook   #'erc-image--maybe-show))
                     t)

  (add-hook 'erc-insert-post-hook #'erc-image--maybe-show t)
  (add-hook 'erc-send-post-hook   #'erc-image--maybe-show t))

(provide 'emacs-solo-erc-image)
;;; emacs-solo-erc-image.el ends here
