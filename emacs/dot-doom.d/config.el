;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq! user-full-name "Chris Montgomery"
       user-mail-address "chris@cdom.io")

(setq! doom-font (font-spec :family "Iosevka" :size 14)
       doom-unicode-font (font-spec :family "Iosevka")
       doom-variable-pitch-font (font-spec :family "Iosevka Sparkle"))

;; Enable font ligatures in emacs-mac@27.
(if IS-MAC (mac-auto-operator-composition-mode t))

;; Start the emacs server.
;; Open a new frame with `emacsclient -cn'.
(server-start)

;; Display the fill-column indicator.
(global-display-fill-column-indicator-mode +1)

;; Reduce the size of text in Zen Mode.
(setq! +zen-text-scale 1)

;; Adjust the size of the modeline.
(after! doom-modeline
  (when IS-MAC
    (setq! doom-modeline-height 1)
    (custom-set-faces!
      '((mode-line mode-line-inactive) :family "Iosevka Term"))))

;; Hide 'UTF-8' encoding from the modeline, since it's the default.
;; @TODO doesn't appear to be working. perhaps needs to be after doom-modeline?
;; https://tecosaur.github.io/emacs-config/config.html
(defun doom-modeline-conditional-buffer-encoding ()
  "We expect the encoding to be LF UTF-8, so only show the modeline when this is not the case"
  (setq-local doom-modeline-buffer-encoding
              (unless (or (eq buffer-file-coding-system 'utf-8-unix)
                          (eq buffer-file-coding-system 'utf-8)))))
(add-hook 'after-change-major-mode-hook #'doom-modeline-conditional-buffer-encoding)

;; Default indent by 2 spaces
(setq! evil-shift-width 2)

(defun +cdom/os-theme (status)
  "Get the theme corresponding to the system's current dark mode status."
  (intern
   (pcase status
     ("dark" (getenv "CDOM_EMACS_THEME_DARK"))
     ("light" (getenv "CDOM_EMACS_THEME_LIGHT"))
     (_ "base16-black-metal-khold"))))

;; @TODO accept param to avoid needing to call `cdom_os_appearance' :performance:
(defun +cdom/load-os-theme ()
  "Load the theme corresponding to the system's dark mode status."
  (interactive)
  (let ((theme (string-trim-right (shell-command-to-string "cdom_os_appearance"))))
    (load-theme (+cdom/os-theme theme) t)
    (run-hooks 'modus-themes-after-load-theme-hook)))

(use-package! modus-themes
  :init
  (require 'modus-themes)
  (setq! modus-themes-bold-constructs t
         modus-themes-fringes 'subtle
         modus-themes-slanted-constructs t
         ;; modus-themes-syntax 'faint
         modus-themes-mode-line 'borderless
         modus-themes-completions 'opinionated
         ;; modus-themes-intense-hl-line t
         modus-themes-paren-match 'subtle-bold)
  (modus-themes-load-themes))

;; (use-package! base16-theme
;;   :after-call +cdom/load-os-theme
;;   :config
;;   (setq! base16-theme-256-color-source "base16-shell"
;;          base16-distinct-fringe-background nil))

;; Load default theme based on macOS dark mode status.
(+cdom/load-os-theme)

(defvar +cdom/org-agenda-directory "~/org/gtd/")
(defvar +cdom/org-notes-directory "~/org/notes/")
(defvar +cdom/org-mind-directory "~/org/mind/")

(setq! org-directory "~/org"
       +org-capture-todo-file (concat +cdom/org-agenda-directory "inbox.org")
       org-roam-directory +cdom/org-mind-directory
       deft-directory org-directory
       deft-recursive t)

;; Simple settings.
;; https://tecosaur.github.io/emacs-config/config.html#simple-settings
(setq! undo-limit 80000000
       truncate-string-ellipsis "…"
       display-line-numbers-type 'relative)

;; Change default buffer and frame names.
;; https://tecosaur.github.io/emacs-config/config.html#window-title
(setq! doom-fallback-buffer-name "► Doom"
       +doom-dashboard-name "► Doom"
       frame-title-format
       '(""
         (:eval
          (if (s-contains-p org-roam-directory (or buffer-file-name ""))
              (replace-regexp-in-string
               ".*/[0-9]*-?" "☰ "
               (subst-char-in-string ?_ ?  buffer-file-name))
            "%b"))
         (:eval
          (let ((project-name (projectile-project-name)))
            (unless (string= "-" project-name)
              (format (if (buffer-modified-p)  " ◉ %s" "  ●  %s") project-name))))
         (:eval " ▲ doom")
         (:eval
          (when (frame-parent) " ◂ [child]"))))

;; Allow the default macOS ~alt~ behavior for special keyboard chars.
(setq! ns-right-alternate-modifier 'none)

;; Autosave
(setq! auto-save-default t
       auto-save-no-message t)
;; @TODO This still throws a message because it's called on the hook, unaffected by ~auto-save-no-message~
(add-hook 'auto-save-hook 'org-save-all-org-buffers)

;; https://tecosaur.github.io/emacs-config/config.html#windows
(setq! evil-vsplit-window-right t
       evil-split-window-below t)

;; https://gitlab.com/ideasman42/emacs-scroll-on-jump
(use-package! scroll-on-jump
  :after (evil)
  :config
  (setq! scroll-on-jump-duration 0.2
         scroll-on-jump-smooth t
         scroll-on-jump-use-curve nil)
  (scroll-on-jump-advice-add evil-undo)
  (scroll-on-jump-advice-add evil-redo)
  (scroll-on-jump-advice-add evil-jump-item)
  (scroll-on-jump-advice-add evil-jump-forward)
  (scroll-on-jump-advice-add evil-jump-backward)
  (scroll-on-jump-advice-add evil-ex-search-next)
  (scroll-on-jump-advice-add evil-ex-search-previous)
  (scroll-on-jump-advice-add evil-forward-paragraph)
  (scroll-on-jump-advice-add evil-backward-paragraph)
  ;; Actions that themselves scroll.
  (scroll-on-jump-with-scroll-advice-add evil-scroll-down)
  (scroll-on-jump-with-scroll-advice-add evil-scroll-up)
  (scroll-on-jump-with-scroll-advice-add evil-scroll-line-to-center)
  (scroll-on-jump-with-scroll-advice-add evil-scroll-line-to-top)
  (scroll-on-jump-with-scroll-advice-add evil-scroll-line-to-bottom))

;; Show previews in ivy.
;; (setq! +ivy-buffer-preview t)

;; https://tecosaur.github.io/emacs-config/config.html#company
(after! company
  (setq! company-idle-delay 0.5
         company-minimum-prefix-length 2
         company-show-numbers t)
  ;; Make aborting less annoying.
  (add-hook 'evil-normal-state-entry-hook #'company-abort))

(use-package! company-box
  :config
  ;; Disable the documentation childframe because it causes emacs to crash!
  ;;
  ;; FIXME Allow doc childframe flyout without crashing
  ;;
  ;; Note that Emacs doesn't crash when running Doom+modules without my config,
  ;; so it's probably something in my config...
  (setq! company-box-doc-enable nil))

;; Extend prescient history lifespan.
(setq-default history-length 1000)
(setq-default prescient-history-length 1000)

;; Prevent projectile from adding unwanted directories as projects.
;; https://tecosaur.github.io/emacs-config/config.html#projectile
(setq! projectile-ignored-projects '("~/" "/tmp" "~/.emacs.d" "~/.emacs.d/.local/straight/repos/"))
(defun projectile-ignored-project-function (filepath)
  "Return t if FILEPATH is within any of `projectile-ignored-projects'"
  (or (mapcar (lambda (p) (s-starts-with-p p filepath)) projectile-ignored-projects)))

(use-package! which-key
  :config
  (setq! which-key-sort-order
         ;; default
         ;; 'which-key-key-order
         ;; sort based on the key description ignoring case
         ;; 'which-key-description-order
         ;; same as default, except single characters are sorted alphabetically
         ;; 'which-key-key-order-alpha
         ;; same as default, except all prefix keys are grouped together at the end
         ;; 'which-key-prefix-then-key-order
         ;; same as default, except all keys from local maps shown first
         'which-key-local-then-key-order))

(setq! which-key-allow-multiple-replacements t)
(after! which-key
  ;; Remove ~evil-~ prefix from keybinding labels
  ;; https://tecosaur.github.io/emacs-config/config.html#which-key
  (pushnew!
   which-key-replacement-alist
   '(("" . "\\`+?evil[-:]?\\(?:a-\\)?\\(.*\\)") . (nil . "◂\\1"))
   '(("\\`g s" . "\\`evilem--?motion-\\(.*\\)") . (nil . "◃\\1"))))

(after! magit
  ;; List magit branches by date.
  (setq! magit-list-refs-sortby "-creatordate")
  ;; Enable delta diff viewer
  (add-hook 'magit-mode-hook (lambda () (magit-delta-mode +1))))

;; Prevent evil-lion from removing extra spaces.
;; Add any desired extra space prior to invoking evil-lion.
;; (setq! evil-lion-squeeze-spaces nil)

;; Prevent vterm from loading emacs from within itself
(use-package! with-editor
  :after (vterm)
  :general
  ([remap async-shell-command] 'with-editor-async-shell-command)
  ([remap shell-command] 'with-editor-shell-command)
  :hook
  (shell-mode . with-editor-export-editor)
  (term-exec  . with-editor-export-editor)
  (eshell-mode . with-editor-export-editor)
  (vterm-mode . with-editor-export-editor))

;; https://tecosaur.github.io/emacs-config/config.html#tweaking-defaults
(use-package! org
  :config
  (setq! org-image-actual-width 300
         org-startup-folded t
         org-startup-with-inline-images t
         org-blank-before-new-entry '((heading . t) (plain-list-item . auto))
         org-cycle-separator-lines -1
         org-use-property-inheritance t              ; it's convenient to have properties inherited
         org-log-done 'time                          ; log the time an item was completed
         org-list-allow-alphabetical t               ; have a. A. a) A) list bullets
         org-export-in-background t                  ; run export processes in external emacs process
         org-catch-invisible-edits 'smart))          ; try not to accidently do weird stuff in invisible regions

(after! org
  (defun +cdom/org-archive-done-tasks ()
    "Archive all completed tasks in a file to an archive sibling."
    (interactive)
    (org-map-entries 'org-archive-subtree "/DONE|KILL" 'file))
  (require 'find-lisp)
  (setq! org-agenda-files (find-lisp-find-files
                           +cdom/org-agenda-directory
                           "\.org$")
         org-archive-default-command 'org-archive-to-archive-sibling
         org-export-copy-to-kill-ring 'if-interactive
         org-log-refile 'time))


(use-package! doct
  :after (org-capture)
  :commands (doct))

(use-package! org-board
  :defer t)

;; Add a CREATED property to org-mode headings.
;; (use-package! org-expiry
;;   :after (org)
;;   :config
;;   (setq! org-expiry-inactive-timestamps t)
;;   (org-expiry-insinuate))

;; (use-package! org-protocol-capture-html
;;   :after (org))

(use-package! org-roam
  :after (doct))

(use-package! org-web-tools
  :after (org))

;; Add doct support to org-roam capture templates.
;; (after! doct org-roam)
;; (defun +doct-org-roam (groups)
;;   (let (converted)
;;     (dolist (group groups)
;;       (let* ((props (nthcdr 5 group))
;;              (roam-properties (plist-get (plist-get props :doct) :org-roam)))
;;         (push `(,@group ,@roam-properties) converted)))
;;     (setq! doct-templates (nreverse converted))))
;; (setq! doct-after-conversion-functions '(+doct-org-roam)))
;; :config
;; (setq! org-roam-dailies-capture-templates
;;       (doct `(("daily") :keys "d"
;;               :type plain
;;               :function org-roam-capture--get-point
;;               :template "%?"
;;               :unnarrowed t
;;               :immediate-finish t
;;               :file-name ,(concat cdom/org-agenda-directory "%<%Y-%m-%d>.org")
;;               :head "#+title: %<%A, %d %B %Y>")))
;; (setq! +org-roam-open-buffer-on-find-file nil))
;;

(after! org-capture
  (defun set-org-capture-templates ()
    (setq! org-capture-templates
           (doct `(("Personal todo"
                    :keys "t"
                    :icon ("checklist" :set "octicon" :color "green")
                    :file +org-capture-todo-file
                    :prepend t
                    :headline "Inbox"
                    :type entry
                    :template ("* TODO %?"
                               "%i %a"))))))
  (set-org-capture-templates))

;; Configure org-journal for compatability with org-roam-dailies
(use-package! org-journal
  :defer-incrementally t
  :init
  (setq! org-journal-file-type 'monthly
         org-journal-file-format "%Y-%m.org"
         org-journal-dir +cdom/org-agenda-directory
         org-journal-date-format "%A, %d %B %Y"
         org-journal-enable-agenda-integration t))

(use-package! ox-gfm
  :after org)

(use-package! ox-jira
  :after org)

(use-package! vimrc-mode
  :defer-incrementally t
  :init
  (add-to-list 'auto-mode-alist '("\\.(idea)?vim\\(rc\\)?\\'" . vimrc-mode)))

(use-package! web-mode
  :config
  ;; Prevent web-mode from loading for all PHP files in WordPress themes.
  ;; Overrides doom behavior.
  (add-to-list 'auto-mode-alist '("wp-content/themes/.+\\.php\\'" . php-mode))
  ;; Template partials should still load web-mode.
  (add-to-list 'auto-mode-alist '("wp-content/.+/template-parts/.+\\.php\\'" . web-mode)))

(use-package! projectile
  :config
  (appendq! projectile-globally-ignored-directories '("client-mu-plugins/vendor")))

(use-package! lsp
  :config
  (setq! lsp-phpactor-path (concat (getenv "COMPOSER_HOME") "/vendor/bin/phpactor"))
  (setq! lsp-vetur-format-default-formatter-js "prettier-eslint"
         lsp-vetur-format-default-formatter-ts "prettier-eslint"
         lsp-vetur-use-workspace-dependencies t))

;; `lsp-mode' integration with Flycheck `sh-shellcheck' checker
;; https://old.reddit.com/r/emacs/comments/hqxm5v/weekly_tipstricketc_thread/fy4pvr8/?context=3
(defun +cdom--lsp-flycheck-enable-shellcheck ()
  "Enable Shellcheck for shell buffers under LSP."
  (when (derived-mode-p 'sh-mode)
    (flycheck-add-next-checker 'lsp 'sh-shellcheck)))
(add-hook 'lsp-after-open-hook #'+cdom--lsp-flycheck-enable-shellcheck)

(use-package! hledger-mode
  :defer
  ;; :load-path "packages/rest/hledger-mode/"
  :mode ("\\.journal\\'")
  :commands hledger-enable-reporting
  :preface
  (defun hledger/next-entry ()
    "Move to next entry and pulse."
    (interactive)
    (hledger-next-or-new-entry)
    (hledger-pulse-momentary-current-entry))

  (defface hledger-warning-face
    '((((background dark))
       :background "Red" :foreground "White")
      (((background light))
       :background "Red" :foreground "White")
      (t :inverse-video t))
    "Face for warning"
    :group 'hledger)

  (defun hledger/prev-entry ()
    "Move to last entry and pulse."
    (interactive)
    (hledger-backward-entry)
    (hledger-pulse-momentary-current-entry))

  :bind (("C-c j" . hledger-run-command)
         :map hledger-mode-map
         ("C-c e" . hledger-jentry)
         ("M-p" . hledger/prev-entry)
         ("M-n" . hledger/next-entry))

  :init
  (setq! hledger-jfile (expand-file-name "~/Documents/finance/all.journal")
         hledger-show-expanded-report nil)
  (when (boundp 'cdom-hledger-service-fetch-url)
    (setq! hledger-service-fetch-url
           cdom-hledger-service-fetch-url))

  :config
  (add-hook 'hledger-view-mode-hook #'hl-line-mode)
  (add-hook 'hledger-view-mode-hook #'center-text-for-reading)
  (add-hook 'hledger-view-mode-hook
            (lambda ()
              (run-with-timer 1
                              nil
                              (lambda ()
                                (when (equal hledger-last-run-command
                                             "balancesheet")
                                  ;; highlight frequently changing accounts
                                  (highlight-regexp "^.*\\(savings\\|cash\\).*$")
                                  (highlight-regexp "^.*credit-card.*$"
                                                    'hledger-warning-face))))))
  (add-hook 'hledger-mode-hook
            (lambda ()
              (make-local-variable 'company-backends)
              (add-to-list 'company-backends 'hledger-company))))

(use-package! hledger-input
  ;; :pin manual
  ;; :load-path "packages/rest/hledger-mode/"
  :bind (("C-c e" . hledger-capture)
         :map hledger-input-mode-map
         ("C-c C-b" . popup-balance-at-point))
  :preface
  (defun popup-balance-at-point ()
    "Show balance for account at point in a popup."
    (interactive)
    (if-let ((account (thing-at-point 'hledger-account)))
        (message (hledger-shell-command-to-string (format " balance -N %s "
                                                          account)))
      (message "No account at point")))

  :config
  (setq! hledger-input-buffer-height 20)
  (add-hook 'hledger-input-post-commit-hook #'hledger-show-new-balances)
  (add-hook 'hledger-input-mode-hook #'auto-fill-mode)
  (add-hook 'hledger-input-mode-hook
            (lambda ()
              (make-local-variable 'company-idle-delay)
              (setq-local company-idle-delay 0.1))))

(use-package! literate-calc-mode
  :defer-incrementally t)

(setq! +ligatures-extra-symbols
       '(
         ;; org
         :name          "»"
         :src_block     "»"
         :src_block_end "«"
         :quote         "“"
         :quote_end     "”"
         ;; Functional
         :lambda        "λ"
         :def           "ƒ"
         :composition   "∘"
         :map           "↦"
         ;; Types
         :null          "∅"
         :true          "𝕋"
         :false         "𝔽"
         ;; :int           "ℤ"
         ;; :float         "ℝ"
         :str           "𝕊"
         :bool          "𝔹"
         :list          "𝕃"
         ;; Flow
         ;; :not           "￢"
         :in            "∈"
         :not-in        "∉"
         :and           "∧"
         :or            "∨"
         :for           "∀"
         :some          "∃"
         :return        "⟼"
         :yield         "⟻"
         ;; Other
         :union         "⋃"
         :intersect     "∩"
         ;; :diff          "∖"
         ;; :tuple         "⨂"
         ;; :pipe          "" ;; FIXME: find a non-private char
         :dot           "•"))

(setq! +doom-quit-messages
       '("(setq nothing t everything 'permitted)"
         "Hey! Hey, M-x listen!"
         "How fast can you take your time, kid?"
         "Sous les pavés, la plage!"
         "You know how everyone's into weirdness right now?"
         "We have such sights to show you..."
         "Take a break."
         "Is Control controlled by its need to control?"
         "Nothing here now but the recordings..."
         "Eat protein!"))

(load! "~/.emacs.private")
