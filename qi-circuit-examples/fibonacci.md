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

Note that there are many equivalent circuits for the same recursive equation. 

For examples:

$F = (X + F X) + F X^2$

![image-20231220140125664](figures/image-20231220140125664.png)

![image-20231225174303422](figures/image-20231225174303422.png)

$F = (X + F X^2) + F X$

![image-20231220140434941](figures/image-20231220140434941.png)

![image-20231225174402198](figures/image-20231225174402198.png)

At first glance, it seems that we have to use two `c-loop`s, but in fact, these two loops can be merged into one.

$F = X + F (X + X^2)$

![image-20231220115342196](figures/image-20231220115342196.png)



![image-20231220115612955](figures/image-20231220115612955.png)

Also, the two additions can be merge to one, because `(c-add +)` can work with multiple inputs.

![image-20231225180034944](figures/image-20231225180034944.png)

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

![image-20231220135853380](figures/image-20231220135853380.png)

$F = (1 + F X + F) X$

![image-20231220135548419](figures/image-20231220135548419.png)

All these circuits above are equivent circuits. In other words, the input $1$ can be replaced with other stream $\sigma$, see [rabbit-farming](rabbit-farming.md).



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

![image-20231220132518110](figures/image-20231220132518110.png)



![image-20231220132553877](figures/image-20231220132553877.png)

This circuit seems more readable.



---

An example from https://homepage.cs.uiowa.edu/~tinelli/classes/181/Spring10/Notes/03-lustre.pdf

```
f = 1 -> pre( f + (0 -> pre f));
```

It can be represented via circuit.

![image-20231223141245848](figures/image-20231223141245848.png)

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











