(in-package #:in.bitspook)

(import 'default-theme::journeys-listing-page)
(import 'default-theme::journey-page)
(import 'clown.publishers.journey:journey)

(defparameter infosec-journey
  (make-instance
   'journey
   :name "infosec"
   :tagline "Information security from attackers pov"
   :notes-with-tags '("infosec" "cryptography" "ctf" "wargame" "xss" "pwned")
   :html-description
   `(:p "I have desired for long to explore infosec in depth. Finally, I have decided to commit and invest in it.")
   :html-content
   `((:p "I am going to continue down the infosec road, learn needs learning, solve what need solving, break what needs breaking.")
     (:p "As a landmark and quantifiable goal, I am reaching for earning an OSCP certification."))))

(let ((*debug-transpiles* t)
      (*conf* (conf-merge
               `(:db-name "./clownpress.db"
                 :site-url "https://bitspook.in/"
                 :author "Charanjit Singh"
                 :avatar "/images/spooky-avatar.png"
                 :twitter "https://twitter.com/bitspook"
                 :linkedin "https://linkedin.com/in/bitspook"
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
  (publish-blog "bitspook's online home")

  (clown-publishers:publish-html-file
   "journeys"
   (clown-theme:with-html-string
       (clown-theme:render
        journeys-listing-page
        :journeys nil
        :title "My Journeys")))

  (clown-publishers:publish-html-file
   "journeys/infosec"
   (clown-theme:with-html-string
       (clown-theme:render
        journey-page
        :journey infosec-journey))))
