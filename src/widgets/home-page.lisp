(in-package #:in.bitspook.website)

(defwidget home-page-w (title posts author about-summary css-file-artifact)
    (tagged-lass
     (base-lass)

     `((.home
        :display flex
        :flex-direction column

        (.main
         :width 100%
         :position relative
         :padding (var --scale-0))

        (.header
         :padding (var --size-4)
         :margin (var --scale-2) 0)

        (.title :font-family (var --font-title)
                :font-size (var --size-10)
                :padding-bottom (var --scale-0)
                :border-bottom 1px solid (var --color-grey-400))

        ((:or .blog-posts .journeys)
         :margin (var --scale-8) 0)

        (.blog-posts
         (a :text-decoration none)

         (header :display flex)

         (.read-more-btn :font-size (var --scale-1)
                         :margin 0.7rem 0
                         :padding 0.6rem 0
                         :text-decoration underline))

        (.listing :padding 0)

        (.pagination :display flex
                     :justify-content space-between
                     :margin-top (var --scale-8))

        (.next :flex-grow 1
               :text-align right)))

     :dark `((.home
              (.title :border-bottom-color (var --color-grey-800))))

     :md `((.home :width (var --width-sm)
                  :margin 0 auto))

     :lg `((.home
            :flex-direction  row
            :width 100%

            (.main :width "calc(100% - 450px)"
                   :max-width 872px
                   :padding-left (var --scale-4)))))
  (:doctype)
  (:html
   (:head (:title title)
          (:meta :name "viewport" :content "width=device-width, initial-scale=1")
          (when css-file-artifact (:link :rel "stylesheet" :href (embed-artifact-as css-file-artifact 'link)))
          (:link :rel "alternate" :type "application/atom+xml" :href (link-artifact 'atom-feed :type 'all :name 'all))
          (:script :src "/js/app.js"))
   (:body
    (:article.home
     (render 'home-sidebar-w :author author)
     (:div
      :class "main"

      (render about-summary)

      (:section.journeys
       (:header (:h2.heading "Journeys")
                (:p "A Journey is a long term commitment with or without a clear end."))
       (:ul.listing
        (dolist (adv (registry-query *registry* 'adventure))
          (:li
           (:a :href (embed-artifact-as adv 'link)
               (adventure-name adv))
           (:p (:raw (plump:text (adventure-summary-dom adv))))))))

      (:section.blog-posts
       (:header (:h2.heading "Blog"))
       (:ul.listing
        (dolist (post posts)
          (render 'blog-post-listing-item-w :post post)))
       (:footer (:a.read-more-btn :href (link-artifact "archive") "View all"))))))))
