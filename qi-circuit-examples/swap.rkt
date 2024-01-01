#lang racket
(require data/collection)
(require qi)
(require qi/probe)
(require "../qi-circuit-lib/circuit.rkt")
(require "../qi-circuit-lib/basic-streams.rkt")
(require "../qi-circuit-lib/stream-zip.rkt")
(require rackunit)

;; This is an example about no c-reg in the c-loop body.

;; NOTE: Arrow SF and Qi-circuit are not exactly the same!
;; For example,
;; c-loop in qi-circuit inputs two streams, 
;; loop in Arrow SF inputs one stream of pairs (which needs zip and unzip).

;; At the moment, I don't see any advantage of "one stream of pairs" over "two streams".

;; TODO:
;;
;; Try one stream of pairs
;; Need lazy pattern matching like Haskell? https://wiki.haskell.org/Lazy_pattern_match
;; Programming with Arrows.pdf
;;
;; Is there any easy way to do in Racket with stream ?
;; f ~(x:xs) = x:xs
;; is translated to
;; f ys = head ys : tail ys
;; For example, thunk the `head ys`?
;;
;; After that, we can use stream of pairs and zip unzip, like in Haskell.


;; runSF (loop (arr id)) [1,2,3]

(~>> ((stream 1 2 ))
     (c-loop (~>> (== _ _)))
     stream->list)
;; '(1 2)


;; runSF (loop (arr swap)) [1,2,3]

(~>> ((stream 1 2 ))
     (c-loop (~>> X))
     stream->list)
;; '(1 2)

;; 上面的代码，等价于下面的代码：
(~>> ((stream 1 2))
     (c-loop (~>> (esc (λ (x y) (values y x)))))
     stream->list)
;; '(1 2)

;; (c-loop (~>> (esc (λ (x y) (values y x))))) 等价于下面的代码
;; (λ (as)
;;     (letrec-values ([(bs cs) (values (stream-lazy cs) as)])
;;       bs))
;; 返回 bs, 而 bs = (stream-lazy cs), 而 cs 就是输入 as, 于是 bs 就是 as
;; 所以，即使没有 reg 也是 OK 的



