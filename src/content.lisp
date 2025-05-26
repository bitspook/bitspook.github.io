(in-package #:in.bitspook.website)

(defparameter *denotes* nil)
(defparameter *journeys* nil)
(defparameter *local-blog-posts* nil)
(defparameter *projects* nil)

(defparameter *published-tags* '("published" "blog-post" "blogpost" "journey")
  "Only artifacts which have any of these tag should be published.")

(defparameter *unpublished-tags* '("draft" "micro")
  "Artifact with any of these tags will not get published. Takes precedence over published-tags.")

(defparameter *control-tags*
  (append *unpublished-tags*  *published-tags* '("blog-post" "blogpost"))
  "List of tags which are meant for controlling the publishing flow and should themselves never be
published as a listing page.")

(defun publish-tag-p (tag)
  "Return `t' if TAG should be published."
  (not (find tag *control-tags* :test #'equal)))

(defun unpublished-p (artifact)
  "An artifact is a draft if:
1. It has any of the *UNPUBLISHED-TAGS*
2. It has none of the *PUBLISHED-TAGS*"
  (let ((tags (artifact-tags artifact)))
    (and
     (not (emptyp tags))
     (or
      (some (op (find _ *unpublished-tags* :test #'equal)) tags)
      (not (some (op (find _ *published-tags* :test #'equal)) tags))))))

(defun remove-unpublished (artifacts)
  (remove-if
   (op (and (find *build-env* '(prod preview))
            (unpublished-p _1)))
   artifacts))

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

(defun publishable-note (note)
  "Convert NOTE to a publish-able HTML-PAGE-ARTIFACT. e.g notes which are blog-posts are converted to
blog-posts."
  (cond
    ((blog-note-p note) (from (from note 'blog-post)
                              'html-page-artifact :location "/"))
    (t (from note 'html-page-artifact :location "/notes"))))

(defun load-denote-post (id)
  "Load a single denote with ID as blog post. It loads "
  (multiple-value-bind (notes deps)
      (provide-all (make 'denote-provider) :ids (list id))
    (dolist (post (mapcar #'publishable-note (append notes deps)))
      (registry-add-artifact *registry* post))))

(defun load-denote-posts ()
  (let ((provider (make 'denote-provider)))
    (setf *denotes*
          (safe-union
           ;; TODO Build a small query language to query with :and :or etc
           (apply #'safe-union (multiple-value-list (provide-all provider :tags '("blog-post"))))
           (apply #'safe-union (multiple-value-list (provide-all provider :tags '("blogpost")))))))

  (mapcar
   (op (registry-add-artifact *registry* (publishable-note _)))
   *denotes*))

(defun journey-p (journey)
  (eq 'journey (class-name-of journey)))

(defun load-journeys ()
  (let* ((provider (make 'journey-provider))
         (notes (apply #'safe-union (multiple-value-list (provide-all provider :tags '("journey"))))))
    (setf *journeys* notes)
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
         (project-pages (remove-if
                         #'unpublished-p
                         (mapcar (op (from _ 'html-page-artifact :location "/projects"))
                                 projects))))
    (dolist (page project-pages)
      (registry-add-artifact *registry* page))))
;; ---

;; Listings
(defparameter *listing-page-size* 10)

(defun add-listing-page (type title path items &optional (component 'blog-post-listing-w))
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
                   :component component
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
      (when (publish-tag-p tag)
        (add-listing-page
         'tag (str:capitalize tag) (format nil "/tags/~a" tag)
         (registry-query *registry* 'tagged :id tag))))))

(defun load-category-listings ()
  (when-let* ((index (@ (registry-indices *registry*) 'categorized))
              (cats (hash-table-keys index)))
    (dolist (cat cats)
      (unless (equal cat "projects")
        (add-listing-page
         'category (str:capitalize cat) (format nil "/~a" cat)
         (registry-query *registry* 'categorized :id cat))))

    (add-listing-page
     'category "Projects" "/projects"
     (registry-query *registry* 'categorized :id "projects")
     'software-project-listing-w)))

(defun load-journey-notebooks ()
  (let ((journeys (registry-query *registry* 'journey))
        (notebooks nil))
    (dolist (journey journeys notebooks)
      (let ((name (journey-name journey))
            (slug (journey-slug journey))
            (notes (mapcar (op (registry-query *registry* _))
                           (journey-note-ids journey))))
        (push (add-listing-page
               'journey-notebook
               (str:capitalize name)
               (format nil "/journeys/~a/notebook" slug)
               notes
               'note-listing-w)
              notebooks)))))

(defun load-listing-pages ()
  (load-tag-listings)
  (load-category-listings)
  (load-journey-notebooks))
;; ---

;;; Home page
(defun load-home-page ()
  (let* ((blog-posts (registry-query *registry* 'blog-posts))
         (archive (make-listing-page
                   :path "/archive"
                   :id "archive"
                   :title "Archive"
                   :name 'all
                   :type 'all
                   :author *author*
                   :component 'blog-post-listing-w
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
