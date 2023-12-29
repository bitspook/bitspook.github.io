(in-package #:in.bitspook.website)

(defun sp-lass ()
  (tagged-lass
   base-lass

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

(defwidget software-project-w (project)
    (sp-lass)
  (with-slots (name created-at author tags body) project
    (:div
     (render 'navbar-w :links nil)
     (:article
      :class "content"
      (:header
       :class "header"
       (:h1 name)
       (:div
        :class "meta"
        (:time :class "meta-item date" (local-time:format-timestring
                                        nil created-at
                                        :format '(:long-month " " :day ", " :year)))))
      (:main :class "post-body" (:raw body)))
     (render 'footer-w :author author :feed-path nil))))
