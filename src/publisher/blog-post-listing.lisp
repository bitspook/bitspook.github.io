(in-package #:in.bitspook.website)

(defun blog-post-listing-page-builder (title &optional feed-link)
  "Create HTML page for a blog-posts listing with TITLE."
  (lambda (&key css body-html)
    (spinneret:with-html
      (:html
       (:head (:title title)
              (:meta :name "viewport" :content "width=device-width, initial-scale=1")
              (:link :rel "stylesheet" :href (embed-artifact-as css 'link))
              (when feed-link (:link :rel "alternate" :type "application/atom+xml" :href feed-link))
              (:script :src "/js/app.js"))
       (:body (:raw body-html))))))


(defun make-blog-post-listing-page (&key dest-dir posts author title (page-size 10))
  (let* ((page-size (or page-size (length posts)))
         (post-pages (batches posts page-size))
         (pages
           (loop
             :for curr-page-posts :in post-pages
             :for page :from 0 :to (length post-pages)
             :collect (make-html-page-artifact
                       (base-path-join dest-dir (format nil "./~a" page) "/index.html")
                       (blog-post-listing-page-builder title)
                       (make 'blog-post-listing-w
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
