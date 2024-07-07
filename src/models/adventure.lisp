(in-package #:in.bitspook.website)

(defclass adventure ()
  ((id :initarg :id :initform nil :accessor adventure-id)
   (slug :initarg :slug :initform nil :accessor adventure-slug)
   (name :initarg :name :accessor adventure-name)
   (notes :initarg :notes :accessor adventure-notes)
   (summary-dom :initarg :summary-dom :accessor adventure-summary-dom :initform nil)
   (content-dom :initarg :content-dom :accessor adventure-content-dom)))

(defmethod initialize-instance :after ((adv adventure) &rest initargs &key)
  "Set default value for adventure-slug."
  (declare (ignorable initargs))
  (when (not (adventure-slug adv))
    (setf (adventure-slug adv) (slugify (adventure-name adv)))))

(defmethod print-object ((adv adventure) out)
  (print-unreadable-object (adv out :type t)
    (format out "~a" (adventure-slug adv))))

(defmethod adventure-content ((adv adventure))
  (plump-smart-serialize
   (resolve-linked-denotes
    (adventure-content-dom adv)
    *registry*)))

(defmethod adventure-summary ((adv adventure))
  (let ((dom (adventure-summary-dom adv)))
    (when dom
      (plump-smart-serialize
       (resolve-linked-denotes dom *registry*)))))

(defmethod from ((note note) (to (eql 'adventure)) &key)
  (let* ((body-dom (note-body-dom note))
         (summary-selector "#description")
         (summary-dom (when-let* ((nodes (null-if-empty (clss:select summary-selector body-dom)))
                                  (node (plump:remove-child (elt nodes 0))))
                        node)))
    (make 'adventure
          :id (note-id note)
          :name (note-title note)
          :slug (note-slug note)
          :summary-dom summary-dom
          :content-dom body-dom
          :notes (note-linked-notes note))))
