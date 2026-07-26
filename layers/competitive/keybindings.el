;;; keybindings.el --- competitive layer keybindings file for Spacemacs.  -*- lexical-binding: t -*-

;; `SPC o' is the prefix Spacemacs reserves for user bindings in `global-map',
;; so these stay reachable from the input pane, not just from source buffers.
(spacemacs/declare-prefix "o" "competitive")
(spacemacs/set-leader-keys
  "or" #'competitive/write-compile-run
  "oc" #'competitive/compile
  "ox" #'competitive/run
  "oi" #'competitive/edit-input
  "ok" #'competitive/kill
  "oq" #'competitive/toggle-panes)

;;; keybindings.el ends here
