# Integral

[SICP Figure 3.32](https://web.mit.edu/6.001/6.037/sicp.pdf) introduces the integral procedure viewed as a signal processing system:

<img src="figures/image-20231218060239436.png" alt="image-20231218060239436" width=50% />

This diagram cannot be directly written in Qi-circuit, but it can be translated to an equivalent circuit.

step-1

<img src="figures/image-20231218060406066.png" alt="image-20231218060406066" width=50% />

step-2

<img src="figures/image-20231218060431346.png" alt="image-20231218060431346" width=50% />

step-3

<img src="figures/image-20231218060454627.png" alt="image-20231218060454627" width=50% />

step-4

<img src="figures/image-20231218060521490.png" alt="image-20231218060521490" width=70% />

```
(define (integral init dt)
  (☯ (~>> (mul dt) (c-loop (~>> (== _ (reg init)) (add +) (-< _ _))) (reg init))))
```