# MinMax

Example from https://homepage.cs.uiowa.edu/~tinelli/classes/181/Spring10/Notes/03-lustre.pdf

```
node MinMax(X : int)
returns (min, max : int); – several outputs
let
  min = X -> if (X < pre min) then X else pre min;
  max = X -> if (X > pre max) then X else pre max;
tel
```

<img src="figures/image-20231223153555572.png" alt="image-20231223153555572" width=50% />

```
(define-flow min
  (~>> (c-loop (~>> (== (-< _ _) (c-reg 0))
                    (-< (~>> (select 1))
                        (~>> (select 2 3)
                             (c-switch (% _ _)
                                       [< 1>]
                                       [else 2>])) )
                    c-->
                    (-< _ _)))
       ))
```

