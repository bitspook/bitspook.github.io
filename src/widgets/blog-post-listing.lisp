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

       ((:and .li-meta (.li-meta a)) :font-family "Roboto, sans-serif"
                                     :display flex)

       (.meta-item :line-height 1
                   :padding 0
                   :padding-right 1em
                   :border-right 1px solid (var --color-grey-500))

       ((:and .meta-item :last-child) :padding-right 0
                                      :border none)
       (.tags :display flex
              :flex-wrap wrap

              (a :margin-left 1rem)))

     :dark `((.li-meta :color (var --color-grey-600))))
  (:li
   (:span :class (format nil "li-icon li-icon--~a" (post-category post)))
   (:div.li-content
    (:a.li-title :href "#" (post-title post))
    (:span.li-meta
     (:span :class "meta-item date"
            (local-time:format-timestring
             nil (post-updated-at post)
             :format '(:long-month " " :day ", " :year)))
     (when-let ((tags (post-tags post)))
       (:span :class "meta-item tags"
              (dolist (tag tags)
                (:a :href (str:concat "/tags/" tag) (str:concat "#" (str:downcase tag))))))))))

(defun bp-listing-lass ()
  (tagged-lass
   base-lass

   `((.header
      :padding (var --size-4)
      :margin (var --scale-2) 0)

     (.title :font-family (var --font-title)
             :font-size (var --size-10)
             :padding-bottom (var --scale-0)
             :border-bottom 1px solid (var --color-grey-400)))

   :dark `((.title :border-bottom-color (var --color-grey-800)))

   :lg `((.content :max-width (var --width-md)
                   :margin 0 auto))))

(defwidget blog-post-listing-w (posts title author)
    (bp-listing-lass)
  (:div
   (render 'navbar-w :links '(("Home" "/")
                              ("Blog" "/blog")
                              ("Poems" "/poems")
                              ("Projects" "https://github.com/bitspook")
                              ("About me" "/about")))
   (:article.content
    (:header.header
     (:h1.title title))

    (:main
     (:ul
      (dolist (post posts)
        (render 'blog-post-listing-item-w :post post)))))

   (render 'footer-w :author author)))
