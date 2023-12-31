# Solving ODE 2

[SICP 3.5.4 Exercise 3.78](https://web.mit.edu/6.001/6.037/sicp.pdf) introduces an signal-flow diagram for the solution to a second-order linear differential equation $\frac{d^2 y}{dt^2} - a \frac{dy}{dt} - by = 0$

<img src="figures/ode-2-sicp.png" alt="ode-2-sicp" width=33% />

This diagram is more challenging than the previous ones, let’s derive it step by step.

step-1

<img src="figures/ode-2-step-1.png" alt="ode-2-step-1" width=50% />

step-2

<img src="figures/ode-2-step-2.png" alt="ode-2-step-2" width=50% />

step-3

<img src="figures/ode-2-step-3.png" alt="ode-2-step-3" width=50% />

step-4

<img src="figures/ode-2-step-4.png" alt="ode-2-step-4" width=50% />

The 3-ways claw has associative law.

step-5

<img src="figures/ode-2-step-5.png" alt="ode-2-step-5" width=50% />

step-6

<img src="figures/ode-2-step-6.png" alt="ode-2-step-6" width=50% />

step-7

<img src="figures/ode-2-step-7.png" alt="ode-2-step-7" width=75% />

step-8

<img src="figures/ode-2-step-8.png" alt="ode-2-step-8"/>

Since the outer loop has only outputs but no inputs, use `c-loop-gen` instead of `c-loop`.

```
(define (solve-2nd a b y0 dy0 dt)
  (~>> ()
       (c-loop-gen (~>> (c-reg dy0)
                        (-< (~>> (c-mul dt)
                                 (c-loop (~>> (== _ (c-reg y0))
                                              (c-add +)
                                              (-< _ _)))
                                 (c-reg y0)
                                 (c-mul b))
                            (c-mul a))
                        (c-add +)
                        (c-mul dt)
                        (c-loop (~>> (== _ (c-reg dy0))
                                     (c-add +)
                                     (-< _ _)))
                        (-< _ _)
                        ))
       (c-reg dy0)
       (c-mul dt)
       (c-loop (~>> (== _ (c-reg y0))
                    (c-add +)
                    (-< _ _)))
       (c-reg y0)
       ))
```
