(in-package #:in.bitspook.website)

(defclass note ()
  ((slug :initarg :slug :initform nil :accessor note-slug)
   (title :initarg :name :accessor note-title)
   (tags :initarg :tags :accessor note-tags)
   (content :initarg :content :accessor note-content)))

(defmethod initialize-instance :after ((nt note) &rest initargs &key)
  "Set default value for note-slug."
  (declare (ignorable initargs))
  (when (not (note-slug nt))
    (setf (note-slug nt) (slugify (note-title nt)))))

(defmethod print-object ((nt note) out)
  (print-unreadable-object (nt out :type t)
    (format out "~a" (note-slug nt))))
