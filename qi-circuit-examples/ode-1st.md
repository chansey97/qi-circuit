# Solving ODE 1

[SICP 3.5.4 Figure-3.34](https://web.mit.edu/6.001/6.037/sicp.pdf) introduces an "analog computer circuit" that solves the equation $dy/dt = f(y)$.

<img src="figures/ode-1-sicp.png" alt="ode-1-sicp" width=33% />

Translate the diagram to an equivalent circuit.

step-1

<img src="figures/ode-1-step-1.png" alt="ode-1-step-1" width=75% />

step-2

<img src="figures/ode-1-step-2.png" alt="ode-1-step-2" width=75% />

step-3

<img src="figures/ode-1-step-3.png" alt="ode-1-step-3" width=75% />

step-4

<img src="figures/ode-1-step-4.png" alt="ode-1-step-4" width=75% />

Since the outer loop has only outputs but no inputs, use `c-loop-gen` instead of `c-loop`.

```
(define (solve f y0 dt)
  (~>> ()
       (c-loop-gen (~>> (c-reg y0)
                        (map f _)
                        (c-mul dt)
                        (c-loop (~>> (== _ (c-reg y0)) (c-add +) (-< _ _)))
                        (-< _ _)))
       (c-reg y0)
       ))
```

Note that this example also shows that you cannot treat `integral` as an independent component, because `(c-reg y0)` must be on the leftmost side of `sf` in the `c-loop` or `c-loop-gen`. Artificially adding a wrong `(c-reg y0)` would result in a non-equivalent circuit.

<img src="figures/ode-1-wrong.png" alt="ode-1-wrong" width=75% />

