(define test-failed #f)

(define-syntax test
  (syntax-rules ()
    ((_ title tested-expression expected-result)
     (begin
       (printf "Testing ~s\n" title)
       (let* ((expected expected-result)
              (produced tested-expression))
         (or (equal? expected produced)
             (begin
               (set! test-failed #t)
               (printf "Failed: ~s~%Expected: ~s~%Computed: ~s~%"
                     'tested-expression expected produced))))))))
