;;; emacs-solo-0x0.el --- Upload text and files to 0x0.st  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: convenience, tools
;; SPDX-License-Identifier: GPL-3.0-or-later
;;
;; Inspired by: https://codeberg.org/daviwil/dotfiles/src/branch/master/Emacs.org#headline-28

;;; Commentary:
;;
;; Provides functions to upload text or files to the 0x0.st paste
;; service directly from Emacs.  The resulting URL is copied to the
;; kill ring for easy pasting.
;;
;; `emacs-solo/0x0-upload-text' uploads the active region or the
;; entire buffer contents.
;;
;; `emacs-solo/0x0-upload-file' prompts for a file and uploads it.
;;
;; Requires `curl' to be available in PATH.

;;; Code:

(defun emacs-solo/0x0-upload-text ()
  "Upload the region or buffer contents to 0x0.st.
If a region is active, upload the selected text; otherwise upload
the entire buffer.  The returned URL is copied to the kill ring."
  (interactive)
  (let* ((contents (if (use-region-p)
                       (buffer-substring-no-properties (region-beginning) (region-end))
                     (buffer-string)))
         (temp-file (make-temp-file "0x0" nil ".txt" contents)))
    (message "Sending %s to 0x0.st..." temp-file)
    (let ((url (string-trim-right
                (shell-command-to-string
                 (format "curl -A 'curl/7.68.8' -s -F'file=@%s' https://0x0.st" temp-file)))))
      (message "The URL is %s" url)
      (kill-new url)
      (delete-file temp-file))))

(defun emacs-solo/0x0-upload-file (file-path)
  "Upload FILE-PATH to 0x0.st.
The returned URL is copied to the kill ring."
  (interactive "fSelect a file to upload: ")
  (message "Sending %s to 0x0.st..." file-path)
  (let ((url (string-trim-right
              (shell-command-to-string
               (format "curl -A 'curl/7.68.8' -s -F'file=@%s' https://0x0.st" (expand-file-name file-path))))))
    (message "The URL is %s" url)
    (kill-new url)))

(provide 'emacs-solo-0x0)
;;; emacs-solo-0x0.el ends here
