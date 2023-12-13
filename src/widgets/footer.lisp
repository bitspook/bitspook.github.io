(in-package #:in.bitspook.website)

(defwidget footer-w (post) nil
  (with-slots (author) post
    (with-slots ((author-name name) handles) author
      (let ((handle (car handles)))
        (:footer.footer.postamble
         (:p.rss-sub
          (:a :href "/archive/feed.xml"
              :title "Follow via RSS"
              :target "blank"
              (:span.rss) "Follow via RSS"))
         (:p ("Author: ~a " author-name)
             (when handle
               (:a :href (third handle)
                   :title (format nil "~a on ~a" author-name (first handle))
                   ("@~a" (second handle))))))))))

(defmethod lass-of ((w footer-w))
  (tagged-lass
   `((.footer
      :font-family monospace
      :color "#666"
      :margin (var --size-24) auto
      :margin-bottom (var --size-12)

      (.validation :display none))
     (:media ,(format nil "(max-width: ~a)" "840px")
             (.postamble
              :max-width 100%
              :padding 0 8%))
     (:media ,(format nil "(max-width: ~a)" "520px")
             (.postamble
              :max-width 100%
              :padding 0 4%))
     ("#mc_embed_signup" :max-width 600px
                         :background transparent
                         :margin-bottom 4rem)
     (.newsletter-email :border 1px solid "#eee"
                        :border-radius 25px
                        :background-color transparent
                        :width 100%
                        :margin-bottom 1rem
                        :padding 0.4rem 0.8rem)

     ((:or ".newsletter-email::-moz-placeholder"
           ".newsletter-email::-webkit-input-placeholder")
      :color "#aaa"))

   :lg `((.footer :max-width (var --width-lg)))))
