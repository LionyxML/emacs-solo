;;; emacs-solo-weather.el --- Weather forecast from wttr.in  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: tools, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Fetches weather forecast data from wttr.in and displays it
;; in a buffer with ANSI color support.

;;; Code:

(use-package emacs-solo-weather
  :ensure nil
  :no-require t
  :defer t
  :init
  (setq emacs-solo-weather-city "Indaiatuba")
  (setq emacs-solo-weather-refresh-interval (* 60 60))

  (defvar-local emacs-solo--weather-refresh-timer nil
    "Buffer-local timer refreshing wttr.in data.")

  (defun emacs-solo--weather-fetch-dispatch (which url1 url2 buffer)
    "Erase BUFFER and (re)fetch wttr.in data according to WHICH."
    (with-current-buffer buffer
      (read-only-mode -1)
      (erase-buffer)
      (insert "Fetching weather data...\n")
      (read-only-mode 1))
    (let ((footer
           (format "Update every %d min, next update will run at %s"
                   (/ emacs-solo-weather-refresh-interval 60)
                   (format-time-string
                    "%H:%M"
                    (time-add nil emacs-solo-weather-refresh-interval)))))
      (pcase which
        ('url1
         (emacs-solo--fetch-weather url1 buffer nil footer))
        ('url2
         (emacs-solo--fetch-weather url2 buffer t footer))
        (_
         (emacs-solo--fetch-weather url1 buffer)
         (emacs-solo--fetch-weather url2 buffer t footer)))))

  (defun emacs-solo/weather-buffer (&optional which)
    "Open a new buffer and asynchronously fetch wttr.in weather data.

Optional WHICH:
  \\='url1 → fetch only wttr.in
  \\='url2 → fetch only v2d.wttr.in
  nil   → fetch both.

The buffer refreshes every `emacs-solo-weather-refresh-interval' seconds;
the timer is cancelled when the buffer is killed."
    (interactive)
    (let* ((city (shell-quote-argument emacs-solo-weather-city))
           (buffer (get-buffer-create
                    (format "*Weather-%s-%s*"
                            (or which 'both)
                            (format-time-string "%Y-%m-%dT%H:%M:%S"))))
           (url1 (format "curl -s 'wttr.in/%s?F'" city))
           (url2 (format "curl -s 'v2n.wttr.in/%s?F&format=v2'" city)))
      (switch-to-buffer buffer)
      (emacs-solo--weather-fetch-dispatch which url1 url2 buffer)

      (with-current-buffer buffer
        (when (timerp emacs-solo--weather-refresh-timer)
          (cancel-timer emacs-solo--weather-refresh-timer))
        (setq emacs-solo--weather-refresh-timer
              (run-at-time emacs-solo-weather-refresh-interval
                           emacs-solo-weather-refresh-interval
                           (lambda ()
                             (if (buffer-live-p buffer)
                                 (emacs-solo--weather-fetch-dispatch
                                  which url1 url2 buffer)
                               (cancel-timer emacs-solo--weather-refresh-timer)))))
        (add-hook 'kill-buffer-hook
                  (lambda ()
                    (when (timerp emacs-solo--weather-refresh-timer)
                      (cancel-timer emacs-solo--weather-refresh-timer)))
                  nil t))))

  (defun emacs-solo--fetch-weather (cmd buffer &optional second footer)
    "Run CMD asynchronously and insert results into BUFFER.
If SECOND is non-nil, separate the results with a newline.
If FOOTER is non-nil, append it as the last line of BUFFER."
    (make-process
     :name "weather-fetch"
     :buffer (generate-new-buffer " *weather-temp*")
     :command (list "sh" "-c" cmd)
     :sentinel
     (lambda (proc _event)
       (when (eq (process-status proc) 'exit)
         (let ((output (with-current-buffer (process-buffer proc)
                         (buffer-string))))
           (kill-buffer (process-buffer proc))
           (setq output
                 (seq-reduce
                  (lambda (s rule) (replace-regexp-in-string (car rule) (cdr rule) s))
                  '(("⠀" . " ")
                    ("[\u2800-\u28FF]" . "*")
                    ("―" . "-")
                    (".*NEW.*" . " ")
                    (".*Follow.*" . " ")
                    ("[\x0f]" . ""))
                  output))
           (with-current-buffer buffer
             (read-only-mode -1)
             (goto-char (point-max))
             (when second (insert "\n\n"))
             (insert output)
             (when footer
               (insert "\n\n" footer "\n"))
             (ansi-color-apply-on-region (point-min) (point-max))
             (goto-char (point-min))
             (read-only-mode 1))))))))

(provide 'emacs-solo-weather)
;;; emacs-solo-weather.el ends here
