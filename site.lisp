(in-package :cl-user)

(ql:quickload "cffi")
(ql:quickload "cl-ownpress")

(setf cffi::*foreign-library-directories*
      (cffi::explode-path-environment-variable "MY_LIBRARY_PATH"))

(add-package-local-nickname :clp :clown-providers)

(setf (clown:conf :db-name) "./clownpress.db")
(clp:invoke-provider clp:*org-file-provider* :content-dir "./content/")
(clp:invoke-provider clp:*org-roam-provider* :tags '("blog-post"))

(let ((clown-slick:*debug-transpiles* nil)
      (clown-slick:*conf*
        (clown-slick:conf-merge
         `(:site-url "https://bitspook.in/"
           :author "Charanjit Singh"
           :avatar "/images/avatar.png"
           :twitter "https://twitter.com/bitspook"
           :linkedin "https://linked.com/in/bitspook"
           :github "https://github.com/bitspook"
           :handle "bitspook"
           :resume "https://docs.google.com/document/d/1HFOxl97RGtuhAX95AhGWwa808SO9qSCYLjP1Pm39la0/"
           :dest "./docs/"
           :static-dir "./static/"
           :mixpanel-token "0f28a64d9f8bce370006d36e1e2e3f61"
           :rss-max-posts 10
           :control-tags ("blog-post" "published")
           :exclude-tags ("draft")))))
  (clown-slick:build))
