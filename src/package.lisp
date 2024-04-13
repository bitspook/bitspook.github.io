(defpackage in.bitspook.website
  (:use #:cl #:serapeum/bundle)
  (:import-from #:in.bitspook.cl-ownpress
   :start-rpc-server :stop-rpc-server
   :css-file-artifact :html-page-artifact
   :make-font-artifact :embed-artifact-as :link :tagged-lass
   :defwidget :render :make-html-page-artifact :emacs-provider :script
   :provide-all :publish-static :publish-artifact :font-face :*base-url*)
  (:import-from #:slug :slugify)
  (:import-from #:spinneret :with-html)
  (:local-nicknames
   (:feeder #:org.shirakumo.feeder)  ;; entry feed link serialize-feed
   (:clown #:in.bitspook.cl-ownpress)))

(in-package #:in.bitspook.website)

(defgeneric from (obj to &key)
  (:documentation "Convert OBJ object to instance of class represented symbol TO"))

(defparameter *fonts-dir*
  (asdf:system-relative-pathname "in.bitspook.website" "src/fonts/"))
