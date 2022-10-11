;; scratch-pad I used to create my initial projects listing. Might come in handy later

(defparameter repos
  (@ (yason:parse
      (uiop:run-program
       "gh api graphql --paginate -f query='
query {
  viewer {
    repositories(first: 100) {
      nodes {
        name
        description
        openGraphImageUrl
        isFork
        isPrivate
        isArchived
        languages(first: 100) { nodes { id color name } }
        url
        stargazerCount
        pushedAt
        createdAt
        updatedAt
      }
    }
  }
}
    '"
       :output :string
       :error-output *standard-output*))
     "data" "viewer" "repositories" "nodes"))

(defun repo-to-orgmode-str (repo)
  (format nil "~
#+TITLE: ~a
#+URL: ~a
#+LANGUAGES: ~{~a, ~}
#+CREATED_AT: ~a
#+PUSHED_AT: ~a
#+IS_FORK: ~a
#+STARS: ~a

#+BEGIN_EXPORT html
<img src=\"~a\" alt=\"Github Card\" />
#+END_EXPORT

~a
"
          (@ repo "name")
          (@ repo "url")
          (mapcar (op (@ _ "name"))
                  (@ repo "languages" "nodes"))
          (@ repo "createdAt")
          (@ repo "pushedAt")
          (@ repo "isFork")
          (@ repo "stargazerCount")
          (@ repo "openGraphImageUrl")
          (@ repo "description")))

(defun write-repo-as-project (repo)
  (let ((str (repo-to-orgmode-str repo))
        (dest (format nil "./projects/~a.org" (@ repo "name"))))
    (ensure-directories-exist (directory-namestring dest))
    (str:to-file dest str :if-exists :overwrite)))
