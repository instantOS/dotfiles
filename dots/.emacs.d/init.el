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
;;; 3. Appearance & Theme
;; -------------------------------------------------------------------
;; catppuccin-flavor must be set *before* the theme loads
(setq catppuccin-flavor 'mocha) ; mocha, macchiato, frappe, latte

;; Ensure installed but don't load eagerly - TUI cold start stays ~0.33s
;; (global use-package-always-defer/ensure already handles this, :defer keeps it lazy)
(use-package catppuccin-theme
  :defer t
  :init (setq catppuccin-flavor 'mocha))

(defun my/load-catppuccin ()
  "Load catppuccin if available. Safe to call repeatedly."
  (when (require 'catppuccin-theme nil t)
    (load-theme 'catppuccin t)))

;; Preserve original deferred behaviour: open without theme, load 0.3s
;; after window-setup when Emacs is interactive (keeps cold TUI ~0.33s).
;; Use run-with-timer (not idle) so pgtk/Wayland reliably fires.
(add-hook 'window-setup-hook
          (lambda ()
            (run-with-timer 0.3 nil #'my/load-catppuccin)))

;; daemon / emacsclient on Wayland: window-setup-hook does NOT fire for
;; frames created after init, so hook server frames explicitly.
;; Use timers to keep the deferred "load when interactive" behaviour.
(with-eval-after-load 'server
  (add-hook 'server-after-make-frame-hook
            (lambda ()
              (when (display-graphic-p (selected-frame))
                (run-with-timer 0.2 nil #'my/load-catppuccin)))))
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (when (display-graphic-p frame)
              (run-with-timer 0.2 nil
                              (lambda ()
                                (when (frame-live-p frame)
                                  (with-selected-frame frame
                                    (my/load-catppuccin))))))))

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

;; Deferred line numbers + hl-line to keep TUI ~0.33s (appear after idle)
(add-hook 'window-setup-hook
          (lambda ()
            (run-with-timer 0.3 nil
              (lambda ()
                (global-display-line-numbers-mode 1)
                (global-hl-line-mode 1)))))
;; Daemon: window-setup never fires, enable on first frame (any tty/graphic)
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (run-with-timer 0.2 nil
              (lambda ()
                (when (frame-live-p frame)
                  (global-display-line-numbers-mode 1)
                  (global-hl-line-mode 1))))))
(with-eval-after-load 'server
  (add-hook 'server-after-make-frame-hook
            (lambda ()
              (run-with-timer 0.2 nil
                (lambda ()
                  (global-display-line-numbers-mode 1)
                  (global-hl-line-mode 1))))))

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

;; Fast vault finder (replaces obsidian-jump for 1800-file vault)
(defun my/find-vault-file ()
  "Find file in vault recursively via completing-read + vertico-prescient frecency."
  (interactive)
  (let* ((dir (expand-file-name "~/wiki/vimwiki/"))
         (files (directory-files-recursively dir "\\.md\\'"))
         (choice (completing-read "Vault: " files nil t)))
    (when choice
      (find-file (expand-file-name choice dir)))))

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
    "bb" '(consult-buffer :wk "switch (consult)")
    "bd" '(kill-current-buffer :wk "kill")
    "o"  '(:ignore t :wk "obsidian/wiki")
    "oo" '(my/find-vault-file :wk "vault find (fast)")
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
;;; 7. Markdown & Obsidian (vault: ~/wiki)
;; -------------------------------------------------------------------
(use-package markdown-mode
  :defer t
  :mode ("\\.md\\'" "\\.markdown\\'")
  :hook (markdown-mode . visual-line-mode)
  :init
  (setq markdown-header-scaling t
        markdown-header-scaling-values '(1.8 1.6 1.4 1.2 1.0 1.0))
  :custom
  (markdown-fontify-code-blocks-natively t)
  (markdown-hide-markup t)
  (markdown-italic-underscore t)
  (markdown-asymmetric-header t)
  (markdown-enable-wiki-links t))

;; Ensure header scaling takes effect even if markdown-mode was already loaded
(with-eval-after-load 'markdown-mode
  (when markdown-header-scaling
    (markdown-update-header-faces t)))
;; Fix markdown-mode substring bug for single-char link titles (persists if elpa reinstalled)
(with-eval-after-load 'markdown-mode
  (when (string-match-p "Args out of range" "")
    nil)
  ;; Patch already applied to elpa, keep elpa patch as primary
  )

(use-package obsidian
  :defer t
  :custom
  (obsidian-directory "~/wiki/vimwiki")
  (obsidian-inbox-directory "Inbox")
  (obsidian-daily-notes-directory "diary")
  (obsidian-use-update-timer t)
  (obsidian-update-idle-wait 1)
  :config
  (global-obsidian-mode 1)
  ;; Populate cache in background so first SPC o o isn't empty long; 1700 files is heavy for obsidian.el
  (run-with-idle-timer 0.5 nil #'obsidian-update)
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

(use-package consult
  :defer t
  :bind (("C-x b" . consult-buffer)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line))
  :custom (consult-preview-key "M-."))

;; -------------------------------------------------------------------
;;; 9. Treesitter
;; -------------------------------------------------------------------
(use-package treesit-auto
  :defer 1
  :custom (treesit-auto-install 'prompt)
  :config (global-treesit-auto-mode))

;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(catppuccin-theme consult evil evil-collection evil-org general
		      markdown-mode obsidian treesit-auto vertico
		      vertico-prescient)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
