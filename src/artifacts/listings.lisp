(in-package #:in.bitspook.website)

(defclass listing-page (html-page-artifact)
  ((id :initform nil :initarg :id :accessor artifact-id)))

(defun make-listing-page (&key path items author title type name (page-size 10) widget css-location (id nil))
  (let* ((page-size (or page-size (length items)))
         (item-batches (batches items page-size))
         (pages (loop
                  :for batch :in item-batches
                  :for batch-num :from 0 :to (length item-batches)
                  :for root-widget := (make widget
                                            :items batch
                                            :title title
                                            :author author
                                            :name name
                                            :type type
                                            :next-page (when (> batch-num 0)
                                                         `("Newer" . ,(if (zerop (1- batch-num))
                                                                          "../"
                                                                          (format nil "../~a" (1- batch-num)))))
                                            :previous-page (when (< batch-num (1- (length item-batches)))
                                                             `("Older" . ,(str:concat
                                                                           (unless (zerop batch-num) "../")
                                                                           (format nil "~a" (1+ batch-num))))))
                  :for css-art := (make 'css-file-artifact :location css-location :root-widget root-widget)
                  :do (setf (slot-value root-widget 'css-file-artifact) css-art)
                  :collect (make 'listing-page
                                 :location (base-path-join
                                            path
                                            (if (zerop batch-num)
                                                ""
                                                (format nil "./~a" batch-num))
                                            "/index.html")
                                 :deps (list css-art)
                                 :root-widget root-widget)))
         (first-page (car pages))
         (rest-pages (cdr pages)))
    (dolist (page rest-pages)
      (clown:add-dep first-page page))

    (when (and id first-page)
      (setf (slot-value first-page 'id) id))

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

(defun make-blog-post-listing-page (&key path posts author title type name (page-size 10) (id nil))
  (make-listing-page
   :path path
   :items posts
   :author author
   :title title
   :page-size page-size
   :widget 'blog-post-listing-w
   :name name
   :type type
   :id id
   :css-location "/css/blog-posts.css"))
