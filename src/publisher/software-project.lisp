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

(defclass software-project-page (html-page-artifact software-project) nil)

(defun make-software-project-page (project &key location (css-location "/css/software-project.css"))
  (with-slots (slug name description tagline issue-tracker source-code tags languages created-at updated-at body author) project
    (let* ((html-path (base-path-join location "/" slug "/index.html"))
           (root-widget (make 'software-project-w :project project))
           (css-art (make 'css-file-artifact :location css-location :root-widget root-widget)))
      (setf (slot-value root-widget 'css-file-artifact) css-art)
      (make 'software-project-page
            ;; software project
            :name name
            :description description
            :tagline tagline
            :issue-tracker issue-tracker
            :source-code source-code
            :tags tags
            :languages languages
            :created-at created-at
            :updated-at updated-at
            :body body
            :author author

            ;; html-page-artifact
            :location html-path
            :root-widget root-widget
            :deps (list css-art)))))
