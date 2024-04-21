(defpackage in.bitspook.website
  (:use #:cl #:serapeum/bundle)
  (:import-from #:trivia :match)
  (:import-from #:slug :slugify)
  (:import-from #:spinneret :with-html)
  (:import-from #:in.bitspook.cl-ownpress
   :start-rpc-server :stop-rpc-server
   :artifact :css-file-artifact :html-page-artifact :artifact-deps
   :make-font-artifact :embed-artifact-as :link :tagged-lass
   :defwidget :render :make-html-page-artifact :emacs-provider :script
   :provide-all :publish-static :publish-artifact :font-face :*base-url*
   :skip-existing :file-already-exists :*already-published-artifacts* :artifact-location)
  (:local-nicknames
   (:feeder #:org.shirakumo.feeder) ;; entry feed link serialize-feed
   (:clown #:in.bitspook.cl-ownpress)))

(in-package #:in.bitspook.website)

(defgeneric from (obj to &key)
  (:documentation "Convert OBJ object to instance of class represented symbol TO"))

(defparameter *fonts-dir*
  (asdf:system-relative-pathname "in.bitspook.website" "src/fonts/"))
