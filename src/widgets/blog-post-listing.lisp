(in-package #:in.bitspook.website)

(defun bp-listing-lass ()
  (tagged-lass
   base-lass

   `((.header
      :padding (var --size-4)
      :margin (var --scale-2) 0)

     (.title :font-family (var --font-title)
             :font-size (var --size-10)
             :padding-bottom (var --scale-0)
             :border-bottom 1px solid (var --color-grey-200))

     (.listing :margin-bottom 0
               :padding 0 (var --scale-0))

     (.pagination :display flex
                  :padding (var --size-4)
                  :justify-content space-between
                  :margin-top (var --scale-8))

     (.next :flex-grow 1
            :text-align right))

   :dark `((.title :border-bottom-color (var --color-grey-800)))

   :lg `((.content :max-width (var --width-md)
                   :margin 0 auto))))

(defwidget blog-post-listing-w (posts title author next-page previous-page)
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
     (:ul.listing
      (dolist (post posts)
        (render 'blog-post-listing-item-w :post post)))
     (when (or previous-page next-page)
       (:nav.pagination
        (when previous-page
          (:a.prev :href (cdr previous-page) (car previous-page)))

        (when next-page
          (:a.next :href (cdr next-page) (car next-page)))))))
   (render 'footer-w :author author)))
