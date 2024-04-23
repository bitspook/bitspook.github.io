(ql:quickload '(:in.bitspook.website))

(in-package #:in.bitspook.website)

;; (defparameter *base-url* "https://bitspook.in")
(defparameter *base-url* "/")

(defparameter *author*
  (make 'persona
        :name "Charanjit Singh"
        :avatar "/images/avatar.png"
        :handles '(("Github" "bitspook" "https://github.com/bitspook")
                   ("Mastodon" "bitspook" "https://infosec.exchange/@bitspook")
                   ("LinkedIn" "bitspook" "https://www.linkedin.com/in/bitspook/")
                   ("RSS" "bitspook.in" "https://bitspook.in/archive/feed.xml"))))

(defparameter *base-dir* (asdf:system-relative-pathname :in.bitspook.website ""))

(defparameter *rpc-server* (start-rpc-server 1337))
(stop-rpc-server *rpc-server*)

(defparameter *denote-posts*
  (let ((notes-provider (make 'denote-provider)))
    (mapcar
     (op (let ((post (from _ 'blog-post :author *author*)))
           (setf (post-category post) "blog")
           (setf (post-tags post) (remove-if (op (equal "blog-post" _)) (post-tags post)))
           post))
     (provide-all notes-provider "blog-post"))))
 ;; expensive operations stored in top-level variables for caching

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

(defparameter *category-indices* (dict)
  "Index pages for categories.")

(defparameter *tag-indices* (dict)
  "Index pages for tags.")

(defparameter *pages* (dict)
  "Independent pages by slug.")

(defparameter *atom-feeds* (dict)
  "Hashtable of atom feeds by name.")

(defun find-page (id-type id)
  "Find a html-page-artifact of ID-TYPE which can be identified by ID.
Possible values for ID-TYPE:
1. category-index
2. tag-index
3. slug
4. atom-feed"
  (ecase id-type
    (category-index (@ *category-indices* id))
    (tag-index (@ *tag-indices* id))
    (slug (@ *pages* id))
    (atom-feed (@ *atom-feeds* id))))

(defun link-page (id-type id)
  "Embed page find with FIND-PAGE as LINK."
  (embed-artifact-as (find-page id-type id) 'link))

(defwidget about-me-summary (categories) nil
  (:p
   (:p "I am a software engineer. I enjoy playing with software, electronics and video games. My favorites
are Factorio, Rimworld and Terraria. I also enjoy reading, writing, people watching and discussing
computers, security and politics.")
   (:p "This website has things I am willing to share publicly. You can go through my "
       (:a :href (link-page 'category-index "blog")  "blog") ", "
       (:a :href (link-page 'category-index "poems")  "poems") ", "
       (:a :href "/projects" "projects") " and also some "
       (:a :href (link-page 'category-index "talks") "talks") "I gave .")
   (:p "You can read more about me " (:a :href (link-page 'slug "about") "here."))))

(defun build ()
  (let* ((site-title "@bitspook's personal website")
         (www (path-join *base-dir* "build/"))
         (static (path-join *base-dir* "src/static/"))
         (*print-pretty* nil)
         (blog-posts
           (sort (remove-if
                  (op (or (find "draft" (post-tags _1) :test #'equal)
                          (find "micro" (post-tags _1) :test #'equal)))
                  (append *local-blog-posts* *denote-posts*))
                 (op (local-time:timestamp> (post-updated-at _1) (post-updated-at _2)))))
         (blog-post-pages (mapcar (op (make-blog-post-page _1 :location (base-path-join "/" (post-category _1))))
                                  blog-posts))
         (archive-page (make-blog-post-listing-page
                        :path "/archive"
                        :title "Archive"
                        :author *author*
                        :posts blog-post-pages)))

    (setf *pages* (loop :for page :in blog-post-pages
                        :with pages := (dict)
                        :for category := (post-category page)
                        :when (or (null category) (str:emptyp category))
                          :do (setf (@ pages (post-slug page)) page)
                        :finally
                           (setf (@ pages "archive") archive-page)
                           (return pages)))

    (match (loop :for category :in (reduce (op (adjoin (post-category _2) _1 :test #'string=))
                                           blog-post-pages :initial-value nil)
                 :with categories := (dict)
                 :with feeds := (dict)
                 :unless (or (null category) (str:emptyp category))
                   :do (let* ((posts (remove-if-not (op (string= (post-category _) category)) blog-post-pages))
                              (cat-art (make-blog-post-listing-page
                                        :path category
                                        :posts posts
                                        :title (str:capitalize category)
                                        :author *author*))
                              (feed-art (make-atom-feed-artifact
                                         :location (base-path-join category "/feed.xml")
                                         :posts (take 15 posts)
                                         :title (str:capitalize category)
                                         :author *author*)))
                         (setf (@ categories category) cat-art)
                         (setf (@ feeds category) feed-art))
                 :finally (return (list categories feeds)))
      ((list cats feeds)
       (setf *category-indices* cats)
       (setf *atom-feeds* feeds)))

    (match (loop :for tag :in (reduce
                               (op (union _1 (post-tags _2) :test #'equal))
                               blog-post-pages :initial-value nil)
                 :with tags := (dict)
                 :with feeds := (dict)
                 :do (let* ((posts (remove-if-not (op (find tag (post-tags _) :test #'equal))
                                                  blog-post-pages))
                            (tag-art (make-blog-post-listing-page
                                      :path (base-path-join "tags/" tag)
                                      :posts posts
                                      :title (str:capitalize tag)
                                      :author *author*))
                            (feed-art (make-atom-feed-artifact
                                       :location (base-path-join tag "/feed.xml")
                                       :posts (take 15 posts)
                                       :title (str:capitalize tag)
                                       :author *author*)))
                       (setf (@ tags tag) tag-art)
                       (setf (@ feeds tag) feed-art))
                 :finally (return (list tags feeds)))
      ((list tags feeds)
       (setf *tag-indices* tags)
       (setf *atom-feeds* (merge-tables *atom-feeds* feeds))))

    (uiop:delete-directory-tree www :validate t :if-does-not-exist :ignore)

    (publish-static :content static :dest-dir www)

    ;; Publish project listing
    ;; (let ((project-listing-pub (make 'software-project-listing-publisher
    ;;                                  :asset-pub asset-pub
    ;;                                  :dest www
    ;;                                  :slug "projects"
    ;;                                  :base-url base-url)))
    ;;   (publish project-listing-pub
    ;;            :projects *projects*
    ;;            :author *author*
    ;;            :title "Projects"))

    (setf (@ *atom-feeds* "archive")
          (make-atom-feed-artifact :title site-title
                                   :posts (take 15 blog-post-pages)
                                   :author *author*
                                   :location "/feed.xml"))

    ;; Publish home-page and all its dependencies
    (let ((*already-published-artifacts* nil))
      (handler-bind ((file-already-exists #'skip-existing))
        (publish-artifact
         (make-home-page :title site-title
                         :all-posts blog-post-pages
                         :author *author*
                         :about-me-summary (make 'about-me-summary))
         www)))

    t))

(build)

;; quick hack to auto-build
;; elisp
;; (defun build-website (successp notes buffer loadp)
;;   (sly-eval '(in.bitspook.website::build)))
;; (add-hook 'sly-compilation-finished-hook #'build-website)


;; (defparameter *test* (make 'clown:artifact))

;; (with-slots ( *test*) a)
