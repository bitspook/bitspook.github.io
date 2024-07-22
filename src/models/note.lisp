(in-package #:in.bitspook.website)

(defclass note ()
  ((slug :initarg :slug :initform nil :accessor note-slug)
   (id :initarg :id :initform nil :accessor note-id)
   (title :initarg :title :accessor note-title)
   (tags :initarg :tags :accessor note-tags)
   (metadata :initarg :metadata :accessor note-metadata)
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

(defmethod note-body ((note note))
  (plump-smart-serialize
   (resolve-linked-denotes
    (note-body-dom note)
    *registry*)))

(defmethod artifact-id ((note note))
  (note-id note))

(defun denote-links (node)
  (declare (plump:node node))
  (clss:select "a[data-denote-id]" node))

(defun linked-denote-id (node)
  (plump:get-attribute node "data-denote-id"))

(defun linked-denote-ids (node)
  (map 'list #'linked-denote-id (denote-links node)))

(defun note-eq (note1 note2)
  (equal (note-slug note1)
         (note-slug note2)))

(defun resolve-linked-denotes (node registry)
  "Convert denotes linked in plump NODE to artifacts from REGISTRY."
  (declare (plump:node node))

  (labels ((resolve-denote (link-node)
             (let* ((id (linked-denote-id link-node))
                    (artifact (registry-query registry id)))
               (plump:set-attribute
                link-node "href" (embed-artifact-as artifact 'link)))))
    (loop :for link-node :across (denote-links node)
          :do (resolve-denote link-node))
    node))
