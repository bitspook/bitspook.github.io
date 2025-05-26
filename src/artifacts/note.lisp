(in-package #:in.bitspook.website)

(defclass note-page (html-page-artifact note) nil)

(defmethod from ((note note) (to (eql 'html-page-artifact)) &key location (css-location "/css/note.css"))
  (let* ((html-path (base-path-join location "/" (note-slug note) "/index.html"))
         (root-component (make 'note-w :note note))
         (css-art (make 'css-file-artifact :location css-location :root-component root-component)))
    (setf (slot-value root-component 'css-file-artifact) css-art)
    (make 'note-page
          ;; note
          :id (note-id note)
          :title (note-title note)
          :slug (note-slug note)
          :tags (note-tags note)
          :created-at (note-created-at note)
          :updated-at (note-updated-at note)
          :body-dom (note-body-dom note)
          :author (note-author note)
          :linked-notes (note-linked-notes note)

          ;; html-page-artifact
          :location html-path
          :root-component root-component
          :deps (list css-art))))

(defmethod artifact-tags ((obj note-page))
  (note-tags obj))

(defmethod note-body ((n note-page))
  (let ((clown:*self* n))
    (call-next-method n)))
