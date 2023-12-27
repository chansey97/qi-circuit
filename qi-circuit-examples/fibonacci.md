# Fibonacci

The generating function of Fibonacci sequence is $F = \frac{X}{1 - X - X^2}$. 

We can derive the recursive equation $F = X + F X + F X^2$ from the generating function.

One way to solve the recursive equation is to use stream algorithms, i.e.

```
(define F (stream-cons 0 (stream-cons 1 (map + F (stream-rest F)))))
(~>> (F) (stream-take _ 20) stream->list)
;; '(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181)
```

However, the recursive equation can also be represented as circuits.

For example:

$F = (X + F X) + F X^2$

<img src="figures/fib-1.png" alt="fib-1" width=50% />

<img src="figures/fib-2.png" alt="fib-2" width=75%/>

Note that there are many equivalent circuits for the same recursive equation. 

$F = (X + F X^2) + F X$

<img src="figures/fib-3.png" alt="fib-3" width=50% />

<img src="figures/fib-4.png" alt="fib-4" width=75% />

At first glance, it seems that we have to use two `c-loop`s, but these two loops can be merged into one.

$F = X + F (X + X^2)$

<img src="figures/fib-5.png" alt="fib-5" width=50% />



<img src="figures/fib-6.png" alt="fib-6.png" width=75% />

Also, the two additions can also be merge to one, because `(c-add +)` supports multiple inputs.

<img src="figures/fib-7.png" alt="fib-7" width=75% />

```
(define fib
  (~>> (one)
       (c-reg 0)
       (c-loop (~>> (== _ (~>> (-< (c-reg 0) (~>> (c-reg 0) (c-reg 0))) ))
                    (c-add +)
                    (-< _ _)))
       ))
       
(~>> (fib) (stream-take _ 20) stream->list)
;; '(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181)
```

As follows are some other possible implementations:

$F = (F X + F X^2) + X$

<img src="figures/fib-8.png" alt="fib-8" width=50% />

$F = (1 + F X + F) X$

<img src="figures/fib-9.png" alt="fib-9" width=50% />

All these circuits above are equivent circuits. Even the input $1$ can be replaced with other stream $\sigma$, see [rabbit-farming](rabbit-farming.md).



---

Fibonacci can also be implemented by `c-loop-gen`.

```
(define fib
  (~>> ()
       (c-loop-gen (~>> (c-reg 0) (-< _ (c-reg 1)) (c-add +) (-< _ _)))
       (c-reg 0)
       ))

(probe (~>> (fib) (stream-take _ 20) stream->list))
;; '(0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181)
```

This stream corresponds to the following circut.

$F = (F + (FX + 1)) X$

<img src="figures/fib-10.png" alt="fib-10" width=75% />



<img src="figures/fib-11.png" alt="fib-11" width=75% />

This circuit seems more readable.



---

An example of Fibonacci from https://homepage.cs.uiowa.edu/~tinelli/classes/181/Spring10/Notes/03-lustre.pdf

```
f = 1 -> pre(f + (0 -> pre f));
```

Represents as a circuit.

<img src="figures/fib-12.png" alt="fib-12" width=75% />

```
(define f
  (~>> ()
       (c-loop-gen (~>> (-< (gen ones) (c-reg 0))
                        c-->
                        (-< _ (~>> (c-reg 0) (-< (gen zero) _) c-->))
                        (c-add +)
                        (-< _ _)
                        ))
       (-< (gen ones) (c-reg 0))
       c-->))
```











