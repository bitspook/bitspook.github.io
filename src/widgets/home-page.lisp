(in-package #:in.bitspook.website)

(defwidget home-page-w (title posts author about-summary)
    (tagged-lass
     base-lass

     `((.home
        :display flex
        :flex-direction column

        (.sidebar
         :left 0 :top 0 :bottom 0
         :padding 35px
         :position relative
         :text-align center
         :width 100%)

        (.avatar :width (var --size-56)
                 :height (var --size-56)
                 :border-radius 50%
                 :overflow hidden)

        (.name
         :font-size (var --scale-4)
         :margin-top (var --scale-5)
         :font-family (var --font-title)
         :font-weight normal)
        (.handle
         :font-size (var --scale-2)
         :line-height (var --line-xl)
         :font-family (var --font-text)
         :font-weight 300
         (a :text-decoration none))
        (.quote
         :padding (var --scale-4)
         :font-family (var --font-text) :font-weight 300 :font-size (var --scale-2)
         :position relative
         :margin 15px 0 :margin-top 45px)
        (".quote::before"
         :content ""
         :background (url "/images/icons/quote.svg") no-repeat
         :position absolute :left 21px :top 0px
         :width 14px :height 14px)
        (.social
         :width (var --size-40)
         :position relative
         :overflow hidden
         :margin 0 auto
         :padding-top 40px
         :display flex :flex-wrap wrap

         (a :display block
            :width "calc(50% - 20px)"
            :margin 10px)

         (span
          :display block
          :position relative
          :width 48px
          :height 48px
          :background-repeat no-repeat
          :background-size contain)

         (.github :background-image (url "/images/icons/github.svg"))
         (.mastodon :background-image (url "/images/icons/mastodon.svg"))
         (.rss :background-image (url "/images/icons/rss.svg"))
         (.linkedin :background-image (url "/images/icons/linkedin.svg")))

        (.pub-key-qr
         :max-width (var --size-72)
         :margin 55px auto
         :margin-bottom 0)

        (.main
         :width 100%
         :position relative
         :padding (var --scale-0)

         (a :text-decoration none)

         (h2 :font-family (var --font-title)
             :margin (var --scale-6) 0 (var --scale-4) 0
             :font-weight normal)

         (.about-me-snippet
          :line-height 1.5
          :align-items center
          :margin (var --scale-4) 0
          :font-weight 500

          (h2 :margin-bottom 0)

          (a :text-decoration underline
             :font-weight normal)))

        (.header
         :padding (var --size-4)
         :margin (var --scale-2) 0)

        (.title :font-family (var --font-title)
                :font-size (var --size-10)
                :padding-bottom (var --scale-0)
                :border-bottom 1px solid (var --color-grey-400))

        (.recent-content
         :margin-bottom 0

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
              (.title :border-bottom-color (var --color-grey-800))
              (.sidebar
               :border-color (var --color-grey-800))))

     :md `((.home :width (var --width-sm)
                  :margin 0 auto))

     :lg `((.home
            :flex-direction  row
            :width 100%

            (.sidebar
             :width (var --size-96) :height fit-content
             :border-right 1px solid (var --color-grey-200))

            (.main :width "calc(100% - 450px)"
                   :max-width 872px
                   :padding-left (var --scale-4)))))
  (:article.home
   (with-slots (avatar name handles) author
     (:div
      :class "sidebar"
      (:div
       :class "author"
       (:img :class "avatar" :src avatar :alt ())
       (:h2.name name)
       (:div.handle (str:concat "@" (second (car handles)))))
      (:div :class "quote" "Math is the new sexy")
      (:div
       :class "social"
       (dolist (handle handles)
         (:a :href (nth 2 handle)
             :title  (str:concat name " on " (nth 0 handle))
             :target "_blank"
             (:span :class (str:downcase (nth 0 handle))))))
      (:img :class "pub-key-qr"
            :alt (format nil "~a's Public GPG Key" name)
            :src "/images/public-key-qr.svg")))
   (:div
    :class "main"
    (:section
     :class "about-me-snippet"
     (:header
      (:h2 "About Me"))
     (spinneret:interpret-html-tree about-summary))

    (:section.recent-content
     (:header (:h2.heading "Recent content"))
     (:ul.listing
      (dolist (post posts)
        (render 'blog-post-listing-item-w :post post)))
     (:footer (:a.read-more-btn :href "/archive" "View all"))))))
