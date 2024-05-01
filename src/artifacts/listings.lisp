(in-package #:in.bitspook.website)

(defun make-listing-page (&key path items author title (page-size 10) widget css-location)
  (let* ((page-size (or page-size (length items)))
         (item-batches (batches items page-size))
         (pages (loop
                  :for batch :in item-batches
                  :for batch-num :from 0 :to (length item-batches)
                  :collect (make-html-page-artifact
                            :location (base-path-join path (if (zerop batch-num) "" (format nil "./~a" batch-num)) "/index.html")
                            :css-location css-location
                            :root-widget (make widget
                                               :items batch
                                               :title title
                                               :author author
                                               :next-page (when (> batch-num 0) `("Newer" . ,(if (zerop (1- batch-num)) "../" (format nil "../~a" (1- batch-num)))))
                                               :previous-page (when (< batch-num (1- (length item-batches)))
                                                                `("Older" . ,(str:concat (unless (zerop batch-num) "../") (format nil "~a" (1+ batch-num)))))))))
         (first-page (car pages))
         (rest-pages (cdr pages)))
    (dolist (page rest-pages)
      (clown:add-dep first-page page))
    first-page))

(defun make-software-project-listing-page (&key path projects author title (page-size 10))
  (make-listing-page
   :path path
   :items projects
   :author author
   :title title
   :page-size page-size
   :widget 'software-project-listing-w
   :css-location "/css/software-projects.css"))

(defun make-blog-post-listing-page (&key path posts author title (page-size 10))
  (make-listing-page
   :path path
   :items posts
   :author author
   :title title
   :page-size page-size
   :widget 'blog-post-listing-w
   :css-location "/css/blog-posts.css"))
