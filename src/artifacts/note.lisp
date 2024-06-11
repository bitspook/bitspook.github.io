(in-package #:in.bitspook.website)

(defclass note-page (html-page-artifact note) nil)

(defmethod from ((note note) (to (eql 'html-page-artifact)) &key location (css-location "/css/note.css"))
  (let* ((html-path (base-path-join location "/" (note-slug note) "/index.html"))
         (root-widget (make 'note-w :note note))
         (css-art (make 'css-file-artifact :location css-location :root-widget root-widget)))
    (setf (slot-value root-widget 'css-file-artifact) css-art)
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
          :root-widget root-widget
          :deps (list css-art))))
