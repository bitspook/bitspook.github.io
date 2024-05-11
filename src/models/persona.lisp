(in-package #:in.bitspook.website)

(defclass persona ()
  ((name :initarg :name
         :initform (error "Persona `name` is required"))
   (handles :initarg :handles
            :documentation "Social media handles of the form `(social-media-name username link)'")
   (avatar :initarg :avatar
           :documentation "Path to an persona's avatar image"))
  (:documentation "An online persona that can be embedded in blog pages."))
