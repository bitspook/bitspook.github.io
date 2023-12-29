(in-package #:in.bitspook.website)

(defwidget blog-post-listing-item-w (post)
    (tagged-lass
     `((li :display flex
           :line-height 1.3
           :padding 0.32rem 0
           :align-items center
           :list-style-type none
           :margin-bottom 0.6rem)

       (.li-icon :display block
                 :background-repeat no-repeat
                 :background-position 0 0
                 :background-size contain
                 :content ""
                 :width 88px
                 :height 48px
                 :flex-shrink 0)

       (.li-icon--blog :background-image "url(/images/icons/post.svg)")

       (.li-icon--talks :background-image "url(/images/icons/talk.svg)")

       (.li-icon--poems :background-image "url(/images/icons/poems.svg)")
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
   (:span :class (format nil "li-icon li-icon--~a" (post-category post)))
   (:div.li-content
    (:a.li-title :href (published-path post) (post-title post))
    (:span.li-meta
     (:span :class "meta-item date"
            (local-time:format-timestring
             nil (post-updated-at post)
             :format '(:long-month " " :day ", " :year)))
     (when-let ((tags (post-tags post)))
       (:span :class "meta-item tags"
              (dolist (tag tags)
                (:a :href (str:concat "/tags/" tag) (str:concat "#" (str:downcase tag))))))))))
