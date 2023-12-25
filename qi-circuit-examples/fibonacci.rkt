#lang racket
(require data/collection)
(require qi)
(require qi/probe)
(require "../qi-circuit-lib/circuit.rkt")
(require "../qi-circuit-lib/basic-streams.rkt")
(require rackunit)

;; The generating function of Fibonacci sequence is F = X / 1 - X - X^2,
;; We can derive the equation F = X + F X + F X^2 from the generating function.

(define F (stream-cons 0 (stream-cons 1 (map + F (stream-rest F)))))

(check-equal?
 (~>> (F) (stream-take _ 20) stream->list)
 '(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181))

;; Represent F = X + F X + F X^2 as a circuit

;; Note that there are many equivalent circuits for F = X + F X + F X^2
;; For examples,
;;
;; F = (X + F X) + F X^2
;;
;; F = (X + F X^2) + F X
;;
;; F = (F X + F X^2) + X
;;
;; F = (1 + F X + F) X
;;
;; F = X + F (X + X^2)
;;
;; etc ...

;; F = (X + F X) + F X^2
(define fib1
  (~>> (one)
       (c-reg 0)
       (c-loop (~>> (== _ (c-reg 0))
                    (c-add +)
                    (c-loop (~>> (== _ (~>> (c-reg 0) (c-reg 0)))
                                 (c-add +)
                                 (-< _ _)))
                    (-< _ _)) )))

(check-equal?
 (~>> (fib1) (stream-take _ 20) stream->list)
 '(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181))

;; F = (X + F X^2) + F X
(define fib2
  (~>> (one)
       (c-reg 0)
       (c-loop (~>> (== _ (~>> (c-reg 0) (c-reg 0)))
                    (c-add +)
                    (c-loop (~>> (== _ (c-reg 0))
                                 (c-add +)
                                 (-< _ _)))
                    (-< _ _)) )))

(check-equal?
 (~>> (fib2) (stream-take _ 20) stream->list)
 '(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181))

;; F = X + F (X + X^2)
(define fib3
  (~>> (one)
       (c-reg 0)
       (c-loop (~>> (== _ (~>> (-< (c-reg 0) (~>> (c-reg 0) (c-reg 0))) (c-add +)))
                    (c-add +)
                    (-< _ _)))))

(check-equal?
 (~>> (fib3) (stream-take _ 20) stream->list)
 '(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181))

(define fib4
  (~>> (one)
       (c-reg 0)
       (c-loop (~>> (== _ (~>> (-< (c-reg 0) (~>> (c-reg 0) (c-reg 0))) ))
                    (c-add +)
                    (-< _ _)))
       ))

(check-equal?
 (~>> (fib4) (stream-take _ 20) stream->list)
 '(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181))

;; F = (F X + F X^2) + X
(define fib5
  (~>> (zero)
       (c-loop (~>> (== _ (~>> (c-reg 0)))
                    (c-add +)
                    (c-loop (~>> (== _ (~>> (c-reg 0) (c-reg 0)))
                                 (c-add +)
                                 (-< _ (gen (~>> (one) (c-reg 0))))
                                 (c-add +)
                                 (-< _ _)))
                    (-< _ _)) )))

(check-equal?
 (~>> (fib5) (stream-take _ 20) stream->list)
 '(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181))

;; F = (1 + F X + F) X
(define fib6
  (~>> (one)
       (c-loop (~>> (== _ (c-reg 0))
                    (c-add +)
                    (c-loop (~>> (== _ (c-reg 0)) (c-add +) (-< _ _)))
                    (c-reg 0)
                    (-< _ _)))))

(check-equal?
 (~>> (fib6) (stream-take _ 20) stream->list)
 '(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181))

;; Lustre example

;; Example from https://homepage.cs.uiowa.edu/~tinelli/classes/181/Spring10/Notes/03-lustre.pdf
;; https://racket.discourse.group/t/qi-circuit-a-domain-specific-language-to-create-signal-flow-graphs/2610/9?u=chansey97

;; f = 1 -> pre( f + (0 -> pre f));

(define f
  (~>> ()
       (c-loop-gen (~>> (-< (gen ones) (c-reg 0))
                        c-->
                        (-< _ (~>> (c-reg 0) (-< (gen zero) _) c-->))
                        (c-add +)
                        (-< _ _)
                        ))
       (-< (gen ones) (c-reg 0))
       c-->))

(check-equal?
 (~>> (f) (stream-take _ 20) stream->list)
 '(1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765))

