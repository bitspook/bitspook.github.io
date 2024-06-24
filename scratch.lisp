(ql:quickload '(:in.bitspook.website))

(in-package #:in.bitspook.website)

(defparameter *rpc-server* (start-rpc-server 1337))
;; (stop-rpc-server *rpc-server*)

;; expensive operations
(load-local-content *registry*)
(load-denotes *registry*)
(load-listing-pages *registry*)
;; end expensive operations

(defun build ()
  (let* ((site-title *site-title*)
         (www (path-join *base-dir* "bubu/"))
         (static (path-join *base-dir* "src/static/"))
         (*print-pretty* nil)
         (blog-post-pages (remove-if-not (op (eq (class-name-of _) 'blog-post-page))
                                         (hash-table-values (registry-store *registry*))))
         (published-posts (remove-if (op (find "draft" (post-tags _) :test #'equal)) blog-post-pages)))

    (uiop:delete-directory-tree www :validate t :if-does-not-exist :ignore)

    (publish-static :content static :dest-dir www)

    ;; TODO remove draft and micro posts
    ;; TODO add projects
    ;; TODO add atom-feeds for every listing

    ;; Publish home-page and all its dependencies
    (let ((*already-published-artifacts* nil)
          (home (load-home-page
                 *registry*
                 :blog-posts published-posts
                 :site-title site-title)))
      (handler-bind ((file-already-exists #'skip-existing))
        ;; (publish-artifact
        ;;  (make-adventure-page deutsch-adventure :location "/adventures/" :author *author*)
        ;;  www)
        (publish-artifact home www)))

    t))

;; quick hack to auto-build
;; elisp
;; (defun build-website (successp notes buffer loadp)
;;   (sly-eval '(in.bitspook.website::build)))
;; (add-hook 'sly-compilation-finished-hook #'build-website)
