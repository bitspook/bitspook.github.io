(in-package :cl-user)

(ql:quickload "cl-ownpress")
(ql:quickload "parenscript")

(defpackage #:bitspook-in
  (:use #:cl
        #:serapeum/bundle
        #:clown-providers
        #:clown-publishers.blog))
(in-package #:bitspook-in)

(setf cffi::*foreign-library-directories*
      (cffi::explode-path-environment-variable "CLOWN_LIBRARY_PATH"))

(defparameter content-provider
  (make-instance 'org-file-provider
                 :name "local-dir-content"
                 :content-dir "./content/"))
(defparameter notes-provider
  (make-instance 'denote-provider
                 :name "personal-notes"
                 :content-dir "~/Documents/org/denotes/"))

(invoke-provider content-provider)
(invoke-provider notes-provider)

(let ((*debug-transpiles* nil)
      (*conf* (conf-merge
               `(:db-name "./clownpress.db"
                 :site-url "https://bitspook.in/"
                 :author "Charanjit Singh"
                 :avatar "/images/avatar.png"
                 :twitter "https://twitter.com/bitspook"
                 :linkedin "https://linked.com/in/bitspook"
                 :github "https://github.com/bitspook"
                 :handle "bitspook"
                 :resume "https://docs.google.com/document/d/1HFOxl97RGtuhAX95AhGWwa808SO9qSCYLjP1Pm39la0/"
                 :dest "./docs/"
                 :static-dirs ("./static/")
                 :mixpanel-token "0f28a64d9f8bce370006d36e1e2e3f61"
                 :rss-max-posts 10
                 :control-tags ("blog-post" "published")
                 :exclude-tags ("draft")
                 :published-categories '("blog" "poems")
                 :theme ,default-theme))))
  ;; (publish-blog "bitspook's online home")
  (publish-projects))
