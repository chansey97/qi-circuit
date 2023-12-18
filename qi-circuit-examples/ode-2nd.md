# Solving ODE 2

[SICP 3.5.4 Exercise 3.78](https://web.mit.edu/6.001/6.037/sicp.pdf) introduces an signal-flow diagram for the solution to a second-order linear differential equation $\frac{d^2 y}{dt^2} - a \frac{dy}{dt} - by = 0$

![image-20231218070710642](figures/image-20231218070710642.png)

This diagram is more challenging than the previous ones, let’s derive it step by step.

step-1

![image-20231218071129661](figures/image-20231218071129661.png)

step-2

![image-20231218071159384](figures/image-20231218071159384.png)

step-3

![image-20231218071246762](figures/image-20231218071246762.png)

step-4

![image-20231218071332719](figures/image-20231218071332719.png)



The 3-ways claw has associative law.

step-5

![image-20231218071603033](figures/image-20231218071603033.png)

step-6

![image-20231218071636505](figures/image-20231218071636505.png)

step-7

![image-20231218071727758](figures/image-20231218071727758.png)

step-8

![image-20231218071812388](figures/image-20231218071812388.png)

step-9



![image-20231218071854592](figures/image-20231218071854592.png)

```
(define (solve-2nd a b y0 dy0 dt)
  (~>> (zero)
       (c-loop (~>> (== _ (~>> (c-reg dy0)
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
                               ))
                    2>
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
