(in-package #:in.bitspook.website)

(defgeneric from (obj to &key)
  (:documentation "Convert OBJ object to instance of class represented symbol TO"))

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
   (if *print-pretty* node (plump-minify node))
   nil))

(defun link-artifact (&rest query)
  "Embed artifact found in *REGISTRY* as LINK."
  (let ((artifact (apply #'registry-query *registry* query)))
    (if artifact
        (embed-artifact-as artifact 'link)
        (warn "Failed to find artifact [query=~a]" query))))

(defun draft-p (artifact)
  (not (some (op (find _ *blacklisted-tags* :test #'equal))
             (artifact-tags artifact))))

(defun remove-drafts (artifacts)
  (remove-if (op (draft-p _1)) artifacts))

(defun get-sorted-posts (artifacts)
  (sort (remove-if-not (op (and (eq (class-name-of _1) 'blog-post-page)
                                (publish-artifact-p _1)))
                       artifacts)
        (lambda (a b)
          (local-time:timestamp>
           (post-published-at a) (post-published-at b)))))

(defun safe-union (&rest lists)
  "Like UNION, but doesn't soil its pants if number of LISTS is not exactly 2."
  (when (null lists) (return-from safe-union nil))

  (when (eq 1 (length lists)) (return-from safe-union (first lists)))

  (reduce #'union lists))
