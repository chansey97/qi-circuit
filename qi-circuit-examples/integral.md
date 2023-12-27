# Integral

[SICP Figure 3.32](https://web.mit.edu/6.001/6.037/sicp.pdf) introduces the integral procedure viewed as a signal processing system:

<img src="figures/integral-sicp.png" alt="integral-sicp" width=50% />

This diagram cannot be directly written in Qi-circuit, but it can be translated to an equivalent circuit.

step-1

<img src="figures/integral-step-1.png" alt="integral-step-1" width=50% />

step-2

<img src="figures/integral-step-2.png" alt="integral-step-2" width=50% />

step-3

<img src="figures/integral-step-3.png" alt="integral-step-3" width=50% />

step-4

<img src="figures/integral-step-4.png" alt="integral-step-4" width=70% />

```
(define (integral init dt)
  (☯ (~>> (mul dt) (c-loop (~>> (== _ (reg init)) (add +) (-< _ _))) (reg init))))
```