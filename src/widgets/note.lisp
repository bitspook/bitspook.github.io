(in-package #:in.bitspook.website)

(defwidget note-w (note css-file-artifact)
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

       (.note-body :padding 0 (var --size-4)
                   :font-size (var --scale-1)
                   :line-height (var --line-md)))

     :lg `((.content :max-width (var --width-md)
                     :margin 0 auto)))
  (with-slots (title updated-at author tags category) note
    (:html
     (:head (:title title)
            (:meta :name "viewport" :content "width=device-width, initial-scale=1")
            (when css-file-artifact (:link :rel "stylesheet" :href (embed-artifact-as css-file-artifact 'link)))
            (:link :rel "alternate" :type "application/atom+xml" :href (link-artifact 'atom-feed :feed "archive"))
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
                                          nil updated-at
                                          :format '(:long-month " " :day ", " :year)))))
        (:main :class "note-body" (:raw (note-body note))))
       (render 'footer-w :author author))))))
