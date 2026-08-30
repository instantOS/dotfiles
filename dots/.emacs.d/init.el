;;; init.el --- Clean vanilla Emacs config for Emacs 31+ -*- lexical-binding: t; -*-

;; -------------------------------------------------------------------
;;; 1. Startup Optimization
;; -------------------------------------------------------------------
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))
(setq native-comp-async-report-warnings-errors 'silent)

;; -------------------------------------------------------------------
;;; 2. Package Management (MELPA)
;; -------------------------------------------------------------------
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(require 'use-package)
(setq use-package-always-ensure t
      use-package-always-defer t
      use-package-expand-minimally t)
(setq package-quickstart t)

;; -------------------------------------------------------------------
;;; 3. Appearance & Theme - lazy catppuccin after TUI is interactive
;; -------------------------------------------------------------------
;; No :demand - load 0.3s after window-setup so cold TUI stays ~0.33s wall
(add-hook 'window-setup-hook
          (lambda ()
            (run-with-idle-timer 0.3 nil
             (lambda ()
               (when (require 'catppuccin-theme nil t)
                 (setq catppuccin-flavor 'mocha) ; mocha, macchiato, frappe, latte
                 (load-theme 'catppuccin t))))))

;; -------------------------------------------------------------------
;;; 4. Basic UI
;; -------------------------------------------------------------------
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(column-number-mode 1)
(show-paren-mode 1)
(setq make-backup-files nil
      auto-save-default nil)

;; -------------------------------------------------------------------
;;; 5. Evil + Leader
;; -------------------------------------------------------------------
(use-package evil
  :demand t
  :init
  (setq evil-want-keybinding nil)  ; required for evil-collection
  (setq evil-want-C-u-scroll t)
  :config (evil-mode 1))

(use-package evil-collection
  :after evil
  :demand t
  :config (evil-collection-init))

;; SPC leader via general.el
(use-package general
  :after evil
  :demand t
  :config
  (general-evil-setup t)
  (general-create-definer my/leader
    :states '(normal visual)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")
  (my/leader
    ""  '(nil :wk "leader")
    "f"  '(:ignore t :wk "file")
    "ff" '(find-file :wk "find file")
    "fs" '(save-buffer :wk "save")
    "fr" '(vertico-repeat :wk "repeat")
    "b"  '(:ignore t :wk "buffer")
    "bb" '(switch-to-buffer :wk "switch")
    "bd" '(kill-current-buffer :wk "kill")
    "o"  '(:ignore t :wk "obsidian/wiki")
    "oo" '(obsidian-jump :wk "jump note")
    "on" '(obsidian-capture :wk "new note")
    "od" '(obsidian-daily-note :wk "daily")
    "ol" '(obsidian-insert-link :wk "insert link")
    "ob" '(obsidian-backlink-jump :wk "backlink")
    "a"  '(:ignore t :wk "org/agenda")
    "aa" '(org-agenda :wk "agenda")
    "ac" '(org-capture :wk "capture")
    "q"  '(save-buffers-kill-terminal :wk "quit")))

(use-package evil-org
  :defer t
  :after org
  :hook (org-mode . evil-org-mode)
  :init (setq evil-org-key-theme '(navigation insert textobjects additional calendar shift todo heading))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;; -------------------------------------------------------------------
;;; 6. Org Mode
;; -------------------------------------------------------------------
(use-package org
  :ensure nil
  :custom
  (org-startup-indented t)
  (org-hide-emphasis-markers t)
  (org-log-done 'time)
  (org-ellipsis " ▾")
  (org-directory "~/org")
  (org-agenda-files '("~/org/inbox.org" "~/org/projects.org")))

;; -------------------------------------------------------------------
;;; 7. Obsidian (vault: ~/wiki)
;; -------------------------------------------------------------------
(use-package obsidian
  :defer t
  :custom
  (obsidian-directory "~/wiki")
  (obsidian-inbox-directory "Inbox")
  (obsidian-daily-notes-directory "diary")
  (obsidian-use-update-timer nil) ; no background 'starting obsidian update timer' - use M-x obsidian-update manually
  (markdown-enable-wiki-links t)
  :config (global-obsidian-mode 1) ; enabled only when you first hit SPC o o (no scan at startup)
  :bind (:map obsidian-mode-map
              ("C-c C-n" . obsidian-capture)
              ("C-c C-l" . obsidian-insert-link)
              ("C-c C-o" . obsidian-follow-link-at-point)
              ("C-c C-p" . obsidian-jump)
              ("C-c C-b" . obsidian-backlink-jump)))

;; -------------------------------------------------------------------
;;; 8. Completion (which-key + vertico)
;; -------------------------------------------------------------------
(use-package which-key
  :ensure nil
  :defer 1
  :custom
  (which-key-idle-delay 0.4)
  (which-key-idle-secondary-delay 0.05)
  :config (which-key-mode 1))

(use-package vertico
  :demand t
  :init (vertico-mode 1))

(use-package vertico-prescient
  :defer 1
  :after vertico
  :config
  (vertico-prescient-mode 1)
  (prescient-persist-mode 1))

;; -------------------------------------------------------------------
;;; 9. Treesitter
;; -------------------------------------------------------------------
(use-package treesit-auto
  :defer 1
  :custom (treesit-auto-install 'prompt)
  :config (global-treesit-auto-mode))

;;; init.el ends here