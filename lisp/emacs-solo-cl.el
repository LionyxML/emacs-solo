;;; emacs-solo-cl.el --- Common Lisp completion + xref, no SLIME  -*- lexical-binding: t; -*-
;;
;; Author: Rahul Martim Juliato
;; URL: https://github.com/LionyxML/emacs-solo
;; Package-Requires: ((emacs "30.1"))
;; Keywords: tools, convenience, languages, lisp
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; In-house Common Lisp support without SLIME/SLY.  Uses two private
;; SBCL subprocesses:
;;   - primary: CAPF, xref, eldoc, mirror (async CAPF/eldoc, never blocks)
;;   - lint:    flymake compile-file diagnostics (isolated, never starves primary)
;;
;; TLDR: open a file in lisp-mode and use
;;       `emacs-solo/cl-start-project' instead of `sly' to start it all.
;;
;; Features:
;;   - `completion-at-point' backend: async, apropos-based, package aware,
;;     understands foo:bar / foo::bar; offers package names too.
;;     Returns lowercased symbols.  Cache served immediately; SBCL queried
;;     in background so typing never blocks.
;;   - `xref' backend: uses `sb-introspect:find-definition-sources-by-name'
;;     for functions, macros, classes, generics, methods, variables,
;;     types, conditions, setf-expanders.  Snaps offset to the actual
;;     defining form (handles earmuffed names like `*version*').
;;   - `eldoc' backend: async, shows lambda-list and first doc line for the
;;     symbol at point via `sb-introspect:function-lambda-list'.
;;   - Describe/macroexpand/hyperspec helpers via the private SBCL, so
;;     they work even when no REPL is running.
;;   - SBCL `SYS:' logical pathnames re-mapped to the install share dir
;;     so `M-.' on built-ins (e.g. `defun') lands in installed sources.
;;   - Auto-loads Quicklisp if `~/quicklisp/setup.lisp' exists.
;;   - Mirror mode: when on, `inferior-lisp' eval/load commands
;;     (`lisp-eval-defun', `lisp-load-file', ...) are also sent to the
;;     primary SBCL so completion/xref see freshly defined symbols.
;;     Errors are caught so the private image survives broken forms.
;;     Toggle with `emacs-solo-cl-mirror-inferior-lisp'.
;;   - Flymake backend: on-the-fly diagnostics via `compile-file' in
;;     a dedicated lint SBCL.  Captures warnings, style-warnings, and
;;     errors with source file positions.  Never blocks primary SBCL.
;;     Enabled automatically with `emacs-solo/cl-mode'.
;;   - `inferior-lisp' glue: sets `inferior-lisp-program' to SBCL,
;;     loads `sb-aclrepl' into fresh REPLs, and binds the usual
;;     C-c C-z/C-c/C-r/C-e/C-l/C-k keys on `lisp-mode-map'.
;;
;; Commands:
;;   `emacs-solo/cl-start-project' one-shot entry point.  If an `.asd'
;;       is found walking up from the project root, start `inferior-lisp'
;;       if needed, register + load-system in REPL, `in-package' into it,
;;       and mirror into the private SBCL.  If no `.asd' is found,
;;       start `inferior-lisp' + private SBCL and, when the buffer has
;;       a file, `(load ...)' it into both so completion/xref see it.
;;   `emacs-solo/cl-load-system'  register project root with ASDF
;;       and `(asdf:load-system ...)' the system.  Best-effort: compile
;;       failures and warnings are skipped so partial work loads.
;;   `emacs-solo/cl-load-file' `(load ...)' current buffer.
;;   `emacs-solo/cl-compile-defun' eval top-level form at point under
;;       buffer's `*package*'.
;;   `emacs-solo/cl-switch-to-repl' pop to inferior-lisp REPL, starting
;;       one if needed.  Bound to C-c C-z.
;;   `emacs-solo/cl-compile-file' (compile-file ...) current buffer in
;;       the REPL.  Bound to C-c C-k.
;;   `emacs-solo/cl-describe-symbol' `(describe ...)' symbol at point,
;;       output in a help window.  Bound to C-c d.
;;   `emacs-solo/cl-macroexpand'     `macroexpand-1' form at point.
;;       Bound to C-c C-m.
;;   `emacs-solo/cl-macroexpand-all' `macroexpand' form at point (full).
;;       Bound to C-c M-m.
;;   `emacs-solo/cl-hyperspec-lookup' open HyperSpec entry for symbol
;;       at point via l1sp.org.  Bound to C-c h.
;;   `emacs-solo/cl-restart'         kill + respawn both private SBCLs.
;;   `emacs-solo/cl-show-buffer'     pop primary SBCL I/O buffer.
;;   `emacs-solo/cl-diagnose'        echo wiring status.
;;
;; Activation is per-buffer via `emacs-solo/cl-mode', added to
;; `lisp-mode-hook'.  Both SBCLs are lazy: nothing starts until a
;; completion, xref, eldoc, or mirror call fires.  Keys are bound on
;; `lisp-mode-map'; disable the minor mode if you want a clean map.

;;; Code:

(require 'xref)
(require 'cl-lib)
(require 'flymake)

(use-package emacs-solo-cl
  :ensure nil
  :no-require t
  :defer t
  :init
  (defgroup emacs-solo-cl nil
    "In-house CL completion and xref."
    :group 'tools)

  (defcustom emacs-solo-cl-sbcl
    (or (executable-find "sbcl") "sbcl")
    "Path to SBCL binary."
    :type 'string
    :group 'emacs-solo-cl)

  (defcustom emacs-solo-cl-quicklisp-setup
    (expand-file-name "quicklisp/setup.lisp" (getenv "HOME"))
    "Path to Quicklisp `setup.lisp'.  Loaded if it exists."
    :type 'file
    :group 'emacs-solo-cl)

  (defcustom emacs-solo-cl-query-timeout 5
    "Seconds to wait for SBCL response in synchronous `--eval' calls."
    :type 'number
    :group 'emacs-solo-cl)

  (defcustom emacs-solo-cl-capf-cache-ttl 30
    "Seconds a seed-based CAPF cache entry stays fresh."
    :type 'number
    :group 'emacs-solo-cl)

  (defcustom emacs-solo-cl-busy-cooldown 3.0
    "Seconds to skip sync queries after a timeout."
    :type 'number
    :group 'emacs-solo-cl)

  (defcustom emacs-solo-cl-mirror-inferior-lisp t
    "When non-nil, mirror `inferior-lisp' eval/load commands into
the primary SBCL so completion/xref see new symbols."
    :type 'boolean
    :group 'emacs-solo-cl)

  (defcustom emacs-solo-cl-lint-timeout 20
    "Seconds to wait for SBCL compile-file lint response."
    :type 'number
    :group 'emacs-solo-cl)

  ;; ---- primary process vars
  (defvar emacs-solo-cl--proc nil "Primary SBCL process (CAPF/xref/eldoc/mirror).")
  (defvar emacs-solo-cl--buf " *emacs-solo-cl*")
  (defvar emacs-solo-cl--marker "__ESCL_END__")
  (defvar emacs-solo-cl--begin "__ESCL_BEG__")
  (defvar emacs-solo-cl--suppress-until 0
    "Float-time until which synchronous queries should be skipped.")

  ;; ---- lint process vars
  (defvar emacs-solo-cl--lint-proc nil "Dedicated flymake SBCL process.")
  (defvar emacs-solo-cl--lint-buf " *emacs-solo-cl-lint*")
  (defvar emacs-solo-cl--flymake-state nil "Plist for single in-flight lint.")
  (defvar emacs-solo-cl--flymake-counter 0 "Monotonic tick for flymake markers.")
  (defvar emacs-solo-cl--flymake-last-raw nil "Last raw lint text, for debugging.")
  (defvar emacs-solo-cl--flymake-last-parsed nil "Last parsed diagnostics, for debugging.")

  ;; ---- async CAPF/eldoc vars
  (defvar emacs-solo-cl--request-counter 0 "Monotonic counter for async request markers.")
  (defvar emacs-solo-cl--capf-pending nil "Plist for in-flight async CAPF query.")
  (defvar emacs-solo-cl--eldoc-pending nil "Plist for in-flight async eldoc query.")
  (defvar emacs-solo-cl--capf-cache nil
    "Seed-based cache plist for `emacs-solo-cl-capf'.
Keys: :pkg :seed :with-packages :external-only :cands :stamp.")

  (defconst emacs-solo-cl--init-forms
    "
(handler-case (require :sb-introspect)
  (error (c) (format *error-output* \";; sb-introspect skip: ~a~%%\" c)))
(handler-case
  (let* ((home (sb-ext:posix-getenv \"SBCL_HOME\"))
         (idx (when home (search \"/lib/sbcl\" home)))
         (share (when idx
                  (concatenate 'string
                               (subseq home 0 idx) \"/share/sbcl/\"))))
    (when (and share (probe-file share))
      (setf (logical-pathname-translations \"SYS\")
            `((\"SYS:SRC;**;*.*.*\"
               ,(concatenate 'string share \"src/**/*.*\"))
              (\"SYS:CONTRIB;**;*.*.*\"
               ,(concatenate 'string share \"contrib/**/*.*\"))))))
  (error (c) (format *error-output* \";; sys-path skip: ~a~%%\" c)))
(handler-case
  (when (probe-file \"%s\")
    (load \"%s\"))
  (error (c) (format *error-output* \";; ql skip: ~a~%%\" c)))
(defpackage :escl (:use :cl) (:export :complete :locate))
(in-package :escl)
(defun complete (prefix pkg-name &optional with-packages external-only)
  (let* ((pkg (or (find-package (string-upcase pkg-name)) *package*))
         (out '())
         (collect (lambda (s)
                    (let ((n (symbol-name s)))
                      (when (and (>= (length n) (length prefix))
                                 (string-equal prefix n :end2 (length prefix)))
                        (push (string-downcase n) out))))))
    (if external-only
        (do-external-symbols (s pkg) (funcall collect s))
        (do-symbols (s pkg) (funcall collect s)))
    (when with-packages
      (dolist (p (list-all-packages))
        (dolist (name (cons (package-name p) (package-nicknames p)))
          (when (and (>= (length name) (length prefix))
                     (string-equal prefix name :end2 (length prefix)))
            (push (concatenate 'string (string-downcase name) \":\") out)))))
    (sort (delete-duplicates out :test #'string=) #'string<)))
(defun locate (name pkg-name)
  (let* ((pkg (or (find-package (string-upcase pkg-name)) *package*))
         (sym (find-symbol (string-upcase name) pkg)))
    (when sym
      (loop for kind in '(:function :macro :generic-function :method
                          :variable :class :structure :type :condition
                          :setf-expander)
            nconc
            (handler-case
              (loop for def in (sb-introspect:find-definition-sources-by-name
                                sym kind)
                    for raw = (sb-introspect:definition-source-pathname def)
                    for path = (when raw
                                 (handler-case
                                   (translate-logical-pathname raw)
                                   (error () raw)))
                    for offs = (sb-introspect:definition-source-character-offset def)
                    when path
                    collect (list (string-downcase (string kind))
                                  (namestring path)
                                  (or offs 0)))
              (error () nil))))))
(in-package :cl-user)
")

  (defconst emacs-solo-cl--lint-forms
    ;; NOTE: each in-package MUST be its own top-level form, CL reader
    ;; interns symbols at read time, so wrapping in a single progn would
    ;; intern lint-file in the wrong package.
    "
(handler-case
  (unless (find-package :escl-lint)
    (defpackage :escl-lint (:use :cl) (:export :lint-file)))
  (error (c) (format *error-output* \";; lint pkg skip: ~a~%\" c)))
(in-package :escl-lint)
(handler-case
  (defun lint-file (path)
    (let ((results '())
          (fasl (make-pathname :type \"fasl\" :defaults path)))
      (ignore-errors
        (handler-bind
            ((warning
              (lambda (c)
                (let* ((ctx (ignore-errors (sb-c::find-error-context nil)))
                       (pos (when ctx
                              (ignore-errors
                                (sb-c::compiler-error-context-file-position ctx))))
                       (kind (if (typep c 'style-warning) \"note\" \"warning\")))
                  (push (list kind (or pos 0)
                              (handler-case (princ-to-string c)
                                (error () \"<unprintable>\")))
                        results))
                (muffle-warning)))
             (error
              (lambda (c)
                (let* ((ctx (ignore-errors (sb-c::find-error-context nil)))
                       (pos (when ctx
                              (ignore-errors
                                (sb-c::compiler-error-context-file-position ctx)))))
                  (push (list \"error\" (or pos 0)
                              (handler-case (princ-to-string c)
                                (error () \"<unprintable>\")))
                        results))
                (let ((r (or (find-restart 'continue)
                             (find-restart 'abort))))
                  (when r (invoke-restart r))))))
          (let ((*error-output* (make-broadcast-stream))
                (*standard-output* (make-broadcast-stream))
                (*compile-verbose* nil)
                (*compile-print* nil))
            (compile-file path :output-file fasl
                          :verbose nil :print nil))))
      (ignore-errors (when (probe-file fasl) (delete-file fasl)))
      (nreverse results)))
  (error (c) (format *error-output* \";; lint defun skip: ~a~%\" c)))
(in-package :cl-user)
")

  ;; ---- primary process

  (defun emacs-solo-cl--live-p ()
    (and emacs-solo-cl--proc
         (process-live-p emacs-solo-cl--proc)))

  (defun emacs-solo-cl--start ()
    "Spawn primary SBCL if not running."
    (unless (emacs-solo-cl--live-p)
      (let* ((buf (get-buffer-create emacs-solo-cl--buf))
             (proc (start-process "escl-sbcl" buf
                                  emacs-solo-cl-sbcl
                                  "--noinform"
                                  "--no-sysinit" "--no-userinit"
                                  "--disable-debugger")))
        (set-process-query-on-exit-flag proc nil)
        (set-process-filter proc #'emacs-solo-cl--filter)
        (setq emacs-solo-cl--proc proc)
        (with-current-buffer buf (erase-buffer))
        (process-send-string
         proc
         (format emacs-solo-cl--init-forms
                 emacs-solo-cl-quicklisp-setup
                 emacs-solo-cl-quicklisp-setup)))))

  (defun emacs-solo-cl--send (form)
    "Fire FORM at primary SBCL; do not wait for result."
    (emacs-solo-cl--start)
    (when (emacs-solo-cl--live-p)
      (condition-case _
          (process-send-string
           emacs-solo-cl--proc
           (format "(handler-case (progn %s) (error (c) (format *error-output* \";; async-err: ~a~%%\" c)))\n"
                   form))
        (error (setq emacs-solo-cl--proc nil)))))

  (defun emacs-solo-cl--eval (form &optional timeout)
    "Send FORM to primary SBCL synchronously; return result string or nil.
Used only for user-initiated commands (xref, describe, macroexpand)
where a brief wait is acceptable."
    (emacs-solo-cl--start)
    (unless (emacs-solo-cl--live-p)
      (setq emacs-solo-cl--proc nil))
    (let ((proc emacs-solo-cl--proc)
          (buf (get-buffer emacs-solo-cl--buf))
          (deadline (+ (float-time)
                       (or timeout emacs-solo-cl-query-timeout)))
          result)
      (unless (and proc (process-live-p proc)) (error "escl: SBCL not running"))
      (with-current-buffer buf
        (let ((start (point-max))
              (beg-re (concat "^" (regexp-quote
                                   emacs-solo-cl--begin) "\n"))
              (end-re (concat "\n" (regexp-quote
                                    emacs-solo-cl--marker) "\n")))
          (condition-case _
              (process-send-string
               proc
               (format "(progn (terpri) (princ \"%s\") (terpri) (prin1 %s) (terpri) (princ \"%s\") (terpri) (finish-output) (values))\n"
                       emacs-solo-cl--begin
                       form
                       emacs-solo-cl--marker))
            (error
             (setq emacs-solo-cl--proc nil)
             (error "escl: SBCL died; M-x emacs-solo/cl-restart")))
          (while (and (< (float-time) deadline)
                      (progn
                        (goto-char start)
                        (not (re-search-forward end-re nil t))))
            (accept-process-output proc 0.05))
          (goto-char start)
          (if (and (re-search-forward beg-re nil t)
                   (let ((pstart (point)))
                     (when (re-search-forward end-re nil t)
                       (let ((raw (buffer-substring-no-properties
                                   pstart (match-beginning 0))))
                         (setq result
                               (string-trim
                                (replace-regexp-in-string
                                 "^\\*\\s-*" "" raw)))))))
              (progn (setq emacs-solo-cl--suppress-until 0) result)
            (setq emacs-solo-cl--suppress-until
                  (+ (float-time) emacs-solo-cl-busy-cooldown)))))
      result))

  ;; ---- lint process

  (defun emacs-solo-cl--lint-live-p ()
    (and emacs-solo-cl--lint-proc
         (process-live-p emacs-solo-cl--lint-proc)))

  (defun emacs-solo-cl--lint-start ()
    "Spawn dedicated flymake SBCL if not running; loads init + lint forms."
    (unless (emacs-solo-cl--lint-live-p)
      (let* ((buf (get-buffer-create emacs-solo-cl--lint-buf))
             (proc (start-process "escl-sbcl-lint" buf
                                  emacs-solo-cl-sbcl
                                  "--noinform"
                                  "--no-sysinit" "--no-userinit"
                                  "--disable-debugger")))
        (set-process-query-on-exit-flag proc nil)
        (set-process-filter proc #'emacs-solo-cl--lint-filter)
        (setq emacs-solo-cl--lint-proc proc)
        (with-current-buffer buf (erase-buffer))
        (process-send-string
         proc
         (concat (format emacs-solo-cl--init-forms
                         emacs-solo-cl-quicklisp-setup
                         emacs-solo-cl-quicklisp-setup)
                 emacs-solo-cl--lint-forms)))))

  ;; ---- filters

  (defun emacs-solo-cl--filter (proc chunk)
    "Primary SBCL filter: appends CHUNK; scans for async CAPF/eldoc responses."
    (when (buffer-live-p (process-buffer proc))
      (with-current-buffer (process-buffer proc)
        (let ((moving (= (point) (or (marker-position (process-mark proc))
                                     (point-max)))))
          (save-excursion
            (goto-char (or (marker-position (process-mark proc)) (point-max)))
            (insert chunk)
            (set-marker (process-mark proc) (point)))
          (when moving (goto-char (process-mark proc))))))
    (when emacs-solo-cl--capf-pending
      (emacs-solo-cl--capf-scan))
    (when emacs-solo-cl--eldoc-pending
      (emacs-solo-cl--eldoc-scan)))

  (defun emacs-solo-cl--lint-filter (proc chunk)
    "Lint SBCL filter: appends CHUNK; scans for flymake responses."
    (when (buffer-live-p (process-buffer proc))
      (with-current-buffer (process-buffer proc)
        (let ((moving (= (point) (or (marker-position (process-mark proc))
                                     (point-max)))))
          (save-excursion
            (goto-char (or (marker-position (process-mark proc)) (point-max)))
            (insert chunk)
            (set-marker (process-mark proc) (point)))
          (when moving (goto-char (process-mark proc))))))
    (when emacs-solo-cl--flymake-state
      (emacs-solo-cl--flymake-scan)))

  ;; ---- helpers

  (defun emacs-solo-cl--read (s)
    "Safely read string S as elisp sexp, or nil."
    (when (and s (not (string-empty-p s)))
      (condition-case nil (car (read-from-string s)) (error nil))))

  (defun emacs-solo-cl--split-sym (sym)
    "Return (PACKAGE . NAME) for SYM like \"foo:bar\", \"foo::bar\", \"bar\"."
    (cond
     ((string-match "\\`\\([^:]+\\)::?\\(.+\\)\\'" sym)
      (cons (match-string 1 sym) (match-string 2 sym)))
     (t (cons "CL-USER" sym))))

  (defun emacs-solo-cl--in-package ()
    "Return nearest package name; in comint, scan backward from point."
    (save-excursion
      (let ((pat "(in-package\\s-+[:#']*\\([A-Za-z0-9._+-]+\\)"))
        (if (derived-mode-p 'inferior-lisp-mode 'comint-mode)
            (if (re-search-backward pat nil t)
                (upcase (match-string-no-properties 1))
              "CL-USER")
          (goto-char (point-min))
          (if (re-search-forward pat nil t)
              (upcase (match-string-no-properties 1))
            "CL-USER")))))

  ;; ---- async CAPF

  (defun emacs-solo-cl--capf-seed (prefix)
    "Return uppercased PREFIX truncated to 2 chars."
    (upcase (substring prefix 0 (min 2 (length prefix)))))

  (defun emacs-solo-cl--capf-fetch-async (seed pkg with-packages external-only)
    "Fire SBCL completion query; update `emacs-solo-cl--capf-cache' on response."
    (when (emacs-solo-cl--live-p)
      (let* ((tick (cl-incf emacs-solo-cl--request-counter))
             (beg (format "__ESCL_CAPF_BEG_%d__" tick))
             (end (format "__ESCL_CAPF_END_%d__" tick))
             (buf (get-buffer emacs-solo-cl--buf))
             (start-pos (and buf (with-current-buffer buf (point-max)))))
        (setq emacs-solo-cl--capf-pending
              (list :beg beg :end end :start-pos start-pos
                    :pkg pkg :seed seed
                    :with-packages with-packages
                    :external-only external-only))
        (condition-case _
            (process-send-string
             emacs-solo-cl--proc
             (format "(progn (terpri) (princ \"%s\") (terpri) (prin1 (escl:complete \"%s\" \"%s\" %s %s)) (terpri) (princ \"%s\") (terpri) (finish-output) (values))\n"
                     beg seed pkg
                     (if with-packages "t" "nil")
                     (if external-only "t" "nil")
                     end))
          (error (setq emacs-solo-cl--capf-pending nil))))))

  (defun emacs-solo-cl--capf-scan ()
    "Scan primary SBCL buffer for a pending CAPF response; update cache."
    (let* ((st emacs-solo-cl--capf-pending)
           (beg (plist-get st :beg))
           (end (plist-get st :end))
           (start-pos (or (plist-get st :start-pos) (point-min)))
           (buf (get-buffer emacs-solo-cl--buf)))
      (when (and st beg end (buffer-live-p buf))
        (with-current-buffer buf
          (save-excursion
            (goto-char start-pos)
            (when (search-forward beg nil t)
              (let ((pstart (point)))
                (when (search-forward end nil t)
                  (let* ((raw (buffer-substring-no-properties
                               pstart (match-beginning 0)))
                         (text (string-trim
                                (replace-regexp-in-string "^\\*\\s-*" "" raw)))
                         (lst (emacs-solo-cl--read text)))
                    (setq emacs-solo-cl--capf-pending nil)
                    (when (listp lst)
                      (setq emacs-solo-cl--capf-cache
                            (list :pkg (plist-get st :pkg)
                                  :seed (plist-get st :seed)
                                  :with-packages (plist-get st :with-packages)
                                  :external-only (plist-get st :external-only)
                                  :cands lst
                                  :stamp (float-time)))))))))))))

  (defun emacs-solo-cl--capf-candidates (prefix pkg with-packages external-only)
    "Return cached candidates for PREFIX in PKG; fire async fetch if stale."
    (let* ((seed (emacs-solo-cl--capf-seed prefix))
           (cache emacs-solo-cl--capf-cache)
           (cache-matches (and cache
                               (equal (plist-get cache :pkg) pkg)
                               (equal (plist-get cache :seed) seed)
                               (eq (plist-get cache :with-packages) with-packages)
                               (eq (plist-get cache :external-only) external-only)))
           (fresh (and cache-matches
                       (< (- (float-time) (plist-get cache :stamp))
                          emacs-solo-cl-capf-cache-ttl))))
      (if fresh
          (plist-get cache :cands)
        (unless emacs-solo-cl--capf-pending
          (emacs-solo-cl--start)
          (emacs-solo-cl--capf-fetch-async seed pkg with-packages external-only))
        (when cache-matches (plist-get cache :cands)))))

  (defun emacs-solo-cl-capf ()
    "`completion-at-point-functions' entry for CL.
Returns cached candidates immediately; refreshes from SBCL in background."
    (when (derived-mode-p 'lisp-mode 'inferior-lisp-mode)
      (let* ((bounds (bounds-of-thing-at-point 'symbol))
             (start (or (car bounds) (point)))
             (end (or (cdr bounds) (point)))
             (sym (buffer-substring-no-properties start end)))
        (when (and sym (> (length sym) 0))
          (let* ((colon (string-match ":" sym))
                 (double (and colon (< (1+ colon) (length sym))
                              (eq (aref sym (1+ colon)) ?:)))
                 (pkg-prefix (when colon
                               (substring sym 0 (+ colon (if double 2 1)))))
                 (pkg (if colon
                          (substring sym 0 colon)
                        (emacs-solo-cl--in-package)))
                 (prefix (if colon
                             (substring sym (+ colon (if double 2 1)))
                           sym))
                 (with-packages (not colon))
                 (external-only (and colon (not double)))
                 (cands (emacs-solo-cl--capf-candidates
                         prefix pkg with-packages external-only))
                 (cands (if pkg-prefix
                            (mapcar (lambda (n) (concat pkg-prefix n)) cands)
                          cands)))
            (when cands
              (list start end
                    (completion-table-dynamic (lambda (_) cands))
                    :exclusive 'no)))))))

  ;; ---- xref backend

  (defun emacs-solo-cl--xref-backend () 'emacs-solo-cl)

  (cl-defmethod xref-backend-identifier-at-point
    ((_b (eql emacs-solo-cl)))
    (thing-at-point 'symbol t))

  (cl-defmethod xref-backend-identifier-completion-table
    ((_b (eql emacs-solo-cl)))
    nil)

  (cl-defmethod xref-backend-definitions
    ((_b (eql emacs-solo-cl)) id)
    (let* ((split (emacs-solo-cl--split-sym id))
           (pkg (if (string= (car split) "CL-USER")
                    (emacs-solo-cl--in-package)
                  (car split)))
           (name (cdr split))
           (out (emacs-solo-cl--eval
                 (format "(escl:locate \"%s\" \"%s\")" name pkg)))
           (hits (emacs-solo-cl--read out)))
      (when (listp hits)
        (delq nil
              (mapcar
               (lambda (h)
                 (let ((kind (nth 0 h)) (path (nth 1 h)) (off (nth 2 h)))
                   (when (and path (file-exists-p path))
                     (let* ((bare (replace-regexp-in-string
                                   "\\`[^:]+:+" "" id))
                            (line (with-temp-buffer
                                    (insert-file-contents path)
                                    (let ((case-fold-search t)
                                          (pat (format
                                                "(\\s-*[-a-z0-9!*:/]*def[-a-z0-9!*:/]*\\s-+\\(?:[^()[:space:]]+:+\\)?%s\\(?:[[:space:]()]\\|$\\)"
                                                (regexp-quote bare))))
                                      (goto-char (min (1+ off) (point-max)))
                                      (or (re-search-backward pat nil t)
                                          (re-search-forward pat nil t)
                                          (goto-char (min (1+ off)
                                                          (point-max)))))
                                    (line-number-at-pos))))
                       (xref-make
                        (format "%s %s" kind id)
                        (xref-make-file-location path line 0))))))
               hits)))))

  ;; ---- async eldoc

  (defun emacs-solo-cl--eldoc-scan ()
    "Scan primary SBCL buffer for a pending eldoc response; invoke callback."
    (let* ((st emacs-solo-cl--eldoc-pending)
           (beg (plist-get st :beg))
           (end-marker (plist-get st :end))
           (start-pos (or (plist-get st :start-pos) (point-min)))
           (buf (get-buffer emacs-solo-cl--buf)))
      (when (and st beg end-marker (buffer-live-p buf))
        (with-current-buffer buf
          (save-excursion
            (goto-char start-pos)
            (when (search-forward beg nil t)
              (let ((pstart (point)))
                (when (search-forward end-marker nil t)
                  (let* ((raw (buffer-substring-no-properties
                               pstart (match-beginning 0)))
                         (text (string-trim
                                (replace-regexp-in-string "^\\*\\s-*" "" raw)))
                         (pair (emacs-solo-cl--read text))
                         (callback (plist-get st :callback))
                         (sym (plist-get st :sym)))
                    (setq emacs-solo-cl--eldoc-pending nil)
                    (when (and callback sym (listp pair))
                      (let* ((arglist-raw (nth 0 pair))
                             (doc-raw (nth 1 pair))
                             (bad-p (lambda (x)
                                      (or (null x)
                                          (string-match-p
                                           "\\`\\(NIL\\|nil\\)\\'\\|error\\|debugger"
                                           (format "%s" x)))))
                             (arglist (and (not (funcall bad-p arglist-raw))
                                          (string-trim (format "%s" arglist-raw))))
                             (doc (and (not (funcall bad-p doc-raw))
                                       (car (split-string
                                             (string-trim
                                              (replace-regexp-in-string
                                               "\"" ""
                                               (format "%s" doc-raw)))
                                             "\n"))))
                             (result (cond
                                      ((and arglist doc)
                                       (format "(%s %s) -- %s"
                                               (downcase sym) arglist doc))
                                      (arglist
                                       (format "(%s %s)" (downcase sym) arglist))
                                      (doc
                                       (format "%s -- %s" (downcase sym) doc))
                                      (t nil))))
                        (when result (funcall callback result)))))))))))))

  (defun emacs-solo-cl--eldoc (callback &rest _)
    "Eldoc backend: async arglist + doc via primary SBCL."
    (let ((sym (thing-at-point 'symbol t)))
      (when (and sym (emacs-solo-cl--live-p))
        (when (and emacs-solo-cl--eldoc-pending
                   (not (equal sym (plist-get emacs-solo-cl--eldoc-pending :sym))))
          (setq emacs-solo-cl--eldoc-pending nil))
        (unless emacs-solo-cl--eldoc-pending
          (let* ((upper (upcase sym))
                 (tick (cl-incf emacs-solo-cl--request-counter))
                 (beg (format "__ESCL_ELDOC_BEG_%d__" tick))
                 (end (format "__ESCL_ELDOC_END_%d__" tick))
                 (buf (get-buffer emacs-solo-cl--buf))
                 (start-pos (and buf (with-current-buffer buf (point-max)))))
            (setq emacs-solo-cl--eldoc-pending
                  (list :beg beg :end end :start-pos start-pos
                        :callback callback :sym sym))
            (condition-case _
                (process-send-string
                 emacs-solo-cl--proc
                 (format "(progn (terpri) (princ \"%s\") (terpri) (prin1 (list (ignore-errors (princ-to-string (sb-introspect:function-lambda-list '%s))) (ignore-errors (documentation '%s 'function)))) (terpri) (princ \"%s\") (terpri) (finish-output) (values))\n"
                         beg upper upper end))
              (error (setq emacs-solo-cl--eldoc-pending nil))))))))

  ;; ---- flymake backend (dedicated lint process)

  (defun emacs-solo-cl--flymake-scan ()
    "Scan lint SBCL buffer for a pending lint's end marker; deliver if found."
    (let* ((st emacs-solo-cl--flymake-state)
           (start (or (plist-get st :start-pos) (point-min)))
           (buf (get-buffer emacs-solo-cl--lint-buf))
           (beg (plist-get st :beg-marker))
           (end (plist-get st :end-marker)))
      (when (and st beg end (buffer-live-p buf))
        (with-current-buffer buf
          (save-excursion
            (goto-char start)
            (when (search-forward beg nil t)
              (let ((pstart (point)))
                (when (search-forward end nil t)
                  (let* ((pend (- (match-beginning 0) (length end)))
                         (raw (buffer-substring-no-properties
                               pstart (max pstart (match-beginning 0))))
                         (text (string-trim
                                (replace-regexp-in-string
                                 "^[*[:space:]]+" ""
                                 (replace-regexp-in-string
                                  "[*[:space:]]+\\'" "" raw)))))
                    (ignore pend)
                    (emacs-solo-cl--flymake-deliver st text))))))))))

  (defun emacs-solo-cl--flymake-deliver (st text)
    "Parse TEXT, build diagnostics, invoke report-fn from state ST."
    (setq emacs-solo-cl--flymake-state nil)
    (let* ((src-buf (plist-get st :src-buf))
           (tmp (plist-get st :tmp))
           (report-fn (plist-get st :report-fn))
           (mod-tick (plist-get st :mod-tick))
           (stale (or (not (buffer-live-p src-buf))
                      (and mod-tick
                           (/= mod-tick
                               (buffer-chars-modified-tick src-buf)))))
           (diags (emacs-solo-cl--read text))
           (result '()))
      (setq emacs-solo-cl--flymake-last-raw text
            emacs-solo-cl--flymake-last-parsed diags)
      (ignore-errors (delete-file tmp))
      (when (and (not stale) (listp diags))
        (with-current-buffer src-buf
          (dolist (d diags)
            (let* ((kind (nth 0 d))
                   (pos (or (nth 1 d) 0))
                   (msg (nth 2 d))
                   (beg (or (ignore-errors (byte-to-position (1+ pos)))
                            (1+ pos)))
                   (beg (max (point-min) (min beg (point-max))))
                   (beg (save-excursion
                          (goto-char beg)
                          (forward-comment (point-max))
                          (point)))
                   (end (save-excursion
                          (goto-char beg)
                          (let* ((bounds (bounds-of-thing-at-point 'sexp))
                                 (cand (or (and bounds
                                                (> (cdr bounds) beg)
                                                (cdr bounds))
                                           (line-end-position))))
                            (min (max (1+ beg) cand) (point-max)))))
                   (type (pcase kind
                           ("error" :error)
                           ("warning" :warning)
                           (_ :note))))
              (push (flymake-make-diagnostic src-buf beg end type msg)
                    result)))))
      (unless stale
        (condition-case err
            (funcall report-fn (nreverse result))
          (error (message "emacs-solo-cl flymake deliver: %s" err))))))

  (defun emacs-solo-cl-flymake (report-fn &rest _args)
    "Async flymake backend via dedicated lint SBCL."
    (when emacs-solo-cl--flymake-state
      (let ((old-tmp (plist-get emacs-solo-cl--flymake-state :tmp)))
        (when old-tmp (ignore-errors (delete-file old-tmp))))
      (setq emacs-solo-cl--flymake-state nil))
    (let* ((src-buf (current-buffer))
           (tmp (make-temp-file "escl-lint-" nil ".lisp"))
           (tick (cl-incf emacs-solo-cl--flymake-counter))
           (beg-marker (format "__ESCL_FM_BEG_%d__" tick))
           (end-marker (format "__ESCL_FM_END_%d__" tick)))
      (condition-case err
          (progn
            (write-region nil nil tmp nil 'silent)
            (emacs-solo-cl--lint-start)
            (let* ((lint-buf (get-buffer emacs-solo-cl--lint-buf))
                   (start-pos (and lint-buf
                                   (with-current-buffer lint-buf (point-max)))))
              (setq emacs-solo-cl--flymake-state
                    (list :report-fn report-fn
                          :src-buf src-buf
                          :tmp tmp
                          :start-pos start-pos
                          :beg-marker beg-marker
                          :end-marker end-marker
                          :mod-tick (buffer-chars-modified-tick src-buf)))
              (process-send-string
               emacs-solo-cl--lint-proc
               (format "(progn (terpri) (princ \"%s\") (terpri) (handler-case (prin1 (escl-lint:lint-file \"%s\")) (error (c) (princ \"NIL \") (princ \";; lint-err: \") (princ c))) (terpri) (princ \"%s\") (terpri) (finish-output) (values))\n"
                       beg-marker tmp end-marker))))
        (error
         (ignore-errors (delete-file tmp))
         (funcall report-fn :panic (format "emacs-solo-cl: %s" err))))))

  ;; ---- minor mode

  (defun emacs-solo-cl--mirror-region (start end)
    (when emacs-solo-cl-mirror-inferior-lisp
      (let ((pkg (emacs-solo-cl--in-package))
            (form (buffer-substring-no-properties start end)))
        (setq emacs-solo-cl--capf-cache nil)
        (emacs-solo-cl--send
         (format "(let ((*package* (find-package \"%s\"))) (eval (read-from-string %S)))"
                 pkg form)))))

  (defun emacs-solo-cl--mirror-load (file)
    (when emacs-solo-cl-mirror-inferior-lisp
      (setq emacs-solo-cl--capf-cache nil)
      (emacs-solo-cl--send (format "(load \"%s\")" file))))

  (defun emacs-solo-cl--advise-region (orig start end &rest rest)
    (prog1 (apply orig start end rest)
      (emacs-solo-cl--mirror-region start end)))

  (defun emacs-solo-cl--advise-defun (orig &rest rest)
    (prog1 (apply orig rest)
      (save-excursion
        (let* ((end (progn (end-of-defun) (point)))
               (start (progn (beginning-of-defun) (point))))
          (emacs-solo-cl--mirror-region start end)))))

  (defun emacs-solo-cl--advise-last-sexp (orig &rest rest)
    (prog1 (apply orig rest)
      (save-excursion
        (let* ((end (point))
               (start (progn (backward-sexp) (point))))
          (emacs-solo-cl--mirror-region start end)))))

  (defun emacs-solo-cl--advise-load (orig file &rest rest)
    (prog1 (apply orig file rest)
      (emacs-solo-cl--mirror-load (expand-file-name file))))

  (with-eval-after-load 'inf-lisp
    (setq inferior-lisp-program emacs-solo-cl-sbcl)
    (advice-add 'lisp-eval-region :around
                #'emacs-solo-cl--advise-region)
    (advice-add 'lisp-eval-defun :around
                #'emacs-solo-cl--advise-defun)
    (advice-add 'lisp-eval-last-sexp :around
                #'emacs-solo-cl--advise-last-sexp)
    (advice-add 'lisp-load-file :around
                #'emacs-solo-cl--advise-load)
    (advice-add 'lisp-compile-file :around
                #'emacs-solo-cl--advise-load))

  (add-hook 'inferior-lisp-mode-hook
            (lambda ()
              (lisp-eval-string
               "(ignore-errors (require \"sb-aclrepl\"))")))

  (defun emacs-solo/cl-load-system (system &optional dir)
    "Register DIR (default: project root) with ASDF and load SYSTEM.
Best-effort: accept compile failures and warnings so partial work loads."
    (interactive
     (let* ((root (or (when-let* ((p (project-current nil)))
                        (project-root p))
                      default-directory))
            (asd (car (file-expand-wildcards
                       (expand-file-name "*.asd" root))))
            (default (when asd (file-name-base asd))))
       (list (read-string (format "System%s: "
                                  (if default (format " (%s)" default) ""))
                          nil nil default)
             root)))
    (let* ((dir (file-name-as-directory (expand-file-name (or dir default-directory))))
           (form (format "
(handler-bind ((warning #'muffle-warning)
               (error (lambda (c)
                        (let ((r (or (find-restart 'asdf/action:accept)
                                     (find-restart 'continue))))
                          (when r (invoke-restart r))
                          (format *error-output* \";; skip: ~a~%%\" c)))))
  (pushnew #P\"%s\" asdf:*central-registry* :test #'equal)
  (asdf:load-system :%s :force-not (asdf:already-loaded-systems)))" dir system)))
      (setq emacs-solo-cl--suppress-until
            (+ (float-time) emacs-solo-cl-busy-cooldown))
      (emacs-solo-cl--send form)
      ;; Mirror into lint proc so compile-file sees project packages.
      (emacs-solo-cl--lint-start)
      (when (emacs-solo-cl--lint-live-p)
        (process-send-string emacs-solo-cl--lint-proc form))
      (message "load-system %s queued (check *emacs-solo-cl* buffer)" system)))

  (defun emacs-solo/cl-start-project ()
    "Do the best for the current project or file.
If an `.asd' is found walking up from the project root, start
`inferior-lisp' if not running, register the root with ASDF,
`asdf:load-system' the system, and `in-package' into it.  Also
load it into the private SBCL so completion and xref see project
symbols.

If no `.asd' is found, start `inferior-lisp' and the private SBCL
and, when the buffer has a file, `(load ...)' it into both so
completion and xref pick it up."
    (interactive)
    (require 'inf-lisp)
    (let* ((start (or (when-let* ((p (project-current nil)))
                        (project-root p))
                      default-directory))
           (asd-dir (locate-dominating-file
                     start
                     (lambda (d)
                       (file-expand-wildcards
                        (expand-file-name "*.asd" d))))))
      (unless (and (boundp 'inferior-lisp-buffer)
                   inferior-lisp-buffer
                   (get-buffer-process inferior-lisp-buffer))
        (save-window-excursion (inferior-lisp inferior-lisp-program)))
      (emacs-solo-cl--start)
      (cond
       (asd-dir
        (let* ((asd (car (file-expand-wildcards
                          (expand-file-name "*.asd" asd-dir))))
               (system (file-name-base asd))
               (dir (file-name-as-directory (expand-file-name asd-dir)))
               (repl-form
                (format "(handler-bind ((warning #'muffle-warning) (error (lambda (c) (let ((r (or (find-restart 'asdf/action:accept) (find-restart 'continue)))) (when r (invoke-restart r)) (format *error-output* \";; skip: ~a~%%\" c))))) (pushnew #P\"%s\" asdf:*central-registry* :test #'equal) (asdf:load-system :%s :force-not (asdf:already-loaded-systems))) (in-package :%s)\n"
                        dir system system)))
          (comint-send-string (inferior-lisp-proc) repl-form)
          (emacs-solo/cl-load-system system asd-dir)
          (display-buffer inferior-lisp-buffer)
          (message "emacs-solo-cl: project %s loaded (repl + private)" system)))
       (buffer-file-name
        (when (buffer-modified-p) (save-buffer))
        (let* ((file buffer-file-name)
               (repl-form (format "(load \"%s\")\n" file)))
          (comint-send-string (inferior-lisp-proc) repl-form)
          (emacs-solo-cl--send (format "(load \"%s\")" file))
          (display-buffer inferior-lisp-buffer)
          (message "emacs-solo-cl: file %s queued (repl + private)"
                   (file-name-nondirectory file))))
       (t
        (display-buffer inferior-lisp-buffer)
        (message "emacs-solo-cl: REPL + private SBCL started (no file, no .asd)")))))

  (defun emacs-solo/cl-load-file ()
    "Load current buffer's file into the primary SBCL (async)."
    (interactive)
    (unless buffer-file-name (user-error "Buffer has no file"))
    (when (buffer-modified-p) (save-buffer))
    (emacs-solo-cl--send (format "(load \"%s\")" buffer-file-name))
    (message "load %s queued" (file-name-nondirectory buffer-file-name)))

  (defun emacs-solo/cl-compile-defun ()
    "Send top-level form at point to primary SBCL."
    (interactive)
    (save-excursion
      (let* ((end (progn (end-of-defun) (point)))
             (beg (progn (beginning-of-defun) (point)))
             (form (buffer-substring-no-properties beg end))
             (pkg (emacs-solo-cl--in-package))
             (out (emacs-solo-cl--eval
                   (format "(let ((*package* (find-package \"%s\"))) (eval (read-from-string %S)))"
                           pkg form))))
        (message "eval -> %s" (or out "timeout")))))

  (defun emacs-solo/cl-diagnose ()
    "Run checks and message the result."
    (interactive)
    (let* ((sym (thing-at-point 'symbol t))
           (pkg (emacs-solo-cl--in-package))
           (capf-in (memq #'emacs-solo-cl-capf
                          completion-at-point-functions))
           (xref-in (memq #'emacs-solo-cl--xref-backend
                          xref-backend-functions))
           (ping (ignore-errors
                   (emacs-solo-cl--eval
                    "(cl-user::identity :pong)"))))
      (message "primary=%s lint=%s capf=%s xref=%s pkg=%s sym=%s ping=%s"
               (emacs-solo-cl--live-p)
               (emacs-solo-cl--lint-live-p)
               (and capf-in t) (and xref-in t) pkg sym ping)))

  (defun emacs-solo/cl-show-buffer ()
    "Pop to primary SBCL I/O buffer for debugging."
    (interactive)
    (pop-to-buffer (get-buffer-create emacs-solo-cl--buf)))

  (defun emacs-solo/cl-flymake-debug ()
    "Print flymake state, filter hookup, and lint SBCL buffer tail."
    (interactive)
    (let* ((proc emacs-solo-cl--lint-proc)
           (filter (and proc (process-filter proc)))
           (buf (get-buffer emacs-solo-cl--lint-buf))
           (tail (when buf
                   (with-current-buffer buf
                     (buffer-substring-no-properties
                      (max (point-min) (- (point-max) 800))
                      (point-max))))))
      (with-help-window "*emacs-solo-cl flymake debug*"
        (princ (format "lint proc live: %s\n" (emacs-solo-cl--lint-live-p)))
        (princ (format "filter:    %s\n" filter))
        (princ (format "expected:  emacs-solo-cl--lint-filter\n"))
        (princ (format "state:     %S\n" emacs-solo-cl--flymake-state))
        (princ (format "parsed count: %s\n\n"
                       (and (listp emacs-solo-cl--flymake-last-parsed)
                            (length emacs-solo-cl--flymake-last-parsed))))
        (princ "--- last raw text ---\n")
        (princ (or emacs-solo-cl--flymake-last-raw "(none)"))
        (princ "\n\n--- last parsed ---\n")
        (princ (format "%S" emacs-solo-cl--flymake-last-parsed))
        (princ "\n\n--- lint SBCL buffer tail (last 800 chars) ---\n")
        (princ (or tail "(no buffer)")))))

  (defun emacs-solo/cl-restart ()
    "Kill and respawn both private SBCLs."
    (interactive)
    (when (emacs-solo-cl--live-p)
      (delete-process emacs-solo-cl--proc))
    (when (emacs-solo-cl--lint-live-p)
      (delete-process emacs-solo-cl--lint-proc))
    (setq emacs-solo-cl--proc nil
          emacs-solo-cl--lint-proc nil
          emacs-solo-cl--capf-pending nil
          emacs-solo-cl--eldoc-pending nil
          emacs-solo-cl--capf-cache nil
          emacs-solo-cl--suppress-until 0)
    (emacs-solo-cl--start)
    (message "emacs-solo-cl: both SBCLs restarted"))

  ;; ---- inferior-lisp REPL helpers

  (defun emacs-solo/cl-switch-to-repl ()
    "Switch to inferior Lisp process, starting one if needed.
Shows the REPL in a window below, keeping focus in the code buffer."
    (interactive)
    (require 'inf-lisp)
    (let ((code-buffer (current-buffer)))
      (unless (and (get-process "inferior-lisp")
                   (process-live-p (get-process "inferior-lisp")))
        (run-lisp inferior-lisp-program)
        (switch-to-buffer code-buffer))
      (display-buffer "*inferior-lisp*"
                      '(display-buffer-below-selected
                        (window-height . 0.33)))))

  (defun emacs-solo/cl-compile-file ()
    "`(compile-file ...)' current buffer in the inferior Lisp."
    (interactive)
    (let ((file (buffer-file-name)))
      (unless file (user-error "Buffer has no file"))
      (save-buffer)
      (lisp-eval-string (format "(compile-file \"%s\")" file))))

  ;; ---- describe / macroexpand / hyperspec (primary SBCL)

  (defun emacs-solo/cl-describe-symbol ()
    "Describe the Common Lisp symbol at point using the primary SBCL."
    (interactive)
    (let* ((sym (thing-at-point 'symbol t))
           (_ (unless sym (user-error "No symbol at point")))
           (pkg (emacs-solo-cl--in-package))
           (form (format
                  "(let ((*package* (find-package \"%s\"))) (with-output-to-string (s) (let ((*standard-output* s)) (ignore-errors (describe (read-from-string \"%s\"))))))"
                  pkg (upcase sym)))
           (raw (emacs-solo-cl--eval form))
           (text (emacs-solo-cl--read raw)))
      (with-help-window "*CL Describe*"
        (princ (or text "(no description)")))))

  (defun emacs-solo-cl--pprint-form (expander form pkg)
    "Pretty-print EXPANDER applied to FORM (string) under PKG in SBCL."
    (let* ((cmd (format
                 "(let ((*package* (find-package \"%s\"))) (with-output-to-string (s) (ignore-errors (pprint (%s (read-from-string %S)) s))))"
                 pkg expander form))
           (raw (emacs-solo-cl--eval cmd)))
      (emacs-solo-cl--read raw)))

  (defun emacs-solo/cl-macroexpand ()
    "Macroexpand the form at point (one step)."
    (interactive)
    (let* ((form (thing-at-point 'list t))
           (_ (unless form (user-error "No form at point")))
           (text (emacs-solo-cl--pprint-form
                  "macroexpand-1" form (emacs-solo-cl--in-package))))
      (with-help-window "*CL Macroexpand*"
        (princ (or text "(no expansion)")))))

  (defun emacs-solo/cl-macroexpand-all ()
    "Fully macroexpand the form at point."
    (interactive)
    (let* ((form (thing-at-point 'list t))
           (_ (unless form (user-error "No form at point")))
           (text (emacs-solo-cl--pprint-form
                  "macroexpand" form (emacs-solo-cl--in-package))))
      (with-help-window "*CL Macroexpand*"
        (princ (or text "(no expansion)")))))

  (defun emacs-solo/cl-hyperspec-lookup ()
    "Look up the symbol at point in the Common Lisp HyperSpec.
Resolve via l1sp.org redirector, then open final HTTPS URL."
    (interactive)
    (let* ((sym (thing-at-point 'symbol t))
           (_ (unless sym (user-error "No symbol at point")))
           (probe (format "http://l1sp.org/cl/%s"
                          (url-hexify-string (downcase sym))))
           (final
            (if (executable-find "curl")
                (string-trim
                 (shell-command-to-string
                  (format "curl -sLo /dev/null -w %%{url_effective} %s"
                          (shell-quote-argument probe))))
              (with-current-buffer (url-retrieve-synchronously probe t t 5)
                (prog1
                    (if (boundp 'url-http-target-url)
                        (url-recreate-url url-http-target-url)
                      probe)
                  (kill-buffer (current-buffer)))))))
      (browse-url
       (replace-regexp-in-string "\\`http://" "https://" final))))

  ;; ---- minor mode and keybindings

  (define-minor-mode emacs-solo/cl-mode
    "Buffer-local CL completion + xref + eldoc + flymake via inferior SBCL."
    :lighter " CL"
    (if emacs-solo/cl-mode
        (progn
          (setq-local comment-column 40)
          (setq-local indent-tabs-mode nil)
          (add-hook 'completion-at-point-functions
                    #'emacs-solo-cl-capf nil t)
          (add-hook 'xref-backend-functions
                    #'emacs-solo-cl--xref-backend nil t)
          (add-hook 'eldoc-documentation-functions
                    #'emacs-solo-cl--eldoc nil t)
          (add-hook 'flymake-diagnostic-functions
                    #'emacs-solo-cl-flymake nil t))
      (remove-hook 'completion-at-point-functions
                   #'emacs-solo-cl-capf t)
      (remove-hook 'xref-backend-functions
                   #'emacs-solo-cl--xref-backend t)
      (remove-hook 'eldoc-documentation-functions
                   #'emacs-solo-cl--eldoc t)
      (remove-hook 'flymake-diagnostic-functions
                   #'emacs-solo-cl-flymake t)))

  (with-eval-after-load 'lisp-mode
    (let ((map lisp-mode-map))
      (define-key map (kbd "C-c C-z") #'emacs-solo/cl-switch-to-repl)
      (define-key map (kbd "C-c C-c") #'lisp-eval-defun)
      (define-key map (kbd "C-c C-r") #'lisp-eval-region)
      (define-key map (kbd "C-c C-e") #'lisp-eval-last-sexp)
      (define-key map (kbd "C-c C-l") #'lisp-load-file)
      (define-key map (kbd "C-c C-k") #'emacs-solo/cl-compile-file)
      (define-key map (kbd "C-c d")   #'emacs-solo/cl-describe-symbol)
      (define-key map (kbd "C-c h")   #'emacs-solo/cl-hyperspec-lookup)
      (define-key map (kbd "C-c C-m") #'emacs-solo/cl-macroexpand)
      (define-key map (kbd "C-c M-m") #'emacs-solo/cl-macroexpand-all)))

  (add-hook 'lisp-mode-hook #'emacs-solo/cl-mode)
  (add-hook 'inferior-lisp-mode-hook #'emacs-solo/cl-mode)
  (dolist (b (buffer-list))
    (with-current-buffer b
      (when (and (derived-mode-p 'lisp-mode 'inferior-lisp-mode)
                 (not emacs-solo/cl-mode))
        (emacs-solo/cl-mode 1)))))

(provide 'emacs-solo-cl)
;;; emacs-solo-cl.el ends here
