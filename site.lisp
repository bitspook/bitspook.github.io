(in-package :cl-user)

(ql:quickload "cl-ownpress")

(defpackage #:in.bitspook
  (:use #:cl
        #:serapeum/bundle
        #:clown-providers
        #:clown-publishers.blog))
(in-package #:in.bitspook)

(defparameter content-provider
  (make-instance 'org-file-provider
                 :name "local-dir-content"
                 :content-dir "./content/"))

(defparameter notes-provider
  (make-instance 'denote-provider
                 :name "personal-notes"
                 :content-dir "~/Documents/org/denotes/"))

(defparameter projects-provider
  (make-instance
   'org-project-provider
   :name "projects"
   :content-dir "./projects"))

(invoke-provider content-provider)
(invoke-provider notes-provider)
(invoke-provider projects-provider)

(defun about-me-short (resume)
  `(:p
    (:p "I enjoy playing with software, electronics and video games. My favorites are
Factorio, Cities Skylines and Terraria. I also enjoy reading, writing, people
watching and discussing computers, security and politics.")
    (:p "This website has things I am willing to share publicly. You can go through my "
        (:a :href "/blog/" "blog") ", "
        (:a :href "/poems" "poems") ", "
        (:a :href "/projects" "projects") ", "
        (:a :href "/talks" "talks") ", and my "
        (:a :href ,resume :target "_blank" "resume")
        " as well.")))

(let* ((*debug-transpiles* nil)
       (dest "./docs/")
       (resume "https://docs.google.com/document/d/1HFOxl97RGtuhAX95AhGWwa808SO9qSCYLjP1Pm39la0/")
       (*conf* (conf-merge
                `(:db-name "./clownpress.db"
                  :site-url "https://bitspook.in/"
                  :author "Charanjit Singh"
                  :avatar "/images/spooky-avatar.png"
                  :mastodon "https://infosec.exchange/@bitspook"
                  :linkedin "https://linkedin.com/in/bitspook"
                  :github "https://github.com/bitspook"
                  :handle "bitspook"
                  :resume ,resume
                  :about-me-short ,(about-me-short resume)
                  :about-me ,(about-me-short resume)
                  :dest ,dest
                  :static-dirs ("./static/")
                  :mixpanel-token "0f28a64d9f8bce370006d36e1e2e3f61"
                  :rss-max-posts 10
                  :control-tags ("blog-post" "published")
                  :exclude-tags ("draft")
                  :published-categories '("blog" "poems")
                  :theme ,default-theme))))
  (publish-blog "bitspook's online home"))
