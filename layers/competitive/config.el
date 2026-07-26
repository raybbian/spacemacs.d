;;; config.el --- competitive layer configuration file for Spacemacs.  -*- lexical-binding: t -*-

(defvar competitive-binary "a.out"
  "Name of the executable produced by the project's `compile' target.")

(defvar competitive-make-target "compile"
  "Makefile target invoked with FILE=<buffer file>.")

(defvar competitive-input-buffer-name "*cp-input*")
(defvar competitive-output-buffer-name "*cp-output*")
(defvar competitive-compile-buffer-name "*cp-compile*")

;; Two slots on the same vertical side stack top-to-bottom: input above output.
(defconst competitive--input-side
  '((side . right) (slot . -1) (window-width . 0.35) (preserve-size . (t . nil))))
(defconst competitive--output-side
  '((side . right) (slot . 1) (window-width . 0.35) (preserve-size . (t . nil))))

(defvar competitive--process nil)

;;; config.el ends here
