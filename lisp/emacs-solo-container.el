;;; emacs-solo-container.el --- Container management UI for Docker and Podman  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: tools, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; A control panel for basic container management (Docker and Podman).
;; Provides tabulated list views for containers, images, and volumes,
;; plus a transient menu for compose operations and container actions.

;;; Code:

(use-package emacs-solo-container
  :ensure nil
  :no-require t
  :defer t
  :init
  (require 'transient)
  (require 'project)

  (defvar container-backend 'podman
    "Container backend: \\='docker or \\='podman.")

  (defvar container-profile 'dev
    "Profile: \\='prod or \\='dev.")

  (defvar container-confirm nil
    "When non-nil, prompt to edit commands before running.")

  (defvar container-force nil
    "When non-nil, use --force on remove operations.")

  (defvar container--process nil)

  (defvar container--active-list nil
    "Currently active list: \\='containers, \\='images, \\='volumes, or nil.")

  (defvar container--marked-ids nil
    "List of marked entry IDs in the current list.")

  (defun container-toggle-backend ()
    "Toggle between Docker and Podman."
    (interactive)
    (setq container-backend (if (eq container-backend 'docker) 'podman 'docker))
    (message "Backend: %s" container-backend))

  (defun container-toggle-profile ()
    "Toggle between prod and dev profiles."
    (interactive)
    (setq container-profile (if (eq container-profile 'prod) 'dev 'prod))
    (message "Profile: %s (%s)" container-profile
             (if (eq container-profile 'prod)
                 "Dockerfile / docker-compose.yml"
               "Dockerfile.dev / docker-compose-dev.yml")))

  (defun container-toggle-confirm ()
    "Toggle command confirmation."
    (interactive)
    (setq container-confirm (not container-confirm))
    (message "Confirm: %s" (if container-confirm "ON" "OFF")))

  (defun container-toggle-force ()
    "Toggle --force on remove operations."
    (interactive)
    (setq container-force (not container-force))
    (message "Force: %s" (if container-force "ON" "OFF")))

  (defun container--command ()
    "Return the container backend command string."
    (symbol-name container-backend))

  (defun container--compose-command ()
    "Return the compose command string."
    (format "%s compose" (container--command)))

  (defun container--project-root ()
    "Return the project root or default-directory."
    (if-let* ((proj (project-current)))
        (project-root proj)
      default-directory))

  (defun container--project-name ()
    "Return the base name of the current project or buffer."
    (let* ((project (project-current))
           (name (if project
                     (file-name-nondirectory (directory-file-name (project-root project)))
                   (file-name-base (or buffer-file-name default-directory)))))
      (downcase name)))

  (defun container--dockerfile ()
    "Return the appropriate Dockerfile based on profile."
    (let ((base (container--project-name)))
      (pcase container-profile
        ('prod (or (car (file-expand-wildcards (format "%s.Dockerfile" base))) "Dockerfile"))
        ('dev  (or (car (file-expand-wildcards (format "%s.Dockerfile.dev" base))) "Dockerfile.dev")))))

  (defun container--compose-file ()
    "Return the appropriate compose file based on profile."
    (let ((root (container--project-root))
          (base (container--project-name)))
      (pcase container-profile
        ('prod (or (car (file-expand-wildcards (format "%s.docker-compose.yml" base)))
                   (concat root "docker-compose.yml")))
        ('dev  (or (car (file-expand-wildcards (format "%s.docker-compose-dev.yml" base)))
                   (concat root "docker-compose-dev.yml"))))))

  (defun container--has-dockerfile-p ()
    "Return non-nil if a Dockerfile exists in the project."
    (file-exists-p (expand-file-name (container--dockerfile) (container--project-root))))

  (defun container--has-compose-file-p ()
    "Return non-nil if a compose file exists in the project."
    (file-exists-p (container--compose-file)))

  (defun container--run-to-buffer (cmd-template)
    "Run CMD-TEMPLATE in *container-output* side buffer.
When `container-confirm' is non-nil, prompt to edit first."
    (let* ((final-cmd (if container-confirm
                          (read-shell-command "Command (confirm with RET): " cmd-template)
                        cmd-template))
           (buf (get-buffer-create "*container-output*")))
      (unless container-confirm
        (message "Running: %s" final-cmd))
      (with-current-buffer buf
        (setq buffer-read-only nil)
        (erase-buffer)
        (comint-mode)
        (ansi-color-for-comint-mode-on))
      (setq container--process
            (start-process-shell-command "container" buf final-cmd))
      (set-process-filter container--process 'comint-output-filter)
      (display-buffer buf '(display-buffer-in-side-window
                            . ((side . bottom) (window-height . 0.35))))))

  (defun container--run-compose (args)
    "Run a compose command with ARGS."
    (container--run-to-buffer
     (format "%s -f %s %s"
             (container--compose-command)
             (container--compose-file)
             args)))

  (defvar-keymap container-list-mode-map
    :doc "Keymap for container list mode."
    "n"   #'next-line
    "p"   #'previous-line
    "m"   #'container-mark
    "M"   #'container-unmark-all
    "s"   #'container-act-stop
    "S"   #'container-act-start
    "r"   #'container-act-restart
    "D"   #'container-act-remove
    "o"   #'container-act-logs
    "e"   #'container-act-shell
    "w"   #'container-act-copy-id
    "g"   #'container-list
    "i"   #'container-images
    "v"   #'container-volumes
    "?"   #'container-menu)

  (define-derived-mode container-list-mode tabulated-list-mode "Containers"
    "Major mode for managing containers.
n/p navigate | m mark | M unmark all
s stop | S start | r restart
D remove | o logs | e shell | w copy ID
g refresh | i images | v volumes | ? menu

\\{container-list-mode-map}"
    (setq tabulated-list-format [("ID" 12 t)
                                 ("Name" 25 t)
                                 ("Image" 30 t)
                                 ("Status" 25 t)
                                 ("Ports" 25 t)]
          tabulated-list-padding 2)
    (tabulated-list-init-header)
    (hl-line-mode 1))

  (defun container--get-id ()
    "Get container ID at point, or prompt if not in list."
    (if (eq major-mode 'container-list-mode)
        (let ((entry (tabulated-list-get-entry)))
          (if entry (string-trim (aref entry 0))
            (user-error "No container at point")))
      (read-string "Container ID/name: ")))

  (defun container--get-name ()
    "Get container name at point."
    (when (eq major-mode 'container-list-mode)
      (let ((entry (tabulated-list-get-entry)))
        (when entry (string-trim (aref entry 1))))))

  (defun container-list ()
    "List containers in an interactive tabulated buffer."
    (interactive)
    (setq container--active-list 'containers
          container--marked-ids nil)
    (let* ((cmd (format "%s ps -a --format '{{.ID}}\\t{{.Names}}\\t{{.Image}}\\t{{.Status}}\\t{{.Ports}}'"
                        (container--command)))
           (output (shell-command-to-string cmd))
           (lines (split-string (string-trim output) "\n" t))
           (entries (mapcar (lambda (line)
                              (let ((fields (split-string line "\t")))
                                (while (< (length fields) 5)
                                  (setq fields (append fields '(""))))
                                (list (nth 0 fields) (vconcat (seq-take fields 5)))))
                            lines)))
      (with-current-buffer (get-buffer-create "*containers*")
        (let ((pos (point)))
          (container-list-mode)
          (setq tabulated-list-entries entries)
          (tabulated-list-print t)
          (goto-char (min pos (point-max))))
        (switch-to-buffer (current-buffer)))))

  (defun container--act (action)
    "Run ACTION on selected containers (marked or at point), refresh list."
    (let* ((ids (container--selected-ids))
           (id-str (string-join ids " "))
           (cmd (format "%s %s %s" (container--command) action id-str)))
      (if container-confirm
          (container--run-to-buffer cmd)
        (message "%s %s..." action id-str)
        (let ((output (string-trim (shell-command-to-string cmd))))
          (message "%s: %s" action output))
        (setq container--marked-ids nil)
        (when (derived-mode-p 'container-list-mode)
          (container-list)))))

  (defun container-act-start ()
    "Start selected containers."
    (interactive) (container--act "start"))

  (defun container-act-stop ()
    "Stop selected containers."
    (interactive) (container--act "stop"))

  (defun container-act-restart ()
    "Restart selected containers."
    (interactive) (container--act "restart"))

  (defun container-act-remove ()
    "Remove selected containers (with confirmation)."
    (interactive)
    (let* ((ids (container--selected-ids))
           (count (length ids))
           (label (if (= count 1) (or (container--get-name) (car ids))
                    (format "%d containers" count))))
      (when (y-or-n-p (format "%s %s? "
                              (if container-force "Force remove" "Remove") label))
        (container--act (if container-force "rm --force" "rm")))))

  (defun container-act-logs ()
    "Stream logs for container at point, split to the right."
    (interactive)
    (let* ((id (container--get-id))
           (name (or (container--get-name) id))
           (cmd (format "%s logs -f %s" (container--command) id))
           (final-cmd (if container-confirm
                          (read-shell-command "Command: " cmd)
                        cmd))
           (buf (get-buffer-create (format "*container-logs-%s*" name))))
      (unless container-confirm
        (message "Running: %s" final-cmd))
      (with-current-buffer buf
        (setq buffer-read-only nil)
        (erase-buffer)
        (comint-mode)
        (ansi-color-for-comint-mode-on))
      (setq container--process
            (start-process-shell-command "container-logs" buf final-cmd))
      (set-process-filter container--process 'comint-output-filter)
      (display-buffer buf '(display-buffer-in-direction
                            . ((direction . right)
                               (window-width . 0.5))))))

  (defun container-act-shell ()
    "Open a shell in the container at point."
    (interactive)
    (let* ((id (container--get-id))
           (name (or (container--get-name) id))
           (shell (read-string "Shell: " "/bin/sh"))
           (buf-name (format "*container-shell-%s*" name)))
      (if (get-buffer buf-name)
          (switch-to-buffer buf-name)
        (let ((buf (make-term (format "container-shell-%s" name)
                              (container--command) nil "exec" "-it" id shell)))
          (switch-to-buffer buf)
          (term-mode)
          (term-char-mode)))))

  (defun container-act-copy-id ()
    "Copy selected IDs to kill ring (space-separated if multiple)."
    (interactive)
    (let* ((ids (or (container--selected-ids)
                    (list (read-string "ID to copy: "))))
           (str (string-join ids " ")))
      (kill-new str)
      (message "Copied: %s" str)))

  (defun container-nav-next ()
    "Move to next entry in the underlying list buffer."
    (interactive)
    (when (derived-mode-p 'tabulated-list-mode)
      (forward-line 1)))

  (defun container-nav-prev ()
    "Move to previous entry in the underlying list buffer."
    (interactive)
    (when (derived-mode-p 'tabulated-list-mode)
      (forward-line -1)))

  (defun container--selected-ids ()
    "Return marked IDs, or a list with just the ID at point."
    (or container--marked-ids
        (when (derived-mode-p 'tabulated-list-mode)
          (let ((id (tabulated-list-get-id)))
            (when id (list id))))))

  (defun container--multiple-marked-p ()
    "Return non-nil when more than one entry is marked."
    (> (length container--marked-ids) 1))

  (defun container-mark ()
    "Toggle mark on entry at point and move to next line."
    (interactive)
    (when (derived-mode-p 'tabulated-list-mode)
      (let ((id (tabulated-list-get-id)))
        (when id
          (if (member id container--marked-ids)
              (progn
                (setq container--marked-ids (delete id container--marked-ids))
                (tabulated-list-put-tag "  "))
            (push id container--marked-ids)
            (tabulated-list-put-tag "* "))
          (forward-line 1)))))

  (defun container-unmark-all ()
    "Unmark all entries."
    (interactive)
    (when (derived-mode-p 'tabulated-list-mode)
      (setq container--marked-ids nil)
      (save-excursion
        (goto-char (point-min))
        (while (not (eobp))
          (tabulated-list-put-tag "  ")
          (forward-line 1)))))

  (defvar-keymap container-image-mode-map
    :doc "Keymap for container image list mode."
    "n"   #'next-line
    "p"   #'previous-line
    "m"   #'container-mark
    "M"   #'container-unmark-all
    "D"   #'container-image-remove
    "w"   #'container-image-copy-id
    "g"   #'container-images
    "l"   #'container-list
    "v"   #'container-volumes
    "?"   #'container-menu)

  (define-derived-mode container-image-mode tabulated-list-mode "Images"
    "Major mode for managing container images.
n/p navigate | m mark | M unmark all | D remove | w copy ID
g refresh | l containers | v volumes | ? menu

\\{container-image-mode-map}"
    (setq tabulated-list-format [("ID" 12 t)
                                 ("Repository" 35 t)
                                 ("Tag" 15 t)
                                 ("Size" 12 t)]
          tabulated-list-padding 2)
    (tabulated-list-init-header)
    (hl-line-mode 1))

  (defun container-images ()
    "List images in an interactive tabulated buffer."
    (interactive)
    (setq container--active-list 'images
          container--marked-ids nil)
    (let* ((cmd (format "%s images --format '{{.ID}}\\t{{.Repository}}\\t{{.Tag}}\\t{{.Size}}'"
                        (container--command)))
           (output (shell-command-to-string cmd))
           (lines (split-string (string-trim output) "\n" t))
           (entries (mapcar (lambda (line)
                              (let ((fields (split-string line "\t")))
                                (while (< (length fields) 4)
                                  (setq fields (append fields '(""))))
                                (list (nth 0 fields) (vconcat (seq-take fields 4)))))
                            lines)))
      (with-current-buffer (get-buffer-create "*container-images*")
        (container-image-mode)
        (setq tabulated-list-entries entries)
        (tabulated-list-print t)
        (goto-char (point-min))
        (switch-to-buffer (current-buffer)))))

  (defun container-image-remove ()
    "Remove selected images."
    (interactive)
    (let* ((ids (container--selected-ids))
           (count (length ids))
           (label (if (= count 1)
                      (let ((entry (tabulated-list-get-entry)))
                        (format "%s:%s" (string-trim (aref entry 1))
                                (string-trim (aref entry 2))))
                    (format "%d images" count))))
      (when (y-or-n-p (format "%s %s? "
                              (if container-force "Force remove" "Remove") label))
        (message "%s"
                 (string-trim
                  (shell-command-to-string
                   (format "%s rmi %s %s" (container--command)
                           (if container-force "--force" "")
                           (string-join ids " ")))))
        (setq container--marked-ids nil)
        (container-images))))

  (defun container-image-copy-id ()
    "Copy image ID at point to kill ring."
    (interactive)
    (let* ((entry (tabulated-list-get-entry))
           (id (string-trim (aref entry 0))))
      (kill-new id)
      (message "Copied: %s" id)))

  (defvar-keymap container-volume-mode-map
    :doc "Keymap for container volume list mode."
    "n"   #'next-line
    "p"   #'previous-line
    "m"   #'container-mark
    "M"   #'container-unmark-all
    "D"   #'container-volume-remove
    "w"   #'container-volume-copy-name
    "RET" #'container-volume-inspect
    "g"   #'container-volumes
    "l"   #'container-list
    "i"   #'container-images
    "?"   #'container-menu)

  (define-derived-mode container-volume-mode tabulated-list-mode "Volumes"
    "Major mode for managing container volumes.
n/p navigate | m mark | M unmark all | D remove | w copy name
RET inspect | g refresh | l containers | i images | ? menu

\\{container-volume-mode-map}"
    (setq tabulated-list-format [("Name" 45 t)
                                 ("Driver" 15 t)
                                 ("Mountpoint" 50 t)]
          tabulated-list-padding 2)
    (tabulated-list-init-header)
    (hl-line-mode 1))

  (defun container-volumes ()
    "List volumes in an interactive tabulated buffer."
    (interactive)
    (setq container--active-list 'volumes
          container--marked-ids nil)
    (let* ((cmd (format "%s volume ls --format '{{.Name}}\\t{{.Driver}}\\t{{.Mountpoint}}'"
                        (container--command)))
           (output (shell-command-to-string cmd))
           (lines (split-string (string-trim output) "\n" t))
           (entries (mapcar (lambda (line)
                              (let ((fields (split-string line "\t")))
                                (while (< (length fields) 3)
                                  (setq fields (append fields '(""))))
                                (list (nth 0 fields) (vconcat (seq-take fields 3)))))
                            lines)))
      (with-current-buffer (get-buffer-create "*container-volumes*")
        (container-volume-mode)
        (setq tabulated-list-entries entries)
        (tabulated-list-print t)
        (goto-char (point-min))
        (switch-to-buffer (current-buffer)))))

  (defun container--volume-name-at-point ()
    "Get volume name at point."
    (let ((entry (tabulated-list-get-entry)))
      (if entry (string-trim (aref entry 0))
        (user-error "No volume at point"))))

  (defun container-volume-remove ()
    "Remove selected volumes."
    (interactive)
    (let* ((ids (container--selected-ids))
           (count (length ids))
           (label (if (= count 1) (car ids) (format "%d volumes" count))))
      (when (y-or-n-p (format "%s %s? "
                              (if container-force "Force remove" "Remove") label))
        (message "%s"
                 (string-trim
                  (shell-command-to-string
                   (format "%s volume rm %s %s" (container--command)
                           (if container-force "--force" "")
                           (string-join ids " ")))))
        (setq container--marked-ids nil)
        (container-volumes))))

  (defun container-volume-copy-name ()
    "Copy volume name at point to kill ring."
    (interactive)
    (let ((name (container--volume-name-at-point)))
      (kill-new name)
      (message "Copied: %s" name)))

  (defun container-volume-inspect ()
    "Inspect volume at point in output buffer."
    (interactive)
    (let ((name (container--volume-name-at-point)))
      (container--run-to-buffer
       (format "%s volume inspect %s" (container--command) name))))

  (defun container-build-image ()
    "Build an image from Dockerfile."
    (interactive)
    (container--run-to-buffer
     (format "%s build -f %s -t TAG ." (container--command) (container--dockerfile))))

  (defun container-pull-image ()
    "Pull a container image."
    (interactive)
    (container--run-to-buffer (format "%s pull " (container--command))))

  (defun container-run-new ()
    "Run a new container."
    (interactive)
    (container--run-to-buffer
     (format "%s run -it --rm -p 3500:3500 " (container--command))))

  (defun container-compose-up ()      (interactive) (container--run-compose "up -d"))
  (defun container-compose-down ()    (interactive) (container--run-compose "down"))
  (defun container-compose-logs ()    (interactive) (container--run-compose "logs -f"))
  (defun container-compose-ps ()      (interactive) (container--run-compose "ps"))
  (defun container-compose-build ()   (interactive) (container--run-compose "build"))
  (defun container-compose-restart () (interactive) (container--run-compose "restart"))

  (defun container-kill-output ()
    "Kill the *container-output* buffer."
    (interactive)
    (let ((buf (get-buffer "*container-output*")))
      (when buf (delete-windows-on buf) (kill-buffer buf))))

  (defun container--in-container-list-p ()
    (eq container--active-list 'containers))

  (defun container--in-image-list-p ()
    (eq container--active-list 'images))

  (defun container--in-volume-list-p ()
    (eq container--active-list 'volumes))

  (transient-define-prefix container-menu ()
    "Container and Compose management menu."
    :refresh-suffixes t
    [["Settings"
      ("b" (lambda () (format "Backend (%s)" container-backend))
       container-toggle-backend :transient t)
      ("f" (lambda () (format "Profile (%s)" container-profile))
       container-toggle-profile :transient t)
      ("!" (lambda () (format "Confirm (%s)" (if container-confirm "ON" "OFF")))
       container-toggle-confirm :transient t)
      ("F" (lambda () (format "Force rm (%s)" (if container-force "ON" "OFF")))
       container-toggle-force :transient t)]
     ["Browse"
      ("l" "Containers" container-list :transient t)
      ("i" "Images" container-images :transient t)
      ("v" "Volumes" container-volumes :transient t)]
     ["Navigate / Mark"
      ("n" "Next" container-nav-next :transient t)
      ("p" "Prev" container-nav-prev :transient t)
      ("m" "Mark" container-mark :transient t)
      ("M" "Unmark all" container-unmark-all :transient t)
      ("w" "Copy ID" container-act-copy-id :transient t)]]
    [["Container(s)"
      ("s" "Stop" container-act-stop
       :transient t :inapt-if-not container--in-container-list-p)
      ("S" "Start" container-act-start
       :transient t :inapt-if-not container--in-container-list-p)
      ("r" "Restart" container-act-restart
       :transient t :inapt-if-not container--in-container-list-p)
      ("D" "Remove" container-act-remove
       :transient t :inapt-if-not container--in-container-list-p)
      ("o" "Logs" container-act-logs
       :transient t :inapt-if-not container--in-container-list-p
       :inapt-if container--multiple-marked-p)
      ("e" "Shell" container-act-shell
       :inapt-if-not container--in-container-list-p
       :inapt-if container--multiple-marked-p)]
     ["Image(s)"
      ("R" "Remove" container-image-remove
       :transient t :inapt-if-not container--in-image-list-p)]
     ["Volume(s)"
      ("X" "Remove" container-volume-remove
       :transient t :inapt-if-not container--in-volume-list-p)
      ("O" "Inspect" container-volume-inspect
       :transient t :inapt-if-not container--in-volume-list-p
       :inapt-if container--multiple-marked-p)]]
    [["Run"
      ("N" "New container" container-run-new :transient t)
      ("P" "Pull image" container-pull-image :transient t)
      ("B" "Build image" container-build-image
       :transient t :inapt-if-not container--has-dockerfile-p)]
     ["Compose"
      ("u" "Up" container-compose-up
       :transient t :inapt-if-not container--has-compose-file-p)
      ("d" "Down" container-compose-down
       :transient t :inapt-if-not container--has-compose-file-p)
      ("c" "PS" container-compose-ps
       :transient t :inapt-if-not container--has-compose-file-p)
      ("C" "Build" container-compose-build
       :transient t :inapt-if-not container--has-compose-file-p)
      ("x" "Restart" container-compose-restart
       :transient t :inapt-if-not container--has-compose-file-p)
      ("G" "Logs" container-compose-logs
       :transient t :inapt-if-not container--has-compose-file-p)]
     [""
      ("k" "Kill output" container-kill-output :transient t)
      ("q" "Quit" transient-quit-one)]])

  (global-set-key (kbd "C-c d") #'container-menu))

(provide 'emacs-solo-container)
;;; emacs-solo-container.el ends here
