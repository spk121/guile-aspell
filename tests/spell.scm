(use-modules (aspell)
             (srfi srfi-64))

(test-begin "spell")

(test-assert "set language to en_US"
  (aspell-set-lang "en_US"))

(test-assert "'aspell-word' offers multiple suggestions for 'tommorow'"
  (not (zero? (length (aspell-word "tommorow")))))

(test-assert "'aspell-correct?' believes 'tomorrow' is valid"
  (aspell-correct? "tomorrow"))

(test-end "spell")
