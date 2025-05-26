(defpackage in.bitspook.website
  (:use #:cl #:serapeum/bundle)
  (:import-from #:trivia :match)
  (:import-from #:slug :slugify)
  (:import-from #:spinneret :with-html)
  (:import-from #:in.bitspook.cl-ownpress
   :start-rpc-server :stop-rpc-server
   :artifact :css-file-artifact :html-page-artifact :artifact-deps
   :make-font-artifact :embed-artifact-as :link :make-html-page-artifact
   :emacs-provider :script :provide-all :publish-static
   :publish-artifact :font-face :*base-url* :skip-existing
   :file-already-exists :*already-published-artifacts*
   :already-published-p :artifact-location
   :artifact-id :artifact-registry
   :registry-indices :registry-on-index-artifact
   :registry-add-artifact :registry-add-index
   :registry-query :registry-store)
  (:import-from #:in.bitspook.web-components
   :tagged-lass :defcomponent :render)
  (:local-nicknames
   (:feeder #:org.shirakumo.feeder) ;; entry feed link serialize-feed
   (:clown #:in.bitspook.cl-ownpress)))

(in-package #:in.bitspook.website)

(defparameter *fonts-dir*
  (asdf:system-relative-pathname "in.bitspook.website" "src/fonts/"))

;; (defparameter *base-url* "https://bitspook.in")
(defparameter *base-url* "")

(defparameter *build-env* 'prod
  "Possible values: `dev' `prod' `preview'")

(defparameter *base-dir* (asdf:system-relative-pathname :in.bitspook.website ""))
(defparameter *build-dir* (path-join *base-dir* "docs/"))

(defparameter *site-title* "@bitspook's personal website")

(defgeneric artifact-tags (artifact)
  (:method ((artifact artifact)) nil))

(defmethod embed-artifact-as ((artifact html-page-artifact) (as (eql 'link)) &key)
  (call-next-method artifact 'link))

(defun build ()
  "Build the complete website for *BUILD-ENV*"
  (let* ((www *build-dir*)
         (static (path-join *base-dir* "src/static/"))
         (*print-pretty* t)
         (*base-url* (if (eq *build-env* 'prod)
                         "https://bitspook.in"
                         "")))

    (uiop:delete-directory-tree www :validate t :if-does-not-exist :ignore)

    (publish-static :content static :dest-dir www)

    (load-home-page)

    ;; Publish home-page and all its dependencies
    (let ((*already-published-artifacts* nil)
          (home (registry-query *registry* "home")))
      (handler-bind ((file-already-exists #'skip-existing))
        (publish-artifact home www)))

    t))
