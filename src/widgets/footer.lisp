(in-package #:in.bitspook.website)

(defwidget footer-w (author feed-path) nil
  (with-slots ((author-name name) handles) author
    (:footer.footer.postamble
     (when feed-path
       (:p.rss-sub
        (:a :href feed-path
            :title "Follow via RSS"
            :target "blank"
            (:span.rss) "Follow via RSS")))
     (:p ("Author: ~a " author-name)))))

(defmethod lass-of ((w footer-w))
  (tagged-lass
   `((.footer
      :color (var --color-grey-600)
      :margin (var --size-24) auto
      :margin-bottom (var --size-12)

      (p :margin (var --size-2) 0)

      (.rss-sub
       (a :display flex :align-items center)
       (.rss :margin-right (var --size-2)
             :display block
             :width 24px
             :height 24px
             :background (url "/images/icons/rss.svg")
             :background-repeat no-repeat
             :background-size contain))

      (.validation :display none))
     (:media ,(format nil "(max-width: ~a)" "840px")
             (.postamble
              :max-width 100%
              :padding 0 8%))
     (:media ,(format nil "(max-width: ~a)" "520px")
             (.postamble
              :max-width 100%
              :padding 0 4%))
     ("#mc_embed_signup" :max-width 600px
                         :background transparent
                         :margin-bottom 4rem)
     (.newsletter-email :border 1px solid "#eee"
                        :border-radius 25px
                        :background-color transparent
                        :width 100%
                        :margin-bottom 1rem
                        :padding 0.4rem 0.8rem)

     ((:or ".newsletter-email::-moz-placeholder"
           ".newsletter-email::-webkit-input-placeholder")
      :color "#aaa"))

   :lg `((.footer :max-width (var --width-md)))))
