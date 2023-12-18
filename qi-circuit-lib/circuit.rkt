#lang racket

(require qi)
(require qi/probe)
(require data/collection) ; use multiple params map
;; (require (for-syntax racket/base syntax/parse))

(provide c-add c-mul c-convo c-reg (for-space qi c-loop))

(define (c-add op)
  (λ (s1 s2)
    (map op s1 s2)))

(define (c-mul x)
  (λ (s)
    (map (curry * x) s)))

(define (c-convo s1 s2)
  (match/values (values s1 s2)
    [((sequence f fs ...) (sequence g gs ...))
     (stream-cons (* f g) ((c-add +) ((c-mul f) gs) (c-convo fs (stream-cons g gs))))]))

(define (c-reg init)
  (λ (s)
    (stream-cons init s)))

(define (c-loop-proc f)
  (λ (as)
    (letrec-values ([(bs cs) (f as (stream-lazy cs))])
      bs)))

(define-qi-syntax-rule (c-loop sf)
  (esc (c-loop-proc (flow sf))))
