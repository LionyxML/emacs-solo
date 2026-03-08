;;; emacs-solo-rate.el --- Cryptocurrency and fiat exchange rate viewer  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: tools, convenience
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; Fetches cryptocurrency and fiat exchange rate data from rate.sx
;; and displays it in a buffer with ANSI color support.

;;; Code:

(use-package emacs-solo-rate
  :ensure nil
  :no-require t
  :defer t
  :init
  (setq emacs-solo-rate-crypto "BTC")
  (setq emacs-solo-rate-fiat "USD")

  (defun emacs-solo/rate-buffer (&optional which)
  "Open a new buffer and asynchronously fetch rate.sx data.

WHICH may be:
  \\='url1 → fetch only the crypto pair
  \\='url2 → fetch only the fiat summary
  nil   → fetch both"
  (interactive)
  (let* ((crypto (shell-quote-argument emacs-solo-rate-crypto))
         (fiat   (shell-quote-argument emacs-solo-rate-fiat))
         (buffer (get-buffer-create
                  (format "*Rate-%s*"
                          (format-time-string "%Y-%m-%dT%H:%M:%S"))))
         (url1   (format "curl -s '%s.rate.sx/%s'" fiat crypto))
         (url2   (format "curl -s '%s.rate.sx/'"   fiat)))
    (with-current-buffer buffer
      (read-only-mode -1)
      (erase-buffer)
      (read-only-mode 1))
    (switch-to-buffer buffer)

    (pcase which
      ('url1
       (emacs-solo--fetch-rate url1 buffer))
      ('url2
       (emacs-solo--fetch-rate url2 buffer t))
      (_
       (emacs-solo--fetch-rate url1 buffer)
       (emacs-solo--fetch-rate url2 buffer t)))))

  (defun emacs-solo--fetch-rate (cmd buffer &optional second)
    "Run CMD asynchronously and insert results into BUFFER.
If SECOND is non-nil, separate the results with a newline."
    (make-process
     :name "rate-fetch"
     :buffer (generate-new-buffer " *rate-temp*")
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
                    ("^Use.*" . " ")
                    (".*NEW.*" . " ")
                    (".*Follow.*" . " ")
                    ("[\x0f]" . ""))
                  output))
           (when second
             (setq output
                   (string-join
                    (nthcdr 5 (split-string output "\n"))
                    "\n")))
           (with-current-buffer buffer
             (read-only-mode -1)
             (when second (insert "\n\n"))
             (insert output)
             (ansi-color-apply-on-region (point-min) (point-max))
             (goto-char (point-min))
             (read-only-mode 1))))))))

(provide 'emacs-solo-rate)
;;; emacs-solo-rate.el ends here
