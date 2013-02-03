;; -*- Mode: scheme; -*-
(define-module (aspell aspell)
  #:export (
	    aspell-add-word
	    aspell-correct?
	    aspell-new-speller
	    aspell-set-lang
	    aspell-speller?
	    aspell-store-replacement
	    aspell-word
))

(load-extension "libguile_aspell" "gu_aspell_init")

