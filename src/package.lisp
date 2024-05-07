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

(defun group-by (items key-fn)
  "Group ITEMS into a hashmap by KEY-FN.
KEY-FN is a getter function which when given an ITEM as argument can return a string/symbol or list
of string/symbol. Each ITEM is grouped into a hashmap with return values of KEY-FN as keys, and list
of ITEMs as value."
  (loop
    :with group := (dict)
    :for item :in items
    :for key := (funcall key-fn item)
    :do
       (if (listp key)
           (dolist (k key) (appendf (href group k) (list item)))
           (appendf (href group key) (list item)))
    :finally (return group)))

;; ---

(defparameter *category-indices* (dict)
  "Index pages for categories.")

(defparameter *tag-indices* (dict)
  "Index pages for tags.")

(defparameter *pages* (dict)
  "Independent pages by slug.")

(defparameter *atom-feeds* (dict)
  "Hashtable of atom feeds by name.")

(defun find-page (id-type id)
  "Find a html-page-artifact of ID-TYPE which can be identified by ID.
Possible values for ID-TYPE:
1. category-index
2. tag-index
3. slug
4. atom-feed"
  (ecase id-type
    (category-index (@ *category-indices* id))
    (tag-index (@ *tag-indices* id))
    (slug (@ *pages* id))
    (atom-feed (@ *atom-feeds* id))))

(defun link-page (id-type id)
  "Embed page find with FIND-PAGE as LINK."
  (embed-artifact-as (find-page id-type id) 'link))
