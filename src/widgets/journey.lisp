(in-package #:in.bitspook.website)

(defwidget journey-w (journey related-posts css-file-artifact author)
    (tagged-lass
     (base-lass)

     `((nav.top-nav :padding 0)
       (footer.postamble :padding 0)
       (.container
        :max-width 1080px
        :margin 0 auto

        ("header.main"
         :margin 2rem 0

         (.title :margin 0
                 :margin-bottom 0.4rem)

         (.subtitle :font-size 1.4rem))

        ("article.main"
         :min-height 40rem

         (p :margin 1rem 0))

        ((:or .btn-github .btn-issues .btn-docs)
         :padding 0 1rem
         :font-size 1.2rem
         :color (var --color-grey-800))

        (.icon :background-size contain
               :display inline-block
               :width 1.4rem
               :height 1.4rem
               :margin-right 0.4rem
               :background-repeat no-repeat)

        (.btn-github (.icon :background-image (url "/images/icons/github.svg")))

        (.btn
         :padding 1rem
         :width 25rem
         :height 8rem
         :display flex
         :margin 2rem 0
         :margin-right 1rem
         :border-color (var --color-grey-300)
         :flex 1

         (.icon :min-width 4rem
                :height 4rem
                :margin-right 1rem)
         (.icon-friends :background-image (url "/images/icons/friends.svg"))
         (.icon-flame :background (var --color-grey-800) no-repeat
                      :mask-size contain
                      :mask-image (url "/images/icons/flame.svg")
                      (svg#flame :fill-color magenta))

         (.title
          :margin 0
          :margin-left 0.8rem
          :text-align left
          :overflow hidden

          (h2 :margin 0
              :margin-bottom 0.6rem
              :font-size 1.8rem))

         (.meta :color (var --color-grey-300)
                :font-size 1rem
                :line-height 1.2
                (.count :margin-right 0.3rem)))
        (.insight-btns
         :display inline-flex
         :max-width 100%)

        (.activity
         :margin 4rem 0

         (.title
          :font-size 2rem
          :font-weight bold)

         (select :border none
           :background white
           :font-size 1.7rem
           :padding 0.4rem 0
           :border-bottom 2px solid (var --color-grey-800)
           :min-width 10rem))

        (.activity-log
         :font-size 1.2rem

         (.activity-item
          :padding 1rem 0
          :position relative
          :display flex

          (.icon-simple-cal
           :width 2rem
           :height 2rem
           :z-index 1
           :background (var --color-grey-100) no-repeat
           :background-image (url "/images/icons/simple-cal.svg")
           :background-size 50%
           :background-position 50% 50%
           :margin-right 1rem
           :margin-left -1rem
           :border 2px solid (var --color-grey-300)
           :border-radius 50%))

         (.activity-body
          (.date
           :font-size 1rem
           :color (var --color-grey-300)
           :padding 0.2rem 0
           :margin-bottom 0.8rem)
          (.events :list-style-type none
                   (li :margin-bottom 0.4rem))))

        (".activity-item::before"
         :width 2px
         :height 100%
         :content ""
         :position absolute
         :left 0 :top 0 :bottom 0
         :background-color (var --color-grey-300))

        (.graph-placeholder :width 60%
                            :height 25rem
                            :border 2px solid (var --color-grey-300)
                            :display flex
                            :align-items center
                            :padding 2rem
                            :margin 1rem 0
                            :border-radius 1rem
                            :color (var --color-grey-300)))))

  (:html
   (:head (:title (journey-name journey))
          (:meta :name "viewport" :content "width=device-width, initial-scale=1")
          (:meta :name "author" :content (slot-value author 'name))
          (:meta :name "description" :content (journey-summary journey))
          (when css-file-artifact (:link :rel "stylesheet" :href (embed-artifact-as css-file-artifact 'link)))
          (:link :rel "alternate" :type "application/atom+xml" :href (link-artifact 'atom-feed :type 'all :name 'all))
          (:script :src "/js/app.js"))
   (:body
    (render 'navbar-w :links nil)

    (:section.container
     (:header.main
      (:h1.title (journey-name journey)))
     (:article.main
      (:raw (journey-summary journey))

      (:div.insight-btns
       (render 'notebook-btn-w :notes (journey-notes journey)))

      (:section.activity
       (:header.title (:span "Activity log for") (:select.log-time
                                                  (:option :value "last-week" "last week")
                                                  (:option :value "this-month" "this month")))
       (:article
        (:div.activity-graph
         (:div.graph-placeholder
          (:p "TODO Add data visualization here")))

        (:div.activity-log
         (:div.activity-item
          (:span.icon.icon-simple-cal)
          (:div.activity-body
           (:div.date "Wednesday 15 Nov, 2022")
           (:ul.events
            (:li
             (:a :href "#" "1 commit")
             " made to project "
             (:a :href "#" "slurp"))
            (:li
             "Created "
             (:a :href "#" "1 new note")))))
         (:div.activity-item
          (:span.icon.icon-simple-cal)
          (:div.activity-body
           (:div.date "Wednesday 16 Nov, 2022")
           (:ul.events
            (:li
             (:a :href "#" "2 commits")
             " made to project "
             (:a :href "#" "cl-ownpress"))
            (:li
             "Modified "
             (:a :href "#" "4 notes"))
            (:li
             "Created "
             (:a :href "#" "2 new notes"))
            (:li
             "Pwned "
             (:a :href "#" "Supermo")
             " box on "
             (:a :href "#" "HackTheBox"))))))))

      (:raw (journey-content journey))

      (:div#explore
       (:h2.title "Related content")
       ;; (render 'posts-listing-widget :posts nil)
       ))
     (render 'footer-w :author author)))))
