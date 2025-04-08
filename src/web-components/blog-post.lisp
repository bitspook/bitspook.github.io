(in-package #:in.bitspook.website)

(defun bp-lass ()
  (tagged-lass
   (base-lass)

   `((.content
      (.header
       :padding (var --size-4)
       :margin (var --scale-2) 0

       (h1 :font-family (var --font-title)
           :font-size (var --scale-6)
           :margin-bottom (var --scale-0))

       (.meta :color (var --color-grey-500)
              :font-size (var --scale-0))

       (.meta-item :display inline)

       (.tags :list-style-type none
              :margin 0
              :padding 0
              :margin-left (var --size-4)

              (.tag
               :display inline-block
               :padding-right (var --size-3)))))

     (.post-body :padding 0 (var --size-4)
                 :font-size (var --scale-1)
                 :line-height (var --line-md)))

   :lg `((.content :max-width (var --width-md)
                   :margin 0 auto))))

(defcomponent blog-post-w (post css-file-artifact)
    (bp-lass)
  (with-slots (title published-at author tags category) post
    (:html
     (:head (:title title)
            (:meta :name "viewport" :content "width=device-width, initial-scale=1")
            (when css-file-artifact (:link :rel "stylesheet" :href (embed-artifact-as css-file-artifact 'link)))
            (:link :rel "alternate" :type "application/atom+xml" :href (link-artifact 'atom-feed :type 'all :name 'all))
            (:script :src "/js/app.js"))
     (:body
      (:div
       (render 'navbar-w :links nil)
       (:article
        :class "content"
        (:header.header
         (:h1 title)
         (:div
          :class "meta"
          (:time :class "meta-item date" (local-time:format-timestring
                                          nil published-at
                                          :format '(:long-month " " :day ", " :year)))

          (when-let ((tags tags))
            (:ul
             :class "meta-item tags"
             (dolist (tag tags)
               (when-let ((link (link-artifact 'listing :type 'tag :name tag)))
                 (:li.tag
                  (:a :href link
                      (str:concat "#" (str:downcase tag))))))))))
        (:main :class "post-body" (:raw (post-body post))))
       (render 'footer-w :author author))))))
