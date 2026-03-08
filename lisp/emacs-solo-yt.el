;;; emacs-solo-yt.el --- YouTube search and playback with yt-dlp and mpv  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: multimedia, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Search YouTube via yt-dlp and display results in a tabulated
;; list with async thumbnail loading.  Play videos with mpv.

;;; Code:

(use-package emacs-solo-youtube
  :ensure nil
  :no-require t
  :defer t
  :init
  (require 'tabulated-list)
  (require 'json)
  (require 'subr-x)

  (defvar youtube-search-max-results 10
    "Default max results for YouTube searches.")

  (defvar youtube-mpv-process nil
    "Holds the current mpv process started by YouTube results.")

  (defvar youtube-active-url nil
    "URL of the video currently being played.")

  (defvar-local youtube--thumbnail-cache nil
    "Alist mapping thumbnail URL -> propertized display string.")

  (defun youtube--first-thumb-url (entry)
    "Return the first thumbnail URL from yt-dlp ENTRY."
    (let ((thumbs (alist-get 'thumbnails entry)))
      (when (and thumbs (> (length thumbs) 0))
        (cdr (assoc 'url (aref thumbs 0))))))


  (defun youtube--thumb-retrieve-async (video-url thumb-url callback)
    "Retrieve THUMB-URL asynchronously and call CALLBACK with VIDEO-URL."
    (let ((fixed-url (if (and (stringp thumb-url) (string-prefix-p "//" thumb-url))
                         (concat "https:" thumb-url)
                       thumb-url)))
      (if-let* ((cached (cdr (assoc fixed-url youtube--thumbnail-cache))))
          (funcall callback video-url cached)
        (if (not (and (stringp fixed-url) (not (string-empty-p fixed-url))))
            (funcall callback video-url "[img]")
          (url-retrieve
           fixed-url
           (lambda (status)
             (let ((result "[img]"))
               (if (not (plist-get status :error))
                   (with-current-buffer (current-buffer)
                     (goto-char (point-min))
                     (when (search-forward "

" nil t)
                       (let* ((image-data (buffer-substring-no-properties (point) (point-max)))
                              (image-object (condition-case nil
                                                (create-image image-data 'jpeg t
                                                              :width 120 :height 68
                                                              :max-width 120 :max-height 68
                                                              :ascent 'center)
                                              (error nil))))
                         (when image-object
                           (setq result (propertize (format " %s " (make-string 12 ? )) 'display image-object)))))))
               (when (buffer-live-p (current-buffer))
                 (kill-buffer (current-buffer)))
               (push (cons fixed-url result) youtube--thumbnail-cache)
               (funcall callback video-url result)))
           nil ; cb-args
           t   ; quiet
           t))))) ; raw-data

  (defun youtube-search--parse-line (line)
    "Parse a single LINE of yt-dlp JSON output into an alist."
    (condition-case nil
        (json-parse-string line :object-type 'alist)
      (error nil)))

  (defun youtube-search--insert-results (results)
    "Insert RESULTS into the tabulated-list buffer.
Also fetch thumbnails asynchronously."
    (with-current-buffer (get-buffer-create "*YouTube Results*")
      (message "Processing youtube results...")
      (youtube-results-mode)
      (setq tabulated-list-entries
            (mapcar
             (lambda (r)
               (let* ((url (alist-get 'url r))
                      (title (or (alist-get 'title r) ""))
                      (channel (or (alist-get 'uploader r) ""))
                      (duration (or (alist-get 'duration_string r) ""))
                      (status (if (and youtube-active-url
                                       (string= url youtube-active-url))
                                  "▶" ""))
                      (thumb-url (youtube--first-thumb-url r)))

                 (when (and thumb-url (> (length thumb-url) 0))
                   (youtube--thumb-retrieve-async
                    url thumb-url
                    (lambda (video-url-cb thumb-prop)
                      (when (get-buffer "*YouTube Results*")
                        (with-current-buffer "*YouTube Results*"
                          (let ((entry (assoc video-url-cb tabulated-list-entries)))
                            (when entry
                              (aset (cadr entry) 1 thumb-prop)
                              (when (get-buffer-window (current-buffer))
                                (tabulated-list-print t)))))))))

                 (list url (vector status
                                   "[img]"
                                   title
                                   duration
                                   channel
                                   url))))
             results))
      (tabulated-list-init-header)
      (tabulated-list-print t)
      (display-buffer (current-buffer)))
    (message "Processing youtube results: Done!"))

  (defun youtube-search-async (query &optional max-results)
    "Search YouTube asynchronously using yt-dlp."
    (interactive "sSearch YouTube:
P")
    (let* ((buf (get-buffer-create "*YouTube Search Raw*"))
           (max-results (or max-results youtube-search-max-results)))
      (with-current-buffer buf (erase-buffer))
      (message "Searching YouTube...")
      (make-process
       :name "youtube-search"
       :buffer buf
       :command `("yt-dlp"
                  "--default-search" "ytsearchdate"
                  "--flat-playlist"
                  "--dump-json"
                  ,(format "ytsearch%d:%s" max-results query))
       :sentinel
       (lambda (p _e)
         (when (eq (process-status p) 'exit)
           (with-current-buffer (process-buffer p)
             (goto-char (point-min))
             (let (results)
               (while (not (eobp))
                 (let* ((line (string-trim (thing-at-point 'line t)))
                        (obj (and (not (string-empty-p line))
                                  (youtube-search--parse-line line))))
                   (when obj (push obj results)))
                 (forward-line 1))
               (message "YouTube search done.")
               (youtube-search--insert-results (nreverse results)))))))))

  ;; Table UI

  (define-derived-mode youtube-results-mode tabulated-list-mode "YouTube Results"
    "Major mode for displaying YouTube search results."
    (setq tabulated-list-format [("▶" 2 nil)
                                 ("Thumb" 20 nil)
                                 ("Title" 60 t)
                                 ("Duration" 10 t)
                                 ("Channel" 25 t)
                                 ("URL" 40 t)])
    (setq tabulated-list-padding 2)
    (setq tabulated-list-sort-key (cons "Title" nil))
    (tabulated-list-init-header))

  (defun youtube-results-play ()
    "Play the selected video with mpv."
    (interactive)
    (let* ((url (tabulated-list-get-id)))
      (when url
        (when (process-live-p youtube-mpv-process)
          (delete-process youtube-mpv-process)
          (setq youtube-mpv-process nil))
        (setq youtube-active-url url)
        (setq youtube-mpv-process
              (start-process "mpv" "*mpv*"
                             "mpv"
                             "--geometry=50%x50%"
                             "--autofit=640x360"
                             url))
        (youtube-search--refresh-status)
        (message "Playing: %s" url))))

  (defun youtube-results-stop ()
    "Stop current mpv process."
    (interactive)
    (if (process-live-p youtube-mpv-process)
        (progn
          (delete-process youtube-mpv-process)
          (setq youtube-mpv-process nil)
          (setq youtube-active-url nil)
          (youtube-search--refresh-status)
          (message "Stopped mpv."))
      (message "No mpv process running.")))

  (defun youtube-search--refresh-status ()
    "Refresh play status in the results buffer."
    (when (get-buffer "*YouTube Results*")
      (with-current-buffer "*YouTube Results*"
        (tabulated-list-print t))))

  ;; Keybindings
  (define-key youtube-results-mode-map (kbd "RET") #'youtube-results-play)
  (define-key youtube-results-mode-map (kbd "x")   #'youtube-results-stop)
  (define-key youtube-results-mode-map (kbd "s")   #'youtube-search-async))

(provide 'emacs-solo-yt)
;;; emacs-solo-yt.el ends here
