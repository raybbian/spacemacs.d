;;; packages.el --- typst layer packages file for Spacemacs.  -*- lexical-binding: t -*-

;; typst-ts-mode is not on MELPA; pulled straight from codeberg via quelpa.
(defconst typst-packages
  '((typst-ts-mode :location (recipe :fetcher git
                                     :url "https://codeberg.org/meow_king/typst-ts-mode.git"))))

(defun typst/init-typst-ts-mode ()
  (use-package typst-ts-mode
    :mode "\\.typ\\'"
    :defer t
    :init
    (add-hook 'typst-ts-mode-hook #'spacemacs//typst-setup-backend)
    :config
    (spacemacs//typst-ensure-grammar)
    (setq typst-ts-watch-options typst-watch-options)
    (spacemacs/declare-prefix-for-mode 'typst-ts-mode "mc" "compile")
    (spacemacs/set-leader-keys-for-major-mode 'typst-ts-mode
      "," 'typst-ts-tmenu
      "cc" 'typst-ts-compile
      "cp" 'typst-ts-compile-and-preview
      "cv" 'typst-ts-preview
      "cw" 'typst-ts-watch-mode
      "cm" 'typst-ts-main-file-ask)))

;;; packages.el ends here
