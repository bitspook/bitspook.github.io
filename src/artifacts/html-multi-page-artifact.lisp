(in-package #:in.bitspook.website)

(defclass html-multi-page-artifact (html-page-artifact) nil)

(defmethod from ((project software-project) (to (eql 'html-page-artifact))
                 &key location (css-location "/css/software-project.css"))
  (with-slots (slug name description tagline issue-tracker source-code tags languages created-at updated-at body author) project
    (let* ((html-path (base-path-join location "/" slug "/index.html"))
           (entry-page (make 'software-project-fragment-w :project project :body body))
           (css-art (make 'css-file-artifact :location css-location :root-component entry-page))
           (child-pages (mapcar
                         (op (make-html-page-artifact :location (base-path-join location "/" slug "/child" "/index.html")
                                                      :css-location css-location
                                                      :root-component (make 'software-project-fragment-w :project project :body _)))
                         '("<h1>CHild 1</h1>" "<h2>Child 2</h2>" "<h3>Child 3</h3>"))))
      (setf (slot-value entry-page 'css-file-artifact) css-art)
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
            :root-component entry-page
            :deps (append child-pages (list css-art))))))
