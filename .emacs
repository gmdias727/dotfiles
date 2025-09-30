(setq inhibit-startup-screen t)

(set-face-attribute 'default nil :height 220)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(add-to-list 'default-frame-alist `(font . "Iosevka 20"))

(tool-bar-mode 0) ;Disables Top Toolbar
(menu-bar-mode 0) ;Disable Top Menu Bar
(scroll-bar-mode 0) ;Disable Scroll Bar
(global-display-line-numbers-mode)


(load-theme 'gruber-darker t)

;; Emacs have windows


