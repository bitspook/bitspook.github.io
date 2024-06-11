(defpackage in.bitspook.website
  (:use #:cl #:serapeum/bundle)
  (:import-from #:trivia :match)
  (:import-from #:slug :slugify)
  (:import-from #:spinneret :with-html)
  (:import-from #:in.bitspook.cl-ownpress
   :start-rpc-server :stop-rpc-server
   :artifact :css-file-artifact :html-page-artifact :artifact-deps
   :make-font-artifact :embed-artifact-as :link :tagged-lass
   :defwidget :render :make-html-page-artifact :emacs-provider :script :provide-all
   :publish-static :publish-artifact :font-face :*base-url*
   :skip-existing :file-already-exists :*already-published-artifacts* :artifact-location
   :artifact-id :artifact-registry :registry-indices :registry-on-index-artifact
   :registry-add-index :registry-query)
  (:local-nicknames
   (:feeder #:org.shirakumo.feeder) ;; entry feed link serialize-feed
   (:clown #:in.bitspook.cl-ownpress)))

(in-package #:in.bitspook.website)

(defgeneric from (obj to &key)
  (:documentation "Convert OBJ object to instance of class represented symbol TO"))

(defparameter *fonts-dir*
  (asdf:system-relative-pathname "in.bitspook.website" "src/fonts/"))

;; Utilities
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

;; Registry
(defparameter *registry* (make 'artifact-registry))

(registry-add-index *registry* 'tagged)
(defmethod registry-on-index-artifact ((reg artifact-registry)
                                       (post blog-post-page)
                                       (idx (eql 'tagged)) &key)
  (call-next-method reg post idx :keys (post-tags post)))

(defmethod registry-query ((reg artifact-registry)
                           (key (eql 'tagged))
                           &key tag)
  (let ((ids (@ (registry-indices reg) 'tagged tag)))
    (mapcar (op (@ (registry-store reg) _)) ids)))

(registry-add-index *registry* 'categorized)
(defmethod registry-on-index-artifact ((reg artifact-registry)
                                       (post blog-post-page)
                                       (idx (eql 'categorized)) &key)
  (call-next-method reg post idx :keys (list (post-category post))))

(defmethod registry-query ((reg artifact-registry)
                           (key (eql 'categorized))
                           &key category)
  (let ((ids (@ (registry-indices reg) 'categorized category)))
    (mapcar (op (@ (registry-store reg) _)) ids)))

(registry-add-index *registry* 'atom-feed)
(defmethod registry-query ((reg artifact-registry)
                           (key (eql 'atom-feed))
                           &key feed)
  nil)

(registry-add-index *registry* 'listing)
(defmethod registry-query ((reg artifact-registry)
                           (key (eql 'listing))
                           &key type name)
  (make-blog-post-listing-page))

;; TODO populate these
(registry-add-index *registry* 'adventure)

;; ---

(defparameter *pages* (dict)
  "Independent pages by slug.")

(defparameter *atom-feeds* (dict)
  "Hashtable of atom feeds by name.")

(defun link-artifact (&rest query)
  "Embed artifact found in *REGISTRY* as LINK."
  (let ((artifact (apply #'registry-query *registry* query)))
    (if artifact
        (embed-artifact-as artifact 'link)
        (warn "Failed to find artifact [query=~a]" query))))

(defun plump-minify (node)
  (typecase node
    (plump:text-node
     (setf (plump:text node) (cl-ppcre:regex-replace-all "(^\\s+)|(\\s+$)" (plump:text node) " ")))
    (plump:element
     (unless (string-equal "pre" (plump:tag-name node))
       (loop for child across (plump:children node)
             do (plump-minify child))))
    (plump:nesting-node
     (loop for child across (plump:children node)
           do (plump-minify child))))
  node)

(defun plump-smart-serialize (node)
  (plump:serialize
   (if *print-pretty*
       node
       (plump-minify node))
   nil))
