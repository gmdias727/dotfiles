; Prevents starting screen to show up on emacs startup
(setq inhibit-startup-screen t)

; Auto saves after 1 second after stopped typing
(setq auto-save-timeout 1)

(setq-default tab-width 4)

(set-face-attribute 'minibuffer-prompt nil :height 150)
(set-face-attribute 'mode-line nil :height 130)

; Set font size
(set-face-attribute 'default nil :height 180)

; Set font family
(set-face-attribute 'default nil :family "Iosevka" :weight 'normal)

; Starts maximized
; (add-to-list 'default-frame-alist '(fullscreen . maximized))

;Disables Top Toolbar
(tool-bar-mode 0)

;Disable Top Menu Bar
(menu-bar-mode 0)

;Disable Scroll Bar
(scroll-bar-mode 0)

; Display numbers
(global-display-line-numbers-mode)

; Load gruber-darker theme (inspired by tsoding)
(load-theme 'gruber-darker t)

; Installs MELPA
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(require 'typescript-mode)
(require 'lsp-mode)

(add-hook 'typescript-mode-hook #'lsp)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Go major mode
(use-package go-mode
  :hook (go-mode . lsp-deferred))

;; Optional: LSP UI for hover docs, sideline info, etc.
(use-package lsp-ui
  :commands lsp-ui-mode)

;; Autocompletion
(use-package company
  :hook (after-init . global-company-mode))

(provide 'emacs) ;;
