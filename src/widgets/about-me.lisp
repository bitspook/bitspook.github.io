(in-package #:in.bitspook.website)

(defwidget about-me-summary-w (categories) nil
  (:p
   (:p "I am a software engineer. I enjoy playing with software, electronics and video games. My favorites
are Factorio, Rimworld and Terraria. I also enjoy reading, writing, people watching and discussing
computers, security and politics.")
   (:p "This website has things I am willing to share publicly. You can go through my "
       (:a :href (link-artifact 'listing :type 'category :name "blog")  "blog") ", "
       (:a :href (link-artifact 'listing :type 'category :name "poems")  "poems") ", "
       (:a :href (link-artifact 'listing :type 'category :name "projects") "projects") " and also some "
       (:a :href (link-artifact 'listing :type 'category :name "talks") "talks") "I gave .")
   (:p "You can read more about me " (:a :href (link-artifact "about") "here."))))
