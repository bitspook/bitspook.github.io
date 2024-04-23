(in-package #:in.bitspook.website)

(defclass persona ()
  ((name :initarg :name
         :initform (error "Persona `name` is required"))
   (handles :initarg :handles
            :documentation "Social media handles of the form `(social-media-name username link)'")
   (avatar :initarg :avatar
           :documentation "Path to an persona's avatar image"))
  (:documentation "An online persona that can be embedded in blog pages."))

(defclass blog-post ()
  ((title :initarg :title
          :initform (error "Post `title` is required")
          :accessor post-title)
   (slug :initarg :slug
         :accessor post-slug
         :initform nil
         :documentation "Url-fragment for this blog post. Defaults to `(slugify title)`")
   (summary :initarg :summary
            :initform (error "Post `summary` is required")
            :accessor post-summary)
   (category :initarg :category
             :initform nil
             :accessor post-category)
   (tags :initarg :tags
         :initform '()
         :accessor post-tags)
   (created-at :initarg :created-at
               :initform (error "Post `created-at' is required")
               :accessor post-created-at)
   (published-at :initarg :published-at
                 :initform (error "Post `published-at' is required")
                 :accessor post-published-at)
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
    (format out "~a/~a" (post-category post) (post-slug post))))

(defclass blog-post-page (html-page-artifact blog-post) nil)

(defun make-blog-post-page (post &key location (css-location "/css/post.css"))
  (with-slots (title slug) post
    (let* ((html-path (base-path-join location "/" slug "/index.html"))
           (root-widget (make 'blog-post-w :post post))
           (css-art (make 'css-file-artifact :location css-location :root-widget root-widget)))
      (setf (slot-value root-widget 'css-file-artifact) css-art)
      (make 'blog-post-page
            ;; blog-post
            :title (post-title post)
            :slug (post-slug post)
            :summary (post-summary post)
            :category (post-category post)
            :tags (post-tags post)
            :created-at (post-created-at post)
            :published-at (post-published-at post)
            :updated-at (post-updated-at post)
            :body (post-body post)
            :author (post-author post)

            ;; html-page-artifact
            :location html-path
            :root-widget root-widget
            :deps (list css-art)))))


