#lang racket

(require qi)
(require qi/probe)

;; In qi-circuit-lib, DO NOT use `map` in data/collection, because for finite stream,
;; it requres all the sequences have the same length, which is inconvenient,
;; use `stream-map*` in stream-zip.rkt instead.
;; However, we still CAN USE data/collection for sequence match, etc.
(require data/collection)
(require "./stream-zip.rkt")
(define map stream-map*)

;; (require (for-syntax racket/base syntax/parse))

(provide c-add c-mul c-convo c-and c-or c-not c-reg c-->
         (for-space qi c-loop c-loop-gen c-switch))

;; data operators

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

(define (c-and xs ys)
  (for/sequence ([x xs]
                 [y ys])
    (and x y)))

(define (c-or xs ys)
  (for/sequence ([x xs]
                 [y ys])
    (or x y)))

(define (c-not xs)
  (map not xs))

(define (c-reg init)
  (λ (s)
    (stream-cons init s)))

(define (c-loop-proc f)
  (λ (as)
    (letrec-values ([(bs cs) (f as (stream-lazy cs))])
      bs)))

(define-qi-syntax-rule (c-loop sf)
  (esc (c-loop-proc (flow sf))))

(define (c-loop-gen-proc f)
  (λ _
    (letrec-values ([(bs cs) (f (stream-lazy cs))])
      bs)))

(define-qi-syntax-rule (c-loop-gen sf)
  (esc (c-loop-gen-proc (flow sf))))

;; followed-by
(define (c--> xs ys)
  (stream-cons (stream-first xs) (stream-rest ys)))

(define-qi-syntax-rule (c-switch args ...)
  (esc (λ xss
         (let ((map-args (cons (λ xs
                                 (apply
                                  (flow (switch args ...))
                                  xs)
                                 )
                           xss)))
           (apply map map-args))
         )))

