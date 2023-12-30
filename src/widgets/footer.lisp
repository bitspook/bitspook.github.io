(in-package #:in.bitspook.website)

(defwidget newsletter-form-w ()
    (tagged-lass
     `(("#mc_embed_signup"
        :max-width (var --width-sm)
        :background transparent
        :margin-bottom (var --scale-4)

        (.newsletter-title :font-size (var --scale-0) :font-family (var --font-text)
                           :font-weight normal)

        (.mc-field-group :margin (var --scale-1) 0)

        (.btn :color (var --color-grey-600)
              :width (var --width-fit-content)
              :cursor pointer)

        ((:and .btn :hover) :color (var --color-grey-500)
                            :border-color (var --color-grey-500))

        (input :border 1px solid (var --color-grey-400)
               :border-radius 25px
               :background-color transparent
               :width 100%
               :color inherit
               :padding 0.4rem 0.8rem))

       ((:or ".newsletter-email::-moz-placeholder"
             ".newsletter-email::-webkit-input-placeholder")
        :color (var --color-grey-600)))

     :dark `(("#mc_embed_signup"
              (input :border-color (var --color-grey-800)))))
  (with-html
    (:div#mc_embed_signup
     (:form :action "https://bitspook.us14.list-manage.com/subscribe/post?u=de25614414d7e23ac4c3ea700&id=b8b47d5b6e"
            :method "post"
            :id  "subscribe-form"
            :name "subscribe-form"
            :class "validate"
            :target "_blank"

            (:div#mc_embed_signup_scroll
             (:h2.newsletter-title "Follow blog via email")
             (:div.mc-field-group
              (:input :type "email" :value ""
                      :placeholder "Email Address"
                      :name "EMAIL"
                      :class "required email newsletter-email"
                      :id "mce-EMAIL"))
             (:div :style "position: absolute; left: -5000px;"
                   :aria-hidden "true"
                   (:input :type "text"
                           :name "b_de25614414d7e23ac4c3ea700_b8b47d5b6e"
                           :tabindex "-1"
                           :value ""))
             (:div#mce-responses
              :class "clear foot"
              (:div :class "response"
                    :id "mce-error-response"
                    :style "display: none")
              (:div :class "response"
                    :id "mce-success-response"
                    :style "display: none"))
             (:div :class "optionalParent"
                   (:div :class "clear foot"
                         (:input :type "submit"
                                 :value "Subscribe"
                                 :name "subscribe"
                                 :id "mc-embedded-subscribe"
                                 :class "btn"))))))))


(defwidget footer-w (author feed-path) nil nil)

(defmethod dom-of ((w footer-w))
  (with-slots (author feed-path) w
    (with-slots ((author-name name) handles) author
      (with-html
        (:footer.footer.postamble
         (render 'newsletter-form-w)
         (when feed-path
           (:p.rss-sub
            (:a :href feed-path
                :title "Follow via RSS"
                :target "blank"
                (:span.rss) "Follow via RSS")))
         (:div.author
          ("Author: ~a " author-name)
          (dolist (handle handles)
            (:a :class (format nil "handle ~a" (str:downcase (first handle)))
                :title (format nil "Follow ~a via ~a" author-name (first handle))
                :href (third handle)))))))))

(defmethod lass-of ((w footer-w))
  (tagged-lass
   `((.footer
      :color (var --color-grey-600)
      :margin (var --size-12) auto
      :padding (var --scale-1)

      (p :margin (var --size-2) 0)

      (.rss-sub
       (a :display flex :align-items center)
       (.rss :margin-right (var --size-2)
             :display block
             :width 24px
             :height 24px
             :background (url "/images/icons/rss.svg")
             :background-repeat no-repeat
             :background-size contain)))

     (.author
      :display flex
      :align-items center

      (.handle
       :display block
       :cursor pointer
       :width (var --size-4)
       :height (var --size-4)
       :margin 0 (var --size-1)
       :background-repeat no-repeat
       :background-size contain)

      (.github :background-image (url "/images/icons/github.svg"))
      (.mastodon :background-image (url "/images/icons/mastodon.svg"))
      (.rss :background-image (url "/images/icons/rss.svg"))
      (.linkedin :background-image (url "/images/icons/linkedin.svg"))))

   :lg `((.footer :max-width (var --width-md)))))
