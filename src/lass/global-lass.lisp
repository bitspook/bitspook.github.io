(in-package #:in.bitspook.website)

(defparameter fonts
  (list
   (cons "Fira Sans"
         (list
          (make-font-artifact
           :files (mapcar (op (base-path-join *fonts-dir* _))
                          '("firasans-thin-webfont.woff2"
                            "firasans-thin-webfont.woff"))
           :weight 300
           :style 'normal)

          (make-font-artifact
           :files (mapcar
                   (op (base-path-join *fonts-dir* _))
                   '("firasans-thinitalic-webfont.woff2" "firasans-thinitalic-webfont.woff"))
           :weight 300
           :style 'italic)

          (make-font-artifact
           :files (mapcar
                   (op (base-path-join *fonts-dir* _))
                   '("firasans-bold-webfont.woff2" "firasans-bold-webfont.woff"))
           :weight 700
           :style 'bold)

          (make-font-artifact
           :files (mapcar
                   (op (base-path-join *fonts-dir* _))
                   '("firasans-heavy-webfont.woff2" "firasans-heavy-webfont.woff"))
           :weight 800
           :style 'bold)

          (make-font-artifact
           :files (mapcar
                   (op (base-path-join *fonts-dir* _))
                   '("firasans-heavyitalic-webfont.woff2" "firasans-heavyitalic-webfont.woff"))
           :weight 700
           :style 'italic)

          (make-font-artifact
           :files (mapcar
                   (op (base-path-join *fonts-dir* _))
                   '("firasans-italic-webfont.woff2" "firasans-italic-webfont.woff"))
           :weight 400
           :style 'italic)

          (make-font-artifact
           :files (mapcar
                   (op (base-path-join *fonts-dir* _))
                   '("firasans-regular-webfont.woff2" "firasans-regular-webfont.woff"))
           :weight 400
           :style 'normal)))
   (cons "Alfa Slab One"
         (list (make-font-artifact
                :files (mapcar
                        (op (base-path-join *fonts-dir* _))
                        '("alfaslabone-regular-webfont.woff2"
                          "alfaslabone-regular-webfont.woff"))
                :weight 400
                :style 'normal)))))

(defun add-fonts ()
  (apply #'concatenate
   'list
   (mapcar
    (lambda (font-set)
      (mapcar
       (op (embed-artifact-as _ 'font-face :family (car font-set)))
       (cdr font-set)))
    fonts)))

(defparameter global-css-vars
  '(:--font-text "Fira Sans"
    :--font-title "Alfa Slab One"))

(defun base-lass ()
  (tagged-lass
   `((":root" ,@pollen-vars
              ,@global-css-vars))
   (add-fonts)
   normalize-lass

   `((body :font-size 16px
           :font-family (var --font-text) sans-serif
           :line-height (var --line-sm)
           :color (var --color-grey-600))

     ((:or h1 h2 h3 h4 h5 h6)
      :margin 0
      :padding 0
      :font-size (var --scale-1)
      :font-weight (var --weight-black)
      :letter-spacing 2px)

     ((:or blockquote dl figure form ol p pre table ul)
      :margin-bottom (var --scale-2)
      :overflow auto)

     (figcaption :font-size (var --scale-00)
                 :color (var --color-grey-400))

     ((:or td th)
      :padding 12px 15px
      :text-align left
      :border-bottom 1px solid (var --color-grey-300))

     (h1 :font-size (var --scale-5))
     (h2 :font-size (var --scale-4))
     (h3 :font-size (var --scale-3))
     (h4 :font-size (var --scale-2))
     (h5 :font-size (var --scale-1))

     (h6 :font-size (var --scale-0))

     (a :color inherit)

     (img :width 100%)

     (blockquote
      :margin (var --size-2) 0
      :padding 0 (var --scale-2)
      :border-left (var --size-2) solid (var --color-grey-300))

     ((:or code kbd samp pre)
      :font-size (var --scale-0)
      :padding (var --size-1)
      :font-family (var --font-mono)
      :background-color (var --color-grey-200)
      :border 1px solid (var --color-grey-300)
      :border-radius (var --radius-xs)))

   :dark `((body :color (var --color-grey-400)
                 :background (var --color-grey-900))

           ((:or code kbd samp pre)
            :background-color (var --color-grey-800)
            :border 1px solid (var --color-grey-900)
            :border-radius (var --radius-xs))

           ((:or input textarea)
            :background-color (var --color-grey-700)
            :color inherit))))
