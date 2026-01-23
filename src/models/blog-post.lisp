(in-package #:in.bitspook.website)

(defclass blog-post ()
  ((id :initarg :id :initform nil :accessor post-id)
   (title :initarg :title
          :initform (error "Post `title` is required")
          :accessor post-title)
   (slug :initarg :slug
         :accessor post-slug
         :initform nil
         :documentation "Url-fragment for this blog post. Defaults to `(slugify title)`")
   (summary-dom :initarg :summary-dom
                :initform (error "Post `summary-dom` is required")
                :accessor post-summary-dom)
   (category :initarg :category
             :initform "blog"
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
   (body-dom :initarg :body-dom
             :initform (error "Post `body-dom` is required")
             :accessor post-body-dom)
   (author :initarg :author
           :initform (error "Post `author` is required")
           :accessor post-author)))

(defmethod initialize-instance :after ((post blog-post) &rest initargs &key)
  "Set default value for post-slug."
  (declare (ignorable initargs))
  (when (not (post-slug post))
    (setf (post-slug post) (slugify (post-title post))))
  (when (not (post-id post))
    (setf (post-id post) (slugify (post-title post)))))

(defmethod print-object ((post blog-post) out)
  (print-unreadable-object (post out :type t)
    (format out "~a/~a" (post-category post) (post-slug post))))

(defmethod published-at ((post blog-post))
  (post-published-at post))

(defmethod post-body ((post blog-post))
  (let ((clown:*self* post))
    (plump-smart-serialize
     (resolve-linked-denotes
      (post-body-dom post)
      *registry*))))

(defmethod post-summary ((post blog-post))
  (let ((clown:*self* post))
    (when-let ((summary-dom (post-summary-dom post)))
      (plump-smart-serialize
       (resolve-linked-denotes summary-dom *registry*)))))

(defmethod from ((note note) (to (eql 'blog-post)) &key)
  (with-accessors ((id note-id)
                   (body-dom note-body-dom)
                   (metadata note-metadata)
                   (title note-title)
                   (author note-author)
                   (created-at note-created-at)
                   (updated-at note-updated-at))
      note
    (make 'blog-post
          :id id
          :title title
          :slug (@ metadata "slug")
          :tags (@ metadata "tags")
          :created-at created-at
          :updated-at updated-at
          :published-at created-at
          :body-dom body-dom
          :summary-dom nil
          :author author)))
