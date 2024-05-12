(in-package #:in.bitspook.website)

(defclass adventure-page (html-page-artifact adventure) nil)

(defun make-adventure-page (adv &key author location (css-location "/css/adventure.css"))
  (let* ((html-path (base-path-join location "/" (adventure-slug adv) "/index.html"))
         (root-widget (make 'adventure-w :adventure adv :author author))
         (css-art (make 'css-file-artifact :location css-location :root-widget root-widget)))
    (setf (slot-value root-widget 'css-file-artifact) css-art)
    (make 'adventure-page
          ;; adventure
          :name (adventure-name adv)
          :slug (adventure-slug adv)
          :summary (adventure-summary adv)
          :content (adventure-content adv)

          ;; html-page-artifact
          :location html-path
          :root-widget root-widget
          :deps (append (list css-art) (adventure-notes adv)))))
