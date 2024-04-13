(load-file (expand-file-name "./org-file.el" (file-name-directory load-file-name)))

(defun main (&rest tags)
  "Provide all denotes which have all TAGS."
  (let ((files (cl-remove-if-not
                (lambda (fname)
                  (cl-subsetp tags (denote-extract-keywords-from-path fname) :test #'equal))
                (denote-all-files))))
    (cl-dolist (file files)
      (clown-rpc-send :event (clown-org-file-to-msg file)))

    (clown-rpc-send :done nil)))

;;; denote.el ends here
;; Local Variables:
;; read-symbol-shorthands: (("clown" . "cl-ownpress-"))
;; End:
