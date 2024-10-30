(in-package #:in.bitspook.website)

(defclass org-file-provider (emacs-provider)
  ((script :initform (asdf:system-relative-pathname :in.bitspook.website "src/elisp/org-file.el"))))

(defmethod provide-all ((provider org-file-provider) &rest script-args)
  (let ((files (apply #'call-next-method `(,provider ,@script-args))))
    (mapcar
     (lambda (file)
       (make-instance
        'org-file
        :id (@ file "id")
        :filepath (@ file "filepath")
        :metadata (when (@ file "metadata")
                    (yason:parse (@ file "metadata")))
        :body-raw (@ file "body_raw")
        :body-html (@ file "body_html")))
     files)))

(defclass org-file ()
  ((id :initarg :id :accessor org-file-id)
   (filepath :initarg :filepath :accessor org-file-filepath)
   (metadata :initarg :metadata :accessor org-file-metadata)
   (body-raw :initarg :body-raw :accessor org-file-body-raw)
   (body-html :initarg :body-html :accessor org-file-body-html))
  (:documentation "A Org file as provided by org-file.el emacs-lisp script."))

(defmethod from ((obj org-file) (to (eql 'note)) &key author)
  (with-accessors ((id org-file-id)
                   (metadata org-file-metadata)
                   (body org-file-body-html)
                   (filepath org-file-filepath))
      obj
    (make 'note
          :id id
          :title (@ metadata "title")
          :slug (@ metadata "slug")
          :tags (@ metadata "tags")
          :metadata metadata
          :created-at (local-time:parse-timestring (@ metadata "created-at") :date-time-separator #\Space)
          :updated-at (local-time:parse-timestring (@ metadata "updated-at") :date-time-separator #\Space)
          :body-dom (plump:parse body)
          :author author)))

(defmethod from ((obj org-file) (to (eql 'blog-post)) &key author)
  (with-accessors ((id org-file-id)
                   (metadata org-file-metadata)
                   (body org-file-body-html)
                   (filepath org-file-filepath))
      obj
    (make 'blog-post
          :id id
          :title (@ metadata "title")
          :slug (@ metadata "slug")
          :tags (@ metadata "tags")
          :created-at (local-time:parse-timestring (@ metadata "created-at") :date-time-separator #\Space)
          :updated-at (local-time:parse-timestring (@ metadata "updated-at") :date-time-separator #\Space)
          :published-at (local-time:parse-timestring (@ metadata "date") :date-time-separator #\Space)
          :body-dom (plump:parse body)
          :summary-dom nil
          :author author)))
