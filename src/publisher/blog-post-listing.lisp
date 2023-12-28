(in-package #:in.bitspook.website)

(defclass blog-post-listing-publisher (html-publisher)
  ((asset-pub :initform (error "Missing argument :asset-pub")
              :initarg :asset-pub)
   (base-url :initform (error "Missing argument :base-url")
             :initarg :base-url)
   (slug :initform (error "Missing argument :slug")
         :initarg :slug))
  (:documentation "Publish a listing page for blog posts."))

(defun blog-post-listing-page-builder (title &optional feed-link)
  "Create HTML page for a blog-posts listing with TITLE."
  (lambda (&key css-file html)
    (spinneret:with-html
      (:html
       (:head (:title title)
              (:meta :name "viewport" :content "width=device-width, initial-scale=1")
              (:link :rel "stylesheet" :href (str:concat "/" css-file))
              (when feed-link (:link :rel "alternate" :type "application/atom+xml" :href feed-link))
              (:script :src "/js/app.js"))
       (:body (:raw html))))))

(defmethod published-path ((pub blog-post-listing-publisher) &key (page 0))
  (str:concat "/" (slot-value pub 'slug) (when (not (zerop page)) (format nil "/~d" page)) "/"))

(defmethod publish ((pub blog-post-listing-publisher)
                    &key posts author title (page-size 10))
  (let* ((page-size (or page-size (length posts)))
         (pages (batches posts page-size))
         (feed-pub (make 'feed-publisher
                         :dest (publisher-dest pub)
                         :asset-pub (slot-value pub 'asset-pub)
                         :base-url (slot-value pub 'base-url)
                         :slug (slot-value pub 'slug))))
    (loop
      :for page-posts :in pages
      :with page := 0
      :do (progn (call-next-method
                  pub
                  :root-widget (make 'blog-post-listing-w
                                     :posts page-posts
                                     :title title
                                     :author author
                                     :next-page
                                     (when (> page 0)
                                       `("Newer posts" . ,(if (zerop (1- page))
                                                              "../"
                                                              (format nil "../~a" (1- page)))))
                                     :previous-page
                                     (when (< page (1- (length pages)))
                                       `("Older posts" . ,(str:concat
                                                           (unless (zerop page) "../")
                                                           (format nil "~a" (1+ page))))))
                  :page-builder (blog-post-listing-page-builder title (published-path feed-pub :feed-file-name "feed.xml"))
                  :path (str:concat (published-path pub :page page) "index.html"))
                 (incf page)))
    (publish feed-pub :posts (first pages) :author author :title title :feed-file-name "feed.xml")))

