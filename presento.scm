(define presento
  (lambda (t1 t2)
    (conde
      ((== t1 t2))
      ((fresh (a d)
         (== (cons a d) t2)
         (conde
           ((presento t1 a))
           ((presento t1 d))))))))

(define present-onceo
  (lambda (t1 t2)
    (conde
      ((== t1 t2))
      ((fresh (a d)
         (== (cons a d) t2)
         (conde
           ((absento t1 d) (present-onceo t1 a))
           ((absento t1 a) (present-onceo t1 d))))))))
