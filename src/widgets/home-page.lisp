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
         :margin (var --scale-6) 0)

        (.journeys
         (.listing :display flex
                   :flex-wrap wrap))

        (.blog-posts
         (a :text-decoration none)

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
                (:p "A Journey is a long term commitment with or without a clear end. Here's a list of journeys I've put
myself on. On these web pages are footprints I've left as I am going through them."))
       (:div.listing
        (dolist (journey (registry-query *registry* 'journey))
          (render 'journey-listing-item :journey journey))))

      (:section.blog-posts
       (:header (:h2.heading "Blog")
                (:p "My blog is an open journal of sorts. Usually, I write here when I want to give my thoughts more
                    structure than my personal journal approves, or to share my thoughts with the
                    world. Mostly, it is just me shouting in the void."))
       (:ul.listing
        (dolist (post posts)
          (render 'blog-post-listing-item-w :post post)))
       (:footer (:a.read-more-btn :href (link-artifact "archive") "View all"))))))))

(defwidget journey-listing-item (journey)
    (tagged-lass
     `((.journey-listing-item
        :display flex
        :flex-direction column
        :border 1px solid (var --color-grey-200)
        :border-radius (var --size-2)
        :padding (var --size-4)
        :max-width (var --size-96)
        :margin (var --scale-1) (var --scale-1)0 0

        (.title
         :font-family (var --font-text)
         :font-size (var --scale-1)
         :text-decoration none)))
     :dark `((.journey-listing-item
              :border-color (var --color-grey-800))))
  (:div.journey-listing-item
   (:h3.title
    (:a :href (embed-artifact-as journey 'link)
        (journey-name journey)))
   (:p (journey-summary journey))))
