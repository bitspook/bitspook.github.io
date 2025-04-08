(in-package #:in.bitspook.website)

(defun make-home-page (&key title all-posts author about-me-summary)
  (let ((home-page (make-html-page-artifact
                    :location "/index.html"
                    :id "home"
                    :root-component (make 'home-page-w
                                          :posts (take 5 all-posts)
                                          :title title
                                          :author author
                                          :about-summary about-me-summary)
                    :css-location "/css/home.css")))
    home-page))
