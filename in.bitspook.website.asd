(defsystem "in.bitspook.website"
  :author "Charanjit Singh"
  :license "AGPL-3.0-only"
  :depends-on (:in.bitspook.cl-ownpress
               :local-time
               :feeder :plump)
  :components ((:module "src"
                :components ((:file "package")
                             (:module "lass"
                              :components ((:file "modern-normalize")
                                           (:file "pollen")
                                           (:file "global-lass")))

                             (:module "publisher"
                              :components ((:file "blog-post")
                                           (:file "blog-post-listing")
                                           (:file "atom-feed")
                                           (:file "software-project")))

                             (:module "provider"
                              :components ((:file "org-file-provider")
                                           (:file "denote-provider")
                                           (:file "org-project-provider")))

                             (:module "widgets"
                              :components ((:file "navbar")
                                           (:file "footer")
                                           (:file "blog-post")
                                           (:file "blog-post-listing")
                                           (:file "software-project"))))))
  :description "A blog implemented using cl-ownpress")
