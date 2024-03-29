#lang racket
(require data/collection)
(require qi)
(require qi/probe)
(require "../qi-circuit-lib/circuit.rkt")
(require "../qi-circuit-lib/basic-streams.rkt")
(require rackunit)

;; Graphical Linear Algebra example

;; Example from https://graphicallinearalgebra.net/2016/09/07/31-fibonacci-and-sustainable-rabbit-farming/

;; (* "forward" Fibonacci *) 
;; (* ffib : int list -> int list *) 
;; let ffib x =
;;   let rec ffibaux r1 r2 r3 x =
;;     match x with
;;     | [] -> []
;;     | xh :: xt ->
;;         xh + r1 + r2 + r3 ::
;;         ffibaux xh r3 (xh + r1 + r2 + r3) xt
;;   in ffibaux 0 0 0 x;;

;; # ffib [1; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0];;
;; - : int list = [1; 2; 3; 5; 8; 13; 21; 34; 55; 89; 144; 233; 377]
;; which is the list of the first thirteen Fibonacci numbers, as in Liber Abaci.

;; Say Giusy throws in one additional rabbit pair each month, then the numbers will be
;; # ffib [1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1];;
;; - : int list = [1; 3; 6; 11; 19; 32; 53; 87; 142; 231; 375; 608; 985]

;; τ = ffib(σ) = ((x + 1) / (1 - x - x^2)) σ

(define-flow ffib
  (~>> (-< _ (c-reg 0))
       (c-add +)
       (c-loop (~>> (== _ (~>> (c-reg 0) (-< _ (c-reg 0)) (c-add +) ))
                    (c-add +)
                    (-< _ _)))))

(check-equal?
 (~>> (one) ffib (stream-take _ 13) stream->list)
 '(1 2 3 5 8 13 21 34 55 89 144 233 377))

;; '(1 2 3 5 8 13 21 34 55 89 144 233 377)
;; This corresponds to (1 + x) / (1 - x - x^2), i.e. generating function (1) in Pawel Sobocinski's blog.

(check-equal?
 (~>> ((stream 1 1 1 1 1 1 1 1 1 1 1 1 1)) ffib stream->list)
 '(1 3 6 11 19 32 53 87 142 231 375 608 985))

;; (* backward Fibonacci *)
;; (* rfib : int list -> int list *) 
;; let rfib x =
;;   let rec rfibaux r1 r2 r3 x =
;;     match x with
;;     | [] -> []
;;     | xh :: xt ->
;;         xh - r1 + r2 + r3 ::
;;         rfibaux (xh - r1 + r2 + r3) r3 (-xh) xt
;;   in rfibaux 0 0 0 x;;

;; as a function, this now computes the inverse to fib. So, for example

;; # rfib [1; 2; 3; 5; 8; 13; 21; 34; 55; 89; 144; 233; 377];;
;; - : int list = [1; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0]

;; Now, let’s say that Giusy has space for 5 rabbit pairs and wants to sell off any
;; overflow. What should her business plan look like?

;; # rfib [5; 5; 5; 5; 5; 5; 5; 5; 5; 5; 5;];;
;; - : int list = [5; -5; 0; -5; 0; -5; 0; -5; 0; -5; 0]


;; Because of τ = ffib(σ) = ((x + 1) / (1 - x - x^2)) σ,
;; σ = rfib(τ) = ((1 - x - x^2) / (1 + x)) τ

(define-flow rfib
  (~>> (-< _ (~>> (c-reg 0) (c-mul -1)) (~>> (c-reg 0) (c-reg 0) (c-mul -1)))
       (c-add +)
       (c-loop (~>> (== _ (~>> (c-reg 0) (c-mul -1)))
                    (c-add +)
                    (-< _ _)))))

(check-equal?
 (~>> ((stream 1 2 3 5 8 13 21 34 55 89 144 233 377)) rfib stream->list)
 '(1 0 0 0 0 0 0 0 0 0 0 0 0))

(check-equal?
 (~>> ((stream 5 5 5 5 5 5 5 5 5 5 5)) rfib stream->list)
 '(5 -5 0 -5 0 -5 0 -5 0 -5 0))
