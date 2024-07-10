(in-package #:in.bitspook.website)

(defclass journey-page (html-page-artifact journey) nil)

(defmethod from ((journey journey) (to (eql 'html-page-artifact)) &key author location (css-location "/css/journey.css"))
  (let* ((html-path (base-path-join location "/" (journey-slug journey) "/index.html"))
         (root-widget (make 'journey-w :journey journey :author author))
         (css-art (make 'css-file-artifact :location css-location :root-widget root-widget)))
    (setf (slot-value root-widget 'css-file-artifact) css-art)
    (make 'journey-page
          ;; journey
          :id (journey-id journey)
          :name (journey-name journey)
          :slug (journey-slug journey)
          :summary-dom (journey-summary-dom journey)
          :content-dom (journey-content-dom journey)
          :notes (journey-notes journey)

          ;; html-page-artifact
          :location html-path
          :root-widget root-widget
          :deps (append (list css-art) (journey-notes journey)))))
