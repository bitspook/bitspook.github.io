(in-package #:in.bitspook.website)

(defclass page-publisher (html-publisher)
  ((asset-pub :initform (error "Missing argument :asset-pub")
              :initarg :asset-pub))
  (:documentation "Publish independent page"))

(defun page-builder (title &optional feed-link)
  (lambda (&key css-file html)
    (spinneret:with-html
      (:html
       (:head (:title title)
              (:meta :name "viewport" :content "width=device-width, initial-scale=1")
              (:link :rel "stylesheet" :href (str:concat "/" css-file))
              (when feed-link (:link :rel "alternate" :type "application/atom+xml" :href feed-link))
              (:script :src "/js/app.js"))
       (:body (:raw html))))))

(defmethod publish ((pub page-publisher) &key root-widget title slug (feed-link nil))
  (let* ((html-path (base-path-join slug "/index.html")))
    (call-next-method pub
                      :page-builder (page-builder title feed-link)
                      :root-widget root-widget
                      :path html-path)))
