(ql:quickload '(:in.bitspook.website))

(in-package #:in.bitspook.website)

(toggle-pretty-print-hash-table)

(defparameter *rpc-server* (start-rpc-server 1337))
;; (stop-rpc-server *rpc-server*)

(load-all-content)

(defun rebuild (env)
  (let ((*build-env* env))
    ;; (load-projects)
    (load-listing-pages)
    (build)))

(rebuild 'prod)
;; quick hack to auto-build
;; elisp
;; (defun build-website (successp notes buffer loadp)
;;   (sly-eval '(in.bitspook.website::build)))
;; (add-hook 'sly-compilation-finished-hook #'build-website)
