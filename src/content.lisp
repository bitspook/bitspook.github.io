(in-package #:in.bitspook.website)

(defparameter *denotes* nil)
(defparameter *local-blog-posts* nil)
(defparameter *projects* nil)

;; Author
(defparameter *author*
  (make 'persona
        :name "Charanjit Singh"
        :avatar "/images/avatar.png"
        :handles `(("Github" "bitspook" "https://github.com/bitspook")
                   ("Mastodon" "bitspook" "https://infosec.exchange/@bitspook")
                   ("LinkedIn" "bitspook" "https://www.linkedin.com/in/bitspook/")
                   ("RSS" "bitspook.in" "/archive/feed.xml"))))

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

;; ---

;; Listings
(defun load-tag-listings (registry)
  (let ((tags (hash-table-keys (@ (registry-indices registry) 'tagged))))
    (dolist (tag tags)
      (let* ((posts (get-sorted-posts (registry-query registry 'tagged :tag tag)))
             (listing-id (format nil "listing-tag-~a" tag))
             (feed-id (format nil "feed-tag-~a" tag))
             (title (str:capitalize tag))
             (path (format nil "/tags/~a" tag))
             (listing (make-blog-post-listing-page
                       :path path
                       :posts posts
                       :author *author*
                       :id listing-id
                       :type 'tag
                       :name tag
                       :title title))
             (feed (make-atom-feed-artifact
                    :title (str:concat *site-title* ": " title)
                    :posts (take 15 posts)
                    :author *author*
                    :id feed-id
                    :location (base-path-join path "/feed.xml"))))
        (when listing
          (registry-add-artifact registry listing)
          (registry-add-artifact registry feed))))))

(defun load-category-listings (registry)
  (let ((cats (hash-table-keys (@ (registry-indices registry) 'categorized))))
    (dolist (cat cats)
      (when cat
        (let* ((posts (get-sorted-posts (registry-query registry 'categorized :category cat)))
               (listing-id (format nil "listing-category-~a" cat))
               (feed-id (format nil "feed-category-~a" cat))
               (path (format nil "/~a" cat))
               (title (str:capitalize cat))
               (listing (make-blog-post-listing-page
                         :path path
                         :posts posts
                         :author *author*
                         :id listing-id
                         :type 'category
                         :name cat
                         :title title))
               (feed (make-atom-feed-artifact
                      :title (str:concat *site-title* ": " title)
                      :posts (take 15 posts)
                      :author *author*
                      :id feed-id
                      :location (base-path-join path "/feed.xml"))))
          (registry-add-artifact registry listing)
          (registry-add-artifact registry feed))))))

(defun load-listing-pages (registry)
  (load-tag-listings registry)
  (load-category-listings registry))
;; ---

;;; Home page
(defun load-home-page (registry)
  (let* ((blog-posts (get-sorted-posts (hash-table-values (registry-store *registry*))))
         (archive (make-blog-post-listing-page
                   :path "/archive"
                   :id "archive"
                   :title "Archive"
                   :name 'all
                   :type 'all
                   :author *author*
                   :posts blog-posts))
         (archive-feed (make-atom-feed-artifact
                        :title (str:concat *site-title* " : All content")
                        :posts (take 15 blog-posts)
                        :author *author*
                        :id "feed-all-all"
                        :location "/archive/feed.xml"))
         (home (make-home-page :title *site-title*
                               :all-posts blog-posts
                               :author *author*
                               :about-me-summary (make 'about-me-summary-w))))
    (registry-add-artifact registry home)
    (registry-add-artifact registry archive)
    (registry-add-artifact registry archive-feed)
    home))

(defun load-all-content ()
  (load-local-content *registry*)
  (load-denotes *registry*)
  (load-listing-pages *registry*)
  (load-home-page *registry*))
