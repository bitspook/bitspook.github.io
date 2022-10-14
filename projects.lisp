(in-package #:bitspook-in)

(import 'default-theme::navbar-dom)
(import 'default-theme::footer-dom)
(import 'default-theme::navbar-css)
(import 'default-theme::top-level-css)
(import 'default-theme::footer-css)
(import 'default-theme::css-var)
(import 'default-theme::css-color)
(import 'default-theme::button-css)

(import 'spinneret:with-html)
(import 'spinneret:with-html-string)
(import 'ps:ps)

(defclass widget ()
  ((children :initarg :children :accessor children)))

(defgeneric render (widget &key)
  (:documentation "Provide spinneret DOM for the WIDGET."))
(defgeneric styles-of (widget)
  (:documentation "Provide lass blocks for WIDGET"))

(defmethod render ((widget widget) &key) nil)
(defmethod styles-of ((widget widget))
  (concatenate 'list (mapcan (lambda (w) (styles-of w)) (children widget))))

(defun used-child-widgets (dom)
  (let ((children nil))
    (walk-tree
     (lambda (cell)
       (when (and (listp cell)
                  (eq (car cell) 'render))
         (push (cadr cell) children)))
     dom)
    children))

(defmacro defwidget (name args &key styles render)
  (let ((instance name)
        (children (used-child-widgets render)))
    `(progn
       (defparameter ,name
         (make-instance 'widget :children (list ,@children)))

       (defmethod styles-of ((widget (eql ,instance)))
         (concatenate 'list ,styles (call-next-method)))

       (defmethod render ((widget (eql ,instance)) &key ,@args)
         ,render))))

(defun compile-and-write-lass-blocks (styles)
  (with-output-to-string (stream)
    (dolist (style-block styles)
      (lass:write-sheet
       (lass:compile-sheet style-block)
       :stream stream))))

(defwidget projects-widget ()
  :styles (concatenate
           'list
           (top-level-css)
           (footer-css)
           `((.top-nav :padding 0)
             (.postamble :padding 0)
             (.main
              :position relative
              :margin 0 auto
              :max-width 1080px
              :font-family ,(css-var :content-font-family)

              (:header :font-family ,(css-var :title-font-family))
              (.title :font-size 2.5rem)
              (.description :font-size 1.4rem)

              (.projects-list :list-style-type none
                              :margin 4rem 0
                              :min-height 40rem)

              (.project
               :margin 1rem 0
               :padding 1rem
               :border 1px solid ,(css-color :separator-light)
               :border-radius 1rem

               (header
                :margin-bottom 2rem
                :font-family ,(css-var :content-font-family)

                (.project-title :font-size 2rem
                                :margin 0
                                :margin-bottom 0.4rem)
                (.subtitle :font-size 1.2rem
                           :color ,(css-color :dim-text))

                (.languages :width 100%
                            :margin-top 1.4rem
                            :margin-bottom 1rem

                            (.lang :display inline-flex
                                   :align-items center
                                   :margin-right 0.8rem)

                            (i :border-radius 80%
                               :width 0.8rem
                               :height 0.8rem
                               :margin 0 0.4rem)))

               (article
                :font-size 1.4rem
                (p :margin 1rem 0))

               (footer :color ,(css-color :dim-text)
                       :margin-top 1rem)))))
  :render
  (with-html
    (:html
     (:head
      (:title "@bitspook's projects")
      (:style (:raw (compile-and-write-lass-blocks (styles-of projects-widget)))))
     (:body
      (navbar-dom)
      (:article.main
       (:h1.title "Featured Projects")
       (:div.description "Listed on this page are projects which I find most interesting, want to
showcase, or are close to my heart. You can find a complete list of all my open
source work on " (:a :href (conf :github) "my github profile") ".")
       (:ul.projects-list
        (:li.project
         (:header (:h2.project-title (:a :href "/projects/spookfox" "Spookfox"))
                  (:p.subtitle "Tinkerer's bridge between Emacs and Firefox.")
                  (:div.languages
                   (:span.lang.emacs-lisp
                    (:i :style "background: #952994")
                    (:span.lang-name "Emacs Lisp"))
                   (:span.lang.typescript
                    (:i :style "background-color: #452134")
                    (:span.lang-name "Typescript"))))
         (:article
          (:p "Spookfox is a Firefox extension and an Emacs package, which allow Emacs and
Firefox to communicate with each other. Its primary goal is to offer an Emacs
tinkerer similar (to Emacs) framework to tinker their browser.")
          (:p "I use Spookfox as my daily driver to enable a number of workflow enhancements,
e.g capturing articles I read and Youtube videos I watch, and also to organize
hundreds tabs using org-mode."))
         (:footer
          (:div.last-update "Last updated on Oct 12, 2022")))))
      (footer-dom)))))

(defwidget listing-widget (items)
  :styles `((.listing
             :list-style-type none
             :font-family "Cantarell, sans-serif"

             (li :display flex
                 :line-height 1.3
                 :padding 0.32rem 0
                 :align-items center
                 :margin-bottom 0.6rem))

            (.li-icon :display block
                      :background-repeat no-repeat
                      :background-position 0 0
                      :background-size contain
                      :content ""
                      :width 88px
                      :height 48px
                      :flex-shrink 0)

            (.li-icon--blog :background-image "url(/images/icons/post.svg)")
            (.li-icon--talks :background-image "url(/images/icons/talk.svg)")
            (.li-icon--poems :background-image "url(/images/icons/poems.svg)")

            (.li-title :font-size 1.5rem)

            (.li-meta :margin-top 0.5rem
                      :font-size 1rem
                      :display flex)

            ((:and .li-meta (.li-meta a)) :font-family "Roboto, sans-serif"
                                          :color ,(css-color :secondary)
                                          :display flex)

            (.meta-item :line-height 1
                        :padding 0
                        :padding-right 1em
                        :border-right ,(format nil "1px solid ~a" (css-color :separator)))
            ((:and .meta-item :last-child) :padding-right 0
                                           :border none)

            (.tags :display flex
                   :flex-wrap wrap

                   (a :margin-left 1rem))

            (.rss :width 24px
                  :height 24px
                  :margin-right 1rem
                  :background "url(\"/images/icons/rss.svg\")"
                  :background-repeat no-repeat
                  :background-size contain))
  :render (with-html
            (:ul.listing
             (:li
              (:span :class "li-icon li-icon--blog")
              (:div.li-content
               (:a.li-title
                :href "/blog/post"
                "I am a blog post")
               (:span.li-meta
                (:span :class "meta-item date" "January 21, 2022")
                (:span :class "meta-item tags"
                       (:a :href "tags/lol" "#lol"))))))))
(setf ps:*js-string-delimiter* #\")
(defwidget oracle-nav (o-spec)
  :styles `((.oracle-container
             :margin 2rem 0

             (select
                 :border none
               :background white
               :margin 0 1rem
               :font-size 1.2rem
               :padding 0.4rem 0
               :border-bottom 2px solid ,(css-color :primary-text)
               :min-width 10rem)))
  :render
  (with-html
    (:div.oracle-container
     :style "display:none;"
     (:span.placeholder "I am")
     (:select :onchange (ps (handle-select-role event.target.value))
       (:option :value "universal" "one with the universe")
       (:option :value "developer" "a developer")
       (:option :value "surfer" "web surfer"))
     (:span#developer-placeholder.placeholder "who wants to")

     (:span#surfer-placeholder.placeholder "who wants to")
     (:select#surfer-intent
      :onchange (ps (handle-select-intent event.target.value))
      (:option :value "know-more" "know more about Spookfox"))

     (:select#developer-intent
      :onchange (ps (handle-select-intent event.target.value))
      (:option :value "know-more" "know more about Spookfox")
      (:option :value "use" "use Spookfox")
      (:option :value "develop" "develop Spookfox")
      (:option :value "hack" "hack with Spookfox")
      (:option :value "contribute" " contribute to Spookfox"))
     (:script
      (:raw
       (ps
         (defun dom-el (selector &optional select-all)
           ((ps:@ document
                  (if select-all
                      'query-selector-all
                      'query-selector))
            selector))
         (defun display (el)
           (ps:@ el style display))
         (defun (setf display) (val el)
           (setf (ps:@ el style display) val))

         (defmacro with-elements (selector-forms &body body)
           `(let ,(loop :for form :in selector-forms
                        :collect `(,(first form) (dom-el ,(second form))))
              ,@body))
         (defmacro with-all-elements (selector-forms &body body)
           `(with-elements ,selector-forms
              (when (and ,@(mapcar #'first selector-forms)) ,@body)))

         (defvar +roles+ '(developer surfer universal))
         (defvar +intents+ '(universal use develop contribute explore feature-request bug-report))
         (defvar +role-intents+
           (ps:create
            surfer '(explore contribute)
            universal '(universal)
            developer  '(use develop contribute bug-report feature-request)))
         (defparameter *state* (ps:create))

         (defun activate-role (role)
           (dolist (r +roles+)
             (with-all-elements ((el (+ "#" r "-intent"))) (setf (display el) "none"))
             (with-all-elements ((el (+ "#" r "-placeholder"))) (setf (display el) "none")))
           (with-elements ((intent-el (+ "#" role "-intent"))
                           (ph-el (+ "#" role "-placeholder")))
             (when intent-el (setf (display intent-el) "inline-block"))
             (when ph-el (setf (display ph-el) "inline-block")))
           (setf (ps:@ *state* "active-role") role))

         (defun active-intents ()
           (ps:@ +role-intents+ (ps:@ *state* "active-role")))

         (defun activate-intent (intent)
           (dolist (i +intents+)
             (with-all-elements ((el (+ "#" i)))
               (setf (display el) "none"))
             (dolist (i (active-intents))
               (with-all-elements ((el (+ "#" i)))
                 (setf (display el) "block")))))

         (defun handle-select-role (role)
           (activate-role role)
           (activate-intent (ps:@ (ps:getprop +role-intents+ role) 0)))

         (defun handle-select-intent (intent)
           (activate-intent intent))

         (defun init ()
           (with-all-elements ((el ".oracle-container"))
             (setf (display el) "flex"))
           (activate-role 'surfer))

         (init)))))))

(defwidget project-widget (project)
  :styles (concatenate
           'list
           (top-level-css)
           (footer-css)
           `((.top-nav :padding 0)
             (.postamble :padding 0)
             (.container
              :max-width 1080px
              :margin 0 auto
              :color ,(css-color :primary-text)

              ("header.main"
               :margin 2rem 0

               (.title :font-size 2.5rem
                       :margin 0
                       :margin-bottom 0.4rem)

               (.subtitle :font-size 1.2rem
                          :color ,(css-color :dim-text)))

              ("article.main"
               :min-height 40rem
               :font-size 1.4rem

               (p :margin 1rem 0))

              (.elsewhere-buttons
               :list-style-type none
               :display flex
               :margin-top 3rem

               (li :margin-right 1.4rem))

              ((:or .btn-github .btn-issues .btn-docs)
               :padding 0 1rem
               :font-size 1.2rem
               :color ,(css-color :secondary)

               (.icon :background-size contain
                      :display inline-block
                      :width 1.4rem
                      :height 1.4rem
                      :margin-right 0.4rem))

              (.btn-github (.icon :background-image (url "/images/icons/github.svg")))
              (.btn-issues (.icon :background-image (url "/images/icons/issues.svg")))
              (.btn-docs (.icon :background-image (url "/images/icons/docs.svg"))))))
  :render
  (with-html
    (:html
     (:head (:title "Spookfox - @bitspook's project")
            (:style (:raw (compile-and-write-lass-blocks (styles-of project-widget)))))
     (:body
      (navbar-dom)
      (:section.container
       (:header.main
        (:h1.title "Spookfox")
        (:p.subtitle "Tinkerer's bridge between Emacs to Firefox"))
       (:article.main
        (:p "Spookfox is a Firefox extension and an Emacs package, which allow Emacs and
             Firefox to communicate with each other. Its primary goal is to
             offer an Emacs tinkerer similar (to Emacs) framework to tinker
             their browser.")
        (:p "I use Spookfox as my daily driver to enable a number of workflow enhancements,
             e.g capturing articles I read and Youtube videos I watch, and also
             to organize hundreds tabs using org-mode.")
        (:ul.elsewhere-buttons
         (:li (:a.btn.btn-github :href (conf :github) (:i.icon) (:span "Source Code")))
         (:li (:a.btn.btn-issues :href (conf :github) (:i.icon) (:span "Issue tracker")))
         (:li (:a.btn.btn-docs :href (conf :github) (:i.icon) (:span "Documentation"))))

        (:div#oracle-nav
         (render oracle-nav))

        (:div#use
         (:h2.title "Usage")
         (:div ("Use this in emacs. Use this in Firefox.")))

        (:div#explore
         (:h2.title "Related blog posts")
         (render listing-widget)))
       (footer-dom))))))

(let ((*debug-transpiles* t)
      (*conf* (conf-merge
               `(:db-name "./clownpress.db"
                 :site-url "https://bitspook.in/"
                 :author "Charanjit Singh"
                 :avatar "/images/avatar.png"
                 :twitter "https://twitter.com/bitspook"
                 :linkedin "https://linked.com/in/bitspook"
                 :github "https://github.com/bitspook"
                 :handle "bitspook"
                 :resume "https://docs.google.com/document/d/1HFOxl97RGtuhAX95AhGWwa808SO9qSCYLjP1Pm39la0/"
                 :dest "./docs/"
                 :static-dirs ("./static/")
                 :mixpanel-token "0f28a64d9f8bce370006d36e1e2e3f61"
                 :rss-max-posts 10
                 :control-tags ("blog-post" "published")
                 :exclude-tags ("draft")
                 :published-categories '("blog" "poems")
                 :theme ,default-theme))))
  (mapcar #'clown-publishers:publish-static (conf :static-dirs))

  (clown-publishers:publish-html-file
   "projects/index.html"
   (with-html-string (render projects-widget)))
  (clown-publishers:publish-html-file
   "projects/spookfox/index.html"
   (with-html-string (render project-widget))))
