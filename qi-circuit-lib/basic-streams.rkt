#lang racket
(require qi)
(require qi/probe)
(require "./circuit.rkt")
(provide false zero one ones positives nats)

;; #f #f #f ...
(define false (stream-cons #f false))

;; 0 0 0 ... 
(define zero (stream-cons 0 zero))

;; 1 0 0 ...
(define one (~>> (zero) (c-reg 1)))

;; 1 1 1 ...
(define ones (~>> (one) (c-loop (~>> (== _ (c-reg 0)) (c-add +) (-< _ _)))))

;; 1 2 3 ...
(define positives (~>> (ones)
                       (c-loop (~>> (== _ (c-reg 0)) (c-add +) (-< _ _)))))

;; 0 1 2 3 ...
(define nats (~>> (positives) (c-reg 0)))
