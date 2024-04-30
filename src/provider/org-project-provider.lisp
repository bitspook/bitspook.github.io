(in-package #:in.bitspook.website)

(defclass org-project-provider (org-file-provider)
  ((script :initform (asdf:system-relative-pathname
                      :in.bitspook.website "src/elisp/org-project-file.el"))))

(defmethod from ((obj org-file) (to (eql 'software-project)) &key author)
  (with-accessors ((id org-file-id)
                   (metadata org-file-metadata)
                   (body org-file-body-html))
      obj
    (make 'software-project
          :name (@ metadata "title")
          :slug (@ metadata "slug")
          :description (@ metadata "description_html")
          :tagline (@ metadata "tagline")
          :issue-tracker (@ metadata "issue-tracker")
          :source-code (@ metadata "source-code")
          :tags (@ metadata "tags")
          :languages (@ metadata "languages")
          :created-at (local-time:parse-timestring (@ metadata "date") :date-time-separator #\Space)
          :updated-at (local-time:parse-timestring (@ metadata "updated_at") :date-time-separator #\Space)
          :body body
          :author (or author (make 'persona :name "Unknown")))))
