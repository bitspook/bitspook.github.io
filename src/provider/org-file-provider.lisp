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
