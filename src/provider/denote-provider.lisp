(in-package #:in.bitspook.website)

(defclass denote-provider (org-file-provider)
  ((script :initform (asdf:system-relative-pathname
                      :in.bitspook.website "src/elisp/denote.el"))))
