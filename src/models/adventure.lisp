(in-package #:in.bitspook.website)

(defclass adventure ()
  ((slug :initarg :slug :initform nil :accessor adventure-slug)
   (name :initarg :name :accessor adventure-name)
   (summary :initarg :summary :accessor adventure-summary)
   (content :initarg :content :accessor adventure-content)
   (notes :initarg :notes :accessor adventure-notes)))

(defmethod initialize-instance :after ((adv adventure) &rest initargs &key)
  "Set default value for adventure-slug."
  (declare (ignorable initargs))
  (when (not (adventure-slug adv))
    (setf (adventure-slug adv) (slugify (adventure-name adv)))))

(defmethod print-object ((adv adventure) out)
  (print-unreadable-object (adv out :type t)
    (format out "~a" (adventure-slug adv))))
