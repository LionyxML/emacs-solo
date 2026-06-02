;;; emacs-solo-khard.el --- Khard contacts browser  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: comm, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Browse and search khard (vCard CLI) contacts in a tabulated
;; list buffer.  Copy contact entries as "Name <email>" to the
;; kill ring.

;;; Code:

(use-package emacs-solo-khard
  :ensure nil
  :no-require t
  :defer t
  :init
  (require 'tabulated-list)

  (defvar emacs-solo-khard-buffer "*Khard Contacts*"
    "Buffer name for displaying khard contacts.")

  (defvar emacs-solo-khard-addressbooks '("gmail" "icloud")
    "Khard addressbooks to offer for new contacts.")

  (defun emacs-solo--khard-parsable (args)
    "Run `khard ARGS -p' and return list of tab-split rows."
    (let* ((output (shell-command-to-string (concat "khard " args " -p")))
           (lines (split-string output "\n" t)))
      (mapcar (lambda (l) (split-string l "\t")) lines)))

  (defun emacs-solo--khard-build-entries ()
    "Build `tabulated-list' entries from khard parsable output.
Joins `khard ls -p' (uid\tname\tbook) with `khard email -p' and
`khard phone -p' by contact name.  Entry id is the contact UID."
    (let* ((ls     (emacs-solo--khard-parsable "ls"))
           (emails (emacs-solo--khard-parsable "email --remove-first-line"))
           (phones (emacs-solo--khard-parsable "phone"))
           (email-map (make-hash-table :test 'equal))
           (phone-map (make-hash-table :test 'equal))
           (i 0)
           entries)
      (dolist (row emails)
        (let ((addr (nth 0 row)) (name (nth 1 row)))
          (when (and name (not (gethash name email-map)))
            (puthash name addr email-map))))
      (dolist (row phones)
        (let ((num (nth 0 row)) (name (nth 1 row)))
          (when (and name (not (gethash name phone-map)))
            (puthash name num phone-map))))
      (dolist (row ls)
        (let ((uid (nth 0 row)) (name (nth 1 row)) (book (nth 2 row)))
          (when (and uid name)
            (setq i (1+ i))
            (push (list uid
                        (vector (number-to-string i)
                                (or name "")
                                (or (gethash name phone-map) "")
                                (or (gethash name email-map) "")
                                (or book "")
                                (substring uid 0 (min 8 (length uid)))))
                  entries))))
      (nreverse entries)))

  (define-derived-mode emacs-solo-khard-mode tabulated-list-mode "Khard"
    "Major mode for viewing Khard contacts."
    (setq tabulated-list-format [("Index" 5 t)
                                 ("Name" 40 t)
                                 ("Phone" 25 t)
                                 ("Email" 40 t)
                                 ("Book" 10 t)
                                 ("UID" 8 t)])
    (setq tabulated-list-padding 2)
    (setq-local revert-buffer-function
                (lambda (&rest _) (emacs-solo/khard-list)))
    (tabulated-list-init-header))

  (defun emacs-solo--khard-row ()
    "Return plist (:uid UID :row LIST) for entry at point.
Errors if point is not on a contact row."
    (let ((id (tabulated-list-get-id))
          (entry (tabulated-list-get-entry)))
      (unless entry (user-error "No contact at point"))
      (list :uid id :row (append entry nil))))

  (defun emacs-solo/khard-list ()
    "Run khard and display contacts in a tabulated buffer."
    (interactive)
    (let ((entries (emacs-solo--khard-build-entries)))
      (with-current-buffer (get-buffer-create emacs-solo-khard-buffer)
        (emacs-solo-khard-mode)
        (setq tabulated-list-entries entries)
        (tabulated-list-print t)
        (switch-to-buffer (current-buffer)))))

  (defun emacs-solo/khard-search ()
    "Search khard contacts and copy `Name <email>' to kill ring."
    (interactive)
    (let ((rows (emacs-solo--khard-parsable "email --remove-first-line"))
          candidates)
      (dolist (row rows)
        (let ((addr (nth 0 row)) (name (nth 1 row)))
          (when (and name addr
                     (not (string-empty-p name))
                     (not (string-empty-p addr)))
            (push (format "%s <%s>" name addr) candidates))))
      (let ((res (completing-read "Search on Khard: " (nreverse candidates))))
        (kill-new res)
        (message ">>> emacs-solo: Copied contact %s" res)
        res)))

  (defun emacs-solo/khard-copy-email ()
    "Copy contact at point as `Name <email>'."
    (interactive)
    (let* ((row (plist-get (emacs-solo--khard-row) :row))
           (name (nth 1 row))
           (email (nth 3 row))
           (res (format "%s <%s>" name email)))
      (kill-new res)
      (message ">>> emacs-solo: Copied %s" res)))

  (defun emacs-solo/khard-add ()
    "Add new khard contact via stdin YAML."
    (interactive)
    (let* ((book (completing-read "Addressbook: "
                                  emacs-solo-khard-addressbooks nil t))
           (first-name (read-string "First name: "))
           (last-name (read-string "Last name: "))
           (email (read-string "Email: "))
           (phone (read-string "Phone (blank to skip): "))
           (yaml (concat
                  (format "First name: %s\n" first-name)
                  (format "Last name: %s\n" last-name)
                  (unless (string-empty-p email)
                    (format "Email:\n    home: %s\n" email))
                  (unless (string-empty-p phone)
                    (format "Phone:\n    home: %s\n" phone)))))
      (with-temp-buffer
        (insert yaml)
        (let ((exit (call-process-region (point-min) (point-max)
                                         "khard" nil
                                         (get-buffer-create "*khard-output*")
                                         nil
                                         "new" "-a" book)))
          (if (zerop exit)
              (progn
                (message ">>> emacs-solo: Added %s %s to %s" first-name last-name book)
                (when (derived-mode-p 'emacs-solo-khard-mode)
                  (emacs-solo/khard-list)))
            (pop-to-buffer "*khard-output*")
            (user-error "Failed adding new contact to khard"))))))

  (defun emacs-solo/khard-edit ()
    "Edit contact at point via khard.
Requires `server-start' so $EDITOR=emacsclient works."
    (interactive)
    (let* ((data (emacs-solo--khard-row))
           (uid (plist-get data :uid))
           (book (nth 4 (plist-get data :row))))
      (async-shell-command
       (format "khard edit -a %s %s"
               (shell-quote-argument book)
               (shell-quote-argument uid))
       "*khard-edit*")))

  (defun emacs-solo/khard-sync ()
    "Run `vdirsyncer sync' async."
    (interactive)
    (async-shell-command "vdirsyncer sync" "*vdirsyncer*"))

  (defun emacs-solo/khard-remove ()
    "Remove contact at point via khard."
    (interactive)
    (let* ((data (emacs-solo--khard-row))
           (uid (plist-get data :uid))
           (row (plist-get data :row))
           (name (nth 1 row))
           (book (nth 4 row)))
      (when (yes-or-no-p (format "Remove %s from %s? " name book))
        (let ((exit (call-process "khard" nil
                                  (get-buffer-create "*khard-output*")
                                  nil
                                  "remove" "--force" "-a" book uid)))
          (if (zerop exit)
              (progn
                (message ">>> emacs-solo: Removed %s" name)
                (emacs-solo/khard-list))
            (pop-to-buffer "*khard-output*")
            (user-error "Failed removing a contact from khard"))))))

  (define-key emacs-solo-khard-mode-map (kbd "a") #'emacs-solo/khard-add)
  (define-key emacs-solo-khard-mode-map (kbd "e") #'emacs-solo/khard-edit)
  (define-key emacs-solo-khard-mode-map (kbd "d") #'emacs-solo/khard-remove)
  (define-key emacs-solo-khard-mode-map (kbd "w") #'emacs-solo/khard-copy-email)
  (define-key emacs-solo-khard-mode-map (kbd "s") #'emacs-solo/khard-sync))

(provide 'emacs-solo-khard)
;;; emacs-solo-khard.el ends here
