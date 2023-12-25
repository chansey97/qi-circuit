#lang racket
(require data/collection)
(require qi)
(require qi/probe)
(require "../qi-circuit-lib/circuit.rkt")
(require "../qi-circuit-lib/basic-streams.rkt")
(require rackunit)

;; Example from https://homepage.cs.uiowa.edu/~tinelli/classes/181/Spring10/Notes/03-lustre.pdf

;; A node Switch(on,off: bool) returns (s: bool);
;; such that:
;;   s raises (false to true) if on, and falls (true to false) if off
;;   everything behaves as if s was false at the origin
;;   must work properly even if off and on are the same

;; node Switch(on,off: bool) returns (s: bool);
;; let s = if(false -> pre s) then not off else on; tel

(define (bistable-switch on off)
  (~>> (on off)
       ▽
       (c-loop (~>> (== △ (~>> (-< (gen false) (c-reg #f)) c-->))
                    (c-switch (% 3> _)
                              [_ (~>> 2> NOT)]
                              [else 1>])
                    (-< _ _)
                    ))))

(check-equal?
 (~>> (false false)
      bistable-switch
      (stream-take _ 5)
      stream->list)
 '(#f #f #f #f #f))

;; SET IS ON, RESET IS OFF, Q is OUTPUT
;; https://pfnicholls.com/Electronics/bistable.html

(check-equal?
 (~>> ((stream #f #f #f #t #t #t #f #f #t #t #f #f #f #f #f #f #f #f #f #f #f #f #f #f #t #t #t #f #f #f #f #f #f #f #f #f #f)
      (stream #f #f #f #f #f #f #f #f #f #f #f #f #f #t #t #t #f #f #f #f #t #t #f #f #f #f #f #f #f #f #t #f #f #f #f #f #f))
     bistable-switch
     stream->list)
 '(#f #f #f #t #t #t #t #t #t #t #t #t #t #f #f #f #f #f #f #f #f #f #f #f #t #t #t #t #t #t #f #f #f #f #f #f #f))
