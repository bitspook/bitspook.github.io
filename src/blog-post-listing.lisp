(in-package #:in.bitspook.website)

(defclass blog-post-listing-publisher (html-publisher)
  ((asset-pub :initform (error "Not implemented")
              :initarg :asset-pub))
  (:documentation "Publish a listing page for blog posts."))

(defun blog-post-listing-page-builder (title)
  "Create HTML page for a blog-posts listing with TITLE."
  (lambda (&key css-file html)
    (spinneret:with-html
      (:html
       (:head (:title title)
              (:meta :name "viewport" :content "width=device-width, initial-scale=1")
              (:link :rel "stylesheet" :href (str:concat "/" css-file))
              (:script :src "/js/app.js"))
       (:body (:raw html))))))

(defmethod publish ((pub blog-post-listing-publisher)
                    &key posts author title (slug nil)) 
  (let* ((slug (or slug (str:concat (slugify title) "/")))
         (html-path (path-join (publisher-dest pub) slug  "index.html"))
         (layout (make 'blog-post-listing-w :posts posts :title title :author author)))
    (call-next-method pub
                      :page-builder (blog-post-listing-page-builder title)
                      :root-widget layout
                      :path html-path)))
