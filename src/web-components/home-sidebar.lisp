(in-package #:in.bitspook.website)

(defcomponent home-sidebar-w (author)
    (tagged-lass
     `((.sidebar
        :left 0 :top 0 :bottom 0
        :padding 35px
        :position relative
        :text-align center
        :width 100%

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
         :margin-bottom 0)))

     :dark `((.sidebar
              :border-color (var --color-grey-800)))

     :lg `((.sidebar
            :width (var --size-96) :height fit-content
            :border-right 1px solid (var --color-grey-200))))

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
           :src "/images/public-key-qr.svg"))))
