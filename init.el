(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))
(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))

(require 'defuns-cfg)
(require 'keybindings-cfg)

(if (member "Monaco" (font-family-list))
    (set-face-attribute 'default nil :font "Monaco 12"))
(if window-system
    (progn
      (setq frame-title-format '(buffer-file-name "%f" ("%b")))
      (tooltip-mode -1)
      (mouse-wheel-mode t)
      (scroll-bar-mode -1))
  (menu-bar-mode -1))

(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(blink-cursor-mode -1)
(setq-default cursor-type '(bar . 2))
(global-hl-line-mode t)
(delete-selection-mode 1)
(transient-mark-mode 1)
(show-paren-mode 1)
(column-number-mode 1)
(defalias 'yes-or-no-p 'y-or-n-p)

(setq inhibit-startup-screen t)
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

(electric-pair-mode 1)
(remove-trailing-whitespace-mode)

(server-start)

;; Bootstrap `use-package'
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-and-compile
  (add-to-list 'load-path (expand-file-name "vendor" user-emacs-directory)))

(use-package ido
  :config
  (setq ido-enable-flex-matching t)
  (ido-everywhere t)
  (ido-mode 1))

(use-package ag
  :ensure t
  :commands (ag ag-regexp ag-project))

(use-package twilight-bright-theme
  :ensure t
  :config (load-theme 'twilight-bright t))

(use-package helm
  :ensure t
  :bind (("M-a" . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x f" . helm-recentf)
         ("C-SPC" . helm-dabbrev)
         ("M-y" . helm-show-kill-ring)
         ("C-x b" . helm-buffers-list))
  :bind (:map helm-map
	      ("M-i" . helm-previous-line)
	      ("M-k" . helm-next-line)
	      ("M-I" . helm-previous-page)
	      ("M-K" . helm-next-page)
	      ("M-h" . helm-beginning-of-buffer)
	      ("M-H" . helm-end-of-buffer))
  :config (progn
	    (setq helm-buffers-fuzzy-matching t)
            (helm-mode 1)))

(use-package helm-descbinds
  :ensure t
  :bind ("C-h b" . helm-descbinds))
(use-package helm-files
  :bind (:map helm-find-files-map
	      ("M-i" . nil)
	      ("M-k" . nil)
	      ("M-I" . nil)
	      ("M-K" . nil)
	      ("M-h" . nil)
	      ("M-H" . nil)))
(use-package helm-swoop
  :ensure t
  :bind (("M-m" . helm-swoop)
	 ("M-M" . helm-swoop-back-to-last-point))
  :init
  (bind-key "M-m" 'helm-swoop-from-isearch isearch-mode-map))
(use-package helm-ag
  :ensure helm-ag
  :bind ("M-p" . helm-projectile-ag)
  :commands (helm-ag helm-projectile-ag)
  :init (setq helm-ag-insert-at-point 'symbol
	      helm-ag-command-option "--path-to-agignore ~/.agignore"))

(use-package projectile
  :ensure t
  :config
  (projectile-mode)
  (setq projectile-enable-caching t))

(use-package helm-projectile
  :ensure t
  :bind (("C-x o" . helm-projectile-find-file)
	 ("M-p" . helm-projectile-find-file)
	 ("C-x r" . helm-projectile-grep))
  :config (helm-projectile-on))

(use-package ruby-mode
  :ensure t
  :defer t
  :mode (("\\.rb\\'"       . ruby-mode)
         ("\\.ru\\'"       . ruby-mode)
	 ("\\.jbuilder\\'" . ruby-mode)
         ("\\.gemspec\\'"  . ruby-mode)
         ("\\.rake\\'"     . ruby-mode)
         ("Rakefile\\'"    . ruby-mode)
         ("Gemfile\\'"     . ruby-mode)
         ("Guardfile\\'"   . ruby-mode)
         ("Capfile\\'"     . ruby-mode)
         ("Vagrantfile\\'" . ruby-mode))
  :config (progn
	    (setq ruby-indent-level 2
		  ruby-deep-indent-paren nil
		  ruby-bounce-deep-indent t
		  ruby-hanging-indent-level 2)))

(use-package rubocop
  :ensure t
  :defer t
  :init (add-hook 'ruby-mode-hook 'rubocop-mode))


(use-package minitest
  :bind ("M-e" . minitest-verify)
  :config (progn
	    (defun minitest-ruby-mode-hook ()
	      (tester-init-test-run #'minitest-run-file "_test.rb$")
	      (tester-init-test-suite-run #'minitest-verify-all))

	    (add-hook 'ruby-mode-hook 'minitest-mode)))

(use-package rspec-mode
  :ensure t
  :defer t
  :config (progn
	    (defun rspec-ruby-mode-hook ()
	      (tester-init-test-run #'rspec-run-single-file "_spec.rb$")
	      (tester-init-test-suite-run #'rake-test))
	    (add-hook 'ruby-mode-hook 'rspec-ruby-mode-hook)))

(use-package rbenv
  :ensure t
  :defer t
  :init (setq rbenv-show-active-ruby-in-modeline nil)
  :config (progn
            (global-rbenv-mode)
            (add-hook 'ruby-mode-hook 'rbenv-use-corresponding)))

(use-package flycheck
  :ensure t
  :defer 5
  :config (progn
	    (global-flycheck-mode 1)
	    ;; https://github.com/purcell/exec-path-from-shell
	    ;; only need exec-path-from-shell on OSX
	    ;; this hopefully sets up path and other vars better
	    (exec-path-from-shell-initialize)

	    ;; disable jshint since we prefer eslint checking
	    (setq-default flycheck-disabled-checkers
			  (append flycheck-disabled-checkers
				  '(javascript-jshint)))

	    ;; use eslint with web-mode for jsx files
	    (flycheck-add-mode 'javascript-eslint 'web-mode)
	    (flycheck-add-mode 'javascript-eslint 'js2-mode)

	    ;; customize flycheck temp file prefix
	    (setq-default flycheck-temp-prefix ".flycheck")

	    ))

(use-package drag-stuff
  :ensure t
  :bind (("M-<up>" . drag-stuff-up)
	 ("M-<down>" . drag-stuff-down)))

(use-package magit
  :ensure t
  :defer 2
  :bind (("C-x g" . magit-status)))

(use-package slim-mode
  :ensure t
  :mode ("\\.slim\\'" . slim-mode))

(use-package yaml-mode
  :ensure t
  :mode ("\\.ya?ml\\'" . yaml-mode))


(defun django-web-mode ()
  "Enable django web mode."
  (interactive)
  (web-mode-set-engine "django"))

(use-package web-mode
  :ensure t
  :mode (("\\.erb\\'" . web-mode)
	 ("\\.mustache\\'" . web-mode)
	 ("\\.html?\\'" . web-mode)
         ("\\.php\\'" . web-mode)
	 ("\\.djhtml\\'" . web-mode)
	 ("\\.djjson\\'" . web-mode)
	 ("\\.scss\\'" . web-mode)
	 ("\\.vue\\'" . web-mode))
  :config (progn
            (setq web-mode-markup-indent-offset 2
		  web-mode-css-indent-offset 2
		  web-mode-code-indent-offset 2
		  web-mode-script-padding 2
		  web-mode-style-padding 2))
  :init (bind-key "M-w d" 'django-web-mode))

(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . markdown-mode))

(use-package coffee-mode
  :ensure t
  :mode ("\\.coffee\\'" . coffee-mode)
  :config (progn
	    (setq coffee-indent-tabs-mode nil
		  coffee-tab-width 2)))

(use-package js2-mode
  :ensure t
  :mode (("\\.es6\\'" . js2-mode)
	 ("\\.js\\'" . js2-mode))
  :config (progn
	    (setq js2-basic-offset 2)))

(use-package robe
  :ensure t
  :bind (("C-r C-j" . robe-jump)
	 ("C-r C-r" . robe-rails-refresh)
	 ("C-r C-s" . robe-start)))
(add-hook 'ruby-mode-hook 'robe-mode)

(use-package persp-projectile
  :ensure t
  :bind (("C-x p" . projectile-persp-switch-project)
	 ("C-p s" . persp-switch))
  :config (persp-mode))

(defun my/use-eslint-from-node-modules ()
  (let* ((root (locate-dominating-file
                (or (buffer-file-name) default-directory)
                "node_modules"))
         (eslint (and root
                      (expand-file-name "node_modules/eslint/bin/eslint.js"
                                        root))))
    (when (and eslint (file-executable-p eslint))
      (setq-local flycheck-javascript-eslint-executable eslint))))
(add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules)
