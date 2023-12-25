#lang racket
(require data/collection)
(require qi)
(require qi/probe)
(require "../qi-circuit-lib/circuit.rkt")
(require "../qi-circuit-lib/basic-streams.rkt")
(require "../qi-circuit-lib/stream-zip.rkt")
(require rackunit)

;; sum1, by qi-circuit
(define (sum1 init)
  (☯ (~>> (c-loop (~>> (== _ (c-reg init)) (c-add +) (-< _ _))))))

(check-equal? (~>> ((stream 1 2 3 4 5)) (sum1 0) stream->list)
              '(1 3 6 10 15))

;; sum1, by stream algorithm
(define (sum1-stream init s)
  (letrec ((sum1 (stream-map* + s (stream-cons init sum1))))
    sum1))

(check-equal? (~>> ((stream 1 2 3 4 5)) (sum1-stream 0) stream->list)
              '(1 3 6 10 15))

;; sum1, by iter algorithm
(define (sum1-iter reg s)
  (match s
    [(sequence) empty-stream]
    [(sequence x xs ...) (stream-cons (+ x reg) (sum1-iter (+ x reg) xs))]))

(check-equal? (~>> ((stream 1 2 3 4 5)) (sum1-iter 0 _) stream->list)
              '(1 3 6 10 15))

;; sum2 corresponds to scanl in Haskell

;; sum2, by qi-circuit
(define (sum2 init)
  (☯ (~>> (c-loop (~>> (== _ (c-reg 0)) (c-add +) (-< _ _))) (c-reg 0))))

(check-equal? (~>> ((stream 1 2 3 4 5)) (sum2 0) stream->list)
              '(0 1 3 6 10 15))

;; sum2, by stream algorithm
(define (sum2-stream init s)
  (letrec ((sum (stream-cons init (stream-map* + s sum))))
    sum))

(check-equal? (~>> ((stream 1 2 3 4 5)) (sum2-stream 0) stream->list)
              '(0 1 3 6 10 15))

;; sum2, by iter algorithm
(define (sum2-iter reg1 reg2 s)
  (match s
    [(sequence) (stream-cons reg2 empty-stream)]
    [(sequence x xs ...) (stream-cons reg2 (sum2-iter (+ x reg1) (+ x reg1) xs))]))

(check-equal? (~>> ((stream 1 2 3 4 5)) (sum2-iter 0 0 _) stream->list)
              '(0 1 3 6 10 15))


;; sum3 corresponds to scanl1 in Haskell

;; sum3, by qi-circuit
(define-flow sum3
  (~>> (c-loop (~>> (== (-< _ _) (c-reg 0))
                       (group 1 _ (c-add +))
                       c-->
                       (-< _ _)))
          ))

(check-equal? (~>> ((stream 1 2 3 4 5)) sum3 stream->list)
              '(1 3 6 10 15))

(check-equal? (~>> ((stream 1)) sum3 stream->list)
              '(1))

(check-equal? (~>> ((stream)) sum3 stream->list)
              '())

;; sum3, by stream algorithm
(define (sum3-stream s)
  (match s
    [(sequence) empty-stream]
    [(sequence x xs ...) (sum2-stream x xs)]))

(check-equal? (~>> ((stream 1 2 3 4 5)) (sum3-stream _) stream->list)
              '(1 3 6 10 15))

(check-equal? (~>> ((stream 1)) (sum3-stream _) stream->list)
              '(1))

(check-equal? (~>> ((stream)) (sum3-stream _) stream->list)
              '())

;; sum3, by iter algorithm
(define (sum3-iter reg s)
  (define (sum3-iter-aux reg s)
    (match s
      [(sequence) empty-stream]
      [(sequence x xs ...) (stream-cons (+ x reg) (sum3-iter-aux (+ x reg) xs))]))
  (match s
    [(sequence) empty-stream]
    [(sequence x xs ...) (stream-cons x (sum3-iter-aux x xs))]))

(check-equal? (~>> ((stream 1 2 3 4 5)) (sum3-iter 0 _) stream->list)
              '(1 3 6 10 15))

(check-equal? (~>> ((stream 1)) (sum3-iter 0 _) stream->list)
              '(1))

(check-equal? (~>> ((stream)) (sum3-iter 0 _) stream->list)
              '())

