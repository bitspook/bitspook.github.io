(in-package #:in.bitspook.website)

(defclass page-publisher (html-publisher)
  ((asset-pub :initform (error "Missing argument :asset-pub")
              :initarg :asset-pub))
  (:documentation "Publish independent page"))

(defun html-page-builder (&key title (feed-link nil))
  "Create HTML page for a blog-post"
  (lambda (&key css body-html)
    (spinneret:with-html
      (:html
       (:head (:title title)
              (:meta :name "viewport" :content "width=device-width, initial-scale=1")
              (:link :rel "stylesheet" :href (embed-artifact-as css 'link))
              (when feed-link (:link :rel "alternate" :type "application/atom+xml" :href feed-link))
              (:script :src "/js/app.js"))
       (:body (:raw body-html))))))

(defun make-home-page (&key title all-posts author about-me-summary)
  (let* ((html-path "/index.html")
         (root-widget (make 'home-page-w
                            :posts (take 5 all-posts)
                            :title title
                            :author author
                            :about-summary about-me-summary)))
    (make-html-page-artifact
     :location html-path
     :builder (html-page-builder :title title)
     :root-widget root-widget)))
