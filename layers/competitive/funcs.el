;;; funcs.el --- competitive layer functions file for Spacemacs.  -*- lexical-binding: t -*-

(require 'ansi-color)

(defun competitive/root ()
  "Return the projectile root, or signal if there is no project here."
  (or (and (fboundp 'projectile-project-root) (projectile-project-root))
      (user-error "Not in a project")))

(defun competitive//input-buffer ()
  "Return the stdin buffer, creating it if needed."
  (or (get-buffer competitive-input-buffer-name)
      (with-current-buffer (get-buffer-create competitive-input-buffer-name)
        (fundamental-mode)
        ;; Deliberately not file-backed, so saving is meaningless rather than a
        ;; prompt for somewhere to dump it.
        (local-set-key [remap save-buffer]
                       (lambda ()
                         (interactive)
                         (message "%s is scratch; nothing to save"
                                  competitive-input-buffer-name)))
        (current-buffer))))

(defun competitive//output-buffer ()
  "Return the program output buffer, creating it if needed."
  (or (get-buffer competitive-output-buffer-name)
      (with-current-buffer (get-buffer-create competitive-output-buffer-name)
        (special-mode)
        (current-buffer))))

(defun competitive//show-panes ()
  "Display both panes as right-hand side windows and return the input window.
Placed directly rather than via `display-buffer', because `window-purpose'
\(pulled in by the helm layer) installs a `display-buffer-overriding-action',
which takes precedence over `display-buffer-alist' and would scatter these
buffers according to its own rules."
  (let ((win (display-buffer-in-side-window
              (competitive//input-buffer) competitive--input-side)))
    (display-buffer-in-side-window (competitive//output-buffer)
                                   competitive--output-side)
    win))

(defun competitive/toggle-panes ()
  "Show or hide the input and output panes."
  (interactive)
  (if (get-buffer-window competitive-output-buffer-name)
      (dolist (name (list competitive-input-buffer-name
                          competitive-output-buffer-name))
        (let ((win (get-buffer-window name)))
          ;; Deleting a side window fails when it would leave no ordinary window.
          (when (window-live-p win) (ignore-errors (delete-window win)))))
    (competitive//show-panes)))

(defun competitive/edit-input ()
  "Show the panes and put point in the input buffer."
  (interactive)
  (let ((win (or (competitive//show-panes)
                 (get-buffer-window (competitive//input-buffer) t))))
    (if (window-live-p win)
        (select-window win)
      (pop-to-buffer (competitive//input-buffer)))))

(defun competitive//filter (proc string)
  (let ((buf (process-buffer proc)))
    (when (buffer-live-p buf)
      (with-current-buffer buf
        (let ((inhibit-read-only t))
          (save-excursion
            (goto-char (point-max))
            (insert (ansi-color-apply string))))
        (dolist (win (get-buffer-window-list buf nil t))
          (set-window-point win (point-max)))))))

(defun competitive//sentinel (proc start)
  (when (memq (process-status proc) '(exit signal))
    (let ((buf (process-buffer proc))
          (code (process-exit-status proc))
          (elapsed (- (float-time) start)))
      (when (buffer-live-p buf)
        (with-current-buffer buf
          (let ((inhibit-read-only t))
            (goto-char (point-max))
            (insert (propertize (format "\n[exit %d — %.3fs]\n" code elapsed)
                                'face (if (zerop code) 'success 'error))))))
      (setq competitive--process nil))))

(defun competitive/kill ()
  "Kill the running program, if any."
  (interactive)
  (cond ((process-live-p competitive--process)
         (kill-process competitive--process)
         (setq competitive--process nil)
         (when (called-interactively-p 'interactive) (message "cp: killed")))
        ((called-interactively-p 'interactive) (message "cp: nothing running"))))

(defun competitive/run (&optional dir)
  "Run the compiled binary with the input buffer on stdin.
DIR defaults to the project root."
  (interactive)
  ;; `default-directory' is buffer-local, so it is captured up front and passed
  ;; explicitly rather than let-bound across the `with-current-buffer' below.
  (let* ((dir (or dir (competitive/root)))
         (exe (expand-file-name competitive-binary dir))
         (input (with-current-buffer (competitive//input-buffer) (buffer-string)))
         (out (competitive//output-buffer))
         (start (float-time)))
    (unless (file-executable-p exe)
      (user-error "No %s in %s — compile first" competitive-binary dir))
    (competitive/kill)
    (with-current-buffer out
      (setq default-directory dir)
      (let ((inhibit-read-only t)) (erase-buffer)))
    (competitive//show-panes)
    (setq competitive--process
          (let ((default-directory dir))
            ;; No :stderr, so sanitizer reports interleave with program output.
            (make-process :name "cp-run"
                          :buffer out
                          :command (list exe)
                          :connection-type 'pipe
                          :noquery t
                          :filter #'competitive//filter
                          :sentinel (lambda (proc _event)
                                      (competitive//sentinel proc start)))))
    (process-send-string competitive--process input)
    (process-send-eof competitive--process)))

(defun competitive//dismiss (buf)
  "Close the window showing BUF, however it was displayed."
  (when (bound-and-true-p popwin-mode)
    (ignore-errors (popwin:close-popup-window)))
  (let ((win (get-buffer-window buf)))
    (when win (quit-window nil win))))

(defun competitive/compile (&optional then)
  "Build the current file via the project Makefile.
THEN, if given, is called with the project root once the build succeeds."
  (interactive)
  (let ((file (or buffer-file-name (user-error "Buffer is not visiting a file")))
        (dir (competitive/root)))
    (unless (file-exists-p (expand-file-name "Makefile" dir))
      (user-error "No Makefile in %s" dir))
    (let* ((default-directory dir)
           (buf (compilation-start
                 (format "make %s FILE=%s" competitive-make-target
                         (shell-quote-argument file))
                 nil
                 (lambda (_mode) competitive-compile-buffer-name))))
      (with-current-buffer buf
        (setq-local compilation-finish-functions
                    (list (lambda (cbuf status)
                            (when (string-prefix-p "finished" status)
                              (competitive//dismiss cbuf)
                              (when then (funcall then dir))))))))))

(defun competitive/write-compile-run ()
  "Save the buffer, build it, then run it against the input buffer."
  (interactive)
  (when (buffer-modified-p) (save-buffer))
  (competitive/compile #'competitive/run))

;;; funcs.el ends here
