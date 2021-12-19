;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(add-to-list 'load-path "~/.config/doom/doom-nano-testing")
;(require 'load-nano)
(require 'nano-writer)

(setq user-full-name "Daniel Biasiotto"
      user-mail-address "daniel.biasiotto@edu.unito.it")

(setq doom-font
      (font-spec :family "Iosevka"
                 :size 15
                 :weight 'regular)
      doom-variable-pitch-font
      (font-spec :family "ETBembo"
                 :size 16
                 :height 160
                 :weight 'light))

(set-face-attribute 'org-document-title nil
                    :family "Roboto Slab"
                    :weight 'semi-bold
                    :height 300)
(set-face-attribute 'org-level-1 nil
                    :family "Roboto"
                    :weight 'regular
                    :height 200)
(set-face-attribute 'org-level-2 nil
                    :family "Roboto"
                    :weight 'regular
                    :height 190)
(set-face-attribute 'org-level-3 nil
                    :family "Roboto"
                    :weight 'regular
                    :height 180)
(set-face-attribute 'org-level-4 nil
                    :family "Roboto"
                    :weight 'regular
                    :height 160)

(use-package mixed-pitch
  :hook
  (text-mode . mixed-pitch-mode)
  (org-roam-mode . mixed-pitch-mode)
  :custom
  (set-face-attribute 'variable-pitch :height 160 :weight 'light)
  :config
  (pushnew! mixed-pitch-fixed-pitch-faces
	    'org-date
	    'org-special-keyword
	    'org-property-value
	    'org-drawer
	    'org-ref-cite-face
	    'org-tag
	    'org-todo-keyword-todo
	    'org-todo-keyword-habt
	    'org-todo-keyword-done
	    'org-todo-keyword-wait
	    'org-todo-keyword-kill
	    'org-todo-keyword-outd
	    'org-todo
	    'org-done
            'org-code
	    'font-lock-comment-face
	    'line-number
	    'line-number-current-line))

;(setq doom-theme 'doom-city-lights)
(setq fancy-splash-image "~/.config/doom/splash.png")

;; Easier to match with a bspwm rule:
;;   bspc rule -a 'Emacs:emacs-everywhere' state=floating sticky=on
(setq emacs-everywhere-frame-name-format "emacs-everywhere")
(add-hook 'emacs-everywhere-init-hooks #'hide-mode-line-mode)
;; Semi-center it over the target window, rather than at the cursor position
;; (which could be anywhere).
(defadvice! my-emacs-everywhere-set-frame-position (&rest _)
  :override #'emacs-everywhere-set-frame-position
  (cl-destructuring-bind (width . height)
      (alist-get 'outer-size (frame-geometry))
    (set-frame-position (selected-frame)
                        (+ emacs-everywhere-window-x
                           (/ emacs-everywhere-window-width 2)
                           (- (/ width 2)))
                        (+ emacs-everywhere-window-y
                           (/ emacs-everywhere-window-height 2)))))

(after! org
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "|" "DONE(d!)" "CANC(c@)")
          (sequence "TBR" "READING" "|" "READ")
          (sequence "TBW" "|" "WATCHED")
          (sequence "BUG" "|" "FIXED"))))

(setq org-superstar-headline-bullets-list '( ?◦))
;;                                            "⚀"
;;                                            "⚁"
;;                                            "⚂"
;;                                            "⚃"))

(setq org-superstar-item-bullet-alist '(
                                  (?- . ?‣)
                                  (?+ . ?•)
                                  (?* . ?◦)
                                  ))
(setq org-ellipsis "⬎")
(setq org-superstar-special-todo-items t)
(use-package! org-superstar
  :hook (org-mode . org-superstar-mode)
  :init
  :config
        (setq org-superstar-todo-bullet-alist
        '(("TODO" . ?☐)
          ("WAIT" . ?⛬)
          ("DONE" . ?☑)
          ("WATCHED" . ?☑)
          ("TBR" . ?☐)
          ("TBW" . ?☐)
          ("READING" . ?☕)
          ("READ" . ?☑)
          ("CANC" . ?☓)
          ("BUG" . ?🐛)
          ("FIXED" . ?🞊))))


(setq org-directory "~/org/"
      org-roam-directory "~/org/roam/")
;(defvar-local journal-file-path   (concat org-roam-directory "journal.org"))
;(defvar-local inbox-file-path     (concat org-roam-directory "inbox.org"))
;(defvar-local agenda-file-path    (concat org-roam-directory "agenda.org"))
;(defvar-local templates-directory (concat org-directory "templates/"))

(defun org-archive-done-tasks ()
  (interactive)
  (org-map-entries
   (lambda ()
     (org-archive-subtree)
     (setq org-map-continue-from (org-element-property :begin (org-element-at-point))))
   "/DONE" 'agenda))

(setq display-line-numbers-type nil)
(setq lsp-ui-sideline-enable nil
      lsp-enable-symbol-highlighting nil)
(setq-default c-basic-offset 2)
(setq-default tab-width 2)
(setq display-time-day-and-date t)
(setq display-time-format "%I:%M %p")
(setq display-time-default-load-average nil)
;(display-time)

(use-package deft
  :bind
  ("C-c d" . deft)
  :custom
  (deft-recursive t)
  (deft-use-filename-as-title nil)
  (deft-default-extension "org")
  (deft-directory org-roam-directory))

(defun cm/deft-parse-title (file contents)
  "Parse the given FILE and CONTENTS and determine the title.
  If `deft-use-filename-as-title' is nil, the title is taken to
  be the first non-empty line of the FILE.  Else the base name of the FILE is
  used as title."
  (let ((begin (string-match "^#\\+[tT][iI][tT][lL][eE]: .*$" contents)))
    (if begin
        (string-trim (substring contents begin (match-end 0)) "#\\+[tT][iI][tT][lL][eE]: *" "[\n\t ]+")
    (deft-base-filename file))))

(advice-add 'deft-parse-title :override #'cm/deft-parse-title)

(setq deft-strip-summary-regexp
  (concat "\\("
	  "[\n\t]" ;; blank
	  "\\|^#\\+[[:alpha:]_]+:.*$" ;; org-mode metadata
	  "\\|^:PROPERTIES:\n\\(.+\n\\)+:END:\n"
	  "\\)"))

(use-package! org-roam
  :after org
  :bind
  ("C-c r" . org-roam-node-find)
  ("C-c i" . org-roam-node-insert)
  ;("C-M-i" . completion-at-point)
  :init
  (setq +org-roam-open-buffer-on-find-file nil
        org-roam-directory (concat org-directory "/roam/")
        org-roam-mode-section-functions
        (list 'org-roam-backlinks-section
              'org-roam-reflinks-section
              'org-roam-unlinked-references-section)
        hp/org-roam-function-tags '("compilation" "argument" "journal" "video"
                                    "podcast" "concept" "tool" "data" "author"
                                    "book" "event" "article"))
  (add-to-list 'magit-section-initial-visibility-alist
               '(org-roam-unlinked-references-section . hide))
  :custom
  (org-roam-completion-everywhere t)
  ;(org-roam-capture-templates
  ;'(("d" "default" plain
  ;    "%?"
  ;    :if-new (file+head "${slug}.org" "#+title: ${title}\n#+date: %U\n")
  ;    :unnarrowed t)
  ;  ("b" "book note" plain
  ;    (file "~/org/templates/BookNote.org")
  ;    :if-new (file+head "${slug}.org" "#+title: ${title}\n#+date: %U\n")
  ;    :unnarrowed t)
  ;  ("a" "author" plain
  ;    (file "~/org/templates/Author.org")
  ;    :if-new (file+head "${slug}.org" "#+title: ${title}\n#+date: %U\n")
  ;    :unnarrowed t)
  ;  ("v" "video note" plain
  ;    (file "~/org/templates/VideoNote.org")
  ;    :if-new (file+head "${slug}.org" "#+title: ${title}\n#+date: %U\n")
  ;    :unnarrowed t)
  ;  ("c" "podcast note" plain
  ;    (file "~/org/templates/PodcastNote.org")
  ;    :if-new (file+head "${slug}.org" "#+title: ${title}\n#+date: %U\n")
  ;    :unnarrowed t)
  ;  ("n" "article note" plain
  ;    (file "~/org/templates/ArticleNote.org")
  ;    :if-new (file+head "${slug}.org" "#+title: ${title}\n#+date: %U\n")
  ;    :unnarrowed t)
  ;  ("p" "project" plain
  ;    (file "~/org/templates/Project.org")
  ;    :if-new (file+head "${slug}.org" "#+title: ${title}\n#+date: %U\n")
  ;    :unnarrowed t)
  ;  )
  ;)
  :config
  ;; Org-roam interface
  (cl-defmethod org-roam-node-hierarchy ((node org-roam-node))
    "Return the node's TITLE, as well as it's HIERACHY."
    (let* ((title (org-roam-node-title node))
           (olp (mapcar (lambda (s) (if (> (length s) 10) (concat (substring s 0 10)  "...") s)) (org-roam-node-olp node)))
           (level (org-roam-node-level node))
           (filetitle (org-roam-get-keyword "TITLE" (org-roam-node-file node)))
           (filetitle-or-name (if filetitle filetitle (file-name-nondirectory (org-roam-node-file node))))
           (shortentitle (if (> (length filetitle-or-name) 20) (concat (substring filetitle-or-name 0 20)  "...") filetitle-or-name))
           (separator (concat " " (all-the-icons-material "chevron_right") " ")))
      (cond
       ((= level 1) (concat (propertize (format "=level:%d=" level) 'display (all-the-icons-material "insert_drive_file" :face 'all-the-icons-dyellow))
                            (propertize shortentitle 'face 'org-roam-olp) separator title))
       ((= level 2) (concat (propertize (format "=level:%d=" level) 'display (all-the-icons-material "insert_drive_file" :face 'all-the-icons-dsilver))
                            (propertize (concat shortentitle separator (string-join olp separator)) 'face 'org-roam-olp) separator title))
       ((> level 2) (concat (propertize (format "=level:%d=" level) 'display (all-the-icons-material "insert_drive_file" :face 'org-roam-olp))
                            (propertize (concat shortentitle separator (string-join olp separator)) 'face 'org-roam-olp) separator title))
       (t (concat (propertize (format "=level:%d=" level) 'display (all-the-icons-material "insert_drive_file" :face 'all-the-icons-yellow))
                  (if filetitle title (propertize filetitle-or-name 'face 'all-the-icons-dyellow)))))))

  (cl-defmethod org-roam-node-functiontag ((node org-roam-node))
    "Return the FUNCTION TAG for each node. These tags are intended to be unique to each file, and represent the note's function.
        journal data literature"
    (let* ((tags (seq-filter (lambda (tag) (not (string= tag "ATTACH"))) (org-roam-node-tags node))))
      (concat
       ;; Argument or compilation
       (cond
        ((member "argument" tags)
         (propertize "=f:argument=" 'display (all-the-icons-material "forum" :face 'all-the-icons-dred)))
        ((member "compilation" tags)
         (propertize "=f:compilation=" 'display (all-the-icons-material "collections" :face 'all-the-icons-dyellow)))
        (t (propertize "=f:empty=" 'display (all-the-icons-material "remove" :face 'org-hide))))
       ;; concept, bio, data or event
       (cond
        ((member "concept" tags)
         (propertize "=f:concept=" 'display (all-the-icons-material "blur_on" :face 'all-the-icons-dblue)))
        ((member "tool" tags)
         (propertize "=f:tool=" 'display (all-the-icons-material "build" :face 'all-the-icons-dblue)))
        ((member "author" tags)
         (propertize "=f:author=" 'display (all-the-icons-material "people" :face 'all-the-icons-dblue)))
        ((member "event" tags)
         (propertize "=f:event=" 'display (all-the-icons-material "event" :face 'all-the-icons-dblue)))
        ((member "data" tags)
         (propertize "=f:data=" 'display (all-the-icons-material "data_usage" :face 'all-the-icons-dblue)))
        (t (propertize "=f:nothing=" 'display (all-the-icons-material "format_shapes" :face 'org-hide))))
       ;; literature
       (cond
        ((member "book" tags)
         (propertize "=f:book=" 'display (all-the-icons-material "book" :face 'all-the-icons-dcyan)))
        ((member "article" tags)
         (propertize "=f:article=" 'display (all-the-icons-material "move_to_inbox" :face 'all-the-icons-dsilver)))
        (t (propertize "=f:nothing=" 'display (all-the-icons-material "book" :face 'org-hide))))
       ;; journal
       )))

  (cl-defmethod org-roam-node-othertags ((node org-roam-node))
    "Return the OTHER TAGS of each notes."
    (let* ((tags (seq-filter (lambda (tag) (not (string= tag "ATTACH"))) (org-roam-node-tags node)))
           (specialtags hp/org-roam-function-tags)
           (othertags (seq-difference tags specialtags 'string=)))
      (concat
       (if othertags
           (propertize "=has:tags=" 'display (all-the-icons-faicon "tags" :face 'all-the-icons-dgreen :v-adjust 0.02))) " "
       (propertize (string-join othertags ", ") 'face 'all-the-icons-dgreen))))

  (cl-defmethod org-roam-node-backlinkscount ((node org-roam-node))
    (let* ((count (caar (org-roam-db-query
                         [:select (funcall count source)
                          :from links
                          :where (= dest $s1)
                          :and (= type "id")]
                         (org-roam-node-id node)))))
      (if (> count 0)
          (concat (propertize "=has:backlinks=" 'display (all-the-icons-material "link" :face 'all-the-icons-blue)) (format "%d" count))
        (concat (propertize "=not-backlinks=" 'display (all-the-icons-material "link" :face 'org-hide))  " "))))

  (cl-defmethod org-roam-node-directories ((node org-roam-node))
    (if-let ((dirs (file-name-directory (file-relative-name (org-roam-node-file node) org-roam-directory))))
        (concat
         (if (string= "journal/" dirs)
             (all-the-icons-material "edit" :face 'all-the-icons-dsilver)
           (all-the-icons-material "folder" :face 'all-the-icons-dsilver))
         (propertize (string-join (f-split dirs) "/") 'face 'all-the-icons-dsilver) " ")
      ""))

  (setq org-roam-node-display-template
        (concat  "${backlinkscount:16} ${functiontag} ${directories}${hierarchy} ${othertags}"))
)

;; From https://github.com/org-roam/org-roam/wiki/Hitchhiker%27s-Rough-Guide-to-Org-roam-V2#hiding-properties
(defun kb/org-hide-properties ()
  "Hide all org-mode headline property drawers in buffer. Could be slow if buffer has a lot of overlays."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward
            "^ *:properties:\n\\( *:.+?:.*\n\\)+ *:end:\n" nil t)
      (let ((ov_this (make-overlay (match-beginning 0) (match-end 0))))
        (overlay-put ov_this 'display "")
        (overlay-put ov_this 'hidden-prop-drawer t)))))

(defun kb/org-show-properties ()
  "Show all org-mode property drawers hidden by org-hide-properties."
  (interactive)
  (remove-overlays (point-min) (point-max) 'hidden-prop-drawer t))

(defun kb/org-toggle-properties ()
  "Toggle visibility of property drawers."
  (interactive)
  (if (eq (get 'org-toggle-properties-hide-state 'state) 'hidden)
      (progn
        (kb/org-show-properties)
        (put 'org-toggle-properties-hide-state 'state 'shown))
    (progn
      (kb/org-hide-properties)
      (put 'org-toggle-properties-hide-state 'state 'hidden))))

(general-define-key
 :keymaps 'org-mode-map
 "C-c p t" 'kb/org-toggle-properties
 )

(use-package! org-roam-ui
    :after org-roam
    :commands (org-roam-ui-mode))

(use-package olivetti
  :hook
  (org-mode . olivetti-mode)
  :custom
  (olivetti-set-width 80))

(setq org-image-actual-width 500)

;(set-irc-server! "chat.freenode.net"
;  `(:tls t
;    :port 6697
;    :nick "doom"
;    :sasl-username ,(+pass-get-user "irc/freenode.net")
;    :sasl-password (lambda (&rest _) (+pass-get-secret "irc/freenode.net"))
;    :channels ("#emacs")))

'(org-format-latex-options
  (quote
     (:foreground default
      :background default
      :scale 0.5
      :html-foreground "Black"
      :html-background "Transparent"
      :html-scale 1.0
      :matchers
        ("begin" "$1" "$" "$$" "\\(" "\\["))))

(global-set-key (kbd "M-s") 'ace-window)
(global-set-key (kbd "C-c w") 'writer-mode)
