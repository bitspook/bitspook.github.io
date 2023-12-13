(ql:quickload '(:in.bitspook.website))

(in-package #:in.bitspook.website)

(defparameter *author*
  (make 'persona
        :name "Charanjit Singh"
        :handles '(("Mastodon" "bitspook" "https://infosec.exchange/@bitspook"))))

(defparameter *base-dir* (asdf:system-relative-pathname :in.bitspook.website ""))

(defparameter *notes*
  (let ((notes-provider (make-instance 'denote-provider)))
    (mapcar
     (op (from _ 'blog-post :author *author*))
     (provide-all notes-provider "blog-post"))))

(defparameter *local-org-files*
  (let ((org-provider (make 'org-file-provider)))
    (provide-all org-provider (path-join *base-dir* "content/"))))

(defun local-org-file-to-post (file)
  (let ((post (from file 'blog-post :author *author*)))
    ;; Set filename as slug if no slug is explicitly provided
    (when (not (@ (org-file-metadata file) "slug"))
      (setf (post-slug post)
            (first (str:split "." (file-namestring (org-file-filepath file))))))
    post))

(defparameter *local-posts*
  (mapcar
   #'local-org-file-to-post
   (remove-if-not
    (op (str:containsp "/blog/" (org-file-filepath _)))
    *local-org-files*)))

(defparameter *poems*
  (mapcar
   #'local-org-file-to-post
   (remove-if-not
    (op (str:containsp "/poems/" (org-file-filepath _)))
    *local-org-files*)))

(defparameter *talks*
  (mapcar
   #'local-org-file-to-post
   (remove-if-not
    (op (str:containsp "/talks/" (org-file-filepath _)))
    *local-org-files*)))

(defparameter *about-me*
  (org-file-to-blog-post
   (find-if (op (str:containsp "/about.org" (org-file-filepath _)))
            *local-org-files*)))

(defparameter *blog-posts*
  (let* ((all-posts (append *local-posts* *notes*))
         (no-drafts (remove-if
                     (op (or (find "draft" (post-tags _1) :test #'equal)
                             (find "micro" (post-tags _1) :test #'equal)))
                     all-posts)))
    no-drafts))

(defun build ()
  (let* ((www (path-join *base-dir* "docs/"))
         (static (path-join *base-dir* "src/static/"))
         (*print-pretty* nil)
         (asset-pub (make 'asset-publisher :dest www))
         (blog-pub (make 'blog-post-publisher
                         :asset-pub asset-pub
                         :dest (path-join www "blog/")))
         (poems-pub (make 'blog-post-publisher
                          :asset-pub asset-pub
                          :dest (path-join www "poems/")))
         (talks-pub (make 'blog-post-publisher
                          :asset-pub asset-pub
                          :dest (path-join www "talks/")))
         (page-pub (make 'blog-post-publisher
                         :asset-pub asset-pub
                         :dest www)))

    (uiop:delete-directory-tree www :validate t :if-does-not-exist :ignore)

    (publish asset-pub :content static)

    (publish page-pub :post *about-me* :layout (make 'blog-post-w :post *about-me*))

    (loop
      :for (publisher posts) :in `((,blog-pub ,*blog-posts*)
                                   (,poems-pub ,*poems*)
                                   (,talks-pub ,*talks*))
      :do (loop :for post :in posts
                :do (let ((layout-w (make 'blog-post-w :post post)))
                      (publish publisher :post post :layout layout-w))))))

(build)

;; quick hack to auto-build
;; elisp
;; (defun build-website (successp notes buffer loadp)
;;   (sly-eval '(in.bitspook.website::build)))
;; (add-hook 'sly-compilation-finished-hook #'build-website)
