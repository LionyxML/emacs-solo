;;; emacs-solo-flymake-languagetool.el --- Flymake backend for LanguageTool  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "31.1"))
;; Keywords: wp, tools
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; A Flymake backend that runs LanguageTool on the current buffer via
;; stdin, so diagnostics follow unsaved edits.
;;
;; LanguageTool boots a JVM on every run (~1.5s here), so the checker
;; raises `flymake-no-changes-timeout' buffer-locally.  See
;; `flymake-languagetool-idle-delay'.
;;
;; The backend is always available.  `emacs-solo-enable-flymake-languagetool'
;; only decides whether `text-mode' buffers start with it on; either way
;; `flymake-languagetool-toggle' (`C-c ! C-t') turns it on or off per buffer.

;;; Code:

(use-package emacs-solo-flymake-languagetool
  :ensure nil
  :no-require t
  :defer t
  :init
  (require 'json)

  (defcustom flymake-languagetool-executable-name "languagetool"
    "Name of executable to run when checker is called.
Must be present in variable `exec-path'."
    :type 'string
    :group 'emacs-solo)

  (defcustom flymake-languagetool-executable-args nil
    "Extra arguments to pass to LanguageTool.
For instance `(\"--disable\" \"WHITESPACE_RULE\")' or `(\"--level\" \"PICKY\")'."
    :type '(choice string (repeat string))
    :group 'emacs-solo)

  (defcustom flymake-languagetool-language "en-US"
    "Language code passed to LanguageTool, e.g. \"en-US\" or \"pt-BR\".
Becomes buffer-local when changed with `flymake-languagetool-set-language'
or `flymake-languagetool-cycle-language'."
    :type 'string
    :group 'emacs-solo)

  (defcustom flymake-languagetool-favorite-languages '("en-US" "pt-BR")
    "Languages cycled through by `flymake-languagetool-cycle-language'."
    :type '(repeat string)
    :group 'emacs-solo)

  (defcustom flymake-languagetool-show-rule-name t
    "When non-nil show the LanguageTool rule id in the diagnostic."
    :type 'boolean
    :group 'emacs-solo)

  (defcustom flymake-languagetool-show-replacements t
    "When non-nil append LanguageTool's suggested replacements to the message."
    :type 'boolean
    :group 'emacs-solo)

  (defcustom flymake-languagetool-max-replacements 3
    "How many suggested replacements to show per diagnostic."
    :type 'integer
    :group 'emacs-solo)

  (defcustom flymake-languagetool-issue-type-severities
    '(("misspelling" . :warning)
      ("grammar" . :warning)
      ("duplication" . :warning)
      ("inconsistency" . :warning)
      ("typographical" . :note)
      ("whitespace" . :note)
      ("style" . :note))
    "Map LanguageTool `issueType' values to Flymake diagnostic types."
    :type '(alist :key-type string :value-type symbol)
    :group 'emacs-solo)

  (defcustom flymake-languagetool-default-severity :note
    "Flymake type used for issue types absent from
`flymake-languagetool-issue-type-severities'."
    :type 'symbol
    :group 'emacs-solo)

  (defcustom flymake-languagetool-idle-delay 3
    "Buffer-local value for `flymake-no-changes-timeout' when enabled.
LanguageTool pays a JVM startup on each run, so checking on every
short pause is wasteful.  Set to nil to leave the global value alone."
    :type '(choice integer (const nil))
    :group 'emacs-solo)

  (defcustom flymake-languagetool-inhibited-modes '(prog-mode)
    "Modes derived from `text-mode' that should not be checked."
    :type '(repeat symbol)
    :group 'emacs-solo)

  (defvar-local flymake-languagetool--process nil
    "Handle to the linter process for the current buffer.")

  (defun flymake-languagetool--executable-args ()
    "Return `flymake-languagetool-executable-args' as a list."
    (if (listp flymake-languagetool-executable-args)
        flymake-languagetool-executable-args
      (list flymake-languagetool-executable-args)))

  (defun flymake-languagetool--ensure-binary-exists ()
    "Error out when `flymake-languagetool-executable-name' is not in `exec-path'."
    (unless (executable-find flymake-languagetool-executable-name t)
      (error "Can't find \"%s\" in exec-path - try to configure `%s'"
             flymake-languagetool-executable-name
             'flymake-languagetool-executable-name)))

  (defun flymake-languagetool--command ()
    "Build the LanguageTool command line reading from stdin."
    `(,flymake-languagetool-executable-name
      "--json"
      "--encoding" "utf-8"
      "--language" ,flymake-languagetool-language
      ,@(flymake-languagetool--executable-args)
      "-"))

  (defun flymake-languagetool--replacements (match)
    "Return MATCH's suggested replacements as a string, or nil."
    (when-let* ((flymake-languagetool-show-replacements)
                (values (seq-take
                         (seq-map (lambda (r) (gethash "value" r))
                                  (gethash "replacements" match))
                         flymake-languagetool-max-replacements))
                ((not (seq-empty-p values))))
      (mapconcat (lambda (v) (format "\"%s\"" v)) values ", ")))

  (defun flymake-languagetool--diag-from-match (match buffer)
    "Transform LanguageTool MATCH for BUFFER into a Flymake diagnostic."
    (let* ((rule (gethash "rule" match))
           (rule-id (gethash "id" rule))
           (issue-type (gethash "issueType" rule))
           (type (or (cdr (assoc issue-type
                                 flymake-languagetool-issue-type-severities))
                     flymake-languagetool-default-severity))
           (suggestions (flymake-languagetool--replacements match))
           (msg (concat (gethash "message" match)
                        (when suggestions (format " -> %s" suggestions))
                        (when (and flymake-languagetool-show-rule-name rule-id)
                          (format " [%s]" rule-id)))))
      (with-current-buffer buffer
        ;; offsets are 0-based char offsets into the text we sent
        (let* ((beg (min (point-max) (+ (point-min) (gethash "offset" match))))
               (end (min (point-max) (+ beg (gethash "length" match)))))
          (unless (= beg end)
            (flymake-make-diagnostic buffer beg end type msg
                                     (list :rule-name rule-id)))))))

  (defun flymake-languagetool--report (stdout-buffer source-buffer)
    "Build Flymake diagnostics for SOURCE-BUFFER from STDOUT-BUFFER."
    (with-current-buffer stdout-buffer
      (goto-char (point-min))
      (let ((json (condition-case nil
                      (json-parse-buffer)
                    (json-parse-error
                     (error "LanguageTool: %s"
                            (string-trim
                             (buffer-substring-no-properties (point-min)
                                                             (point-max))))))))
        (delq nil
              (seq-map (lambda (match)
                         (flymake-languagetool--diag-from-match match source-buffer))
                       (gethash "matches" json))))))

  (defun flymake-languagetool--create-process (source-buffer callback)
    "Create the linter process for SOURCE-BUFFER.
CALLBACK is called with the process stdout buffer once it finishes."
    (when (process-live-p flymake-languagetool--process)
      (kill-process flymake-languagetool--process))
    (setq flymake-languagetool--process
          (make-process
           :name "flymake-languagetool"
           :connection-type 'pipe
           :noquery t
           :coding 'utf-8-unix
           :buffer (generate-new-buffer " *flymake-languagetool*")
           ;; progress chatter goes to stderr, keep it out of the JSON
           :stderr (make-pipe-process :name "flymake-languagetool-stderr"
                                      :noquery t
                                      :buffer nil)
           :command (flymake-languagetool--command)
           :sentinel
           (lambda (proc &rest _ignored)
             (let ((status (process-status proc))
                   (buffer (process-buffer proc)))
               (when (and (eq 'exit status)
                          (buffer-live-p source-buffer)
                          ;; make sure we're using the latest lint process
                          (eq proc (buffer-local-value 'flymake-languagetool--process
                                                       source-buffer)))
                 (funcall callback buffer))
               (when (memq status '(exit signal))
                 (kill-buffer buffer)))))))

  (defun flymake-languagetool--checker (report-fn &rest _ignored)
    "Run LanguageTool on the current buffer, reporting via REPORT-FN."
    (flymake-languagetool--ensure-binary-exists)
    (let ((source-buffer (current-buffer)))
      (if (zerop (buffer-size))
          (funcall report-fn nil)
        (flymake-languagetool--create-process
         source-buffer
         (lambda (stdout)
           (funcall report-fn (flymake-languagetool--report stdout source-buffer))))
        (process-send-string flymake-languagetool--process
                             (buffer-substring-no-properties (point-min) (point-max)))
        (process-send-eof flymake-languagetool--process))))

  (defvar flymake-languagetool--languages nil
    "Cache of (CODE . NAME) pairs reported by `languagetool --list'.")

  (defun flymake-languagetool--languages ()
    "Return available languages as (CODE . NAME) pairs, querying LanguageTool once."
    (or flymake-languagetool--languages
        (setq flymake-languagetool--languages
              (or (ignore-errors
                    (with-temp-buffer
                      (when (eq 0 (call-process flymake-languagetool-executable-name
                                                nil (list (current-buffer) nil) nil
                                                "--list"))
                        (goto-char (point-min))
                        (let (langs)
                          (while (re-search-forward "^\\([^ \t\n]+\\)[ \t]+\\(.*\\)$" nil t)
                            (push (cons (match-string 1) (match-string 2)) langs))
                          (nreverse langs)))))
                  ;; fall back to favorites if --list is unavailable
                  (mapcar (lambda (code) (cons code ""))
                          flymake-languagetool-favorite-languages)))))

  (defun flymake-languagetool--apply-language (language)
    "Set LANGUAGE buffer-locally, recheck, and report it."
    (setq-local flymake-languagetool-language language)
    (when flymake-mode (flymake-start))
    (message ">>> emacs-solo: LanguageTool language set to %s" language))

  (defun flymake-languagetool-set-language (language)
    "Set LANGUAGE for this buffer and recheck it right away.
Completes over every language LanguageTool supports."
    (interactive
     (let* ((langs (flymake-languagetool--languages))
            (completion-extra-properties
             (list :annotation-function
                   (lambda (code)
                     (when-let* ((name (cdr (assoc code langs))))
                       (concat "  " name))))))
       (list (completing-read "LanguageTool language: " langs nil nil nil nil
                              flymake-languagetool-language))))
    (flymake-languagetool--apply-language language))

  (defun flymake-languagetool-cycle-language ()
    "Cycle to the next of `flymake-languagetool-favorite-languages' and recheck."
    (interactive)
    (let* ((favorites flymake-languagetool-favorite-languages)
           (rest (cdr (member flymake-languagetool-language favorites))))
      (flymake-languagetool--apply-language (or (car rest) (car favorites)))))

  (defun flymake-languagetool-enable ()
    "Enable Flymake and the LanguageTool backend in the current buffer."
    (interactive)
    (unless (seq-some #'derived-mode-p flymake-languagetool-inhibited-modes)
      (when flymake-languagetool-idle-delay
        (setq-local flymake-no-changes-timeout flymake-languagetool-idle-delay))
      (add-hook 'flymake-diagnostic-functions #'flymake-languagetool--checker nil t)
      (flymake-mode 1)))

  (defun flymake-languagetool-disable ()
    "Disable the LanguageTool backend in the current buffer.
Leaves `flymake-mode' and any other backend untouched."
    (interactive)
    (remove-hook 'flymake-diagnostic-functions #'flymake-languagetool--checker t)
    (when (process-live-p flymake-languagetool--process)
      (kill-process flymake-languagetool--process))
    (when flymake-mode
      ;; cycle flymake-mode to drop the stale LanguageTool diagnostics/overlays
      (flymake-mode -1)
      (flymake-mode 1))
    (message ">>> emacs-solo: LanguageTool disabled in this buffer"))

  (defun flymake-languagetool-toggle ()
    "Toggle the LanguageTool backend in the current buffer."
    (interactive)
    (if (memq #'flymake-languagetool--checker flymake-diagnostic-functions)
        (flymake-languagetool-disable)
      (flymake-languagetool-enable)))

  (when emacs-solo-enable-flymake-languagetool
    (add-hook 'text-mode-hook #'flymake-languagetool-enable))

  ;; reachable before any flymake backend is running
  (define-key text-mode-map (kbd "C-c ! C-t") #'flymake-languagetool-toggle)

  (with-eval-after-load 'flymake
    ;; `C-c ! l' and `C-c ! t' are already bound in the flymake block of init.el
    (define-key flymake-mode-map (kbd "C-c ! L") #'flymake-languagetool-set-language)
    (define-key flymake-mode-map (kbd "C-c ! C-l") #'flymake-languagetool-cycle-language)
    (define-key flymake-mode-map (kbd "C-c ! C-t") #'flymake-languagetool-toggle)))

(provide 'emacs-solo-flymake-languagetool)
;;; emacs-solo-flymake-languagetool.el ends here
