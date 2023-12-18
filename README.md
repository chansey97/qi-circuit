



# Qi-circuit

The flows in Racket Qi can be viewed as stream functions if inputs and outputs are streams. We call them stream circuits; in some literature, they
are also referred to as signal flow graphs. Qi-circuit is a domain specific language to allow convenient creating such circuits.



## Core constructs

A large circuit can be constructed by combining small circuits. Qi-circuit currently provides 5 types of basic circuits:

- `(c-add op)` 

  ![image-20231218051343371](image-20231218051343371.png)

  Adder circuit. The `op` is a binary operator that can be `+` or `*`.

- `(c-mul x)` 

  ![image-20231218051622354](image-20231218051622354.png)

  Multiplier circuit scales the input stream by x times.

- `(c-convo s1 s2)` 

  ![image-20231218051729154](image-20231218051729154.png)

  Convolution circuit.

- `(c-reg init)` 

  ![image-20231218092559434](image-20231218092559434.png)

  Register circuit can be viewed as consisting of a one-place memory cell that initially contains the value `init`.

- `(c-loop sf)` 

  ![image-20231218053014367](image-20231218053014367.png)

  

## Behaviors

Although any Qi flow can be viewed a circuit as long as the inputs and outputs are streams, it's better to think of the inputs and outputs as signals, at time moments 0, 1, 2, ... For example:

![image-20231218035840532](image-20231218035840532.png)

The  $\sigma$, $\tau$, $\rho$ are streams, but you should think of them as signals. At moment $n \geq 0$, the adder simultaneously inputs the values $\sigma_n$ and $\tau_n$ at its input ends,and outputs their sum $\rho_n = \sigma_n + \tau_n$ at its output end.

Moreover, even though Qi-circuit is a purely functional programming language (i.e. no side effect), it's better to pretend that the circuits have memory. For example:

![image-20231218034832408](image-20231218034832408.png)

The register starts its activity, at time moment 0, by outputting its value 0 at its output end, while it simultaneously inputs the value $\sigma_0$ at its input end, which is stored in the memory cell. At any future time moment $n \geq 1$, the value $\tau_n=\sigma_{n-1}$ is output and the value $\sigma_{n}$ is input and stored.



## Examples

To effectively utilize Qi-circuit, there are two considerations:

1. Most known circuits are not written in Qi-circuit syntax. Typically, for ease of writing, they incorporate shorthands or "sugars" to streamline circuits. As a result, when constructing circuits with Qi-circuit, it is necessary to translate those circuits into Qi-circuit compatible equivalent circuits.
2. Handling circuits with feedback loops, especially in a [strict programming language](https://en.wikipedia.org/wiki/Strict_programming_language) such as Racket, is a challenge. The solution is still translating those circuits into equivalent circuits.

Note that equivalent circuits might look very different from the original circuits! The following will illustrate the two considerations through some concrete examples.

- [Sum](qi-circuit-examples/sum.md)
- [Integral](qi-circuit-examples/integral.md)
- [Fibonacci](qi-circuit-examples/fibonacci.md)
- [Solving ODE 1](qi-circuit-examples/ode-1st.md)
- [Solving ODE 2](qi-circuit-examples/ode-2nd.md)
- [Catalan numbers](qi-circuit-examples/catalan.md)



