(in-package #:in.bitspook.website)

(defclass blog-post-page (html-page-artifact blog-post) nil)

(defmethod from ((post blog-post) (to (eql 'html-page-artifact)) &key location (css-location "/css/post.css"))
  (let* ((html-path (base-path-join location "/" (post-category post) "/" (post-slug post) "/index.html"))
         (root-widget (make 'blog-post-w :post post))
         (css-art (make 'css-file-artifact :location css-location :root-widget root-widget)))
    (setf (slot-value root-widget 'css-file-artifact) css-art)
    (make 'blog-post-page
          ;; blog-post
          :id (post-id post)
          :title (post-title post)
          :slug (post-slug post)
          :summary-dom (post-summary-dom post)
          :category (post-category post)
          :tags (post-tags post)
          :created-at (post-created-at post)
          :published-at (post-published-at post)
          :updated-at (post-updated-at post)
          :body-dom (post-body-dom post)
          :author (post-author post)

          ;; html-page-artifact
          :location html-path
          :root-widget root-widget
          :deps (list css-art))))

(defmethod artifact-tags ((obj blog-post-page))
  (post-tags obj))
