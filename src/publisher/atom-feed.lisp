(in-package #:in.bitspook.website)

(defmethod from ((post blog-post) (to (eql 'entry)) &key base-url)
  (with-accessors ((category post-category)
                   (slug post-slug)
                   (author post-author)
                   (published-at post-published-at)
                   (updated-at post-updated-at)
                   (summary post-summary)
                   (title post-title)
                   (body post-body))
      post
    (let* ((title (concatenate 'simple-string title))
           (link (make 'link :url (str:concat base-url (published-path post))
                             :title title)))
      (make 'entry
            :id link
            :categories (list category)
            :authors (list (slot-value author 'name))
            :published-on published-at
            :updated-on updated-at
            :link link
            :title title
            :summary (concatenate 'simple-string summary)
            :content (plump:parse body)))))

(defclass feed-publisher (blog-post-listing-publisher) nil)

(defmethod published-path ((pub feed-publisher) &key (feed-file-name "feed.xml"))
  (str:concat (call-next-method pub) feed-file-name))

(defmethod publish ((pub feed-publisher)
                    &key posts author title feed-file-name
                      (summary "") (feed-format 'org.shirakumo.feeder:atom))
  "Create an RSS feed in FEED-FORMAT for POSTS."
  (let* ((base-url (slot-value pub 'base-url))
         (link (make 'link :url (str:concat base-url (published-path pub :feed-file-name feed-file-name))
                           :relation "self" :title title))
         (entries (mapcar (op (from _ 'entry :base-url base-url)) posts))
         (plump:*tag-dispatchers* plump:*xml-tags*)
         (feed-dom (serialize-feed
                    (make 'feed
                          :id link
                          :logo (str:concat base-url "/images/avatar.png")
                          :authors (list (slot-value author 'name))
                          :published-on (local-time:now)
                          :link link
                          :title (str:concat title " - " (nth-value 2 (quri:parse-uri base-url)))
                          :summary summary
                          :content entries)
                    feed-format)))
    (str:to-file
     (base-path-join (publisher-dest pub) (published-path pub :feed-file-name feed-file-name))
     (with-output-to-string (str)
       (plump:make-element (plump:first-element feed-dom)
           "base" :attributes (dict "href" base-url))
       (plump:serialize feed-dom str)))))
