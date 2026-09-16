;;; config.el --- typst layer configuration file for Spacemacs.  -*- lexical-binding: t -*-

(defvar typst-backend 'lsp
  "Backend for typst buffers: `lsp' (tinymist via lsp-mode) or nil.")

(defvar typst-watch-options '("--open")
  "Extra arguments passed to `typst watch'.")

(defvar typst-grammar-url "https://github.com/Ziqi-Yang/tree-sitter-typst"
  "Grammar source pinned by typst-ts-mode to the version it supports.")

;;; config.el ends here
