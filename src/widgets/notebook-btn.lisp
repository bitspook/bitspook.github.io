(in-package #:in.bitspook.website)

(defwidget notebook-btn-w (tags)
    (tagged-lass
     `((.icon-nb :background-image (url "/images/icons/nb.svg"))))
  (let* ((tag-count (length tags))
         (description (cond ((eq tag-count 1) (format nil "tagged ~{#~a~}" tags))
                            ((eq tag-count 2)
                             (format nil "tagged #~a and #~a"
                                     (first tags)
                                     (second tags)))
                            ((> tag-count 2)
                             (format nil "with tags ~{#~a ~} and ~d more"
                                     (firstn 2 tags) (- (length tags) 2)))
                            (t (format nil "")))))
    (:button.btn
     (:i.icon.icon-nb)
     (:div.title
      (:h2 "Notebook")
      (:div.meta
       (:span.count "20 notes")
       (:span description))))))
