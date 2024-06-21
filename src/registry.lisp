(in-package #:in.bitspook.website)

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
  (let ((blog-posts (remove-if-not
                     (op (eq (class-name-of _) 'blog-post-page))
                     (hash-table-values (registry-store *registry*)))))
    (make-atom-feed-artifact
     :title *site-title*
     :posts (take 15 blog-posts)
     :author *author*
     :location "/archive/feed.xml")))

(defmethod registry-query ((reg artifact-registry)
                           (key (eql 'listing))
                           &key type name)
  (let ((artifacts (ecase type
                     (category (registry-query reg 'categorized :category name))
                     (tag (registry-query reg 'tagged :tag name))))
        (location (ecase type
                    (category name)
                    (tag (format nil "tags/~a" name)))))
    (make-blog-post-listing-page
     :path location
     :posts artifacts
     :author *author*
     :title (str:capitalize name))))

;; TODO populate these
(registry-add-index *registry* 'adventure)
