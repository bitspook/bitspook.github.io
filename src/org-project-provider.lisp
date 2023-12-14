(in-package #:in.bitspook.website)

(defclass org-project-provider (org-file-provider)
  ((script :initform (asdf:system-relative-pathname
                      :in.bitspook.website "src/elisp/org-project-file.el"))))
