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

(defun build ()
  (let* ((www (path-join *base-dir* "docs/"))
         (static (path-join *base-dir* "src/static/"))
         (*print-pretty* nil)
         (asset-pub (make 'asset-publisher :dest www))
         (post-pub (make 'blog-post-publisher
                         :asset-pub asset-pub
                         :dest www)))

    (uiop:delete-directory-tree www :validate t :if-does-not-exist :ignore)

    (publish asset-pub :content static)

    ;; Publish all posts
    (loop :for post :in *published-blog-posts*
          :do (publish post-pub :post post))

    ;; Publish a listing for each category
    (loop :for category :in (reduce (op (adjoin (post-category _2) _1 :test #'string=))
                                    *published-blog-posts* :initial-value nil)
          :unless (or (null category) (str:emptyp category))
            :do (let ((posts (remove-if-not (op (string= (post-category _) category)) *published-blog-posts*))
                      (cat-pub (make 'blog-post-listing-publisher
                                     :dest (base-path-join www (str:concat category "/"))
                                     :asset-pub asset-pub)))
                  (publish cat-pub
                           :posts posts
                           :title (str:capitalize category)
                           :author *author*)))

    ;; Publish a listing for each tag
    (loop :for tag :in (reduce
                        (op (union _1 (post-tags _2) :test #'equal))
                        *published-blog-posts* :initial-value nil)
          :do (let ((posts (remove-if-not (op (find tag (post-tags _) :test #'equal))
                                          *published-blog-posts*))
                    (tag-pub (make 'blog-post-listing-publisher
                                   :asset-pub asset-pub
                                   :dest (base-path-join www (str:concat "tags/" tag "/")))))
                (publish tag-pub :posts posts
                                 :title (str:capitalize tag)
                                 :author *author*)))
    ;; Publish *projects*
    (loop :for project :in *projects*
          :for publisher := (make 'software-project-publisher
                                  :asset-pub asset-pub
                                  :dest (base-path-join www "projects/"))
          :do (publish publisher :project project))

    ;; Publish archive of all blog-posts
    (let ((archive-pub (make 'blog-post-listing-publisher
                             :dest (path-join *base-dir* www "archive/")
                             :asset-pub asset-pub)))
      (publish archive-pub :posts *published-blog-posts*
                           :title "Archive"
                           :page-size 10
                           :author *author*))))

(build)

;; quick hack to auto-build
;; elisp
;; (defun build-website (successp notes buffer loadp)
;;   (sly-eval '(in.bitspook.website::build)))
;; (add-hook 'sly-compilation-finished-hook #'build-website)
