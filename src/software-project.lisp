(in-package #:in.bitspook.website)

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
               :initform (error "Project `updated-at' is required"))
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
