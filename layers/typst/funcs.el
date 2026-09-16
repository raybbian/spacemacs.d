;;; funcs.el --- typst layer functions file for Spacemacs.  -*- lexical-binding: t -*-

(require 'treesit)

(defun spacemacs//typst-ensure-grammar ()
  "Build the typst tree-sitter grammar into ~/.emacs.d/tree-sitter if missing."
  (add-to-list 'treesit-language-source-alist (list 'typst typst-grammar-url))
  (unless (treesit-language-available-p 'typst)
    (treesit-install-language-grammar 'typst)))

(defun spacemacs//typst-setup-backend ()
  (when (and (eq typst-backend 'lsp)
             (configuration-layer/layer-used-p 'lsp))
    (lsp-deferred)))

;; typst-ts-mode adds {}()[]$&. to `electric-indent-chars', reindenting the
;; current line on every one of those keystrokes while it is still half-typed.
(defun spacemacs//typst-setup-editing ()
  (setq-local electric-indent-inhibit t))

;;; funcs.el ends here
