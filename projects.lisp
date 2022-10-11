(in-package #:bitspook-in)

(import 'default-theme::navbar-dom)
(import 'default-theme::navbar-css)
(import 'default-theme::top-level-css)
(import 'default-theme::css-var)

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
   (top-level-css)
   `((.top-nav :padding 0)
     (.main
      :position relative
      :margin 0 auto
      :max-width 1080px
      :font-family ,(css-var :content-font-family)

      (:header :font-family ,(css-var :title-font-family))
      (.title :font-size 2.2em)
      (.description :font-size 1.6em)
      (.projects-list :list-style-type none)

      (.project
       (header :margin 2em 0)
       (.title :font-size 2em
               :margin none)
       (.subtitle :font-size 1.8em)
       (article :font-size 1.4em))))))

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
       (:header (:h2.title "Spookfox")
                (:p.subtitle "Hacker's bridge between Emacs and Firefox." ))
       (:article ""))))))

(defmethod render ((widget projects-widget) &key)
  (call-next-method
   widget
   :head-dom
   (lambda ()
     (with-html
       (:title "Mittran de project!")))))

(defun publish-projects ()
  (let* ((p-widget (make-instance 'projects-widget :projects nil))
         (html (with-html-string (render p-widget))))
    (clown-publishers:publish-html-file "projects/index.html" html)))
