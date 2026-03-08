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

  (defun emacs-solo/weather-buffer (&optional which)
    "Open a new buffer and asynchronously fetch wttr.in weather data.

Optional WHICH:
  \\='url1 → fetch only wttr.in
  \\='url2 → fetch only v2d.wttr.in
  nil   → fetch both."
    (interactive)
    (let* ((city (shell-quote-argument emacs-solo-weather-city))
           (buffer (get-buffer-create
                    (format "*Weather-%s*"
                            (format-time-string "%Y-%m-%dT%H:%M:%S"))))
           (url1 (format "curl -s 'wttr.in/%s?format'" city))
           (url2 (format "curl -s 'v2d.wttr.in/%s?format'" city)))
      (with-current-buffer buffer
        (read-only-mode -1)
        (erase-buffer)
        (insert "Fetching weather data...\n")
        (read-only-mode 1))
      (switch-to-buffer buffer)

      (pcase which
        ('url1
         (emacs-solo--fetch-weather url1 buffer))
        ('url2
         (emacs-solo--fetch-weather url2 buffer t))
        (_
         (emacs-solo--fetch-weather url1 buffer)
         (emacs-solo--fetch-weather url2 buffer t)))))

  (defun emacs-solo--fetch-weather (cmd buffer &optional second)
    "Run CMD asynchronously and insert results into BUFFER.
If SECOND is non-nil, separate the results with a newline."
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
                  '(("[\u2800-\u28FF]" . "*")
                    ("―" . "-")
                    (".*NEW.*" . " ")
                    (".*Follow.*" . " ")
                    ("[\x0f]" . ""))
                  output))
           (with-current-buffer buffer
             (read-only-mode -1)
             (when second (insert "\n\n"))
             (insert output)
             (ansi-color-apply-on-region (point-min) (point-max))
             (goto-char (point-min))
             (read-only-mode 1))))))))

(provide 'emacs-solo-weather)
;;; emacs-solo-weather.el ends here
