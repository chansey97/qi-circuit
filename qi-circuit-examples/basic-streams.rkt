#lang racket

(require qi)
(require qi/probe)
(require "../qi-circuit-lib/circuit.rkt")
(provide false zero one ones positives nats)

;; #f #f ...
(define false (stream-cons #f false))

;; 0

(define zero (stream-cons 0 zero))
;; (probe (~>> (zero) (stream-take _ 10) stream->list))
;; '(0 0 0 0 0 0 0 0 0 0)


;; 1

(define one (~>> (zero) (c-reg 1)))
;; (probe (~>> (one) (stream-take _ 10) stream->list))
;; '(1 0 0 0 0 0 0 0 0 0)


;; Rutten Example 4.17, 4.18: τ = (1 / 1 - X) σ
;; τ = sf-4.17(σ) = [σ0, σ0+σ1, σ0+σ1+σ2, ...]

(define-flow sf-4.17
  (~>> (c-loop (~>> (== _ (c-reg 0)) (c-add +) (-< _ _)))))

(define ones ((☯ sf-4.17) one))
;; (probe (~>> (ones) (stream-take _ 10) stream->list))
;; '(1 1 1 1 1 1 1)

;; Rutten Example 4.21: τ = (1 / 1 - 2X) σ

(define-flow sf-4.21
  (~>> (c-loop (~>> (== _ (c-reg 0)) (== _ (c-mul 2)) (c-add +) (-< _ _)))))

(define power2 ((☯ sf-4.21) one))
;; (probe (~>> (power2) (stream-take _ 10) stream->list))
;; '(1 2 4 8 16 32 64 128 256 512)


;; Rutten Example 4.23:  τ = (1 / (1 - X)^2) σ

(define-flow sf-4.23
  (~>> (c-loop (~>> (== _ (c-reg 0)) (c-add +) (-< _ _)))
       (c-loop (~>> (== _ (c-reg 0)) (c-add +) (-< _ _)))))

(define positives ((☯ sf-4.23) one))
;; (probe (~>> (positives) (stream-take _ 10) stream->list))
;; '(1 2 3 4 5 6 7 8 9 10)


;; Natural numbers start from 0, by multiplying the positives by X (shifting one bit to the right)
;; i.e. X / (1 - X)^2

(define nats (~>> (positives) (c-reg 0)))
;; (probe (~>> (nats) (stream-take _ 10) stream->list))
;; '(0 1 2 3 4 5 6 7 8 9)

