(in-package #:in.bitspook.website)

(defclass journey ()
  ((id :initarg :id :initform nil :accessor journey-id)
   (slug :initarg :slug :initform nil :accessor journey-slug)
   (name :initarg :name :accessor journey-name)
   (note-ids :initarg :note-ids :accessor journey-note-ids)
   (summary-dom :initarg :summary-dom :accessor journey-summary-dom :initform nil)
   (content-dom :initarg :content-dom :accessor journey-content-dom)))

(defmethod initialize-instance :after ((journey journey) &rest initargs &key)
  "Set default value for journey-slug."
  (declare (ignorable initargs))
  (when (not (journey-slug journey))
    (setf (journey-slug journey) (slugify (journey-name journey)))))

(defmethod print-object ((journey journey) out)
  (print-unreadable-object (journey out :type t)
    (format out "~a" (journey-slug journey))))

(defmethod artifact-id ((journey journey))
  (journey-id journey))

(defmethod journey-content ((journey journey))
  (plump-smart-serialize
   (resolve-linked-denotes
    (journey-content-dom journey)
    *registry*)))

(defmethod journey-summary ((journey journey))
  "Return text of JOURNEY-SUMMARY-DOM."
  (let ((dom (journey-summary-dom journey)))
    (when dom
      (str:trim
       (plump:text
        (resolve-linked-denotes dom *registry*))))))

(defmethod from ((note note) (to (eql 'journey)) &key)
  (let* ((body-dom (note-body-dom note))
         (summary-selector "#description")
         (summary-dom (when-let* ((nodes (null-if-empty (clss:select summary-selector body-dom)))
                                  (node (plump:remove-child (elt nodes 0))))
                        node)))
    (make 'journey
          :id (note-id note)
          :name (note-title note)
          :slug (note-slug note)
          :summary-dom summary-dom
          :content-dom body-dom
          :note-ids nil)))
