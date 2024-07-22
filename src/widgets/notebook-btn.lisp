(in-package #:in.bitspook.website)

(defwidget notebook-btn-w (note-ids)
    (tagged-lass
     `((.icon-nb :background-image (url "/images/icons/nb.svg"))))
  (unless (emptyp note-ids)
    (:button.btn
     (:i.icon.icon-nb)
     (:div.title
      (:h2 "Notebook")
      (:div.meta
       (:span.count ("~a notes" (length note-ids))))))))
