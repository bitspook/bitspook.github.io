;; clown-common -- Common elisp utilities for cl-ownpress Emacs interaction
;;
;;; Commentary:
;;; These are utility functions and variables to be used in Elisp written
;;; with/for cl-ownpress.
;; 
;;; Code:

(require 'seq)
(require 'cl-lib)
(require 'org)
(require 'org-element)
(require 'jsonrpc)
(require 'htmlize)
(require 's)

(defvar clown-rpc-url "http://localhost:1337")

(defun clown-rpc-send (name body-forms)
  "Make cl-ownpress RPC request with name NAME and body BODY-FORMS."
  (plz 'post clown-rpc-url :body (json-encode `(:type ,name :payload ,body-forms))))

(defun clown-get-org-file-props (filename)
  "Get file-level org props for FILENAME."
  (with-temp-buffer
    (insert-file filename)
    (org-mode)
    (let ((props (org-element-map (org-element-parse-buffer 'greater-element)
                     '(keyword)
                   (lambda (kwd)
                     (let ((data (cadr kwd)))
                       (cons (downcase (plist-get data :key))
                             (plist-get data :value)))))))
      props)))



(provide 'clown-common)
;;; clown-common.el ends here
;; Local Variables:
;; read-symbol-shorthands: (("clown" . "cl-ownpress-"))
;; End:
