# Integral

[SICP Figure 3.32](https://web.mit.edu/6.001/6.037/sicp.pdf) introduces the integral procedure viewed as a signal processing system:

![image-20231218060239436](figures/image-20231218060239436.png)

This diagram cannot be directly written in Qi-circuit, but it can be translated to an equivalent circuit.

step-1

![image-20231218060406066](figures/image-20231218060406066.png)

step-2

![image-20231218060431346](figures/image-20231218060431346.png)

step-3

![image-20231218060454627](figures/image-20231218060454627.png)

step-4



![image-20231218060521490](figures/image-20231218060521490.png)

```
(define (integral init dt)
  (☯ (~>> (mul dt) (c-loop (~>> (== _ (reg init)) (add +) (-< _ _))) (reg init))))
```