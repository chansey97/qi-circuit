#lang racket
(require qi)
(require qi/probe)
(require "../qi-circuit-lib/circuit.rkt")
(require "../qi-circuit-lib/basic-streams.rkt")
(require rackunit)

(check-equal?
 (~>> (false) (stream-take _ 10) stream->list)
 '(#f #f #f #f #f #f #f #f #f #f))

(check-equal?
 (~>> (zero) (stream-take _ 10) stream->list)
 '(0 0 0 0 0 0 0 0 0 0))

(check-equal?
 (~>> (one) (stream-take _ 10) stream->list)
 '(1 0 0 0 0 0 0 0 0 0))

(check-equal?
 (~>> (ones) (stream-take _ 10) stream->list)
 '(1 1 1 1 1 1 1 1 1 1))

(check-equal?
 (~>> (positives) (stream-take _ 10) stream->list)
 '(1 2 3 4 5 6 7 8 9 10))

(check-equal?
 (~>> (nats) (stream-take _ 10) stream->list)
 '(0 1 2 3 4 5 6 7 8 9))




