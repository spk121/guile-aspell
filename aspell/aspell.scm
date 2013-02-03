;; -*- Mode: scheme; -*-

;; Copyright 2009, 2013 Michael L Gran

;; This file is part of guile-aspell.

;; guile-aspell is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; guile-aspell is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with guile-aspell.  If not, see <http://www.gnu.org/licenses/>.

(define-module (aspell)
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

(use-modules (ice-9 optargs))

(define (aspell-speller? sci)
  "Return #t if `x' is a spellcheck instance, #f otherwise."
  (%aspell-speller? sci))

(define (aspell-new-speller)
  "Create a new spellcheck instance and returns it.  Typically a new spellcheck
instance is used for each \"document\"."
  (%aspell-new-speller))

(define (aspell-set-lang lang)
  "Sets the default language for new spellcheck instances.  Takes a string like \"en_US\"
or \"es_MX\".  It also resets the language for the default spellcheck instance."
  (%aspell-set-lang lang))

(define* (aspell-word word #:optional sci)
  "Returns a list of suggestions for the given word.  Optionally a spellcheck
instance can be included, and the suggestion will come from that instance."
  (if sci
      (%aspell-word word sci)
      (%aspell-word word)))

(define* (aspell-correct? word #:optional sci)
  "Returns #t if the word appears in the dictionary.  Optionally, a spellcheck
instance can be included, and the suggestion will come from that instance."
  (if sci
      (%aspell-correct? word sci)
      (%aspell-correct? word)))

(define* (aspell-add-word word #:optional sci)
  "Add the word to the dictionary.  Optionally, a spellcheck instance can be
included, and the word will be added to that instance."
  (if sci
      (%aspell-add-word word sci)
      (%aspell-add-word word)))
      

(define* (aspell-store-replacement misspelled correct #:optional sci)
  "Store a new suggestion for a misspelled word.  Takes a misspelled word
and the corrected version.  Optionally, a spellcheck instance can be included,
and the suggestion will be added to that instance."
  (if sci
      (%aspell-store-replacement misspelled correct sci)
      (%aspell-store-replacement misspelled correct)))
      
