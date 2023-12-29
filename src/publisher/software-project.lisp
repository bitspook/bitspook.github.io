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

(defclass software-project-publisher (html-publisher)
  ((asset-pub :initarg :asset-pub
              :initform (error "asset-publisher is required")
              :documentation "A PUBLISHER to use for publishing assets (e.g Css, Js, images).")
   (slug :initarg :slug
         :initform (error "Missing argument :slug")
         :documentation "Slug used to locate and publish created artifacts."))
  (:documentation "Publish a software-project."))

(defmethod published-path ((pub software-project-publisher) &key project)
  (base-path-join "/" (slot-value pub 'slug) "/" (project-slug project)))

(defun software-project-page-builder (project)
  "Create HTML page for a software-project"
  (with-slots (name) project
    (lambda (&key css-file html)
      (spinneret:with-html
        (:html
         (:head (:title name)
                (:meta :name "viewport" :content "width=device-width, initial-scale=1")
                (:link :rel "stylesheet" :href (str:concat "/" css-file))
                (:script :src "/js/app.js"))
         (:body (:raw html)))))))

(defmethod publish ((pub software-project-publisher) &key project )
  (with-slots (name slug) project
    (let* ((html-path (base-path-join (published-path pub :project project) "/index.html"))
           (layout (make 'software-project-w :project project)))
      (call-next-method pub
                        :page-builder (software-project-page-builder project)
                        :root-widget layout
                        :path html-path))))
