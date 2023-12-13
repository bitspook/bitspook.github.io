(ql:quickload '(:in.bitspook.website))

(in-package #:in.bitspook.website)

(defparameter *notes*
  (let ((notes-provider (make-instance 'denote-provider)))
    (provide-all notes-provider)))

(defun build ()
  (let* ((www #p"/tmp/www/")
         (static (asdf:system-relative-pathname :in.bitspook.website "src/static/"))
         (author (make-instance 'persona
                                :name "Charanjit Singh"
                                :handles '(("Mastodon" "bitspook" "https://infosec.exchange/@bitspook"))))
         (asset-pub (make-instance 'asset-publisher
                                   :dest www))
         (post-pub (make-instance 'blog-post-publisher
                                  :asset-pub asset-pub
                                  :dest (path-join www "blog/"))))

    (uiop:delete-directory-tree www :validate t :if-does-not-exist :ignore)
    (publish asset-pub :content static)
    (loop :for post :in (mapcar (op (from _ 'blog-post)) *notes*)
          :do (let ((root-w (make 'blog-post-w :post post)))
                (setf (post-author post) author)
                (publish post-pub :post post :layout root-w)))))

(build)

;; quick hack to auto-build
;; elisp
;; (defun build-website (successp notes buffer loadp)
;;   (sly-eval '(in.bitspook.website::build)))
;; (add-hook 'sly-compilation-finished-hook #'build-website)
