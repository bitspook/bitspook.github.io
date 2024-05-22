(push :HUNCHENTOOT-NO-SSL *features*)

(defsystem "in.bitspook.website"
  :author "Charanjit Singh"
  :license "AGPL-3.0-only"
  :depends-on (:in.bitspook.cl-ownpress
               :local-time :serapeum :trivia
               :feeder :plump :quri :lquery)
  :components ((:module "src"
                :components ((:file "package")

                             (:module "provider"
                              :components ((:file "org-file-provider")
                                           (:file "denote-provider")
                                           (:file "org-project-provider")))

                             (:module "models"
                              :components ((:file "persona")
                                           (:file "blog-post")
                                           (:file "software-project")
                                           (:file "adventure")
                                           (:file "note")))

                             (:module "lass"
                              :components ((:file "modern-normalize")
                                           (:file "pollen")
                                           (:file "global-lass")))

                             (:module "widgets"
                              :components ((:file "navbar")
                                           (:file "footer")
                                           (:file "notebook-btn")
                                           (:file "post-listing-item")
                                           (:file "blog-post")
                                           (:file "blog-post-listing")
                                           (:file "software-project-listing-item")
                                           (:file "software-project")
                                           (:file "software-project-listing")
                                           (:file "home-page")
                                           (:file "adventure")
                                           (:file "note")))

                             (:module "artifacts"
                              :components ((:file "blog-post")
                                           (:file "atom-feed")
                                           (:file "software-project")
                                           (:file "listings")
                                           (:file "note")
                                           (:file "home-page"))))))
  :description "A blog implemented using cl-ownpress")
