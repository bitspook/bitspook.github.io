(in-package #:in.bitspook.website)

(export-always 'persona)
(defclass persona ()
  ((name :initarg :name
         :initform (error "Persona `name` is required"))
   (handles :initarg :handles
            :documentation "Social media handles of the form `(social-media-name username link)'"))
  (:documentation "An online persona that can be embedded in blog pages."))

(export-always 'blog-post)
(defclass blog-post ()
  ((title :initarg :title
          :initform (error "Post `title` is required")
          :accessor post-title)
   (slug :initarg :slug
         :accessor post-slug
         :initform nil
         :documentation "Url-fragment for this blog post. Defaults to `(slugify title)`")
   (description :initarg :description
                :initform (error "Post `description` is required")
                :accessor post-description)
   (category :initarg :category
             :accessor post-category)
   (tags :initarg :tags
         :initform '()
         :accessor post-tags)
   (created-at :initarg :created-at
               :initform (error "Post `created-at' is required")
               :accessor post-created-at)
   (updated-at :initarg :updated-at
               :initform (error "Post `updated-at' is required")
               :accessor post-updated-at)
   (body :initarg :body
         :initform (error "Post `body` is required")
         :accessor post-body)
   (author :initarg :author
           :initform (error "Post `author` is required")
           :accessor post-author)))

(defmethod initialize-instance :after ((post blog-post) &rest initargs &key)
  "Set default value for post-slug."
  (declare (ignorable initargs))
  (when (not (post-slug post))
    (setf (post-slug post) (slugify (post-title post)))))

(defmethod print-object ((post blog-post) out)
  (print-unreadable-object (post out :type t)
    (princ (post-title post) out)))

(export-always 'blog-post-publisher)
(defclass blog-post-publisher (html-publisher)
  ((asset-pub
    :initarg :asset-pub
    :initform (error "asset-publisher is required")
    :documentation "A PUBLISHER to use for publishing assets (e.g Css, Js, images)."))
  (:documentation "Publish a blog post."))

(defun blog-post-page-builder (post)
  "Create HTML page for a blog-post"
  (with-slots (title) post
      (lambda (&key css-file html)
        (spinneret:with-html
          (:html
           (:head (:title title)
                  (:meta :name "viewport" :content "width=device-width, initial-scale=1")
                  (:link :rel "stylesheet" :href (str:concat "/" css-file))
                  (:script :src "/js/app.js"))
           (:body (:raw html)))))))

(defmethod publish ((pub blog-post-publisher) &key post)
  "Publish blog POST using LAYOUT widget
LAYOUT must be a WIDGET which accepts the POST as an argument."
  (with-slots (title slug) post
    (let* ((html-path (path-join (str:concat slug "/") "index.html"))
           (layout (make 'blog-post-w :post post)))
      (call-next-method pub
                        :page-builder (blog-post-page-builder post)
                        :root-widget layout
                        :path html-path))))

