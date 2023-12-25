#lang racket
(require data/collection)
(require qi)
(require qi/probe)
(require "../qi-circuit-lib/circuit.rkt")
(require "../qi-circuit-lib/basic-streams.rkt")
(require rackunit)

;; Example from https://homepage.cs.uiowa.edu/~tinelli/classes/181/Spring10/Notes/03-lustre.pdf

;; node MinMax(X : int)
;; returns (min, max : int); – several outputs
;; let
;;   min = X -> if (X < pre min) then X else pre min;
;;   max = X -> if (X > pre max) then X else pre max;
;; tel

;; #inputs "X":int
;; #outputs "min":int "max":int
;; #step 1 
;; 1 2 1 1
;; 1 1
;; #step 2 
;; 1 2
;; #step 3 
;; 1 2
;; #step 4 
;; 1 2
;; #step 5


(define-flow min
  (~>> (c-loop (~>> (== _ (c-reg +inf.0))
                    (c-switch (% _ _)
                              [< 1>]
                              [else 2>])
                    (-< _ _)))
       ))

(define-flow max
  (~>> (c-loop (~>> (== _ (c-reg -inf.0))
                    (c-switch (% _ _)
                              [> 1>]
                              [else 2>])
                    (-< _ _)))
       ))

(define-flow minmax
  (-< min max))


(check-equal?
 (~>> ((stream 1 2 1 1))
      minmax
      (== (~>> (stream-take _ 4) stream->list)
          (~>> (stream-take _ 4) stream->list))
      ▽)
 (list '(1 1 1 1)
       '(1 2 2 2)))


;; Method 2, do not use +inf.0 and -inf.0, use "followed by", i.e. c--> instead

(define-flow min*
  (~>> (c-loop (~>> (== (-< _ _) (c-reg 0))
                    (-< (~>> (select 1))
                        (~>> (select 2 3)
                             (c-switch (% _ _)
                                       [< 1>]
                                       [else 2>])) )
                    c-->
                    (-< _ _)))
       ))

(define-flow max*
  (~>> (c-loop (~>> (== (-< _ _) (c-reg 0))
                    (-< (~>> (select 1))
                        (~>> (select 2 3)
                             (c-switch (% _ _)
                                       [> 1>]
                                       [else 2>])) )
                    c-->
                    (-< _ _)))
       ))

(define-flow minmax*
  (-< min max))

(check-equal?
 (~>> ((stream 1 2 1 1))
            minmax*
            (== (~>> (stream-take _ 4) stream->list)
                (~>> (stream-take _ 4) stream->list))
            ▽)
 (list '(1 1 1 1)
       '(1 2 2 2)))
