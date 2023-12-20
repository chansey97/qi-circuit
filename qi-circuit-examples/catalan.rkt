#lang racket

(require qi)
(require qi/probe)
(require "../qi-circuit-lib/circuit.rkt")
(require "basic-streams.rkt")

;; Catalan numbers

;; Binary trees. In the generating function T for enumerating binary trees, the coeffi-
;; cient of x^n is the number of trees on n nodes. A binary tree is either empty or has
;; one root node and two binary subtrees. There is one tree with zero nodes, so the
;; head term of T is 1. A tree of n + 1 nodes has two subtrees with n nodes total; if
;; one of them has i nodes, the other has n − i. Convolution! Convolution of T with
;; itself is squaring, so T^2 is the generating function for the counts of n-node pairs of
;; trees. To associate these counts with n + 1-node trees, we multiply by x. Hence T = 1 + x T^2
;; See Power series, power serious.pdf

;; Let T is the generating function of Catalan numbers, T must satisfy the equation:
;; T = 1 + x T^2

(define catalan
  (~>> (one)
       (c-loop (~>> (== _ (c-reg 0))
                    (c-add +)
                    (-< _ (~>> (-< _ _) c-convo))))
       ))

(probe (~>> (catalan) (stream-take _ 10) stream->list))
;; '(1 1 2 5 14 42 132 429 1430 4862)
