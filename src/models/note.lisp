(in-package #:in.bitspook.website)

(defclass note ()
  ((slug :initarg :slug :initform nil :accessor note-slug)
   (title :initarg :title :accessor note-title)
   (tags :initarg :tags :accessor note-tags)
   (body :initarg :body
         :initform (error "Note `body` is required")
         :accessor note-body)
   (author :initarg :author
           :initform (error "Note `author` is required")
           :accessor note-author)
   (created-at :initarg :created-at
               :initform (error "Note `created-at' is required")
               :accessor note-created-at)
   (updated-at :initarg :updated-at
               :initform (error "Note `updated-at' is required")
               :accessor note-updated-at)))

(defmethod initialize-instance :after ((nt note) &rest initargs &key)
  "Set default value for note-slug."
  (declare (ignorable initargs))
  (when (not (note-slug nt))
    (setf (note-slug nt) (slugify (note-title nt)))))

(defmethod print-object ((nt note) out)
  (print-unreadable-object (nt out :type t)
    (format out "~a" (note-slug nt))))

(defmethod from ((obj org-file) (to (eql 'note)) &key author)
  (with-accessors ((id org-file-id)
                   (metadata org-file-metadata)
                   (body org-file-body-html)
                   (filepath org-file-filepath))
      obj
    (make 'note
          :title (@ metadata "title")
          :slug (@ metadata "slug")
          :tags (@ metadata "tags")
          :created-at (local-time:parse-timestring (@ metadata "date") :date-time-separator #\Space)
          :updated-at (local-time:parse-timestring (@ metadata "date") :date-time-separator #\Space)
          :body body
          :author (or author (make 'persona :name "Unknown")))))
