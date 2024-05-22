(in-package #:in.bitspook.website)

(defclass note ()
  ((slug :initarg :slug :initform nil :accessor note-slug)
   (id :initarg :id :initform nil :accessor note-id)
   (title :initarg :title :accessor note-title)
   (tags :initarg :tags :accessor note-tags)
   (body-dom :initarg :body-dom
             :initform (error "Note `body-dom` is required")
             :accessor note-body-dom
             :documentation "A Plump node representing body of note.")
   (author :initarg :author
           :initform (error "Note `author` is required")
           :accessor note-author)
   (created-at :initarg :created-at
               :initform (error "Note `created-at' is required")
               :accessor note-created-at)
   (updated-at :initarg :updated-at
               :initform (error "Note `updated-at' is required")
               :accessor note-updated-at)
   (linked-notes :initarg :linked-notes
                 :initform nil
                 :accessor note-linked-notes)))

(defmethod initialize-instance :after ((nt note) &rest initargs &key)
  "Set default value for note-slug."
  (declare (ignorable initargs))
  (unless (note-slug nt)
    (setf (note-slug nt)
          (str:join "-" (append1
                         (mapcar #'slugify (note-tags nt))
                         (slugify (note-title nt))))))
  (unless (note-id nt)
    (setf (note-id nt) (note-slug nt))))

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
          :id id
          :title (@ metadata "title")
          :slug (@ metadata "slug")
          :tags (@ metadata "tags")
          :created-at (local-time:parse-timestring (@ metadata "date") :date-time-separator #\Space)
          :updated-at (local-time:parse-timestring (@ metadata "date") :date-time-separator #\Space)
          :body-dom (plump:parse body)
          :author (or author (make 'persona :name "Unknown")))))

(defun note-eq (note1 note2)
  (equal (note-slug note1)
         (note-slug note2)))
