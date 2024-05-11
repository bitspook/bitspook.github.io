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

(defclass software-project ()
  ((name :initarg :name
         :initform (error "Project `name` is required")
         :accessor project-name)
   (slug :initarg :slug
         :accessor project-slug
         :initform nil
         :documentation "Url-fragment for this project. Defaults to `(slugify name)`")
   (description :initarg :description
                :initform (error "Project `description` is required")
                :accessor project-description)
   (tagline :initarg :tagline
            :initform (error "Project `tagline` is required")
            :accessor project-tagline)
   (issue-tracker :initarg :issue-tracker
                  :accessor project-issue-tracker)
   (source-code :initarg :source-code
                :accessor project-source-code)
   (tags :initarg :tags
         :initform '()
         :accessor project-tags)
   (languages :initarg :languages
              :initform '()
              :accessor project-languages)
   (created-at :initarg :created-at
               :initform (error "Project `created-at' is required")
               :accessor project-created-at)
   (updated-at :initarg :updated-at
               :initform (error "Project `updated-at' is required")
               :accessor project-updated-at)
   (body :initarg :body
         :initform (error "Project `body` is required")
         :accessor project-body)
   (author :initarg :author
           :initform (error "Project `author` is required")
           :accessor project-author)))

(defmethod initialize-instance :after ((project software-project) &rest initargs &key)
  "Set default value for project-slug."
  (declare (ignorable initargs))
  (when (not (project-slug project))
    (setf (project-slug project) (slugify (project-name project)))))

(defmethod print-object ((project software-project) out)
  (print-unreadable-object (project out :type t)
    (format out "~a" (project-slug project))))

(defclass adventure ()
  ((slug :initarg :slug :initform nil :accessor adventure-slug)
   (name :initarg :name :accessor adventure-name)
   (summary :initarg :summary :accessor adventure-summary)
   (content :initarg :content :accessor adventure-content)))

(defmethod initialize-instance :after ((adv adventure) &rest initargs &key)
  "Set default value for adventure-slug."
  (declare (ignorable initargs))
  (when (not (adventure-slug adv))
    (setf (adventure-slug adv) (slugify (adventure-name adv)))))

(defmethod print-object ((adv adventure) out)
  (print-unreadable-object (adv out :type t)
    (format out "~a" (adventure-slug adv))))
