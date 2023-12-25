#lang racket
(require data/collection)
(require qi)
(require qi/probe)
(require "../qi-circuit-lib/circuit.rkt")
(require "../qi-circuit-lib/basic-streams.rkt")
(require rackunit)

;; Example from https://homepage.cs.uiowa.edu/~tinelli/classes/181/Spring10/Notes/03-lustre.pdf

;; A node Count(reset,x: bool) returns (c: int);
;; such that:
;;   c is reset to 0 if reset, otherwise it is incremented if x,
;;   everything behaves as if c was 0 at the origin

;; Counter:
;; node Count(reset,x: bool) returns (c: int);
;; let
;;   c = if reset then 0
;;     else if x then (0->pre c) + 1
;;     else (0->pre c);
;; tel

;; Rename Lustre slide's count to counter, because name conflict with Qi's count
(define (counter reset x)
  (~>> (reset x)
       ▽
       (c-loop (~>> (== △ (~>> (c-reg 0) (-< (gen zero) _) c--> (-< (~>> (-< (gen ones) _) (c-add +)) _))) ; reset × x × (0->pre c) + 1 × (0->pre c)   
                    (c-switch (% _ _)
                              [1> 0]
                              [2> 3>]
                              [else 4>])
                    (-< _ _)
                    ))))

(define (bin->bool n)
  (if (= n 0) #f #t))

(check-equal?
 (~>> ((stream 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0)
       (stream 0 1 1 0 0 1 1 1 1 1 0 1 0 1 1 0 0 0 0 0))
      (== (map bin->bool _) (map bin->bool _))
      counter
      stream->list)
 '(0 1 2 2 2 3 0 1 2 3 3 4 0 1 2 2 2 2 2 2))

;; r '(0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0)
;; x '(0 1 1 0 0 1 1 1 1 1 0 1 0 1 1 0 0 0 0 0)
;; o '(0 1 2 2 2 3 0 1 2 3 3 4 0 1 2 2 2 2 2 2)
