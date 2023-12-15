(ql:quickload '(:in.bitspook.website))

(in-package #:in.bitspook.website)

(defparameter *author*
  (make 'persona
        :name "Charanjit Singh"
        :handles '(("Mastodon" "bitspook" "https://infosec.exchange/@bitspook"))))

(defparameter *base-dir* (asdf:system-relative-pathname :in.bitspook.website ""))

;; expensive operations stored in top-level variables for caching
(defparameter *denote-posts*
  (let ((notes-provider (make-instance 'denote-provider)))
    (mapcar
     (op (let ((post (from _ 'blog-post :author *author*)))
           (setf (post-category post) "blog")
           post))
     (provide-all notes-provider "blog-post"))))

(defparameter *local-blog-posts*
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
      (loop
        :for file :in local-org-files
        :for post := (local-org-file-to-post file)
        :do (setf
             (post-category post)
             (first-elt (str:split
                         "/" (str:replace-all
                              (namestring content-base-dir) ""
                              (directory-namestring (org-file-filepath file))))))
        :collect post))))

(defparameter *projects*
  (let ((project-provider (make 'org-project-provider)))
    (mapcar
     (op (from _ 'software-project :author *author*))
     (provide-all project-provider (path-join *base-dir* "projects/")))))
;; end expensive operations

(defparameter *published-blog-posts*
  (sort (remove-if
         (op (or (find "draft" (post-tags _1) :test #'equal)
                 (find "micro" (post-tags _1) :test #'equal)))
         (append *local-blog-posts* *denote-posts*))
        (op (local-time:timestamp> (post-updated-at _1) (post-updated-at _2))))
  "Chronologically ordered blog posts.")

(defparameter *categorized-posts*
  (loop
    :for post :in *published-blog-posts*
    :with table := (dict)
    :do (setf (@ table (post-category post))
              (append1 (href-default nil table (post-category post)) post))
    :finally (return table)))

(defun build ()
  (let* ((www (path-join *base-dir* "docs/"))
         (static (path-join *base-dir* "src/static/"))
         (*print-pretty* nil)
         (asset-pub (make 'asset-publisher :dest www)))

    (uiop:delete-directory-tree www :validate t :if-does-not-exist :ignore)

    (publish asset-pub :content static)

    ;; Publish *categorized-posts*
    (do-hash-table (category posts *categorized-posts*)
      (unless (str:emptyp category)
        (let* ((cat-dest (base-path-join www (if (str:emptyp category) ""
                                                 (str:concat category "/"))))
               (cat-pub (make 'blog-post-publisher
                              :asset-pub asset-pub
                              :dest cat-dest))
               (index-pub (make 'blog-post-listing-publisher
                                :dest cat-dest
                                :asset-pub asset-pub)))
          (loop :for post :in posts
                :do (publish cat-pub :post post))

          (publish index-pub :posts (@ *categorized-posts* category)
                             :title (str:capitalize category)
                             :slug ""
                             :author *author*))))

    (let ((pages (@ *categorized-posts* "")))
      (loop :for post :in pages
            :with publisher := (make 'blog-post-publisher :asset-pub asset-pub :dest www)
            :do (publish publisher :post post)))

    ;; Publish *projects*
    (loop :for project :in *projects*
          :for publisher := (make 'software-project-publisher
                                  :asset-pub asset-pub
                                  :dest (base-path-join www "projects/"))
          :do (publish publisher :project project))

    ;; Publish archive of all blog-posts
    (let ((archive-pub (make 'blog-post-listing-publisher
                             :dest (path-join *base-dir* www)
                             :asset-pub asset-pub)))
      (publish archive-pub :posts *published-blog-posts*
                           :title "Archive"
                           :author *author*))))

(build)

;; quick hack to auto-build
;; elisp
;; (defun build-website (successp notes buffer loadp)
;;   (sly-eval '(in.bitspook.website::build)))
;; (add-hook 'sly-compilation-finished-hook #'build-website)
