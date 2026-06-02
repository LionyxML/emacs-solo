;;; emacs-solo-khal.el --- Khal calendar browser  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: calendar, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Browse, add, edit and remove khal (CalDAV CLI) events in a
;; tabulated list buffer.  Edit and remove operate on the underlying
;; .ics files; pair with `vdirsyncer sync' (bound to `s') to push
;; changes back to the server.

;;; Code:

(use-package emacs-solo-khal
  :ensure nil
  :no-require t
  :defer t
  :init
  (require 'tabulated-list)

  (defvar emacs-solo-khal-buffer "*Khal Events*"
    "Buffer name for displaying khal events.")

  (defvar emacs-solo-khal-range "30d"
    "Range passed to `khal list today RANGE'.
Examples: \"30d\", \"7d\", \"today\".")

  (defvar emacs-solo-khal-calendars-dir
    (expand-file-name "~/.local/share/vdirsyncer/calendars/")
    "Local directory holding vdirsyncer calendar collections.
Used to locate `.ics' files for edit and remove.")

  (defvar emacs-solo-khal-default-calendar nil
    "Default calendar for new events.  Nil prompts every time.")

  (defvar emacs-solo--khal-fmt
    "EV\t{uid}\t{start}\t{end}\t{title}\t{calendar}\t{location}"
    "Format passed to `khal list -f' to emit tab-separated rows.
Sentinel \"EV\\t\" prefixes every event line so day-format headers
(set empty via `-df') and stray output can be filtered out.")

  (defun emacs-solo--khal-events ()
    "Return list of plists describing events in the configured range."
    (let* ((cmd (format "khal list today %s -df '' -f %s"
                        (shell-quote-argument emacs-solo-khal-range)
                        (shell-quote-argument emacs-solo--khal-fmt)))
           (output (shell-command-to-string cmd))
           events)
      (dolist (line (split-string output "\n" t))
        (when (string-prefix-p "EV\t" line)
          (let* ((cols (split-string (substring line 3) "\t")))
            (push (list :uid (nth 0 cols)
                        :start (nth 1 cols)
                        :end (nth 2 cols)
                        :title (nth 3 cols)
                        :calendar (nth 4 cols)
                        :location (or (nth 5 cols) ""))
                  events))))
      (nreverse events)))

  (defun emacs-solo--khal-calendars ()
    "Return list of calendar names from `khal printcalendars'."
    (split-string (shell-command-to-string "khal printcalendars") "\n" t))

  (defun emacs-solo--khal-build-entries ()
    "Build tabulated entries from `khal list -f' output."
    (let ((i 0))
      (mapcar
       (lambda (ev)
         (let ((uid   (or (plist-get ev :uid) ""))
               (title (or (plist-get ev :title) ""))
               (start (or (plist-get ev :start) ""))
               (end   (or (plist-get ev :end) ""))
               (cal   (or (plist-get ev :calendar) ""))
               (loc   (or (plist-get ev :location) "")))
           (setq i (1+ i))
           (list uid
                 (vector (number-to-string i)
                         start
                         end
                         title
                         cal
                         loc
                         (substring uid 0 (min 8 (length uid)))))))
       (emacs-solo--khal-events))))

  (define-derived-mode emacs-solo-khal-mode tabulated-list-mode "Khal"
    "Major mode for viewing Khal events."
    (setq tabulated-list-format [("Idx" 4 t)
                                 ("Start" 17 t)
                                 ("End" 17 t)
                                 ("Title" 40 t)
                                 ("Cal" 12 t)
                                 ("Where" 25 t)
                                 ("UID" 8 t)])
    (setq tabulated-list-padding 2)
    (setq-local revert-buffer-function
                (lambda (&rest _) (emacs-solo/khal-list)))
    (tabulated-list-init-header))

  (defun emacs-solo--khal-row ()
    "Return plist (:uid UID :row LIST) for entry at point."
    (let ((id (tabulated-list-get-id))
          (entry (tabulated-list-get-entry)))
      (unless entry (user-error "No event at point"))
      (list :uid id :row (append entry nil))))

  (defun emacs-solo--khal-find-ics (uid)
    "Return path to `.ics' file matching UID, or nil."
    (unless (and emacs-solo-khal-calendars-dir
                 (file-directory-p emacs-solo-khal-calendars-dir))
      (user-error "Set `emacs-solo-khal-calendars-dir' to a valid path"))
    (car (directory-files-recursively
          emacs-solo-khal-calendars-dir
          (concat "^" (regexp-quote uid) "\\.ics\\'"))))

  (defun emacs-solo/khal-list ()
    "List khal events in a tabulated buffer."
    (interactive)
    (let ((entries (emacs-solo--khal-build-entries)))
      (with-current-buffer (get-buffer-create emacs-solo-khal-buffer)
        (emacs-solo-khal-mode)
        (setq tabulated-list-entries entries)
        (tabulated-list-print t)
        (switch-to-buffer (current-buffer)))))

  (defun emacs-solo/khal-add ()
    "Create new khal event from minibuffer prompts."
    (interactive)
    (let* ((calendars (emacs-solo--khal-calendars))
           (cal (or emacs-solo-khal-default-calendar
                    (completing-read "Calendar: " calendars nil t)))
           (start (read-string "Start (e.g. 2026-05-18 14:00 or tomorrow 9am): "))
           (end (read-string "End (e.g. 15:00 or 1h or blank): "))
           (summary (read-string "Summary: "))
           (location (read-string "Location (blank to skip): "))
           (args (append
                  (list "new" "-a" cal)
                  (when (not (string-empty-p location))
                    (list "-l" location))
                  (list start)
                  (unless (string-empty-p end) (list end))
                  (list summary))))
      (let ((exit (apply #'call-process "khal" nil
                         (get-buffer-create "*khal-output*")
                         nil args)))
        (if (zerop exit)
            (progn
              (message ">>> emacs-solo: Added event %s" summary)
              (when (derived-mode-p 'emacs-solo-khal-mode)
                (emacs-solo/khal-list)))
          (pop-to-buffer "*khal-output*")
          (user-error "khal new failed")))))

  (defun emacs-solo/khal-edit ()
    "Open `.ics' file for event at point.
Save the buffer then `s' from the list to push via vdirsyncer."
    (interactive)
    (let* ((uid (plist-get (emacs-solo--khal-row) :uid))
           (path (emacs-solo--khal-find-ics uid)))
      (unless path (user-error "No .ics file found for UID %s" uid))
      (find-file path)))

  (defun emacs-solo/khal-remove ()
    "Delete the `.ics' file for event at point."
    (interactive)
    (let* ((data (emacs-solo--khal-row))
           (uid (plist-get data :uid))
           (row (plist-get data :row))
           (title (nth 3 row))
           (path (emacs-solo--khal-find-ics uid)))
      (unless path (user-error "No .ics file found for UID %s" uid))
      (when (yes-or-no-p (format "Delete event %S (%s)? " title path))
        (delete-file path)
        (message ">>> emacs-solo: Deleted %s. Run `s' to sync." title)
        (emacs-solo/khal-list))))

  (defun emacs-solo/khal-copy-summary ()
    "Copy event title at point to kill ring."
    (interactive)
    (let* ((row (plist-get (emacs-solo--khal-row) :row))
           (title (nth 3 row)))
      (kill-new title)
      (message ">>> emacs-solo: Copied %s" title)))

  (defun emacs-solo/khal-sync ()
    "Run `vdirsyncer sync' async."
    (interactive)
    (async-shell-command "vdirsyncer sync" "*vdirsyncer*"))

  (define-key emacs-solo-khal-mode-map (kbd "a") #'emacs-solo/khal-add)
  (define-key emacs-solo-khal-mode-map (kbd "e") #'emacs-solo/khal-edit)
  (define-key emacs-solo-khal-mode-map (kbd "d") #'emacs-solo/khal-remove)
  (define-key emacs-solo-khal-mode-map (kbd "w") #'emacs-solo/khal-copy-summary)
  (define-key emacs-solo-khal-mode-map (kbd "s") #'emacs-solo/khal-sync))

(provide 'emacs-solo-khal)
;;; emacs-solo-khal.el ends here
