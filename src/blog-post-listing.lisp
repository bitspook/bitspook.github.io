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
                    &key posts author title (page-size 10))
  (let* ((page-size (or page-size (length posts)))
         (pages (batches posts page-size)))
    (loop
      :for page-posts :in pages
      :with index := 0
      :do (progn (call-next-method
                  pub
                  :root-widget (make 'blog-post-listing-w
                                     :posts page-posts
                                     :title title
                                     :author author
                                     :next-page
                                     (when (> index 0)
                                       `("Newer posts" . ,(if (zerop (1- index))
                                                              "../"
                                                              (format nil "../~a" (1- index)))))
                                     :previous-page
                                     (when (< index (1- (length pages)))
                                       `("Older posts" . ,(str:concat
                                                           (unless (zerop index) "../")
                                                           (format nil "~a" (1+ index))))))
                  :page-builder (blog-post-listing-page-builder title)
                  :path (str:concat (unless (eql index 0) (format nil "~a/" index)) "index.html"))
                 (incf index)))))

