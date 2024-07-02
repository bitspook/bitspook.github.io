(in-package #:in.bitspook.website)

(defwidget about-me-summary-w (categories)
    (tagged-lass
     `((.about-me-snippet
        :line-height 1.5
        :align-items center
        :margin (var --scale-4) 0
        :font-weight 500

        (.heading :font-family (var --font-title)
                  :margin (var --scale-4) 0 (var --scale-2) 0
                  :font-weight normal))))
  (:section
   :class "about-me-snippet"
   (:header
    (:h2.heading "About Me"))
   (:p
    (:p "I am a software engineer. I enjoy playing with software, electronics and video games. My favorites
are Factorio, Rimworld and Terraria. I also enjoy reading, writing, people watching and discussing
computers, security and politics.")
    (:p "This website has things I am willing to share publicly. You can go through my "
        (:a :href (link-artifact 'listing :type 'category :name "blog")  "blog") ", "
        (:a :href (link-artifact 'listing :type 'category :name "poems")  "poems") ", "
        (:a :href (link-artifact 'listing :type 'category :name "projects") "projects") " and also some "
        (:a :href (link-artifact 'listing :type 'category :name "talks") "talks") "I gave .")
    (:p "You can read more about me " (:a :href (link-artifact "about") "here.")))))
