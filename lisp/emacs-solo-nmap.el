;;; emacs-solo-nmap.el --- Nmap front-end for network scanning  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: net, tools, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; A small front-end around the `nmap' CLI.  `emacs-solo/nmap' opens
;; an interactive menu; the individual commands can also be called
;; directly:
;;
;;   emacs-solo/nmap            dispatch menu with every action below
;;   emacs-solo/nmap-discover   list every host up on the local network
;;   emacs-solo/nmap-report     detailed report of a single host
;;   emacs-solo/nmap-scan       port scan with a chosen profile / flags
;;   emacs-solo/nmap-ports      quick port scan of a single host
;;
;; `emacs-solo/nmap-discover' shows the network in a `tabulated-list'
;; buffer.  From there:
;;
;;   RET   detailed report of the host at point
;;   p     quick port scan of the host at point
;;   w     copy the host IP to the kill ring
;;   g     re-run the discovery scan
;;
;; Scans run asynchronously; output lands in a `special-mode' buffer
;; with ANSI colors decoded.  Some scans need root: OS detection
;; (`-O'), the aggressive `-A' profile, SYN scans, and -- notably --
;; `emacs-solo/nmap-discover', which without root cannot ARP the LAN
;; and therefore leaves the MAC and Vendor columns empty.  To run as
;; root set `emacs-solo-nmap-use-sudo' to t, or call any command with
;; a prefix argument (`C-u') to use sudo for that single run.
;;
;; Scans have no tty, so sudo cannot prompt for a password itself.  By
;; default (`emacs-solo-nmap-sudo-askpass' t) Emacs prompts once and
;; feeds it to `sudo -S'; set that variable to nil if your sudoers
;; grants passwordless access.
;;
;; Only scan hosts and networks you are authorized to scan.

;;; Code:

(use-package emacs-solo-nmap
  :ensure nil
  :no-require t
  :defer t
  :init
  (require 'tabulated-list)
  (require 'ansi-color)

  (defvar emacs-solo-nmap-executable "nmap"
    "Path to the nmap executable.")

  (defvar emacs-solo-nmap-use-sudo nil
    "When non-nil, run every scan through sudo.
A prefix argument to any command forces sudo for that single run
regardless of this value.")

  (defvar emacs-solo-nmap-sudo-askpass t
    "How sudo obtains its password when a scan needs root.
When non-nil, Emacs prompts with `read-passwd' and feeds it to
`sudo -S' over stdin (the scan runs without a tty, so sudo cannot
prompt on its own).  Set to nil if your sudoers grants nmap
NOPASSWD, in which case `sudo -n' is used and no prompt appears.")

  (defvar emacs-solo-nmap-network nil
    "Default network (CIDR) to scan, e.g. \"192.168.1.0/24\".
When nil, `emacs-solo--nmap-guess-network' probes `ip route' and,
failing that, prompts.")

  (defvar emacs-solo-nmap-profiles
    '(("Quick top-1000 ports"        . ("-F"))
      ("Service & version detection" . ("-sV"))
      ("Service + default scripts"   . ("-sV" "-sC"))
      ("All TCP ports"               . ("-p-"))
      ("Aggressive (-A, needs root)" . ("-A"))
      ("OS detection (-O, needs root)" . ("-O"))
      ("Ping only (host up?)"        . ("-sn")))
    "Alist of NAME to a list of nmap flags, used by `emacs-solo/nmap-scan'.")

  (defvar emacs-solo-nmap-buffer "*nmap*"
    "Buffer name for free-form scan output.")

  (defvar emacs-solo-nmap-discover-buffer "*nmap hosts*"
    "Buffer name for the network discovery list.")

  (defun emacs-solo--nmap-cidr (ip hexmask)
    "Return the network CIDR string for IP masked by HEXMASK.
IP is dotted-quad, HEXMASK is a hex netmask like \"ffffff00\"."
    (let* ((mask (string-to-number hexmask 16))
           (octets (mapcar #'string-to-number (split-string ip "\\.")))
           (ipint (logior (ash (nth 0 octets) 24) (ash (nth 1 octets) 16)
                          (ash (nth 2 octets) 8) (nth 3 octets)))
           (net (logand ipint mask))
           (prefix 0))
      (dotimes (bit 32)
        (unless (zerop (logand mask (ash 1 bit))) (setq prefix (1+ prefix))))
      (format "%d.%d.%d.%d/%d"
              (logand (ash net -24) 255) (logand (ash net -16) 255)
              (logand (ash net -8) 255) (logand net 255) prefix)))

  (defun emacs-solo--nmap-guess-network-linux ()
    "Guess the local network CIDR from `ip route' (Linux)."
    (when (executable-find "ip")
      (with-temp-buffer
        (when (zerop (call-process "ip" nil t nil "route"))
          (goto-char (point-min))
          (when (re-search-forward
                 "^\\([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+/[0-9]+\\)[^\n]*proto kernel"
                 nil t)
            (match-string 1))))))

  (defun emacs-solo--nmap-default-iface-bsd ()
    "Return the default-route interface name via `netstat' (BSD/macOS)."
    (when (executable-find "netstat")
      (with-temp-buffer
        (when (zerop (call-process "netstat" nil t nil "-rn" "-f" "inet"))
          (goto-char (point-min))
          (when (re-search-forward
                 "^default[ \t]+[^ \t]+[ \t]+[^ \t]+[ \t]+\\([^ \t\n]+\\)" nil t)
            (match-string 1))))))

  (defun emacs-solo--nmap-guess-network-bsd ()
    "Guess the local network CIDR from `ifconfig' (BSD/macOS).
Reads the inet addqress and netmask of the default interface."
    (let ((iface (emacs-solo--nmap-default-iface-bsd)))
      (when (and iface (executable-find "ifconfig"))
        (with-temp-buffer
          (when (zerop (call-process "ifconfig" nil t nil iface))
            (goto-char (point-min))
            ;; BSD/macOS: "inet 10.0.0.2 netmask 0xffffff00 ..."
            (when (re-search-forward
                   "inet \\([0-9.]+\\) netmask 0x\\([0-9a-fA-F]+\\)" nil t)
              (emacs-solo--nmap-cidr (match-string 1) (match-string 2))))))))

  (defun emacs-solo--nmap-guess-network ()
    "Best-effort guess of the local network in CIDR notation.
Works on Linux (`ip route'), and on BSD/macOS (`netstat' +
`ifconfig').  Returns a string like \"192.168.1.0/24\" or nil."
    (or (emacs-solo--nmap-guess-network-linux)
        (emacs-solo--nmap-guess-network-bsd)))

  (defun emacs-solo--nmap-read-network ()
    "Return the network to scan, prompting with a sensible default."
    (let ((default (or emacs-solo-nmap-network
                       (emacs-solo--nmap-guess-network)
                       "192.168.1.0/24")))
      (read-string (format "Network (CIDR) [%s]: " default) nil nil default)))

  (defun emacs-solo--nmap-read-host (&optional prompt)
    "Read a host or IP from the minibuffer, using PROMPT."
    (let ((host (read-string (or prompt "Host / IP: "))))
      (when (string-empty-p (string-trim host))
        (user-error "No host given"))
      (string-trim host)))

  (defun emacs-solo--nmap-sudo-p (sudo)
    "Return non-nil when this run should go through sudo."
    (or sudo emacs-solo-nmap-use-sudo))

  (defun emacs-solo--nmap-command (args sudo)
    "Return the command list running nmap with ARGS.
When SUDO is non-nil (or `emacs-solo-nmap-use-sudo'), prepend sudo.
With `emacs-solo-nmap-sudo-askpass' the password is read via stdin
\(sudo -S); otherwise passwordless sudo is assumed (sudo -n)."
    (append (when (emacs-solo--nmap-sudo-p sudo)
              (if emacs-solo-nmap-sudo-askpass
                  (list "sudo" "-S" "-p" "")
                (list "sudo" "-n")))
            (list emacs-solo-nmap-executable)
            args))

  (defun emacs-solo--nmap-start (args buffer sudo name sentinel &optional filter)
    "Start nmap with ARGS in BUFFER and return the process.
NAME names the process, SENTINEL and FILTER hook it.  When the run
needs sudo with `emacs-solo-nmap-sudo-askpass', prompt for the
password and feed it over stdin."
    (unless (executable-find (if (emacs-solo--nmap-sudo-p sudo)
                                 "sudo"
                               emacs-solo-nmap-executable))
      (user-error "Cannot find `%s' in PATH" emacs-solo-nmap-executable))
    (let* ((askpass (and (emacs-solo--nmap-sudo-p sudo)
                         emacs-solo-nmap-sudo-askpass))
           (password (when askpass (read-passwd "sudo password: ")))
           (proc (make-process
                  :name name
                  :buffer buffer
                  :command (emacs-solo--nmap-command args sudo)
                  :noquery t
                  :connection-type 'pipe
                  :filter filter
                  :sentinel sentinel)))
      (when password
        (process-send-string proc (concat password "\n"))
        (clear-string password))
      proc))

  (defun emacs-solo--nmap-run (args buffer-name &optional sudo)
    "Run nmap with ARGS asynchronously into BUFFER-NAME.
SUDO forces running through sudo.  Displays the buffer and decodes
ANSI colors as output arrives."
    (let* ((cmd (emacs-solo--nmap-command args sudo))
           (buffer (get-buffer-create buffer-name)))
      (with-current-buffer buffer
        (let ((inhibit-read-only t))
          (erase-buffer)
          (special-mode)
          (insert (propertize (format "$ %s\n\n" (string-join cmd " "))
                              'face 'shadow))))
      (emacs-solo--nmap-start args buffer sudo "emacs-solo-nmap"
                              #'emacs-solo--nmap-sentinel
                              #'emacs-solo--nmap-filter)
      (display-buffer buffer)
      (message ">>> emacs-solo: nmap running... (%s)" (string-join cmd " "))
      buffer))

  (defun emacs-solo--nmap-filter (proc string)
    "Insert STRING from PROC, decoding ANSI colors, keeping point at end."
    (when (buffer-live-p (process-buffer proc))
      (with-current-buffer (process-buffer proc)
        (let ((inhibit-read-only t)
              (at-end (and (eq (window-buffer (selected-window)) (current-buffer))
                           (>= (point) (process-mark proc)))))
          (save-excursion
            (goto-char (process-mark proc))
            (insert string)
            (ansi-color-apply-on-region (process-mark proc) (point))
            (set-marker (process-mark proc) (point)))
          (when at-end (goto-char (point-max)))))))

  (defun emacs-solo--nmap-sentinel (proc _event)
    "Report completion of nmap PROC in its buffer."
    (when (and (memq (process-status proc) '(exit signal))
               (buffer-live-p (process-buffer proc)))
      (with-current-buffer (process-buffer proc)
        (let ((inhibit-read-only t))
          (goto-char (point-max))
          (insert (propertize
                   (format "\n>>> emacs-solo: nmap finished (exit %s)\n"
                           (process-exit-status proc))
                   'face 'shadow))))
      (message ">>> emacs-solo: nmap finished (exit %s)"
               (process-exit-status proc))))

  (defun emacs-solo--nmap-parse-discovery (output)
    "Parse `nmap -sn' OUTPUT into a list of plists.
Each plist has :ip :host :latency :mac :vendor."
    (let (hosts current)
      (dolist (line (split-string output "\n"))
        (cond
         ((string-match
           "^Nmap scan report for \\(?:\\([^ ]+\\) (\\([0-9.]+\\))\\|\\([0-9.]+\\)\\)"
           line)
          (when current (push current hosts))
          (setq current
                (list :ip (or (match-string 2 line) (match-string 3 line))
                      :host (or (match-string 1 line) ""))))
         ((and current (string-match "Host is up (\\([^ )]*\\)" line))
          (setq current (plist-put current :latency (match-string 1 line))))
         ((and current (string-match "MAC Address: \\([0-9A-Fa-f:]+\\) ?(\\([^)]*\\))?"
                                     line))
          (setq current (plist-put current :mac (match-string 1 line)))
          (setq current (plist-put current :vendor (or (match-string 2 line) ""))))))
      (when current (push current hosts))
      (nreverse hosts)))

  (defun emacs-solo--nmap-discover-entries (hosts)
    "Turn parsed HOSTS (list of plists) into tabulated-list entries."
    (let ((i 0))
      (mapcar
       (lambda (h)
         (setq i (1+ i))
         (list (plist-get h :ip)
               (vector (number-to-string i)
                       (or (plist-get h :ip) "")
                       (or (plist-get h :host) "")
                       (or (plist-get h :latency) "")
                       (or (plist-get h :mac) "")
                       (or (plist-get h :vendor) ""))))
       hosts)))

  (define-derived-mode emacs-solo-nmap-mode tabulated-list-mode "Nmap"
    "Major mode for browsing hosts discovered by nmap."
    (setq tabulated-list-format [("Idx" 4 t)
                                 ("IP" 16 t)
                                 ("Host" 28 t)
                                 ("Latency" 12 t)
                                 ("MAC" 18 t)
                                 ("Vendor" 24 t)])
    (setq tabulated-list-padding 2)
    (setq tabulated-list-sort-key (cons "IP" nil))
    (tabulated-list-init-header))

  (defun emacs-solo--nmap-host-at-point ()
    "Return the IP of the host at point, or signal an error."
    (or (tabulated-list-get-id)
        (user-error "No host at point")))

  (defun emacs-solo--nmap-discover-finish (proc network)
    "Parse PROC output and populate the discovery buffer for NETWORK."
    (let* ((raw (with-current-buffer (process-buffer proc) (buffer-string)))
           (hosts (emacs-solo--nmap-parse-discovery raw))
           (entries (emacs-solo--nmap-discover-entries hosts))
           (buf (get-buffer emacs-solo-nmap-discover-buffer)))
      (kill-buffer (process-buffer proc))
      (when (buffer-live-p buf)
        (with-current-buffer buf
          (setq tabulated-list-entries entries)
          (setq mode-line-process nil)
          (tabulated-list-print t)))
      (message ">>> emacs-solo: found %d host(s) on %s"
               (length entries) network)))

  (defun emacs-solo/nmap-discover (&optional network sudo)
    "Discover every host up on NETWORK and list them.
Interactively prompts for the network (defaulting to the local
one).  Runs `nmap -sn' asynchronously and fills the list when it
finishes, so Emacs stays responsive.

With a prefix argument (or SUDO non-nil) run through sudo, which
enables ARP discovery and therefore resolves MAC addresses and
hardware vendors."
    (interactive (list nil current-prefix-arg))
    (let ((network (or network (emacs-solo--nmap-read-network))))
      (with-current-buffer (get-buffer-create emacs-solo-nmap-discover-buffer)
        (emacs-solo-nmap-mode)
        (setq-local revert-buffer-function
                    (lambda (&rest _) (emacs-solo/nmap-discover network sudo)))
        (setq mode-line-process (propertize " [scanning...]" 'face 'warning))
        (setq tabulated-list-entries nil)
        (tabulated-list-print t)
        (switch-to-buffer (current-buffer)))
      (emacs-solo--nmap-start
       (list "-sn" network)
       (generate-new-buffer " *nmap-discover-raw*")
       sudo "emacs-solo-nmap-discover"
       (lambda (proc _event)
         (when (memq (process-status proc) '(exit signal))
           (emacs-solo--nmap-discover-finish proc network))))
      (message ">>> emacs-solo: discovering hosts on %s... (running in background)"
               network)))

  (defun emacs-solo/nmap-discover-report ()
    "Detailed report of the host at point in the discovery list."
    (interactive)
    (emacs-solo/nmap-report (emacs-solo--nmap-host-at-point) current-prefix-arg))

  (defun emacs-solo/nmap-discover-ports ()
    "Quick port scan of the host at point in the discovery list."
    (interactive)
    (emacs-solo/nmap-ports (emacs-solo--nmap-host-at-point) current-prefix-arg))

  (defun emacs-solo/nmap-discover-copy-ip ()
    "Copy the IP of the host at point to the kill ring."
    (interactive)
    (let ((ip (emacs-solo--nmap-host-at-point)))
      (kill-new ip)
      (message ">>> emacs-solo: copied %s" ip)))

  (define-key emacs-solo-nmap-mode-map (kbd "RET") #'emacs-solo/nmap-discover-report)
  (define-key emacs-solo-nmap-mode-map (kbd "p")   #'emacs-solo/nmap-discover-ports)
  (define-key emacs-solo-nmap-mode-map (kbd "w")   #'emacs-solo/nmap-discover-copy-ip)

  (defun emacs-solo/nmap-report (&optional host sudo)
    "Detailed scan report of HOST (`-sV -sC').
With a prefix argument (or SUDO non-nil) run through sudo, which
also enables OS detection (`-O')."
    (interactive (list (emacs-solo--nmap-read-host "Report host / IP: ")
                       current-prefix-arg))
    (let* ((host (or host (emacs-solo--nmap-read-host "Report host / IP: ")))
           (args (append '("-sV" "-sC")
                         (when (or sudo emacs-solo-nmap-use-sudo) '("-O"))
                         (list host))))
      (emacs-solo--nmap-run args emacs-solo-nmap-buffer sudo)))

  (defun emacs-solo/nmap-ports (&optional host sudo)
    "Quick top-1000 port scan of HOST (`-F').
With a prefix argument (or SUDO non-nil) run through sudo."
    (interactive (list (emacs-solo--nmap-read-host "Port scan host / IP: ")
                       current-prefix-arg))
    (let ((host (or host (emacs-solo--nmap-read-host "Port scan host / IP: "))))
      (emacs-solo--nmap-run (list "-F" host) emacs-solo-nmap-buffer sudo)))

  (defun emacs-solo/nmap-scan (&optional sudo)
    "Scan a host using a profile picked from `emacs-solo-nmap-profiles'.
Also lets you append extra flags.  With a prefix argument (or SUDO
non-nil) run through sudo."
    (interactive "P")
    (let* ((host (emacs-solo--nmap-read-host "Scan host / IP: "))
           (name (completing-read "Profile: " emacs-solo-nmap-profiles nil t))
           (flags (cdr (assoc name emacs-solo-nmap-profiles)))
           (extra (read-string "Extra flags (blank to skip): "))
           (args (append flags
                         (unless (string-empty-p (string-trim extra))
                           (split-string extra))
                         (list host))))
      (emacs-solo--nmap-run args emacs-solo-nmap-buffer sudo)))

  (defvar emacs-solo-nmap-actions
    '(("Discover hosts on the local network" . emacs-solo/nmap-discover)
      ("Detailed report of a host"           . emacs-solo/nmap-report)
      ("Quick port scan of a host"           . emacs-solo/nmap-ports)
      ("Scan a host (pick a profile)"        . emacs-solo/nmap-scan))
    "Alist of menu label to command, used by `emacs-solo/nmap'.")

  (defun emacs-solo/nmap ()
    "Interactive nmap menu.
Pick an action from `emacs-solo-nmap-actions'."
    (interactive)
    (let* ((label (completing-read "nmap: " emacs-solo-nmap-actions nil t))
           (cmd (cdr (assoc label emacs-solo-nmap-actions))))
      (call-interactively cmd))))

(provide 'emacs-solo-nmap)
;;; emacs-solo-nmap.el ends here
