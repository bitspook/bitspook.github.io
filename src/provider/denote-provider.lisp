(in-package #:in.bitspook.website)

(defclass denote-provider (org-file-provider)
  ((script :initform (asdf:system-relative-pathname
                      :in.bitspook.website "src/elisp/denote.el"))
   (store :initform (dict)
          :accessor denote-store)))

(defmethod provide-all ((prov denote-provider) &rest script-args)
  (let* ((files (apply #'call-next-method prov script-args))
         (notes (mapcar (op (from _ 'note :author *author*)) files)))

    (dolist (note notes)
      (setf (@ (denote-store prov) (note-id note)) note))

    (values notes
            (reduce #'union (mapcar (op (provide-linked-denotes prov _)) notes)))))

(defmethod provide-linked-denotes ((prov denote-provider) (note note))
  "Use PROV to provide all denotes linked from NOTE. STORE is a hashmap which stores notes found so
far. STORE is needed to resolve circular dependencies of denotes."
  (let* ((linked-denote-ids (linked-denote-ids (note-body-dom note)))
         (missing-linked-ids (remove-if
                              (op (@ (denote-store prov) _))
                              linked-denote-ids)))

    (unless (emptyp missing-linked-ids)
      (provide-all prov :ids missing-linked-ids))

    (mapcar (op (@ (denote-store prov) _)) linked-denote-ids)))
