(in-package #:in.bitspook.website)

(defun make-blog-post-listing-page (&key path posts author title (page-size 10))
  (let* ((page-size (or page-size (length posts)))
         (post-pages (batches posts page-size))
         (pages
           (loop
             :for curr-page-posts :in post-pages
             :for page :from 0 :to (length post-pages)
             :collect (make-html-page-artifact
                       :location (base-path-join path (if (zerop page) "" (format nil "./~a" page)) "/index.html")
                       :css-location "/css/listing.css"
                       :root-widget (make 'blog-post-listing-w
                                          :posts curr-page-posts
                                          :title title
                                          :author author
                                          :next-page
                                          (when (> page 0)
                                            `("Newer posts" . ,(if (zerop (1- page))
                                                                   "../"
                                                                   (format nil "../~a" (1- page)))))
                                          :previous-page
                                          (when (< page (1- (length post-pages)))
                                            `("Older posts" . ,(str:concat
                                                                (unless (zerop page) "../")
                                                                (format nil "~a" (1+ page)))))))))
         (first-page (car pages))
         (rest-pages (cdr pages)))
    (dolist (page rest-pages)
      (clown:add-dep first-page page))
    first-page))
