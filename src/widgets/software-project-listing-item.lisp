(in-package #:in.bitspook.website)

(defwidget software-project-listing-item-w (project publisher)
    (tagged-lass
     `((li :display flex
           :line-height 1.3
           :padding 0.32rem 0
           :align-items center
           :list-style-type none
           :margin-bottom 0.6rem)

       (.li-title :font-size (var --size-5))

       (.li-meta :margin-top (var --size-1)
                 :font-size (var --size-3)
                 :color (var --color-grey-500)
                 :display flex)

       ((:and .li-meta (.li-meta a)) :font-family (var --font-text)
                                     :display flex)

       (.meta-item :line-height (var --line-sm)
                   :padding 0
                   :padding-right 1em
                   :border-right 1px solid (var --color-grey-500))

       ((:and .meta-item :last-child) :padding-right 0
                                      :border none)
       (.tags :display flex
              :flex-wrap wrap

              (a :margin-left 1rem)))

     :dark `((.li-meta :color (var --color-grey-600))
             (.meta-item :border-color (var --color-grey-800))))
  (:li
   (:div.li-content
    (:a.li-title :href (published-path publisher :project project) (project-name project))
    (:span.li-meta
     (:span :class "meta-item date"
            (local-time:format-timestring
             nil (project-updated-at project)
             :format '(:long-month " " :day ", " :year)))))))
