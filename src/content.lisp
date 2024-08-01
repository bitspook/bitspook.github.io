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

(defun load-denote-posts ()
  (let ((provider (make 'denote-provider)))
    (setf *denotes*
          (safe-union
           ;; TODO Build a small query language to query with :and :or etc
           (apply #'safe-union (multiple-value-list (provide-all provider :tags '("blog-post"))))
           (apply #'safe-union (multiple-value-list (provide-all provider :tags '("blogpost")))))))

  (loop :for note :in *denotes*
        :do (registry-add-artifact
             *registry*
             (cond
              ((blog-note-p note) (from (from note 'blog-post)
                                        'html-page-artifact :location "/"))
              (t (from note 'html-page-artifact :location "/notes"))))))

(defun journey-p (journey)
  (eq 'journey (class-name-of journey)))

(defun load-journeys ()
  (let* ((provider (make 'journey-provider))
         (notes (apply #'safe-union (multiple-value-list (provide-all provider :tags '("journey"))))))

    (loop :for note :in notes
          :do (progn
                (registry-add-artifact
                 *registry*
                 (cond
                   ((journey-p note) (from note 'html-page-artifact :location "/journeys" :author *author*))
                   (t (from note 'html-page-artifact :location "/notes"))))))))

;; ---

;; Local content
(defun load-local-content ()
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
        :do (registry-add-artifact *registry* page)))

;; ---
;; Projects
(defun load-projects ()
  ;; TODO This ain't complete.
  (let* ((project-provider (make 'org-project-provider))
         (projects (mapcar
                    (op (from _ 'software-project :author *author*))
                    (provide-all project-provider (path-join *base-dir* "projects/"))))
         (project-pages (mapcar (op (from _ 'html-page-artifact :location "/"))
                                projects)))
    (dolist (page project-pages)
      (registry-add-artifact *registry* page))))
;; ---

;; Listings
(defparameter *listing-page-size* 10)

(defun add-listing-page (type title path items &optional (widget 'blog-post-listing-w))
  (let* ((name (slugify (str:downcase title)))
         (listing-id (format nil "listing-~(~a~)-~a" type name))
         (feed-id (format nil "feed-~(~a~)-~a" type name))
         (listing (make-listing-page
                   :id listing-id
                   :path path
                   :items items
                   :author *author*
                   :type type
                   :name (slugify (str:downcase name))
                   :title title
                   :page-size *listing-page-size*
                   :widget widget
                   :css-location (format nil "/css/~(~a~).css" type)))
         (feed (make-atom-feed-artifact
                :title (str:concat *site-title* ": " title)
                :posts (take 15 items)
                :author *author*
                :id feed-id
                :location (base-path-join path "/feed.xml"))))
    (when listing
      (registry-add-artifact *registry* listing)
      (registry-add-artifact *registry* feed))
    listing))

(defun load-tag-listings ()
  (when-let* ((index (@ (registry-indices *registry*) 'tagged))
              (tags (hash-table-keys index)))
    (dolist (tag tags)
      (add-listing-page
       'tag (str:capitalize tag) (format nil "/tags/~a" tag)
       (get-sorted-posts (registry-query *registry* 'tagged :id tag))))))

(defun load-category-listings ()
  (when-let* ((index (@ (registry-indices *registry*) 'categorized))
              (cats (hash-table-keys index)))
    (dolist (cat cats)
      (unless (equal cat "projects")
        (add-listing-page
         'category (str:capitalize cat) (format nil "/~a" cat)
         (get-sorted-posts (registry-query *registry* 'categorized :id cat)))))

    (add-listing-page
     'category "Projects" "/projects"
     (registry-query *registry* 'categorized :id "projects")
     'software-project-listing-w)))

(defun load-journey-notebooks ()
  (let ((journeys (registry-query *registry* 'journey)))
    (dolist (journey journeys)
      (let ((name (journey-name journey))
            (slug (journey-slug journey))
            (notes (mapcar (op (registry-query *registry* _))
                           (journey-note-ids journey))))
        (add-listing-page
         'journey-notebook
         (str:capitalize name)
         (format nil "/journeys/~a/notebook" slug)
         notes
         'note-listing-w)))))

(defun load-listing-pages ()
  (load-tag-listings)
  (load-category-listings)
  (load-journey-notebooks))
;; ---

;;; Home page
(defun load-home-page ()
  (let* ((blog-posts (get-sorted-posts (hash-table-values (registry-store *registry*))))
         (archive (make-listing-page
                   :path "/archive"
                   :id "archive"
                   :title "Archive"
                   :name 'all
                   :type 'all
                   :author *author*
                   :widget 'blog-post-listing-w
                   :page-size 10
                   :css-location "/css/archive.css"
                   :items blog-posts))
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
    (registry-add-artifact *registry* home)
    (registry-add-artifact *registry* archive)
    (registry-add-artifact *registry* archive-feed)
    home))

(defun load-all-content ()
  (load-local-content)
  (load-denote-posts)
  (load-journeys)
  (load-projects)
  (load-listing-pages)
  (load-home-page))
