#lang racket
(require data/collection)
(require qi)
(require qi/probe)
(require "../qi-circuit-lib/circuit.rkt")
(require "../qi-circuit-lib/basic-streams.rkt")
(require rackunit rackunit/text-ui)

;; Example from https://homepage.cs.uiowa.edu/~tinelli/classes/181/Spring10/Notes/03-lustre.pdf

;; node Edge (X : bool) returns (E : bool);
;; let
;;   E = false -> X and not pre X ;
;; tel

;; #inputs "X":bool
;; #outputs "E":bool
;; #step 1 
;; true false true false false false true true true false true true true true true
;; 0
;; #step 2 
;; 0
;; #step 3 
;; 1
;; #step 4 
;; 0
;; #step 5 
;; 0
;; #step 6 
;; 0
;; #step 7 
;; 1
;; #step 8 
;; 0
;; #step 9 
;; 0
;; #step 10 
;; 0
;; #step 11 
;; 1
;; #step 12 
;; 0
;; #step 13 
;; 0
;; #step 14 
;; 0
;; #step 15 
;; 0
;; #step 16 

;; 在电子学和数字逻辑中，"rising edge" 指的是数字信号从低电平（0）跃升到高电平（1）的瞬间。
;; 注意：并不记录从高电平（1）到低电平（0）的下降！
;; 类似 mouse button state 映射到 mouse button click event（高电平理解为按下时触发，但并不关心弹起）。

(define-flow edge
  (~>> (-< _ (~>> (c-reg #f) c-not))
       c-and
       (-< (gen false) _)
       c-->))

(define (bool->bin b)
  (if b 1 0))

(check-equal?
 (~>> ((stream #t #f #t #f #f #f #t #t #t #f #t #t #t #t #t))
      edge
      (map bool->bin _)
      stream->list)
 '(0 0 1 0 0 0 1 0 0 0 1 0 0 0 0))


