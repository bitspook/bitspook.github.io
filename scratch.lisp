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
     (op (from _ 'blog-post :author *author*))
     (provide-all notes-provider "blog-post"))))

(defparameter *local-org-files*
  (let ((org-provider (make 'org-file-provider)))
    (provide-all org-provider (path-join *base-dir* "content/"))))

(defparameter *projects*
  (let ((project-provider (make 'org-project-provider)))
    (mapcar
     (op (from _ 'software-project :author *author*))
     (provide-all project-provider (path-join *base-dir* "projects/")))))
;; end expensive operations

(defparameter *categorized-posts*
  (labels ((local-org-file-to-post (file)
             (let ((post (from file 'blog-post :author *author*)))
               ;; Set filename as slug if no slug is explicitly provided
               (when (not (@ (org-file-metadata file) "slug"))
                 (setf (post-slug post)
                       (first (str:split "." (file-namestring (org-file-filepath file))))))
               post)))
    (let* ((categorized-posts
             (let* ((base-dir (namestring (path-join *base-dir* "content/")))
                    (posts (dict)))
               (loop :for file :in *local-org-files*
                     :for category := (str:substring
                                       0 -1
                                       (directory-namestring
                                        (str:replace-first base-dir "" (org-file-filepath file))))
                     :do (let ((cat-posts (@ posts category)))
                           (setf (@ posts category) (append1 cat-posts (local-org-file-to-post file)))))
               posts))
           (all-posts (append (@ categorized-posts "blog")
                              *denote-posts*))
           (published-posts (remove-if
                             (op (or (find "draft" (post-tags _1) :test #'equal)
                                     (find "micro" (post-tags _1) :test #'equal)))
                             all-posts)))
      (setf (@ categorized-posts "blog") published-posts)
      categorized-posts)))

(defun build ()
  (let* ((www (path-join *base-dir* "docs/"))
         (static (path-join *base-dir* "src/static/"))
         (*print-pretty* nil)
         (asset-pub (make 'asset-publisher :dest www)))

    (uiop:delete-directory-tree www :validate t :if-does-not-exist :ignore)

    (publish asset-pub :content static)

    ;; Publish *categorized-posts*
    (do-hash-table (category posts *categorized-posts*)
      (let ((publisher (make 'blog-post-publisher
                             :asset-pub asset-pub
                             :dest (base-path-join www (if (str:emptyp category) ""
                                                           (str:concat category "/"))))))
        (loop :for post :in posts
              :do (publish publisher
                           :post post
                           :layout (make 'blog-post-w :post post)))))

    ;; Publish *projects*
    (loop :for project :in *projects*
          :for publisher := (make 'software-project-publisher
                                   :asset-pub asset-pub
                                   :dest (base-path-join www "projects/"))
          :do (publish publisher
                       :project project
                       :layout (make 'software-project-w :project project)))))

(build)

;; quick hack to auto-build
;; elisp
;; (defun build-website (successp notes buffer loadp)
;;   (sly-eval '(in.bitspook.website::build)))
;; (add-hook 'sly-compilation-finished-hook #'build-website)
