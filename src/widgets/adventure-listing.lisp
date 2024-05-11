(in-package #:in.bitspook.website)

(defwidget adventures-listing-w (adventures title description css-file-artifact)
    (tagged-lass
     (base-lass)

     `((.main
        :position relative
        :margin 0 auto
        :max-width 1080px
        :min-height 40rem
        :font-family (var --font-text)
        :font-size 1.4rem

        (p :margin 1rem 0)

        (:header :font-family (var --font-title))
        (.title :font-size 2.5rem)

        (.main-list :list-style-type none
                    :margin 4rem 0)

        (.adventure
         :margin 1rem 0
         :padding 1rem
         :border 1px solid (var --color-grey-800)
         :border-radius 1rem
         :display flex

         (.primary :flex-grow 1)
         (.health :width 15rem
                  :height 15rem
                  :margin 0 2rem)

         (.activity :list-style-type none
                    :font-size 1rem
                    :color (var --color-grey-400)
                    :padding 0.4rem 1rem)

         (.grade :border 1rem solid (var --color-green-600)
                 :color (var --color-green-600)
                 :border-radius 50%
                 :height 10rem
                 :width 10rem
                 :display flex
                 :align-items center
                 :justify-content center
                 :font-weight bold
                 :font-size 4rem)

         (header
          :margin-bottom 2rem
          :font-family (var --font-text)

          (.title :font-size 2rem
                  :margin 0
                  :margin-bottom 0.4rem)

          (.subtitle :font-size 1.4rem
                     :color (var --color-grey-400)))

         (footer :color (var --color-grey-400)
                 :margin-top 1rem)))))

  (:html
   (:head (:title title)
          (:meta :name "viewport" :content "width=device-width, initial-scale=1")
          (when css-file-artifact (:link :rel "stylesheet" :href (embed-artifact-as css-file-artifact 'link)))
          (:link :rel "alternate" :type "application/atom+xml" :href (link-page 'atom-feed "archive"))
          (:script :src "/js/app.js"))
   (:body
    (:div
     (render 'navbar-w)
     (:article.main
      (:h1.title title)
      (:p "A adventure is a commitment to move forward. Sometimes to reach a destination/goal, and sometimes
just for the sake of movement.")

      (:ul.main-list
       (:li.adventure
        (:section.primary
         (:header (:h2.title (:a :href "/adventures/infosec" "Infosec"))
                  (:p.subtitle "Information security from attacker's perspective"))
         (:article (:p "I have desired for long to explore infosec in depth. Finally, I have decided to
                        commit and invest in it.")))
        (:section.health
         (:div.grade (:span "A+"))
         (:ul.activity
          (:li "Very good health")
          (:li "7 day streak")
          (:li "0 companions")))))

      (:div.description
       (or description
           (:p "Criteria I use to decide what qualifies as a adventure:")
           (:ol
            (:li (:p "An objective which need a long term commitment")
                 (:p "A adventure is more than just exploring a topic for a few days/weeks. A
        adventure starts when I have done the exploration and am ready to make a
        commitment."))
            (:li (:p "A feasible method of measuring progress")
                 (:p "It is really a wish if we can't track whether any progress is being made on
        the adventure or not."))))))
     (render 'footer-w)))))
