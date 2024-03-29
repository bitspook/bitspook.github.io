(in-package #:in.bitspook.website)

(defparameter navbar-lass
  (tagged-lass
   `((.top-nav
      :min-height (var --size-16)
      :max-width (var --width-lg)
      :margin 0 auto
      :display flex
      :padding (var --size-2)
      :flex-direction column
      :position relative
      :justify-content space-between

      (.brand
       :width (var --size-16)
       :height (var --size-16)
       :align-self center
       :flex-grow 1

       (img :width (var --size-16)))

      (ul.nav
       :list-style-type none
       :padding 0
       :display flex
       :flex-wrap wrap
       :justify-content center
       :align-items center

       (li :padding 0 (var --size-4) (var --size-4)))))

   :sm  `((.top-nav
           :padding-right 1em
           :flex-direction row

           (a :font-size 1em)

           (ul.nav (li :padding 0 (var --size-4)))))))

(defwidget navbar-w (links) navbar-lass
  (let ((links (or links '(("Home" "/")
                           ("Blog" "/blog")
                           ("Projects" "/projects")
                           ("About me" "/about")))))
    (:nav :class "top-nav"
          (:div :class "brand"
                (:a :href "/"
                    (:img :class "brand-avatar"
                          :src "/images/avatar.png"
                          :alt "Brand")))
          (:ul :class "nav"
               (loop :for link :in links
                     :do (:li (:a :href (second link) (first link))))))))
