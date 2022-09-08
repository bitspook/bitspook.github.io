(in-package :cl-user)

(ql:quickload "cl-ownpress")

(clown-slick:*conf*)

(let ((clown-slick:*conf*
        `((:author . "Charanjit Singh")
          (:avatar . "/images/avatar.png")
          (:twitter . "https://twitter.com/bitspook")
          (:linkedin . "https://linked.com/in/bitspook")
          (:github . "https://github.com/bitspook")
          (:handle . "bitspook")
          (:resume . "https://docs.google.com/document/d/1HFOxl97RGtuhAX95AhGWwa808SO9qSCYLjP1Pm39la0/")
          (:dest . "./_site")
          (:static-dir . "./static/"))))
  (clown-slick:build))
