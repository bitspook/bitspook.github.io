(ql:quickload '(:in.bitspook.website))

(in-package #:in.bitspook.website)

(defparameter *author*
  (make 'persona
        :name "Charanjit Singh"
        :handles '(("Mastodon" "bitspook" "https://infosec.exchange/@bitspook"))))

(defparameter *base-dir* (asdf:system-relative-pathname :in.bitspook.website ""))

(defparameter *notes*
  (let ((notes-provider (make-instance 'denote-provider)))
    (provide-all notes-provider "blog-post")))

(defparameter *local-org-files*
  (let ((org-provider (make 'org-file-provider)))
    (provide-all org-provider (path-join *base-dir* "content/"))))

(defparameter *blog-posts*
  (let* ((all-posts
           (mapcar
            (lambda (note)
              (let ((post (from note 'blog-post)))
                (setf (post-author post) *author*)
                post))
            (append *local-org-files* *notes*)))
         (no-drafts (remove-if
                     (op (find "draft" (post-tags _) :test #'equal))
                     all-posts)))
    no-drafts))

(defun build ()
  (let* ((www (path-join *base-dir* "docs/"))
         (static (path-join *base-dir* "src/static/"))
         (asset-pub (make-instance 'asset-publisher :dest www))
         (post-pub (make-instance 'blog-post-publisher
                                  :asset-pub asset-pub
                                  :dest (path-join www "blog/"))))

    (uiop:delete-directory-tree www :validate t :if-does-not-exist :ignore)
    (publish asset-pub :content static)
    (loop :for post :in *blog-posts*
          :do (let ((root-w (make 'blog-post-w :post post))) 
                (publish post-pub :post post :layout root-w)))))

(build)

;; quick hack to auto-build
;; elisp
;; (defun build-website (successp notes buffer loadp)
;;   (sly-eval '(in.bitspook.website::build)))
;; (add-hook 'sly-compilation-finished-hook #'build-website)
