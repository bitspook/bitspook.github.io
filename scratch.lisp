(ql:quickload '(:in.bitspook.website))

(in-package #:in.bitspook.website)

(toggle-pretty-print-hash-table)

(defparameter *rpc-server* (start-rpc-server 1337))
;; (stop-rpc-server *rpc-server*)

(load-all-content)

(defun build ()
  (let* ((www (path-join *base-dir* "build/"))
         (static (path-join *base-dir* "src/static/"))
         (*print-pretty* nil))

    (uiop:delete-directory-tree www :validate t :if-does-not-exist :ignore)

    (publish-static :content static :dest-dir www)

    ;; TODO remove draft and micro posts
    ;; TODO add projects
    ;; TODO add atom-feeds for every listing

    (load-home-page)

    ;; Publish home-page and all its dependencies
    (let ((*already-published-artifacts* nil)
          (home (registry-query *registry* "home")))
      (handler-bind ((file-already-exists #'skip-existing))
        (publish-artifact home www)))

    t))

;; quick hack to auto-build
;; elisp
;; (defun build-website (successp notes buffer loadp)
;;   (sly-eval '(in.bitspook.website::build)))
;; (add-hook 'sly-compilation-finished-hook #'build-website)
