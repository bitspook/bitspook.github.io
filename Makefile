build-dir ?= build

.PHONY: build
build:
	sbcl --load scratch.lisp

.PHONY: serve
serve:
	python3 -m http.server --directory $(build-dir)
