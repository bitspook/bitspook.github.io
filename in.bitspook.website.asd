(push :HUNCHENTOOT-NO-SSL *features*)

(defsystem "in.bitspook.website"
  :author "Charanjit Singh"
  :license "AGPL-3.0-only"
  :depends-on (:in.bitspook.cl-ownpress
               :local-time :serapeum :trivia
               :feeder :plump :quri :clss :lquery)
  :components ((:module "src"
                :components ((:file "package")
                             (:file "utils")

                             (:module "models"
                              :components ((:file "persona")
                                           (:file "note")
                                           (:file "blog-post")
                                           (:file "software-project")
                                           (:file "adventure")))

                             (:module "provider"
                              :components ((:file "org-file-provider")
                                           (:file "denote-provider")
                                           (:file "org-project-provider")))

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
                                           (:file "home-sidebar")
                                           (:file "home-page")
                                           (:file "adventure")
                                           (:file "note")
                                           (:file "about-me")))

                             (:module "artifacts"
                              :components ((:file "blog-post")
                                           (:file "atom-feed")
                                           (:file "software-project")
                                           (:file "listings")
                                           (:file "note")
                                           (:file "adventure")
                                           (:file "home-page")))

                             (:file "registry")
                             (:file "content"))))
  :description "A blog implemented using cl-ownpress")
