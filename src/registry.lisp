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

;; Projects
(defmethod registry-on-index-artifact ((reg artifact-registry)
                                       (post software-project-page)
                                       (idx (eql 'categorized)) &key)
  (call-next-method reg post idx :keys '("projects")))

;; Query an Atom feed
(defmethod registry-query ((reg artifact-registry)
                           (key (eql 'atom-feed))
                           &key type name)
  (let* ((listing-id (str:downcase
                      (format nil "feed-~a-~a" type name))))
    (registry-query reg listing-id)))

;; Query a listing page
(defmethod registry-query ((reg artifact-registry)
                           (key (eql 'listing))
                           &key type name)
  (let* ((listing-id (str:downcase (format nil "listing-~a-~a" type name))))
    (registry-query reg listing-id)))

;; Query adventures
(registry-add-index *registry* 'adventure)
(defmethod registry-on-index-artifact ((reg artifact-registry)
                                       (adv adventure-page)
                                       (idx (eql 'adventure)) &key)
  (call-next-method reg adv idx :keys '("all")))

(defmethod registry-query ((reg artifact-registry)
                           (key (eql 'adventure)) &key)
  (let ((adventure-ids (@ (registry-indices reg) 'adventure "all")))
    (mapcar (op (@ (registry-store reg) _))
            adventure-ids)))

(registry-query *registry* 'adventure)
