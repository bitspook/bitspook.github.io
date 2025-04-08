(in-package #:in.bitspook.website)

(defcomponent notebook-btn-w (note-ids href)
    (tagged-lass
     `((.notebook-btn
        (.icon-nb :background-image (url "/images/icons/nb.svg"))
        (.btn (.meta :color (var --color-grey-500))))))
  (:div.notebook-btn
   (unless (emptyp note-ids)
     (:a.btn :href href
             (:i.icon.icon-nb)
             (:div.title
              (:h2 "Notebook")
              (:div.meta
               (:span.count ("~a notes" (length note-ids)))))))))
