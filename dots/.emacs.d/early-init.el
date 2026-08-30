;;; early-init.el --- Early init for PGTK Wayland -*- lexical-binding: t; -*-

;; Defer GC for fast startup (init.el restores GC after startup)
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6
      load-prefer-newer t
      frame-inhibit-implied-resize t
      native-comp-async-report-warnings-errors 'silent
      package-quickstart t)

;; Hide GUI chrome early to avoid flicker and extra resizing.
;; These are applied to every new frame, including daemon emacsclient frames.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(undecorated . t) default-frame-alist)
(push '(undecorated-round . t) default-frame-alist)
(push '(drag-internal-border . 1) default-frame-alist)
(push '(internal-border-width . 5) default-frame-alist)
;; Maximized without title bar negotiation is faster on Wayland
(push '(fullscreen . maximized) default-frame-alist)

(push '(menu-bar-lines . 0) initial-frame-alist)
(push '(tool-bar-lines . 0) initial-frame-alist)
(push '(vertical-scroll-bars) initial-frame-alist)
(push '(undecorated . t) initial-frame-alist)
(push '(undecorated-round . t) initial-frame-alist)
