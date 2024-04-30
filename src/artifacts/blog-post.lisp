(in-package #:in.bitspook.website)

(defclass blog-post-page (html-page-artifact blog-post) nil)

(defun make-blog-post-page (post &key location (css-location "/css/post.css"))
  (let* ((html-path (base-path-join location "/" (post-slug post) "/index.html"))
         (root-widget (make 'blog-post-w :post post))
         (css-art (make 'css-file-artifact :location css-location :root-widget root-widget)))
    (setf (slot-value root-widget 'css-file-artifact) css-art)
    (make 'blog-post-page
          ;; blog-post
          :title (post-title post)
          :slug (post-slug post)
          :summary (post-summary post)
          :category (post-category post)
          :tags (post-tags post)
          :created-at (post-created-at post)
          :published-at (post-published-at post)
          :updated-at (post-updated-at post)
          :body (post-body post)
          :author (post-author post)

          ;; html-page-artifact
          :location html-path
          :root-widget root-widget
          :deps (list css-art))))


