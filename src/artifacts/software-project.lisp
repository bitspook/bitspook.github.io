(in-package #:in.bitspook.website)

(defclass software-project-page (html-page-artifact software-project) nil)

(defun make-software-project-page (project &key location (css-location "/css/software-project.css"))
  (with-slots (slug name description tagline issue-tracker source-code tags languages created-at updated-at body author) project
    (let* ((html-path (base-path-join location "/" slug "/index.html"))
           (root-widget (make 'software-project-w :project project))
           (css-art (make 'css-file-artifact :location css-location :root-widget root-widget)))
      (setf (slot-value root-widget 'css-file-artifact) css-art)
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
            :location html-path
            :root-widget root-widget
            :deps (list css-art)))))
