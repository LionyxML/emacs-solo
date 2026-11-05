;;; emacs-solo-erc-image.el --- Inline images in ERC chat buffers  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "31.1"))
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

  (defun erc-image--create (file window)
    (create-image file nil nil
                  :max-width  (if window
                                  (min erc-image-max-width (window-body-width window t))
                                erc-image-max-width)
                  :max-height (if window
                                  (min erc-image-max-height (window-body-height window t))
                                erc-image-max-height)))

  (defun erc-image--put (file marker)
    "Insert image FILE at MARKER, keeping the prompt in view."
    (when-let* ((buffer (marker-buffer marker)))
      (with-current-buffer buffer
        (let ((windows (get-buffer-window-list buffer nil t)))
          (save-excursion
            (let ((inhibit-read-only t))
              (goto-char marker)
              (insert "\n" (propertize " " 'display
                                       (erc-image--create file (car windows))))))
          (when (bound-and-true-p erc-scrolltobottom-mode)
            (dolist (window windows)
              (with-selected-window window
                (erc-scroll-to-bottom))))))))

  (defun erc-image--fetch (url file marker)
    (url-queue-retrieve
     url
     (lambda (status)
       (let ((data (and (not (plist-get status :error))
                        (progn (goto-char (point-min))
                               (search-forward "\n\n" nil t))
                        (buffer-substring-no-properties (point) (point-max)))))
         (kill-buffer)
         (when (and data (image-type-from-data data))
           (let ((coding-system-for-write 'binary))
             (write-region data nil file nil 'silent))
           (erc-image--put file marker))))
     nil t))

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

  (defun erc-image--image-url (url)
    (if-let* ((id (erc-image--youtube-video-id url)))
        (format "https://img.youtube.com/vi/%s/hqdefault.jpg" id)
      (and (erc-image--image-url-p url) url)))

  (defun erc-image--message-urls ()
    "Image URLs in the current (narrowed) message."
    (save-excursion
      (goto-char (point-min))
      (let (urls)
        (while (re-search-forward "https?://" nil t)
          (when-let* ((img (erc-image--image-url (thing-at-point 'url t))))
            (push img urls)))
        (delete-dups (nreverse urls)))))

  (defun erc-image--maybe-show ()
    (when (display-graphic-p)
      (dolist (url (erc-image--message-urls))
        (let ((file (expand-file-name (md5 url) erc-image-cache-directory))
              (marker (copy-marker (1- (point-max)) t)))
          (if (file-exists-p file)
              ;; Deferred so the image lands after ERC finishes this message.
              (run-at-time 0 nil #'erc-image--put file marker)
            (erc-image--fetch url file marker))))))

  (defun erc-image-cleanup-cache ()
    "Delete all cached ERC images."
    (interactive)
    (when (and (boundp 'erc-image-cache-directory)
               (file-directory-p erc-image-cache-directory)
               (yes-or-no-p "Delete all cached ERC images? "))
      (dolist (file (directory-files erc-image-cache-directory t "\\`[^.]"))
        (ignore-errors (delete-file file)))
      (message ">>> emacs-solo: ERC image cache cleared.")))

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
