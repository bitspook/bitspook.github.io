(load-file (expand-file-name "./org-file.el" (file-name-directory load-file-name)))

(defvar *clown-exported-denotes* nil)

(defun clown-org-export-denote-link (link description backend)
  (let* ((path-id (denote-link--ol-resolve-link-to-target link :full-data))
         (path (file-relative-name (nth 0 path-id)))
         (id (nth 1 path-id))
         (search (nth 2 path-id))
         (anchor (file-name-sans-extension path))
         (desc (cond
                (description)
                (search (format "denote:%s::%s" id search))
                (t (concat "denote:" id)))))
    (if search
        (format "<a href=\"%s.html%s\" data-denote-id=\"%s\">%s</a>" anchor search id desc)
      (format "<a href=\"%s.html\" data-denote-id=\"%s\">%s</a>" anchor id desc))))

(org-link-set-parameters
 "denote"
 :export #'clown-org-export-denote-link)

(cl-defun main (&key tags ids)
  "Provide all denotes which have all TAGS."
  (let* ((all-files (denote--directory-get-files))
         (files-with-id (if ids (cl-remove-if-not
                                 (lambda (fname)
                                   (let ((file-id (denote-extract-id-from-string fname)))
                                     (seq-contains-p ids file-id #'equal)))
                                 all-files)
                          all-files))
         (files (if tags (cl-remove-if-not
                          (lambda (fname)
                            (cl-subsetp tags (denote-extract-keywords-from-path fname) :test #'equal))
                          files-with-id)
                  files-with-id)))
    (cl-dolist (file files)
      (clown-rpc-send :event (clown-org-file-to-msg file (denote-extract-id-from-string file))))

    (clown-rpc-send :done nil)))

;;; denote.el ends here
;; Local Variables:
;; read-symbol-shorthands: (("clown" . "cl-ownpress-"))
;; End:
