(uiop:define-package #:in.bitspook.website
  (:use #:cl #:serapeum/bundle
        #:in.bitspook.cl-ownpress #:in.bitspook.cl-ownpress/publisher #:in.bitspook.cl-ownpress/provider)
  (:import-from #:slug :slugify))

(in-package #:in.bitspook.website)

(defgeneric from (obj to &key)
  (:documentation "Convert OBJ object to instance of class represented symbol TO"))
