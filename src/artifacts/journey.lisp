(in-package #:in.bitspook.website)

(defclass journey-page (html-page-artifact journey) nil)

(defmethod from ((journey journey) (to (eql 'html-page-artifact)) &key author location (css-location "/css/journey.css"))
  (let* ((html-path (base-path-join location "/" (journey-slug journey) "/index.html"))
         (self (make 'journey-page
                     ;; journey
                     :id (journey-id journey)
                     :name (journey-name journey)
                     :slug (journey-slug journey)
                     :summary-dom (journey-summary-dom journey)
                     :content-dom (journey-content-dom journey)
                     :note-ids (journey-note-ids journey)

                     ;; html-page-artifact
                     :location html-path))
         (clown:*self* self)
         (root-component (make 'journey-w :journey journey :author author))
         (css-art (make 'css-file-artifact :location css-location :root-component root-component)))
    (setf (slot-value root-component 'css-file-artifact) css-art)
    (setf (clown:artifact-root-component self) root-component)
    (push css-art (artifact-deps self))
    self))
