(in-package #:in.bitspook.website)

(defparameter *denotes* nil)
(defparameter *local-blog-posts* nil)
(defparameter *projects* nil)

;; Denotes
(defun blog-note-p (note)
  (declare (note note))
  (or (find "blog-post" (note-tags note) :test #'equal)
      (find "blogpost" (note-tags note) :test #'equal)))

(defun adventure-note-p (note)
  (declare (note note))
  (find "adventure" (note-tags note) :test #'equal))

(defun load-denotes (registry)
  (let ((provider (make 'denote-provider)))
    (setf *denotes*
          (union
           (apply #'union (multiple-value-list (provide-all provider :tags '("blog-post"))))
           (apply #'union (multiple-value-list (provide-all provider :tags '("german")))))))

  (loop :for note :in *denotes*
        :do (registry-add-artifact
             registry
             (cond
               ((adventure-note-p note)
                (from (from note 'adventure)
                      'html-page-artifact :location "/adventures" :author *author*))
               ((blog-note-p note) (from (from note 'blog-post)
                                         'html-page-artifact :location "/"))
               (t (from note 'html-page-artifact :location "/notes"))))))

;; ---

;; Local content
(defun load-local-content (registry)
  (labels ((local-org-file-to-post (file)
             "Set filename as slug if no slug is explicitly provided"
             (let ((post (from file 'blog-post :author *author*)))

               (when (not (@ (org-file-metadata file) "slug"))
                 (setf (post-slug post)
                       (first (str:split "." (file-namestring (org-file-filepath file))))))
               post)))
    (let* ((content-base-dir (path-join *base-dir* "content/"))
           (org-provider (make 'org-file-provider))
           (local-org-files (provide-all org-provider content-base-dir)))
      (setf *local-blog-posts* (loop
                                 :for file :in local-org-files
                                 :for post := (local-org-file-to-post file)
                                 :do (setf
                                      (post-category post)
                                      (first-elt (str:split
                                                  "/" (str:replace-all
                                                       (namestring content-base-dir) ""
                                                       (directory-namestring (org-file-filepath file))))))
                                 :collect post))))

  (loop :for post :in *local-blog-posts*
        :for page := (from post 'html-page-artifact :location "/")
        :do (registry-add-artifact registry page)))

;; ---
;; Projects
(defun load-projects ()
  ;; TODO This ain't complete.
  (let ((project-provider (make 'org-project-provider)))
    (mapcar
     (op (from _ 'software-project :author *author*))
     (provide-all project-provider (path-join *base-dir* "projects/")))))
