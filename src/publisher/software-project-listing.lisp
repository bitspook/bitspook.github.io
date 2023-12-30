(in-package #:in.bitspook.website)

(defclass software-project-listing-publisher (html-publisher)
  ((asset-pub :initform (error "Missing argument :asset-pub")
              :initarg :asset-pub)
   (base-url :initform (error "Missing argument :base-url")
             :initarg :base-url)
   (slug :initform (error "Missing argument :slug")
         :initarg :slug)))

(defun software-project-listing-page-builder (title)
  (lambda (&key css-file html)
    (spinneret:with-html
      (:html
       (:head (:title title)
              (:meta :name "viewport" :content "width=device-width, initial-scale=1")
              (:link :rel "stylesheet" :href (str:concat "/" css-file))
              (:script :src "/js/app.js"))
       (:body (:raw html))))))

(defmethod published-path ((pub software-project-listing-publisher) &key (page 0))
  (str:concat "/" (slot-value pub 'slug) (when (not (zerop page)) (format nil "/~d" page)) "/"))

(defmethod publish ((pub software-project-listing-publisher)
                    &key projects author title (page-size 10))
  (let* ((page-size (or page-size (length projects)))
         (pages (batches projects page-size)))
    (loop
      :for page-projects :in pages
      :with page := 0
      :do (let ((project-pub (make 'software-project-publisher
                                   :asset-pub (slot-value pub 'asset-pub)
                                   :dest (publisher-dest pub)
                                   :slug (slot-value pub 'slug))))
            ;; Publish the project itself
            (loop :for project :in page-projects
                  :do (publish project-pub :project project))

            (call-next-method
             pub
             :root-widget (make 'software-project-listing-w
                                :projects page-projects
                                :project-publisher project-pub
                                :title title
                                :author author
                                :next-page
                                (when (> page 0)
                                  `("Newer projects" . ,(if (zerop (1- page))
                                                            "../"
                                                            (format nil "../~a" (1- page)))))
                                :previous-page
                                (when (< page (1- (length pages)))
                                  `("Older projects" . ,(str:concat
                                                         (unless (zerop page) "../")
                                                         (format nil "~a" (1+ page))))))
             :page-builder (software-project-listing-page-builder title)
             :path (str:concat (published-path pub :page page) "index.html"))
            (incf page)))))
