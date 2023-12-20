(in-package #:in.bitspook.website)

(defclass org-file-provider (emacs-provider)
  ((script :initform (asdf:system-relative-pathname
                      :in.bitspook.website "src/elisp/org-file.el"))))

(defmethod provide-all ((provider org-file-provider) &rest script-args)
  (let ((notes (apply #'call-next-method `(,provider ,@script-args))))
    (mapcar
     (lambda (note)
       (make-instance
        'org-file
        :id (@ note "id")
        :filepath (@ note "filepath")
        :metadata (when (@ note "metadata")
                    (yason:parse (@ note "metadata")))
        :body-raw (@ note "body_raw")
        :body-html (@ note "body_html")))
     notes)))

(defclass org-file ()
  ((id :initarg :id :accessor org-file-id)
   (filepath :initarg :filepath :accessor org-file-filepath)
   (metadata :initarg :metadata :accessor org-file-metadata)
   (body-raw :initarg :body-raw :accessor org-file-body-raw)
   (body-html :initarg :body-html :accessor org-file-body-html))
  (:documentation "A Org file as provided by org-file.el emacs-lisp script."))

(defmethod from ((obj org-file) (to (eql 'blog-post)) &key author)
  (with-accessors ((id org-file-id)
                   (metadata org-file-metadata)
                   (body org-file-body-html)
                   (filepath org-file-filepath))
      obj
    (make 'blog-post
          :title (@ metadata "title")
          :slug (@ metadata "slug")
          :tags (@ metadata "tags")
          :created-at (local-time:parse-timestring (@ metadata "date") :date-time-separator #\Space)
          :updated-at (local-time:parse-timestring (@ metadata "date") :date-time-separator #\Space)
          :body body
          :description ""
          :author (or author (make 'persona :name "Unknown")))))

(defmethod from ((obj org-file) (to (eql 'software-project)) &key author)
  (with-accessors ((id org-file-id)
                   (metadata org-file-metadata)
                   (body org-file-body-html))
      obj
    (make 'software-project
          :name (@ metadata "title")
          :slug (@ metadata "slug")
          :description (@ metadata "description_html")
          :tagline (@ metadata "tagline")
          :issue-tracker (@ metadata "issue-tracker")
          :source-code (@ metadata "source-code")
          :tags (@ metadata "tags")
          :languages (@ metadata "languages")
          :created-at (local-time:parse-timestring (@ metadata "date") :date-time-separator #\Space)
          :updated-at (local-time:parse-timestring (@ metadata "updated_at") :date-time-separator #\Space)
          :body body
          :author (or author (make 'persona :name "Unknown")))))
