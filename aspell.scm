;; -*- Mode: scheme; -*-

;; Copyright 2009, 2013, 2016, 2017, 2021 Michael L Gran

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
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 i18n)
  #:use-module (ice-9 optargs)
  #:use-module (ice-9 format)
  #:use-module (rnrs bytevectors)
  #:use-module (system foreign)
  #:export (
	    aspell-add-word
	    aspell-correct?
	    aspell-new-speller
	    aspell-set-lang
	    aspell-speller?
	    aspell-store-replacement
	    aspell-word
))

(define (find-cygwin-dll prefix)
  (let ((dirstream (false-if-exception (opendir "/usr/bin")))
	(extension ".dll")
	(short-name (string-append prefix ".dll"))
	(hyphen-prefix (string-append prefix "-")))
    (let ((hyphen-prefix-len (string-length hyphen-prefix))
	  (extension-len (string-length extension))
	  (short-name-len (string-length short-name)))
      (if (not dirstream)
	  (error "Cannot find appropriate dll")
	  ;; else
	  (let loop ((cur (readdir dirstream)))
	    (cond
	     ((eof-object? cur)
	      ;; Could not find a versioned dll for this prefix
	      short-name)
	     ((and
	       (>= (string-length cur) short-name-len)
	       (string= cur hyphen-prefix 0 hyphen-prefix-len)
	       (string= cur extension (- (string-length cur) extension-len)))
	      ;; A likely candidate
	      cur)
	     (else (loop (readdir dirstream)))))))))

(define libaspell
  (cond
   ((string-contains %host-type "cygwin")
    ;; As of 2021-11-30, the standard Cygwin dll is /usr/bin/cygaspell-15.dll.
    (dynamic-link (find-cygwin-dll "cygaspell")))
   (else
    (dynamic-link "libaspell"))))

;; These are the special type conversions for libaspell
(define-wrapped-pointer-type AspellCanHaveError
  AspellCanHaveError?
  wrap-AspellCanHaveError unwrap-AspellCanHaveError
  (lambda (AC p)
    (format p "#<AspellCanHaveError ~x>"
	    (pointer-address (unwrap-AspellCanHaveError AC)))))

(define-wrapped-pointer-type AspellConfig
  AspellConfig?
  wrap-AspellConfig unwrap-AspellConfig
  (lambda (AC p)
    (format p "#<AspellConfig ~x>"
	    (pointer-address (unwrap-AspellConfig AC)))))

(define-wrapped-pointer-type AspellSpeller
  AspellSpeller?
  wrap-AspellSpeller unwrap-AspellSpeller
  (lambda (AS p)
    (format p "#<AspellSpeller ~x>"
	    (pointer-address (unwrap-AspellSpeller AS)))))

(define-wrapped-pointer-type AspellStringEnumeration
  AspellStringEnumeration?
  wrap-AspellStringEnumeration unwrap-AspellStringEnumeration
  (lambda (AS p)
    (format p "#<AspellStringEnumeration ~x>"
	    (pointer-address (unwrap-AspellStringEnumeration AS)))))

(define-wrapped-pointer-type AspellWordList
  AspellWordList?
  wrap-AspellWordList unwrap-AspellWordList
  (lambda (AS p)
    (format p "#<AspellWordList ~x>"
	    (pointer-address (unwrap-AspellWordList AS)))))


;; These are the libaspell functions that will be used.

;; aspell_config_error_message
;;   const char * aspell_config_error_message(const struct AspellConfig * ths);
(define %aspell-config-error-message
  (pointer->procedure '*
		      (dynamic-func "aspell_config_error_message" libaspell)
		      (list '*)))
(define (aspell-config-error-message AC)
  (pointer->string (%aspell-config-error-message (unwrap-AspellConfig AC))))

;; aspell_config_replace
;;   int aspell_config_replace(struct AspellConfig * ths, const char * key, const char * value);
(define %aspell-config-replace
  (pointer->procedure int
		      (dynamic-func "aspell_config_replace" libaspell)
		      '(* * *)))
(define (aspell-config-replace ths key value)
  (%aspell-config-replace (unwrap-AspellConfig ths)
			  (string->pointer key)
			  (string->pointer value)))

;; aspell_config_retrieve
;;   const char * aspell_config_retrieve(struct AspellConfig * ths, const char * key);
(define %aspell-config-retrieve
  (pointer->procedure '*
		      (dynamic-func "aspell_config_retrieve" libaspell)
		      '(* *)))
(define (aspell-config-retrieve ths key)
  (pointer->string
   (%aspell-config-retrieve (unwrap-AspellConfig ths)
			    (string->pointer key))))

;; aspell_error_message
;;   const char * aspell_error_message(const struct AspellCanHaveError * ths);
(define %aspell-error-message
  (pointer->procedure '*
		      (dynamic-func "aspell_error_message" libaspell)
		      (list '*)))
(define (aspell-error-message ths)
  (pointer->string
   (%aspell-error-message (unwrap-AspellCanHaveError ths))))

;; aspell_error_number
;;   unsigned int aspell_error_number(const struct AspellCanHaveError * ths);
(define %aspell-error-number
  (pointer->procedure unsigned-int
		      (dynamic-func "aspell_error_number" libaspell)
		      (list '*)))
(define (aspell-error-number ths)
  (%aspell-error-number (unwrap-AspellCanHaveError ths)))

;; aspell_speller_add_to_session
;;   int aspell_speller_add_to_session(struct AspellSpeller * ths, const char * word, int word_size);
(define %aspell-speller-add-to-session
  (pointer->procedure int
		      (dynamic-func "aspell_speller_add_to_session" libaspell)
		      (list '* '* int)))
(define (aspell-speller-add-to-session ths word)
  (let* ([word-bytevector (string->bytevector word (locale-encoding))]
	 [word-len (bytevector-length word-bytevector)])
    (%aspell-speller-add-to-session (unwrap-AspellSpeller ths)
				    (bytevector->pointer word-bytevector)
				    word-len)))

;; aspell_speller_check
;;   int aspell_speller_check(struct AspellSpeller * ths, const char * word, int word_size);
(define %aspell-speller-check
  (pointer->procedure int
		      (dynamic-func "aspell_speller_check" libaspell)
		      (list '* '* int)))
(define (aspell-speller-check ths word)
  (let* ([word-bytevector (string->bytevector word (locale-encoding))]
	 [word-len (bytevector-length word-bytevector)])
    (%aspell-speller-check (unwrap-AspellSpeller ths)
			   (bytevector->pointer word-bytevector)
			   word-len)))

;; aspell_speller_error_message
;;   const char * aspell_speller_error_message(const struct AspellSpeller * ths);
(define %aspell-speller-error-message
  (pointer->procedure '*
		      (dynamic-func "aspell_speller_error_message" libaspell)
		      (list '*)))
(define (aspell-speller-error-message ths)
  (pointer->string
   (%aspell-speller-error-message (unwrap-AspellSpeller ths))))

;; aspell_speller_store_replacement
;;   int aspell_speller_store_replacement(struct AspellSpeller * ths, const char * mis, int mis_size, const char * cor, int cor_size);
(define %aspell-speller-store-replacement
  (pointer->procedure int
		      (dynamic-func "aspell_speller_store_replacement" libaspell)
		      (list '* '* int '* int)))
(define (aspell-speller-store-replacement ths mistake correction)
  (let* ([mistake-bytevector (string->bytevector mistake (locale-encoding))]
	 [mistake-len (bytevector-length mistake-bytevector)]
	 [correction-bytevector (string->bytevector correction (locale-encoding))]
	 [correction-len (bytevector-length correction-bytevector)])
    (%aspell-speller-store-replacement (unwrap-AspellSpeller ths)
				       (bytevector->pointer mistake-bytevector)
				       mistake-len
				       (bytevector->pointer correction-bytevector)
				       correction-len)))

;; aspell_speller_suggest
;;   const struct AspellWordList * aspell_speller_suggest(struct AspellSpeller * ths, const char * word, int word_size);
(define %aspell-speller-suggest
  (pointer->procedure '*
		      (dynamic-func "aspell_speller_suggest" libaspell)
		      (list '* '* int)))
(define (aspell-speller-suggest ths word)
  (let* ([word-bytevector (string->bytevector word (locale-encoding))]
	 [word-len (bytevector-length word-bytevector)])
    (wrap-AspellWordList
     (%aspell-speller-suggest (unwrap-AspellSpeller ths)
			      (bytevector->pointer word-bytevector)
			      word-len))))

;; aspell_string_enumeration_next
;;   const char * aspell_string_enumeration_next(struct AspellStringEnumeration * ths);
(define %aspell-string-enumeration-next
  (pointer->procedure '*
		      (dynamic-func "aspell_string_enumeration_next" libaspell)
		      (list '*)))
(define (aspell-string-enumeration-next ths)
  (let ([ret (%aspell-string-enumeration-next (unwrap-AspellStringEnumeration ths))])
    (if (null-pointer? ret)
	""
	(pointer->string ret))))

;; aspell_word_list_elements
;;   struct AspellStringEnumeration * aspell_word_list_elements(const struct AspellWordList * ths);
(define %aspell-word-list-elements
  (pointer->procedure '*
		      (dynamic-func "aspell_word_list_elements" libaspell)
		      (list '*)))
(define (aspell-word-list-elements ths)
  (wrap-AspellStringEnumeration
   (%aspell-word-list-elements (unwrap-AspellWordList ths))))

;; delete_aspell_config
;;   void delete_aspell_config(struct AspellConfig * ths);
(define %delete-aspell-config
  (pointer->procedure void
		      (dynamic-func "delete_aspell_config" libaspell)
		      (list '*)))
(define (delete-aspell-config ths)
  (%delete-aspell-config (unwrap-AspellConfig ths)))

;; delete_aspell_speller
;;   void delete_aspell_speller(struct AspellSpeller * ths);
(define %delete-aspell-speller
  (pointer->procedure void
		      (dynamic-func "delete_aspell_speller" libaspell)
		      (list '*)))
(define (delete-aspell-speller ths)
  (%delete-aspell-speller (unwrap-AspellSpeller ths)))

;; delete_aspell_string_enumeration
;;   void delete_aspell_string_enumeration(struct AspellStringEnumeration * ths);
(define %delete-aspell-string-enumeration
  (pointer->procedure void
		      (dynamic-func "delete_aspell_string_enumeration" libaspell)
		      (list '*)))
(define (delete-aspell-string-enumeration ths)
  (%delete-aspell-string-enumeration (unwrap-AspellStringEnumeration ths)))

;; new_aspell_speller
;;   struct AspellCanHaveError * new_aspell_speller(struct AspellConfig * config);
(define %new-aspell-speller
  (pointer->procedure '*
		      (dynamic-func "new_aspell_speller" libaspell)
		      (list '*)))
(define (new-aspell-speller config)
  (wrap-AspellCanHaveError
   (%new-aspell-speller (unwrap-AspellConfig config))))

;; to_aspell_speller
;;   struct AspellSpeller * to_aspell_speller(struct AspellCanHaveError * obj);
(define %to-aspell-speller
  (pointer->procedure '*
		      (dynamic-func "to_aspell_speller" libaspell)
		      (list '*)))
(define (to-aspell-speller obj)
  (wrap-AspellSpeller
   (%to-aspell-speller (unwrap-AspellCanHaveError obj))))

;; new_aspell_config
;;  struct AspellConfig * new_aspell_config()
(define %new-aspell-config
  (pointer->procedure '*
		      (dynamic-func "new_aspell_config" libaspell)
		      (list)))
(define (new-aspell-config)
  (wrap-AspellConfig (%new-aspell-config)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define *spell-config* (new-aspell-config))

(define (aspell-speller? sci)
  "Return #t if `x' is a spellcheck instance, #f otherwise."
  (AspellSpeller? sci))

(define (aspell-new-speller)
  "Create a new spellcheck instance and returns it.  Typically a new spellcheck
instance is used for each \"document\"."
  (let ([possible-err (new-aspell-speller *spell-config*)])
    (if (not (= 0 (aspell-error-number possible-err)))
	(error (aspell-error-message possible-err))
	;; else
	(to-aspell-speller possible-err))))

(define *default-speller* (aspell-new-speller))

(define (aspell-set-lang lang)
  "Sets the default language for new spellcheck instances.  Takes a string like \"en_US\"
or \"es_MX\".  It also resets the language for the default spellcheck instance."
  (let ([orig-lang (aspell-config-retrieve *spell-config* "lang")])
    (if (string=? lang orig-lang)
	#t
	;; else
	(let ([ret (aspell-config-replace *spell-config* "lang" lang)])
	  (if (= 0 ret)
	      (error (aspell-config-error-message *spell-config*))
	      ;; else
	      ;; Because we're changing languages, reboot the speller.
	      (let ([possible-err (new-aspell-speller *spell-config*)])
		(if (not (= 0 (aspell-error-number possible-err)))
		    (error (aspell-error-message possible-err))
		    ;; else
		    (begin
		      (delete-aspell-speller *default-speller*)
		      (set! *default-speller* (to-aspell-speller possible-err))
		      #t))))))))

(define* (aspell-word word #:optional (sci *default-speller*))
  "Returns a list of suggestions for the given word.  Optionally a spellcheck
instance can be included, and the suggestion will come from that instance."
  (let* ([suggestions (aspell-speller-suggest sci word)]
	 [elements (aspell-word-list-elements suggestions)])
    (let loop ([word2 (aspell-string-enumeration-next elements)]
	       [lst '()])
      (if (string-null? word2)
	  (begin
	    (delete-aspell-string-enumeration elements)
	    lst)
	  ;; else
	  (loop (aspell-string-enumeration-next elements)
		(append lst (list word2)))))))

(define* (aspell-correct? word #:optional (sci *default-speller*))
  "Returns #t if the word appears in the dictionary.  Optionally, a spellcheck
instance can be included, and the suggestion will come from that instance."
  (let ([correct (aspell-speller-check sci word)])
    (if (= 0 correct)
	#f
	#t)))

(define* (aspell-add-word word #:optional (sci *default-speller*))
  "Add the word to the dictionary.  Optionally, a spellcheck instance can be
included, and the word will be added to that instance."
  (let ([ret (aspell-speller-add-to-session sci word)])
    (if (= 0 ret)
	(error (aspell-speller-error-message sci))
	#t)))

(define* (aspell-store-replacement misspelled correct #:optional (sci *default-speller*))
  "Store a new suggestion for a misspelled word.  Takes a misspelled word
and the corrected version.  Optionally, a spellcheck instance can be included,
and the suggestion will be added to that instance."
  (aspell-speller-store-replacement sci misspelled correct)
  *unspecified*)
