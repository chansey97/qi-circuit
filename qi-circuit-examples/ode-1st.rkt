#lang racket

(require data/collection)
(require qi)
(require qi/probe)
(require "../qi-circuit-lib/circuit.rkt")
(require "basic-streams.rkt")

;; SICP 3.5.3 Exploiting the Stream Paradigm
;; 
;; <<figure-3.32>> The ~integral~ procedure viewed as a signal-processing system.
;;  
;;                               initial-value
;;                                    |
;;         +-----------+              |   |\__
;;  input  |           |      |\__    +-->|   \_  integral
;;  ------>| scale: dt +----->|   \_      |cons_>--*------->
;;         |           |      | add_>---->| __/    |
;;         +-----------+  +-->| __/       |/       |
;;                        |   |/                   |
;;                        |                        |
;;                        +------------------------+
;;  

;; SICP 3.5.4 Streams and Delayed Evaluation
;;
;; <<figure-3.34>> An "analog computer circuit" that solves the equation dy/dt = f(y).
;;  
;;                              y_0
;;                               |
;;                               V
;;      +----------+  dy   +----------+     y
;;  +-->|  map: f  +------>| integral +--*----->
;;  |   +----------+       +----------+  |
;;  |                                    |
;;  +------------------------------------+


;; Solving y' = f(y), the initial condition y(0) = y0

(define (solve f y0 dt)
  (~>> ()
       (c-loop-gen (~>> (c-reg y0)
                        (map f _)
                        (c-mul dt)
                        (c-loop (~>> (== _ (c-reg y0)) (c-add +) (-< _ _)))
                        (-< _ _)))
       (c-reg y0)
       ))

;; For example, let f(x) = x, y(0) = 1,
;; i.e. solve y' = y with y(0) = 1
;; Solved: y(t) = e^t, so y(1) = e.
;; See https://www.wolframalpha.com/input?i2d=true&i=y%27+%3D+y%5C%2844%29+y%5C%2840%290%5C%2841%29+%3D+1

(define (solved-y t)
  (let* ((precision 1000.0)
         (dt (/ 1 precision))
         (f (λ (y) y))
         (y0 1))
    (stream-ref (solve f y0 dt) (inexact->exact (round (* t precision)))) 
    ))

(solved-y 1)
;; 2.716923932235896



