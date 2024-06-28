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

(defun publish-artifact-p (artifact)
  "Can this artifact be published?"
  (and
   (not (some (op (find _ *blacklisted-tags* :test #'equal))
              (artifact-tags artifact)))

   (not (let ((loc (namestring (artifact-location artifact))))
          (and (string-contains-p "/tags/" loc)
               (some (op (string-contains-p _ loc))
                     *unpublished-tags*))))))
