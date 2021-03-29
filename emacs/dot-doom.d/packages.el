;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here, run 'doom sync' on
;; the command line, then restart Emacs for the changes to take effect.
;; Alternatively, use M-x doom/reload.


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
;(unpin! pinned-package)
;; ...or multiple packages
;(unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;(unpin! t)


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;(package! some-package)

;; To install a package directly from a particular repo, you'll need to specify
;; a `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/raxod502/straight.el#the-recipe-format
;(package! another-package
;  :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;(package! this-package
;  :recipe (:host github :repo "username/repo"
;           :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, for whatever reason,
;; you can do so here with the `:disable' property:
;(package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;(package! builtin-package :recipe (:nonrecursive t))
;(package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see raxod502/straight.el#279)
;(package! builtin-package :recipe (:branch "develop"))

;; Themes
(package! almost-mono-themes)
(package! base16-theme)
(package! modus-themes)
(package! tao-theme)

;; UI
(package! scroll-on-jump
  :recipe (:host gitlab
           :repo "ideasman42/emacs-scroll-on-jump"))

;; Languages
(package! bats-mode)                 ; mode for editing and running BATS tests
(package! doct)                      ; _d_eclarative _o_rg _c_apture _t_emplates
(package! literate-calc-mode)        ; like soulver, but in emacs
(package! neon-mode
  :recipe (:host github :repo "montchr/neon-mode"))
(package! vimrc-mode)                ; vimrc syntax

;; Import/Export
;; (package! org-protocol-capture-html) ; Capture webpage via org-protocol
(package! org-web-tools)             ; Webpage to org-mode content
(package! ox-gfm)                    ; Export to GFM syntax
(package! ox-jira                    ; Export to Jira syntax
  :recipe (:branch "trunk"))

;; Apps
(package! hledger-mode)
(package! org-board)                 ; Pinboard-ish for org-mode
(package! reaper)                    ; Harvest time tracking mode

;; Tools
(package! firestarter)               ; Do things upon save.
(package! magit-delta)               ; Use delta in magit diffs.
(package! with-editor)               ; pass $EDITOR to embedded terminal processes
