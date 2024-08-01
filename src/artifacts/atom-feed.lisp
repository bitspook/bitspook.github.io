(in-package #:in.bitspook.website)

(defmethod from ((post blog-post) (to (eql 'feeder:entry)) &key)
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
           (link (make 'feeder:link :url (namestring (artifact-location post))
                                    :title title)))
      (make 'feeder:entry
            :id link
            :categories (list category)
            :authors (list (slot-value author 'name))
            :published-on published-at
            :updated-on updated-at
            :link link
            :title title
            :summary (concatenate 'simple-string summary)
            :content (plump:parse body)))))

(defmethod from ((note note) (to (eql 'feeder:entry)) &key)
  (with-accessors ((slug note-slug)
                   (author note-author)
                   (published-at note-created-at)
                   (updated-at note-updated-at)
                   (summary "")
                   (title note-title)
                   (body note-body))
      note
    (let* ((title (concatenate 'simple-string title))
           (link (make 'feeder:link :url (namestring (artifact-location note))
                                    :title title)))
      (make 'feeder:entry
            :id link
            :categories '("Note")
            :authors (list (slot-value author 'name))
            :published-on published-at
            :updated-on updated-at
            :link link
            :title title
            :summary (concatenate 'simple-string "")
            :content (plump:parse body)))))

(defclass atom-feed-artifact (artifact)
  ((location :initarg :location :accessor artifact-location)
   (title :initarg :title)
   (author :initarg :author)
   (posts :initarg :posts)
   (summary :initarg :summary)))

(defun make-atom-feed-artifact (&key posts author title location (id nil) (summary ""))
  "Create an RSS feed in FEED-FORMAT for POSTS."
  (make 'atom-feed-artifact
        :id id
        :title title
        :posts posts
        :author author
        :summary summary
        :location location))

(defmethod artifact-content ((art atom-feed-artifact))
  (with-slots (title location author posts summary) art
    (let* ((base-url *base-url*)
           (feed-format 'feeder:atom)
           (link (make 'feeder:link :url (str:concat base-url (namestring location))
                                    :relation "self" :title title))
           (entries (mapcar (op (from _ 'feeder:entry)) posts))
           (plump:*tag-dispatchers* plump:*xml-tags*)
           (feed-dom (feeder:serialize-feed
                      (make 'feeder:feed
                            :id link
                            :logo (str:concat base-url "/images/avatar.png")
                            :authors (list (slot-value author 'name))
                            :published-on (local-time:now)
                            :link link
                            :title (str:concat title " - " (nth-value 2 (quri:parse-uri base-url)))
                            :summary summary
                            :content entries)
                      feed-format)))

      (with-output-to-string (str)
        (plump:make-element (plump:first-element feed-dom)
            "base" :attributes (dict "href" base-url))
        (plump:serialize feed-dom str)))))

(defmethod publish-artifact ((art atom-feed-artifact) dest-dir)
  (when (find (artifact-location art) *already-published-artifacts*)
    (return-from publish-artifact))
  (appendf *already-published-artifacts* (list (artifact-location art)))

  (setf *already-published-artifacts*
        (concatenate 'list *already-published-artifacts* (list art)))
  (let ((content (artifact-content art)))
    (dolist (dep (artifact-deps art))
      (publish-artifact dep dest-dir))

    (publish-static
     :dest-dir dest-dir
     :content content
     :path (artifact-location art))))
