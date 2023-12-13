(defsystem "in.bitspook.website"
  :author "Charanjit Singh"
  :license "AGPL-3.0-only"
  :depends-on (:in.bitspook.cl-ownpress :local-time)
  :components ((:module "src"
                :components ((:file "package")
                             (:module "lass"
                              :components ((:file "modern-normalize")
                                           (:file "pollen")
                                           (:file "global-lass")))
                             (:file "blog-post")
                             (:file "org-file-provider")
                             (:file "denote-provider")

                             (:module "widgets"
                              :components ((:file "navbar")
                                           (:file "footer")
                                           (:file "blog-post"))))))
  :description "A blog implemented using cl-ownpress")
