# Rabbit Farming

In [Graphical Linear Algebra](https://graphicallinearalgebra.net/), Pawel Sobocinski introduced [Sustainable Rabbit Farming](https://graphicallinearalgebra.net/2016/09/07/31-fibonacci-and-sustainable-rabbit-farming/):

> Giusy originally got a pair of rabbits. No external rabbits get added, nor any taken away at any point afterwards. So we can think of this as the following rabbit input sequence 
>
> $$1, 0, 0, 0, 0, 0, 0, 0, 0, 0, …$$ 
>
> with resulting rabbit output sequence
>
> $$1, 2, 3, 5, 8, 13, 21, 34, 55, 89, …$$
>
> Similarly, as we have already discussed, adding the first pair one month late would mean that the shifted rabbit input sequence
>
> $$0, 1, 0, 0, 0, 0, 0, 0, 0, 0, …$$
>
> results in the shifted output sequence
>
> $$0, 1, 2, 3, 5, 8, 13, 21, 34, 55, …$$
>
> But there’s no reason to add just one pair. For example, what if Giusy started with two pairs of rabbits? And, moreover, let’s suppose that she goes to the rabbit market every second month to buy another pair of rabbits. This rabbit input
> sequence would then be
>
> $$2, 0, 1, 0, 1, 0, 1, 0, 1, 0, …$$
>
> Following the Fibonacci principle of rabbit reproduction, we would get output
> sequence
>
> $$2, 4, 7, 12, 20, 33, 54, 88, 143, 232, …$$

> We can use the same kind of reasoning to figure out what would happen if Giusy started an ambitious commercial rabbit breeding farm. Say her business plan started with investing in three pairs, then selling one pair in the first month, two
> in the second, three in the third, and so forth. In this case, the rabbit input sequence would be
>
> $$3, -1, -2, -3, -4, -5, -6, -7, -8, -9, …$$
>
> and the result is, unfortunately
>
> $$3, 5, 5, 5, 3, -1, -9, -23, -47, -87, …$$
>
> so it looks like Giusy’s rabbit business would collapse sometime in the  fifth month: negative rabbits doesn’t sound good. To be a successful  rabbit entrepreneur, Giusy needs to understand the principles of  sustainable rabbit farming, which we will discover at the end of this  episode.

> What’s going on here, mathematically speaking?
>
> It looks like we are defining a *function* that takes number sequences to number sequences. By introducing and taking away rabbits we are *causing* the total numbers to change. We could try to write down a formula to  calculate subsequent entries in the output sequence based on previously  outputted values and the current input value. But formulas are boring.
>
> Moreover, I hope that I’ve managed to make you at least a little bit [uncomfortable](https://graphicallinearalgebra.net/2015/08/04/causality-feedback-and-relations/) about the pseudo-scientific language of causality. In graphical linear algebra, relations take  centre stage. Of course, it is useful to know when a relation describes a function – as we will see below – but functions are not part of our  basic setup. Instead, we think of the Fibonacci rules of rabbit breeding as **defining a relation between number sequences**. For example, it relates
>
> $1, 0, 0, 0, 0, 0, 0, 0, 0, 0, …$ with $1, 2, 3, 5, 8, 13, 21, 34, 55, 89, …$
>
> $2, 0, 1, 0, 1, 0, 1, 0, 1, 0, …$ with $2, 4, 7, 12, 20, 33, 54, 88, 143, 232, …$
>
> $3, -1, -2, -3, -4, -5, -6, -7, -8, -9, …$ with $3, 5, 5, 5, 3, -1, -9, -23, -47, -87, …$
>
> and so forth.
>
> This relation is a kind of “ratio” between sequences. We have already seen how [fractions](https://graphicallinearalgebra.net/2015/11/24/25-fractions-diagrammatically/) in graphical linear algebra work and that they can be thought of as ratios. 

This relation can be captured with diagrams in Graphical Linear Algebra. The following is the diagram for $\large \frac {1 + x} {1 -x - x^2}$, the generating function for the Fibonacci sequence $1, 2, 3, 5, 8, 13, 21, 34, 55, 89, …$ 

![](https://graphicallinearalgebra.files.wordpress.com/2016/09/diagspec.gif?w=406&h=111)

By diagrammatic reasoning, it can be rewired into the following two signal flow graphs.

**"forward" Fibonacci**



![](https://graphicallinearalgebra.files.wordpress.com/2016/09/fibff.gif?w=406)

**"backward" Fibonacci**

![](https://graphicallinearalgebra.files.wordpress.com/2016/09/rfib.gif?w=531)

We have no diagrammatic reasoning like Pawel's settings, but can still obtain these two signal flow diagrams by manipulating the generated function equations. Let the input sequence is $\sigma$, the output sequence is $\tau$, then

**"forward" Fibonacci** 

$$\tau = \large \frac {1 + x} {1 -x - x^2} \sigma$$

$$\Rightarrow \tau = \sigma (1 + x) + \tau(x + x^2)$$

**"backward" Fibonacci**

$$\sigma= \large \frac {1 -x - x^2}  {1 + x} \tau  $$

$$\Rightarrow \sigma = \tau (1 - x - x^2) -\sigma x$$

We have known how to translate these recursive equations to Qi-circuit in [Fibonacci](fibonacci.md):

```
(define-flow ffib
  (~>> (-< _ (c-reg 0))
       (c-add +)
       (c-loop (~>> (== _ (~>> (c-reg 0) (-< _ (c-reg 0)) (c-add +) ))
                    (c-add +)
                    (-< _ _)))))
```

```
(define-flow rfib
  (~>> (-< _ (~>> (c-reg 0) (c-mul -1)) (~>> (c-reg 0) (c-reg 0) (c-mul -1)))
       (c-add +)
       (c-loop (~>> (== _ (~>> (c-reg 0) (c-mul -1)))
                    (c-add +)
                    (-< _ _)))))
```

P.S. Another way to solve this is [Power series, power serious](https://www.cambridge.org/core/journals/journal-of-functional-programming/article/power-series-power-serious/19863F4EAACC33E1E01DE2A2114EC7DF).

