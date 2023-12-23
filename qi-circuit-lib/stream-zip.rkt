#lang racket
(provide (all-defined-out))

;; https://github.com/chansey97/stream-zip

(define (stream-zip . strms)
  (define (stream-zip strms)
    (if (ormap stream-empty? strms)
        empty-stream
        (stream-cons
         (apply
          values
          (for/foldr ([res '()])
            ([strm strms])
            (append (call-with-values (λ () (stream-first strm)) list) res)))
         (stream-zip (map stream-rest strms)))))
  (cond
    [(ormap (lambda (x) (not (stream? x))) strms)
     (raise-argument-error 'stream-zip "non-stream argument" strms)]
    [else (stream-zip strms)]))

(define (stream-unzip strm)
  (define (stream-unzip strm n)
    (cond
      [(stream-empty? strm)
       (apply
        values
        (for/list ([_ (in-range n)])
          empty-stream))]
      [else
       (call-with-values
        (λ ()
          (stream-first strm))
        (λ vs
          (let ((vslen (min (length vs) n)))
            (apply
             values
             (for/list ([i (in-range n)])
               (cond
                 [(< i vslen)
                  (stream-cons
                   (list-ref vs i)
                   (list-ref (call-with-values (λ () (stream-unzip (stream-rest strm) vslen)) list) i))] ; TODO: performance issue?
                 [else
                  empty-stream])
               ))))
        )]))
  (cond
    [(stream-empty? strm) empty-stream]
    [else (call-with-values
           (λ ()
             (stream-first strm))
           (λ vs
             (let ((n (length vs)))
               (apply
                values
                (for/list ([i (in-naturals)]
                           [v vs])
                  (stream-cons v (list-ref (call-with-values (λ () (stream-unzip (stream-rest strm) n)) list) i)))))
             ))]))

(define (stream-map* proc . strms)
  (cond
    [(not (procedure? proc))
     (raise-argument-error 'stream-map* "procedure?" proc)] 
    [(null? strms)
     (raise-argument-error 'stream-map* "no stream arguments" strms)]
    [(ormap (lambda (x) (not (stream? x))) strms)
     (raise-argument-error 'stream-map* "non-stream argument" strms)]
    [else (stream-map proc (apply stream-zip strms))]))

(module+ main

  (require stream-values)

  ;; test zip

  (stream-zip)
  ;; #<stream>

  (stream-unzip (stream-zip))
  ;; void

  (define stream-1 (stream 1 2 3 4 5 6 7))
  (define stream-2 (stream 10 20 30 40))
  (define stream-1-2 (stream-map* list stream-1 stream-2))
  (stream->list stream-1-2)
  ;; '((1 10) (2 20) (3 30) (4 40))

  
  (define nats (in-naturals))
  (stream->list (stream-take nats 20))
  ;; '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19)

  (stream->list (stream-take (stream-zip nats) 20))
  ;; '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19)

  (define evens (stream-map (curry * 2) nats))
  (stream->list (stream-take evens 20))
  ;; '(0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38)

  (define odds (stream-map (curry + 1) evens))
  (stream->list (stream-take odds 20))
  ;; '(1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39)

  (define fibs
    (stream-cons 0 (stream-cons 1 (stream-map* + fibs (stream-rest fibs)))))
  (stream->list (stream-take fibs 20))
  ;; '(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181)

  (define nats-evens (stream-zip nats evens))
  (stream->list (stream-take
                 (for/stream ([(x y) (in-stream nats-evens)])
                   (list x y))
                 20))
  ;; '((0 0) (1 2) (2 4) (3 6) (4 8) (5 10) (6 12) (7 14) (8 16) (9 18) (10 20) (11 22) (12 24) (13 26) (14 28) (15 30) (16 32) (17 34) (18 36) (19 38))

  (define odds-fibs (stream-zip odds fibs))
  (stream->list (stream-take
                 (for/stream ([(x y) (in-stream odds-fibs)])
                   (list x y))
                 20))
  ;; '((1 0) (3 1) (5 1) (7 2) (9 3) (11 5) (13 8) (15 13) (17 21) (19 34) (21 55) (23 89) (25 144) (27 233) (29 377) (31 610) (33 987) (35 1597) (37 2584) (39 4181))

  (define nats-evens-odds-fibs (stream-zip nats-evens odds-fibs))
  (stream->list (stream-take (stream-map list nats-evens-odds-fibs) 20))
  ;; '((0 0 1 0)
  ;;   (1 2 3 1)
  ;;   (2 4 5 1)
  ;;   (3 6 7 2)
  ;;   (4 8 9 3)
  ;;   (5 10 11 5)
  ;;   (6 12 13 8)
  ;;   (7 14 15 13)
  ;;   (8 16 17 21)
  ;;   (9 18 19 34)
  ;;   (10 20 21 55)
  ;;   (11 22 23 89)
  ;;   (12 24 25 144)
  ;;   (13 26 27 233)
  ;;   (14 28 29 377)
  ;;   (15 30 31 610)
  ;;   (16 32 33 987)
  ;;   (17 34 35 1597)
  ;;   (18 36 37 2584)
  ;;   (19 38 39 4181))


  (define 1-to-10 (stream-take nats 10))
  (stream->list 1-to-10)
  ;; '(0 1 2 3 4 5 6 7 8 9)

  (stream->list (stream-map list (stream-zip 1-to-10 nats)))
  ;; '((0 0) (1 1) (2 2) (3 3) (4 4) (5 5) (6 6) (7 7) (8 8) (9 9))


  ;; test unzip

  (let-values ([(nats evens) (stream-unzip nats-evens)])
    (values
     (stream->list (stream-take nats 20))
     (stream->list (stream-take evens 20))))
  ;; '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19)
  ;; '(0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38)

  (let-values ([(nats evens) (stream-unzip (stream-take nats-evens 15) )])
    (values
     (stream->list nats)
     (stream->list evens)))
  ;; '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14)
  ;; '(0 2 4 6 8 10 12 14 16 18 20 22 24 26 28)

  (define weird-stream (stream/values (values 1 2) (values 3 4) (values 5 6 7) (values 8 9 10) (values 11 12 13) (values 14) (values 15)))

  (let-values ([(s1 s2) (stream-unzip weird-stream )])
    (list
     (stream->list s1)
     (stream->list s2)))
  ;; '((1 3 5 8 11 14 15)
  ;;   (2 4 6 9 12))


  (let-values ([(s1 s2) (stream-unzip weird-stream )])
    (list
     (stream->list s1)
     (stream->list s2)))
  ;; '((1 3 5 8 11)
  ;;   (2 4 6 9 12))

  ;; TODO: pull request to stream-values, or racket, or discourse?



;; (define test-strm (stream (list 1 2) (list 3 4) (list 5 6) (list 7 8)))

;; (define test-strm-unziped
;;   (stream-fold
;;    (λ (acc vs)
;;      (list
;;       (stream-cons (car vs) (cadr acc))
;;       (stream-cons (car vs) (cadr acc))))
;;    (list empty-stream empty-stream)
;;    test-strm))


;; ;; (match-let ([(list s1 s2) test-strm-unziped])
;; ;;   (list
;; ;;      (stream->list s1)
;; ;;      (stream->list s2))
;; ;;   )

  
;; (for/stream/values ([i (in-naturals)])
;;       (values i (add1 i)))

  ;; https://hackage.haskell.org/package/base-4.19.0.0/docs/src/GHC.List.html#unzip
  )


;; why no stream-foldr? in Racket?
;; (define (stream-foldr proc z s)
;;   (cond
;;     [(stream-empty? s) z]
;;     [else (proc (stream-first s) (stream-foldr proc z (stream-rest s)))]))


(define (stream-foldr proc z s)
  (cond
    [(stream-empty? s) z]
    [else (stream-cons (stream-first s) (stream-foldr proc z (stream-rest s)))]))

