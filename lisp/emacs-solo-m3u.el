;;; emacs-solo-m3u.el --- M3U playlist viewer and online radio player  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: multimedia, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Parse and display M3U playlists in a tabulated list buffer.
;; Supports downloading online radio playlists and playing streams
;; via mpv.  Includes inline logo display support.
;;
;; TLDR: C-c r (select an online radio list to download)
;;       RET - play with mpv
;;       x   - stop with mpv
;;
;; TODO: make already downloaded list the default when reopening with C-c r

;;; Code:

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

  (defvar m3u-visualizer-buffer "*M3U Playlist*"
    "Buffer name for the visualized M3U playlist.")

  (defvar-local m3u-visualizer--entries nil
    "List of parsed entries as (TITLE GROUP LOGO URL).")

  (defvar-local m3u-visualizer--active-url nil
    "Currently active/playing entry URL.")

  (defvar m3u-visualizer--mpv-process nil
    "Holds the current mpv process instance.")

  (defun m3u-visualizer--collect-entries-from-buffer ()
    "Parse current buffer as M3U and return list of (title group logo url)."
    (let ((entries '()))
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward
                ;; Match lines like: #EXTINF:-1 [optional attributes], Title
                "^#EXTINF:-1\\(?:\\s-+\\([^,]+\\)\\)?[ \t]*,[ \t]*\\(.*?\\)[ \t]*[\r\n]+\\(http[^\r\n]+\\)"
                nil t)
          (let* ((attr-str (match-string 1))
                 (title (string-trim (match-string 2)))
                 (url (match-string 3))
                 (logo "")
                 (group ""))
            (when attr-str
              (when (string-match "tvg-logo=\"\\([^\"]*\\)\"" attr-str)
                (setq logo (match-string 1 attr-str)))
              (when (string-match "group-title=\"\\([^\"]*\\)\"" attr-str)
                (setq group (match-string 1 attr-str))))
            (push (list title group logo url) entries))))
      (nreverse entries)))

  (define-derived-mode m3u-visualizer-mode tabulated-list-mode "M3U-Visualizer"
    "Major mode for viewing M3U playlists in a table."
    (setq tabulated-list-format
          [(" " 2 nil)   ;; status marker (▶)
           ("Title" 50 t)
           ("Group" 20 t)
           ("Logo" 40 t)
           ("URL" 60 t)])
    (setq tabulated-list-padding 2)
    (tabulated-list-init-header)
    (setq truncate-lines t)
    (buffer-disable-undo))

  (defun m3u-visualizer--build-tab-entries ()
    "Return tabulated-list entries built from `m3u-visualizer--entries'."
    (mapcar (lambda (entry)
              (let* ((title (or (nth 0 entry) ""))
                     (group (or (nth 1 entry) ""))
                     (logo  (or (nth 2 entry) ""))
                     (url   (or (nth 3 entry) ""))
                     (status (if (and m3u-visualizer--active-url
                                      (string= url m3u-visualizer--active-url))
                                 "▶"
                               "")))
                ;; id = url (helps us find the row later)
                (list url (vector status title group logo url))))
            m3u-visualizer--entries))

  (defun m3u-visualizer--refresh ()
    "Refresh the tabulated buffer from `m3u-visualizer--entries'."
    (setq tabulated-list-entries (m3u-visualizer--build-tab-entries))

    (tabulated-list-print t)

    (when m3u-visualizer--active-url
      (goto-char (point-min))
      (when (re-search-forward (regexp-quote m3u-visualizer--active-url) nil t)
        (beginning-of-line))))

  (defun m3u-visualizer-open-buffer (&optional raw-buffer)
    "Parse RAW-BUFFER (M3U contents) and pop to the tabulated view.
If RAW-BUFFER is nil, use the current buffer."
    (interactive)
    (let ((raw-buffer (or raw-buffer (current-buffer))))
      (with-current-buffer raw-buffer
        (let ((entries (m3u-visualizer--collect-entries-from-buffer)))
          (with-current-buffer (get-buffer-create m3u-visualizer-buffer)
            (let ((inhibit-read-only t))
              (erase-buffer)
              (m3u-visualizer-mode)
              (setq m3u-visualizer--entries entries)
              (m3u-visualizer--refresh)
              (pop-to-buffer (current-buffer))))))))

  (defun emacs-solo/get-online-radio-list-m3u ()
    "Select and download an online M3U playlist, then visualize it."
    (interactive)
    (let* ((choice (completing-read "Choose your Online Radio playlist: " emacs-solo/m3u-radio-sources))
           (url (cdr (assoc choice emacs-solo/m3u-radio-sources)))
           (raw-buffer (get-buffer-create "*M3U Raw*")))
      (message "Getting the playlist...")
      (url-retrieve
       url
       (lambda (_status)
         (goto-char (point-min))
         (when (re-search-forward "\n\n" nil t)
           (let* ((body-start (point))
                  (raw (buffer-substring-no-properties body-start (point-max)))
                  (decoded (decode-coding-string raw 'utf-8)))
             (with-current-buffer raw-buffer
               (let ((inhibit-read-only t))
                 (erase-buffer)
                 (insert decoded)
                 (message "Playlist loaded!")
                 (goto-char (point-min))
                 (m3u-visualizer-open-buffer (current-buffer)))))))
       nil t)))

  (defun m3u-visualizer--mpv-sentinel (proc _event)
    "Sentinel for mpv PROC. When it ends, clear active marker and refresh."
    ;; When process is no longer live, clear the active marker and refresh the table
    (unless (process-live-p proc)
      (let ((buf (process-get proc 'm3u-buffer)))
        (when (buffer-live-p buf)
          (with-current-buffer buf
            (setq m3u-visualizer--active-url nil)
            (setq m3u-visualizer--mpv-process nil)
            (m3u-visualizer--refresh))))))

  (defun m3u-visualizer--kill-mpv ()
    "Force kill the current mpv process if running."
    (when (and m3u-visualizer--mpv-process
               (process-live-p m3u-visualizer--mpv-process))
      ;; First try SIGTERM
      (ignore-errors (kill-process m3u-visualizer--mpv-process))
      ;; If still alive, send SIGKILL
      (when (process-live-p m3u-visualizer--mpv-process)
        (ignore-errors (signal-process (process-id m3u-visualizer--mpv-process) 9)))
      ;; Wait until it's gone
      (while (process-live-p m3u-visualizer--mpv-process)
        (sleep-for 0.05))
      (setq m3u-visualizer--mpv-process nil)))

  (defun m3u-visualizer-play-current ()
    "Play the stream URL at point using mpv and mark the row as playing."
    (interactive)
    (let ((url (tabulated-list-get-id)))
      (unless url (user-error "No URL at point"))

      (m3u-visualizer--kill-mpv)

      (setq m3u-visualizer--active-url url)
      (let ((proc (start-process "mpv-stream" "*mpv*" "mpv" "--no-terminal" url)))
        (setq m3u-visualizer--mpv-process proc)
        (process-put proc 'm3u-buffer (current-buffer))
        (set-process-sentinel
         proc
         (lambda (p _e)
           (when (not (process-live-p p))
             (let ((buf (process-get p 'm3u-buffer)))
               (when (buffer-live-p buf)
                 (with-current-buffer buf
                   (setq m3u-visualizer--active-url nil)
                   (setq m3u-visualizer--mpv-process nil)
                   (m3u-visualizer--refresh))))))))
      (m3u-visualizer--refresh)
      (message "Playing: %s" url)))

  (defun m3u-visualizer-stop-mpv ()
    "Stop current mpv process and clear playing marker."
    (interactive)
    (if (and m3u-visualizer--mpv-process (process-live-p m3u-visualizer--mpv-process))
        (progn
          (kill-process m3u-visualizer--mpv-process)
          ;; sentinel will clear marker, but do it immediately for snappiness
          (setq m3u-visualizer--mpv-process nil)
          (setq m3u-visualizer--active-url nil)
          (m3u-visualizer--refresh)
          (message "Stopped mpv."))
      (message "No mpv process running.")))


  (defvar-local m3u-visualizer--logo-cache nil
    "Alist mapping logo-URL -> propertized display string (cached images).")

  (defun m3u-visualizer--find-entry-by-url (url)
    "Return the entry (list) from `m3u-visualizer--entries'.
whose 4th element equals URL."
    (catch 'found
      (dolist (e m3u-visualizer--entries)
        (when (and (nth 3 e) (string= (nth 3 e) url))
          (throw 'found e)))
      nil))


  (defun m3u-visualizer-toggle-logo-at-point ()
    "Toggle inline logo image for the entry at point.

If the logo column is a URL, download (or reuse cached) image and replace the
logo field in `m3u-visualizer--entries' with a propertized string that has a
`display' property. If it's already an image, restore the original URL text."
    (interactive)
    (let* ((id (tabulated-list-get-id)) ;; stream URL (we use it to find the entry)
           (entry (and id (m3u-visualizer--find-entry-by-url id))))
      (unless entry (user-error "No entry at point"))

      (let ((logo (nth 2 entry))) ;; the entry's logo field (string or propertized string)
        (cond
         ;; If it's already a propertized string with a display property -> hide it.
         ((and (stringp logo) (get-text-property 0 'display logo))
          (let ((orig (get-text-property 0 'orig-url logo)))
            (setf (nth 2 entry) (or orig ""))
            (message "Logo hidden")))
         ;; No logo info at all
         ((or (not logo) (string-empty-p logo))
          (message "No logo available for this entry"))
         ;; Otherwise: it's a URL string -> show image (use cache if present)
         (t
          (let ((cached (assoc logo m3u-visualizer--logo-cache)))
            (if cached
                (progn
                  (setf (nth 2 entry) (cdr cached))
                  (message "Logo loaded! (from cache)"))
              (message "Getting playlist entry logo...")
              (let ((img-buf (url-retrieve-synchronously logo t t 6)))
                (unless img-buf (user-error "Failed to fetch logo: %s" logo))
                (with-current-buffer img-buf
                  (goto-char (point-min))
                  (when (search-forward "\n\n" nil t)
                    (let* ((data (buffer-substring-no-properties (point) (point-max)))
                           ;; adjust scale to taste - 0.3..0.6 are reasonable for table cells
                           (img (create-image data nil t :scale 0.6))
                           (disp (propertize " " 'display img 'orig-url logo)))
                      ;; cache and set entry's logo field to the propertized display string
                      (push (cons logo disp) m3u-visualizer--logo-cache)
                      (setf (nth 2 entry) disp)
                      (message "Logo loaded!"))))))))))
      ;; Rebuild the table from the (now-modified) m3u-visualizer--entries
      (m3u-visualizer--refresh)))

  (global-set-key (kbd "C-c r") #'emacs-solo/get-online-radio-list-m3u)
  (define-key m3u-visualizer-mode-map (kbd "RET") #'m3u-visualizer-play-current)
  (define-key m3u-visualizer-mode-map (kbd "x")   #'m3u-visualizer-stop-mpv)
  (define-key m3u-visualizer-mode-map (kbd "n")   #'next-line)
  (define-key m3u-visualizer-mode-map (kbd "p")   #'previous-line)
  (define-key m3u-visualizer-mode-map (kbd "i") #'m3u-visualizer-toggle-logo-at-point))

(provide 'emacs-solo-m3u)
;;; emacs-solo-m3u.el ends here
