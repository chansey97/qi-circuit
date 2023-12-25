#lang racket
(require data/collection)
(require qi)
(require qi/probe)
(require "../qi-circuit-lib/circuit.rkt")
(require "../qi-circuit-lib/basic-streams.rkt")
(require rackunit)

;; factorial = product
(define product (stream-cons 1 (map * product positives)))

(check-equal?
 (~>> (product) (stream-take _ 10) stream->list)
 '(1 1 2 6 24 120 720 5040 40320 362880))

(define fact (~>> (positives)
                  (c-loop (~>> (== _ (c-reg 1)) (c-add *) (-< _ _)))
                  (c-reg 1)
                  ))

(check-equal?
 (~>> (fact) (stream-take _ 10) stream->list)
 '(1 1 2 6 24 120 720 5040 40320 362880))
