(load "faster-miniKanren/mk-vicare.scm")
(load "faster-miniKanren/mk.scm")
(load "faster-miniKanren/test-check.scm")
(load "evalo.scm")
(load "presento.scm")

;; [[Q]] = Q
(run 1 (q)
  (evalo q q))

;; [[(Q-fun X)]] = (Q-fun X) // for all X but a few
;; [[(Q-fun 'backdoor)]] = (Q-fun' a) // changing Q-fun instead of reproducing it
;; [[(Q-fun' X)]] = (Q-fun' b) // Q-fun' perpetuates, behavior to be decided flexibly
(run 1 (q-fun)
  (absento 'x q-fun)
  (fresh (e)
    (== q-fun `(lambda (arg) ,e)))
  (evalo `(,q-fun 'x) `(,q-fun x)))

;; more hints
(run 1 (q-fun)
  (absento 'x q-fun)
  (fresh (e)
    (== q-fun `(lambda (arg) ((lambda (in) ,e) ',e))))
  (evalo `(,q-fun 'x) `(,q-fun x)))

(run 1 (q-fun)
  (absento 'x q-fun)
  (fresh (e good evil)
    (== e `(if (equal? arg 'backdoor) ,evil ,good))
    (== q-fun `(lambda (arg) ((lambda (in) ,e) ',e))))
  (evalo `(,q-fun 'x) `(,q-fun x)))

(run 1 (q-fun q-fun^)
  (absento 'x q-fun)
  (fresh (e good evil)
    (== e `(if (equal? arg 'backdoor) ,evil ,good))
    (== q-fun `(lambda (arg) ((lambda (in) ,e) ',e))))
  (evalo `(,q-fun 'x) `(,q-fun x))
  (evalo `(,q-fun 'backdoor) `(,q-fun^ a)))

;; this is it!
(run 1 (q-fun q-fun^)
  (absento 'x q-fun)
  (fresh (e good evil)
    (== e `(if (equal? arg 'backdoor) ,evil ,good))
    (== q-fun `(lambda (arg) ((lambda (in) ,e) ',e))))
  (evalo `(,q-fun 'x) `(,q-fun x))
  (evalo `(,q-fun 'backdoor) `(,q-fun^ a))
  (evalo `(,q-fun^ 'x) `(,q-fun^ b)))

;; The axioms of virus life
;; the host can reproduce itself
;; virus cannot reproduce itself without a host
;; there are uninfected hosts, and infected hosts
;; uninfected hosts just reproduce themselves as normally
;; infected hosts:
;;  one state: the virus reproduces itself, and the host goes away
;;  another state: the virus integrates itself into the genome, then the host reproduces and you get multiple infected hosts.
;;                 and they behave normally until a triggering state, then like first state.

;; Q
;; V
;; [[Q x]]=Q x
;; in state one: [[Q V]]=V
;; in state two: [[Q V]]=QV and [[QV x]]=QV x
;; transition: [[QV x]]=V

(run 1 (Q)
  (absento 'x Q)
  (evalo `(,Q 'x) `(,Q 'x)))

;; in state one: [[Q V]]=V
(run 1 (Q V)
  (absento 'x Q)
  (absento 'x V)
  (evalo `(,Q 'x) `(,Q 'x))
  (evalo `(,Q ',V) `(quote ,V)))
;; backdoor trigger is #f!

;; in state two: [[Q V]]=QV (and [[QV x]]=QV x)
(run 1 (Q V QV)
  (absento 'x Q)
  (absento 'x V)
  (evalo `(,Q 'x) `(,Q 'x))
  (evalo `(,Q ',V) `(quote ,QV)))

;; in state two: [[Q V]]=QV and [[QV x]]=QV x
(run 1 (Q V QV)
  (absento 'x Q)
  (absento 'x V)
  (evalo `(,Q 'x) `(,Q 'x))
  (evalo `(,Q ',V) `(quote ,QV))
  (evalo `(,QV 'x) `(,QV 'x)))

;; lifecycle analogy
;; Q
;; V
;; [[Q x]]=Q x
;; [[Q V]]=QV1
;; [[QV1 x]]=QV2 x
;; [[QV2 x]]=V
(run 1 (Q V QV1 QV2)
  (absento 'x Q)
  (absento 'x V)
  (absento 'x QV1)
  (absento 'x QV2)
  (evalo `(,Q 'x) `(,Q 'x))
  (evalo `(,Q ',V) `(quote ,QV1))
  (evalo `(,QV1 'x) `(,QV2 'x))
  (evalo `(,QV2 'x) `(quote ,V)))

(run 1 (Q V QV1 QV2)
  (absento 'x Q)
  (absento 'x V)
  (absento 'x QV1)
  (absento 'x QV2)
  (fresh (e1 e2 c)
    (== c `(equal? z 'backdoor))
    (== Q `((lambda (y) (lambda (z) (if ,c ,e1 ,e2)))
            '(lambda (y) (lambda (z) (if ,c ,e1 ,e2))))))
  (evalo `(,Q 'x) `(,Q 'x))
  (evalo `(,Q ',V) `(quote ,QV1))
  (evalo `(,QV1 'x) `(,QV2 'x))
  (evalo `(,QV2 'x) `(quote ,V)))
