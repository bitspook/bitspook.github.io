(in-package #:in.bitspook.website)

(defclass software-project-page (html-page-artifact software-project) nil)

(defmethod from ((project software-project) (to (eql 'html-page-artifact))
                 &key location (css-location "/css/software-project.css"))
  (with-slots (slug name description tagline issue-tracker source-code tags languages created-at updated-at body author) project
    (let* ((html-path (base-path-join location "/" slug "/index.html"))
           (root-component (make 'software-project-w :project project))
           (css-art (make 'css-file-artifact :location css-location :root-component root-component)))
      (setf (slot-value root-component 'css-file-artifact) css-art)
      (make 'software-project-page
            ;; software project
            :name name
            :description description
            :tagline tagline
            :issue-tracker issue-tracker
            :source-code source-code
            :tags tags
            :languages languages
            :created-at created-at
            :updated-at updated-at
            :body body
            :author author

            ;; html-page-artifact
            :id (format nil "project-~a" name)
            :location html-path
            :root-component root-component
            :deps (list css-art)))))

(defmethod artifact-tags ((obj software-project-page))
  (project-tags obj))
