(in-package #:bitspook-in)

(import 'clown-blog.theme:render)
(import 'clown-blog.theme:with-html-string)
(import 'clown-blog.theme.default::projects-widget)
(import 'clown-blog.theme.default::project-widget)

(defparameter projects-provider
  (make-instance
   'org-project-provider
   :name "projects"
   :content-dir "./projects"))

(invoke-provider projects-provider)

(let ((*debug-transpiles* t)
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
  (mapcar #'clown-publishers:publish-static (conf :static-dirs))

  (clown-publishers:publish-html-file
   "projects/index.html"
   (with-html-string
     (render projects-widget
             :title "Featured projects"
             :projects (clown-blog:fetch-all-projects))))

  (loop :for project
          :in (clown-blog:fetch-all-projects)
        :do
           (clown-publishers:publish-html-file
            (clown-blog:project-public-path project)
            (with-html-string
              (render project-widget :project project)))))
