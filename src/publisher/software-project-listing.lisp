(in-package #:in.bitspook.website)

(defun make-software-project-listing-page (&key path projects author title (page-size 10))
  (let* ((items projects)
         (page-size (or page-size (length items)))
         (item-batches (batches projects page-size))
         (pages (loop
                  :for batch :in item-batches
                  :for batch-num :from 0 :to (length item-batches)
                  :collect (make-html-page-artifact
                            :location (base-path-join path (if (zerop batch-num) "" (format nil "./~a" batch-num)) "/index.html")
                            :css-location "/css/software-projects.css"
                            :root-widget (make 'software-project-listing-w
                                               :projects batch
                                               :title title
                                               :author author
                                               :next-page (when (> batch-num 0) `("Newer" . ,(if (zerop (1- batch-num)) "../" (format nil "../~a" (1- batch-num)))))
                                               :previous-page (when (< batch-num (1- (length item-batches)))
                                                                `("Older posts" . ,(str:concat (unless (zerop batch-num) "../") (format nil "~a" (1+ batch-num)))))))))
         (first-page (car pages))
         (rest-pages (cdr pages)))
    (dolist (page rest-pages)
      (clown:add-dep first-page page))
    first-page))
