(in-package #:in.bitspook.website)

(defwidget about-me-summary-w (categories)
    (tagged-lass
     `((.about-me-snippet
        :line-height 1.5
        :align-items center
        :margin (var --scale-4) 0
        :font-weight 500

        (.heading :font-family (var --font-title)
                  :margin (var --scale-2) 0
                  :font-weight normal))))
  (:section
   :class "about-me-snippet"
   (:p
    (:p "Hello!")
    (:p "Welcome to my little corner of the Internet. This website has things I am willing to share publicly.
You can go through my "
        (:a :href (link-artifact 'listing :type 'category :name "blog")  "blog") ", "
        (:a :href (link-artifact 'listing :type 'category :name "poems")  "poems") ", "
        (:a :href (link-artifact 'listing :type 'category :name "projects") "projects") " and also some "
        (:a :href (link-artifact 'listing :type 'category :name "talks") "talks") "I gave .")
    (:p "If you want to know more about me,  you can read " (:a :href (link-artifact "about") " the short bio.")))))
