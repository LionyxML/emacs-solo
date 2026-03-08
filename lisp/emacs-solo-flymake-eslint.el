;;; emacs-solo-flymake-eslint.el --- Flymake backend for ESLint  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: languages, tools
;; SPDX-License-Identifier: GPL-3.0-or-later
;;
;; Adapted from: https://github.com/orzechowskid/flymake-eslint (archived)
;; Maybe as time passes I will need something more modern like:
;; https://github.com/orzechowskid/flymake-jsts

;;; Commentary:
;;
;; A Flymake backend that runs ESLint on the current buffer via
;; stdin.  Supports both text and JSON diagnostic formats and
;; can find project-local ESLint installations automatically.

;;; Code:

(use-package emacs-solo-flymake-eslint
  :if emacs-solo-enable-flymake-eslint
  :ensure nil
  :no-require t
  :defer t
  :hook
  ((typescript-ts-base-mode-hook . (lambda () (run-with-idle-timer 1 nil #'flymake-eslint-enable)))
   (js-base-mode-hook . (lambda () (run-with-idle-timer 1 nil #'flymake-eslint-enable))))
  :init
  (require 'cl-lib)
  (when (featurep 'project)
    (require 'project))
  (when (featurep 'json)
    (require 'json))

  (require 'tramp)

  (defcustom flymake-eslint-executable-name "eslint"
    "Name of executable to run when checker is called.
Must be present in variable `exec-path'."
    :type 'string
    :group 'emacs-solo)

  (defcustom flymake-eslint-executable-args nil
    "Extra arguments to pass to eslint."
    :type '(choice string (repeat string))
    :group 'emacs-solo)

  (defcustom flymake-eslint-show-rule-name t
    "When non-nil show eslint rule name in flymake diagnostic."
    :type 'boolean
    :group 'emacs-solo)

  (defcustom flymake-eslint-defer-binary-check t
    "Defer the eslint binary presence check.
When non-nil, the initial check, which ensures that eslint binary
is present, is disabled.  Instead, this check is performed during
backend execution.

Useful when the value of variable `exec-path' is set dynamically
and the location of eslint might not be known ahead of time."
    :type 'boolean
    :group 'emacs-solo)

  (defcustom flymake-eslint-project-root nil
    "Buffer-local.
Set to a filesystem path to use that path as the current working
directory of the linting process."
    :type 'string
    :group 'emacs-solo)

  (defcustom flymake-eslint-prefer-json-diagnostics t
    "Try to use the JSON diagnostic format when running eslint.
This gives more accurate diagnostics but requires having an Emacs
installation with JSON support."
    :type 'boolean
    :group 'emacs-solo)

  (defcustom flymake-eslint-project-markers
    '("eslint.config.js" "eslint.config.mjs" "eslint.config.cjs" "package.json")
    "List of files indicating the root of a JavaScript project.

flymake-eslint starts ESLint at the root of your JavaScript
project. This root is defined as the first directory containing a file
of this list, starting from the value of `default-directory' in the
current buffer.

Adding a \".eslintrc.js\" entry (or another supported extension) to this
list only makes sense if there is at most one such file per project."
    :type '(repeat string)
    :group 'emacs-solo)

  (defvar flymake-eslint--message-regexp
    (rx bol (* space) (group (+ num)) ":" (group (+ num)) ; line:col
        (+ space) (group (or "error" "warning"))          ; type
        (+ space) (group (+? anychar))                    ; message
        (>= 2 space) (group (* not-newline)) eol)         ; rule name
    "Regexp to match eslint messages.")

  (defvar-local flymake-eslint--process nil
    "Handle to the linter process for the current buffer.")

  (defun flymake-eslint-enable ()
    "Enable Flymake and flymake-eslint.
Add this function to some js major mode hook."
    (interactive)
    (unless flymake-eslint-defer-binary-check
      (flymake-eslint--ensure-binary-exists))
    (make-local-variable 'flymake-eslint-project-root)
    (flymake-mode t)
    (add-hook 'flymake-diagnostic-functions 'flymake-eslint--checker nil t))

  (defun flymake-eslint--executable-args ()
    "Get additional arguments for `flymake-eslint-executable-name'.
Return `flymake-eslint-executable-args' value and ensure that
this is a list."
    (if (listp flymake-eslint-executable-args)
        flymake-eslint-executable-args
      (list flymake-eslint-executable-args)))

  (defun flymake-eslint--ensure-binary-exists ()
    "Ensure that `flymake-eslint-executable-name' exists.
Otherwise, throw an error and tell Flymake to disable this
backend if `flymake-eslint-executable-name' can't be found in
variable `exec-path'"
    (unless (executable-find flymake-eslint-executable-name t)
      (let ((option 'flymake-eslint-executable-name))
        (error "Can't find \"%s\" in exec-path - try to configure `%s'"
               (symbol-value option) option))))

  (defun flymake-eslint--get-position (line column buffer)
    "Get the position at LINE and COLUMN for BUFFER."
    (with-current-buffer buffer
      (save-excursion
        (when (and line column)
          (goto-char (point-min))
          (forward-line (1- line))
          (forward-char (1- column))
          (point)))))

  (defun flymake-eslint--diag-from-eslint (eslint-diag buffer)
    "Transform ESLINT-DIAG diagnostic for BUFFER into a Flymake one."
    (let* ((beg-line (gethash "line" eslint-diag))
           (beg-col (gethash "column" eslint-diag))
           (beg-pos (flymake-eslint--get-position beg-line beg-col buffer))
           (end-line (gethash "endLine" eslint-diag))
           (end-col (gethash "endColumn" eslint-diag))
           (end-pos (if end-line
                        (flymake-eslint--get-position end-line end-col buffer)
                      (cdr (flymake-diag-region buffer beg-line))))
           (lint-rule (gethash "ruleId" eslint-diag))
           (severity (gethash "severity" eslint-diag))
           (type (if (equal severity 1) :warning :error))
           (msg (gethash "message" eslint-diag))
           (full-msg (concat
                      msg
                      (when (and flymake-eslint-show-rule-name lint-rule)
                        (format " [%s]" lint-rule)))))
      (flymake-make-diagnostic
       buffer
       beg-pos
       end-pos
       type
       full-msg
       (list :rule-name lint-rule))))

  (defun flymake-eslint--report-json (eslint-stdout-buffer source-buffer)
    "Create Flymake diagnostics from the JSON diagnostic in ESLINT-STDOUT-BUFFER.
The diagnostics are reported against SOURCE-BUFFER."
    (if (featurep 'json)
        (with-current-buffer eslint-stdout-buffer
          (goto-char (point-min))
          (let* ((full-diagnostics (flymake-eslint--json-parse-buffer))
                 (eslint-diags (gethash "messages"(elt full-diagnostics 0))))
            (seq-map
             (lambda (diag)
               (flymake-eslint--diag-from-eslint diag source-buffer))
             eslint-diags)))
      (error
       "Tried to parse JSON diagnostics but current Emacs does not support it:")))

  (defun flymake-eslint--json-parse-buffer ()
    "Return eslint diagnostics in the current buffer.

The current buffer is expected to contain a JSON output of
diagnostics messages written by eslint.

The return value is a list containing a single element: a hash
table of eslint execution results.

When eslint crashes, the current buffer may contain non-JSON
output. In this case, the function returns the same kind of data
but the only contained error consists of information about the
crash."
    (condition-case nil
        (json-parse-buffer)
      (json-parse-error (flymake-eslint--generate-fake-diagnostics-from-non-json-output))))

  (defun flymake-eslint--generate-fake-diagnostics-from-non-json-output ()
    "Return a diagnostic list containing the reason for eslint's crash."
    (let ((eslint-message (make-hash-table :test 'equal)))
      (puthash "line" 1 eslint-message)
      (puthash "column" 1 eslint-message)
      (puthash "ruleId" "eslint" eslint-message)
      (puthash "severity" 2 eslint-message)
      (puthash "message"
               (buffer-substring-no-properties (point-min) (point-max))
               eslint-message)
      (let ((eslint-messages (list eslint-message))
            (result (make-hash-table :test 'equal)))
        (puthash "messages" eslint-messages result)
        (list result))))

  (defun flymake-eslint--use-json-p ()
    "Check if eslint diagnostics should be requested to be formatted as JSON."
    (and (featurep 'json) flymake-eslint-prefer-json-diagnostics))

  (defun flymake-eslint--report (eslint-stdout-buffer source-buffer)
    "Create Flymake diag messages from contents of ESLINT-STDOUT-BUFFER.
They are reported against SOURCE-BUFFER.  Return a list of
results."
    (with-current-buffer eslint-stdout-buffer
      ;; start at the top and check each line for an eslint message
      (goto-char (point-min))
      (if (looking-at-p "Error:")
          (pcase-let ((`(,beg . ,end) (with-current-buffer source-buffer
                                        (cons (point-min) (point-max))))
                      (msg (thing-at-point 'line t)))
            (list (flymake-make-diagnostic source-buffer beg end :error msg)))
        (cl-loop
         until (eobp)
         when (looking-at flymake-eslint--message-regexp)
         collect (let* ((row (string-to-number (match-string 1)))
                        (column (string-to-number (match-string 2)))
                        (type (match-string 3))
                        (msg (match-string 4))
                        (lint-rule (match-string 5))
                        (msg-text (concat (format "%s: %s" type msg)
                                          (when flymake-eslint-show-rule-name
                                            (format " [%s]" lint-rule))))
                        (type-symbol (pcase type ("warning" :warning) (_ :error)))
                        (src-pos (flymake-diag-region source-buffer row column)))
                   ;; new Flymake diag message
                   (flymake-make-diagnostic
                    source-buffer
                    (car src-pos)
                    ;; buffer might have changed size
                    (min (buffer-size source-buffer) (cdr src-pos))
                    type-symbol
                    msg-text
                    (list :rule-name lint-rule)))
         do (forward-line 1)))))

  ;; Heavily based on the example found at
  ;; https://www.gnu.org/software/emacs/manual/html_node/flymake/An-annotated-example-backend.html
  (defun flymake-eslint--create-process (source-buffer callback)
    "Create linter process for SOURCE-BUFFER.
CALLBACK is invoked once linter has finished the execution.
CALLBACK accepts a buffer containing stdout from linter as its
argument."
    (when (process-live-p flymake-eslint--process)
      (kill-process flymake-eslint--process))
    (let ((default-directory
           (or
            flymake-eslint-project-root
            (flymake-eslint--directory-containing-project-marker)
            (when (and (featurep 'project)
                       (project-current))
              (project-root (project-current)))
            default-directory))
          (format-args
           (if (flymake-eslint--use-json-p)
               '("--format" "json")
             ""))
          (file-name (let ((file-name (buffer-file-name source-buffer)))
                       (if (file-remote-p file-name)
                           (tramp-file-name-localname (tramp-dissect-file-name file-name))
                         file-name))))
      (setq flymake-eslint--process
            (make-process
             :name "flymake-eslint"
             :file-handler t
             :connection-type 'pipe
             :noquery t
             :buffer (generate-new-buffer " *flymake-eslint*")
             :command `(,flymake-eslint-executable-name
                        "--no-color"
                        "--no-ignore"
                        ,@format-args
                        "--stdin"
                        "--stdin-filename"
                        ,(or file-name (buffer-name source-buffer))
                        ,@(flymake-eslint--executable-args))
             :sentinel
             (lambda (proc &rest _ignored)
               (let ((status (process-status proc))
                     (buffer (process-buffer proc)))
                 (when (and (eq 'exit status)
                            ;; make sure we're not using a deleted buffer
                            (buffer-live-p source-buffer)
                            ;; make sure we're using the latest lint process
                            (eq proc (buffer-local-value 'flymake-eslint--process
                                                         source-buffer)))
                   ;; read from eslint output
                   (funcall callback buffer))
                 ;; destroy temp buffer when done or killed
                 (when (memq status '(exit signal))
                   (kill-buffer buffer))))))))

  (defun flymake-eslint--directory-containing-project-marker ()
    "Return the directory containing a project marker.

Return the first directory containing a file of
`flymake-eslint-project-markers', starting from the value of
`default-directory' in the current buffer."
    (locate-dominating-file
     default-directory
     (lambda (directory)
       (seq-find
        (lambda (project-marker)
          (file-exists-p (expand-file-name project-marker directory)))
        flymake-eslint-project-markers))))

  (defun flymake-eslint--check-and-report (source-buffer report-fn)
    "Run eslint against SOURCE-BUFFER.
Use REPORT-FN to report results."
    (when flymake-eslint-defer-binary-check
      (flymake-eslint--ensure-binary-exists))
    (let ((diag-builder-fn
           (if (flymake-eslint--use-json-p)
               'flymake-eslint--report-json
             'flymake-eslint--report)))
      (let ((content (buffer-string)))
        (if (string-empty-p content)
            (funcall report-fn (list))
          (flymake-eslint--create-process
           source-buffer
           (lambda (eslint-stdout)
             (funcall
              report-fn
              (funcall diag-builder-fn eslint-stdout source-buffer))))
          (with-current-buffer source-buffer
            (process-send-string flymake-eslint--process (buffer-string))
            (process-send-eof flymake-eslint--process))))))

  (defun flymake-eslint--checker (report-fn &rest _ignored)
    "Run eslint on the current buffer.
Report results using REPORT-FN.  All other parameters are
currently ignored."
    (flymake-eslint--check-and-report (current-buffer) report-fn)))

(provide 'emacs-solo-flymake-eslint)
;;; emacs-solo-flymake-eslint.el ends here
