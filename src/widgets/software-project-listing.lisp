(in-package #:in.bitspook.website)

(defwidget software-project-listing-w (css-file-artifact projects project-publisher title author next-page previous-page)
    (tagged-lass
     (base-lass)

     `((.header
        :padding (var --size-4) :margin (var --scale-2) 0
        :display flex
        :align-items center
        :border-bottom 1px solid (var --color-grey-200))

       (.title :font-family (var --font-title)
               :font-size (var --size-10))

       (.listing :margin-bottom 0
                 :padding 0 (var --scale-0))

       (.pagination :display flex
                    :padding (var --size-4)
                    :justify-content space-between
                    :margin-top (var --scale-0))

       (.next :flex-grow 1
              :text-align right))

     :dark `((.title :border-color (var --color-grey-800))
             (.header :border-color (var --color-grey-800)))

     :lg `((.content :max-width (var --width-md)
                     :margin 0 auto)))
  (:html
   (:head (:title title)
          (:meta :name "viewport" :content "width=device-width, initial-scale=1")
          (when css-file-artifact (:link :rel "stylesheet" :href (embed-artifact-as css-file-artifact 'link)))
          (:link :rel "alternate" :type "application/atom+xml" :href (link-page 'atom-feed "archive"))
          (:script :src "/js/app.js"))
   (:body
    (:div
     (render 'navbar-w :links nil)
     (:article.content
      (:header.header
       (:h1.title title))

      (:main
       (:ul.listing
        (dolist (project projects)
          (render 'software-project-listing-item-w :project project)))
       (when (or previous-page next-page)
         (:nav.pagination
          (when previous-page
            (:a.prev :href (cdr previous-page) (car previous-page)))

          (when next-page
            (:a.next :href (cdr next-page) (car next-page)))))))
     (render 'footer-w :author author :feed-path nil)))))
