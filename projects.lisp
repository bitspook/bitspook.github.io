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

(defclass widget () ())

(defgeneric dom-of (widget &key))
(defgeneric styles-of (widget &key))
(defgeneric render (widget &key))

(defmethod render ((widget widget) &key head-dom)
  (let ((styles
          (with-output-to-string (stream)
            (dolist (style-block (styles-of widget))
              (lass:write-sheet
               (lass:compile-sheet style-block)
               :stream stream)))))
    (with-html
      (:html
       (:head
        (when (functionp head-dom) (funcall head-dom))
        (:style (:raw styles)))
       (dom-of widget)))))

(defmethod dom-of ((widget widget) &key) nil)
(defmethod styles-of ((widget widget) &key) nil)

(defclass projects-widget (widget)
  ((projects :initarg :projects
             :initform (error "projects to render were not provided"))))

(defmethod styles-of ((widget projects-widget) &key)
  (concatenate
   'list
   (navbar-css)
   (footer-css)
   (top-level-css)
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
               :margin-top 1rem))))))

(defmethod dom-of ((widget projects-widget) &key)
  (with-html
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
    (footer-dom)))

(defmethod render ((widget projects-widget) &key)
  (call-next-method
   widget
   :head-dom
   (lambda ()
     (with-html
       (:title "Mittran de project!")))))

(defclass project-widget (widget)
  ((project :initarg :project
            :initform (error "Project is required"))))

(defmethod styles-of ((widget project-widget) &key)
  (concatenate
   'list
   (top-level-css)
   (navbar-css)
   (footer-css)
   `((.top-nav :padding 0)
     (.preamble :padding 0)
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
      (.btn-docs (.icon :background-image (url "/images/icons/docs.svg")))))))

(defmethod dom-of ((widget project-widget) &key)
  (with-html
    (navbar-dom)
    (:section.container
     (:header.main
      (:h1.title "Spookfox")
      (:p.subtitle "Tinkerer's bridge between Emacs to Firefox"))
     (:article.main
      (:p "Spookfox is a Firefox extension and an Emacs package, which allow Emacs and
Firefox to communicate with each other. Its primary goal is to offer an Emacs
tinkerer similar (to Emacs) framework to tinker their browser.")
      (:p "I use Spookfox as my daily driver to enable a number of workflow enhancements,
e.g capturing articles I read and Youtube videos I watch, and also to organize
hundreds tabs using org-mode.")
      (:ul.elsewhere-buttons
       (:li (:a.btn.btn-github :href (conf :github) (:i.icon) (:span "Source Code")))
       (:li (:a.btn.btn-issues :href (conf :github) (:i.icon) (:span "Issue tracker")))
       (:li (:a.btn.btn-docs :href (conf :github) (:i.icon) (:span "Documentation")))))
     (footer-dom))))

(let ((*debug-transpiles* nil)
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
  (let* ((p-widget (make-instance 'projects-widget :projects nil))
         (pp-widget (make-instance 'project-widget :project nil))
         (html (with-html-string (render p-widget))))
    (mapcar #'clown-publishers:publish-static (conf :static-dirs))
    (clown-publishers:publish-html-file "projects/index.html" html)
    (clown-publishers:publish-html-file "projects/spookfox/index.html" (with-html-string (render pp-widget)))))
