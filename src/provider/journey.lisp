(in-package #:in.bitspook.website)

(defclass journey-provider (denote-provider) nil)

(defmethod provide-all ((prov journey-provider) &rest script-args)
  (format t "Journey Providing: ~a" script-args)
  (multiple-value-bind (journeys deps) (apply #'call-next-method prov script-args)
    ;; TODO Read 'notebook' from NOTE metadata, request all notes that satisfy it, and populate
    ;; (JOURNEY-NOTES) with provided notes
    ;; Perhaps we should change JOURNEY-NOTES to JOURNEY-NOTE-IDS, and make JOURNEY-NOTES a method on
    ;; JOURNEY which performs (REGISTRY-QUERY *regisry* note-id)
    (dolist (journey journeys)
      (when-let* ((notebook (@ (note-metadata journey) "notebook"))
                  (notebook-tags (read-from-string notebook)))
        (unless (emptyp notebook-tags)
          (multiple-value-bind (notes note-deps) (call-next-method prov :tags notebook-tags)
            (format t "NOTES: ~a~%" notes)
            (setf deps (safe-union deps notes note-deps))))))

    (format t "DEPS: ~a" deps)

    (values journeys deps)))

(defparameter *test-prov* (make 'journey-provider))
(defparameter *test-js* (provide-all *test-prov* :tags '("journey")))

(multiple-value-list (provide-all *test-prov* :tags '("journey")))
