(load-file (expand-file-name "./org-file.el" (file-name-directory load-file-name)))

(defun main (&rest tags)
  "Provide all denotes which have all TAGS."
  (let ((conn (clown-rpc-server))
        (files (cl-remove-if-not
                (lambda (fname) (cl-subsetp tags (denote-extract-keywords-from-path fname)))
                (denote-all-files))))
    (cl-dolist (file files)
      (jsonrpc-notify conn :event (clown-org-file-to-msg file)))

    (jsonrpc-notify conn :done nil)))

;;; denote.el ends here
;; Local Variables:
;; read-symbol-shorthands: (("clown" . "cl-ownpress-"))
;; End:
