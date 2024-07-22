(in-package #:in.bitspook.website)

(defclass journey-provider (denote-provider) nil)

(defmethod provide-all ((prov journey-provider) &rest script-args)
  (multiple-value-bind (raw-journeys deps) (apply #'call-next-method prov script-args)
    (let ((journeys nil))
      (dolist (raw-journey raw-journeys)
        (when-let* ((journey (from raw-journey 'journey))
                    (notebook (@ (note-metadata raw-journey) "notebook"))
                    (notebook-tags (read-from-string notebook)))
          (unless (emptyp notebook-tags)
            (multiple-value-bind (notes note-deps) (call-next-method prov :tags notebook-tags)
              (setf deps (safe-union deps notes note-deps))
              (setf (journey-note-ids journey) (mapcar #'artifact-id notes))))
          (push journey journeys)))

      (values journeys deps))))
