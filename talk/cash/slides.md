---
# try also 'default' to start simple
theme: seriph
title: Cumulative Semantics
info: |
  ## Cumulative Semantics
  Leveraging Generic Interfaces for Abstract Domain Accumulation

# apply UnoCSS classes to the current slide
class: text-center
transition: slide-left
# enable MDC Syntax: https://sli.dev/features/mdc
mdc: true
hideInToc: true
---
# Cumulative Abstract Semantics

## Generic Interfaces for Abstract Domain Accumulation

<Toc v-click minDepth="1" maxDepth="2"></Toc>

---

# What Is Accumulation of Semantics?

- Parametric functions allow for the decoupling of return value
    + But how can you parameterize the direction of evaluation?
    + This goes lower than type level constructs

````md magic-move
```elixir
eval_forward(syntax, state): (Int, state')
```
```elixir
eval_forward_generic[D](syntax, state): (D, state')
```
```elixir
eval_bidirectional_generic[D](syntax, state): (D, state')
```
````

---

# Interfaces and Witnesses

- Type Classes allow polymorphism via the definition of an interface
    - A witness is an implementation that obeys this interface


```mermaid
graph TD
    A["Type Class: Eq a<br/>(Interface)"]
    B["eq :: a → a → Bool<br/>neq :: a → a → Bool"]
    
    C["Witness <br/>Instance: Eq Int"]
    D["Witness <br/>Instance: Eq String"]
    E["Witness <br/>Instance: Eq Bool"]
    
    
    A -->|defines| B
    A -->|has witness| C
    A -->|has witness| D
    A -->|has witness| E
    
    
    style A fill:#e1f5ff,stroke:#0066cc,stroke-width:3px,color:#000
    style B fill:#fff4e1,stroke:#ff9800,stroke-width:2px,color:#000
    style C fill:#e8f5e9,stroke:#4caf50,stroke-width:2px,color:#000
    style D fill:#e8f5e9,stroke:#4caf50,stroke-width:2px,color:#000
    style E fill:#e8f5e9,stroke:#4caf50,stroke-width:2px,color:#000
```

---

# Resumptions for Bidirectionality

```mermaid
graph LR
    Eval1["eval σ seq(s1, s2)"] -->|perform| HandlerF{Forwards}
    Eval1 -->|perform| HandlerR{Reverse}
    
    HandlerF --> Eval2F["eval σ s1"]
    Eval2F --> St1F["σ'"]
    St1F --> Eval3F["eval σ' s2"]
    Eval3F --> EndF([End])
    
    HandlerR --> Eval2R["eval σ s2"]
    Eval2R --> St1R["σ'"]
    St1R --> Eval3R["eval σ' s1"]
    Eval3R --> EndR([End])
    
    style Eval1 fill:#90caf9,stroke:#1976d2,stroke-width:3px,color:#000
    
    style HandlerF fill:#ff9800,stroke:#e65100,stroke-width:3px,color:#000
    style St1F fill:#bbdefb,stroke:#1976d2,stroke-width:2px,color:#000
    
    style Eval2F fill:#64b5f6,stroke:#1976d2,stroke-width:2px,color:#000
    style Eval3F fill:#42a5f5,stroke:#1976d2,stroke-width:2px,color:#000
    style EndF fill:#2196f3,stroke:#1565c0,stroke-width:2px,color:#fff
    
    style HandlerR fill:#4caf50,stroke:#2e7d32,stroke-width:3px,color:#fff
    style St1R fill:#e1bee7,stroke:#7b1fa2,stroke-width:2px,color:#000
    
    style Eval2R fill:#ba68c8,stroke:#7b1fa2,stroke-width:2px,color:#000
    style Eval3R fill:#ab47bc,stroke:#7b1fa2,stroke-width:2px,color:#000
    style EndR fill:#9c27b0,stroke:#6a1b9a,stroke-width:2px,color:#fff
```

````md magic-move
```elixir
def handle_forwards(s1, s2, k) =
    k(k(eval(s1,σ)), s2)
```
```elixir {2}
def handle_forwards(s1, s2, k) =
    k(σ`, s2)
```
```elixir
σ``
```
```elixir
def handle_backwards(s1, s2, k) =
    k(k(eval(s2,σ)), s1)
```
```elixir{2}
def handle_backwards(s1, s2, k) =
    k(σ`, s1)
```
```elixir
σ``
```

````

---

# Example Language

```
Expressions e ::= e
                 | cst(n)
                 | e1 + e2
                 | if(e1) e2 else e3
                 | var(x)
                 | seq(e1,e2)

Int         n ::= int
Ident       x ::= string
```

---
layout: two-cols
---

# Monolithic

```mermaid {scale: 0.75}
graph TD
    D["eval_rev: v̂"]
    E["eval: v"]
    F["eval_I: v̂"]
    
    
    style D fill:#fff,stroke:#333,stroke-width:2px,color:#000
    style E fill:#fff,stroke:#333,stroke-width:2px,color:#000
    style F fill:#fff,stroke:#333,stroke-width:2px,color:#000
    
    linkStyle default stroke:#333,stroke-width:2px,color:#000
```

::right::

````md magic-move
```elixir
def eval(e: expr, env:...): ...
```
```elixir
def eval(e: expr, env): int = match e
    ...
    | seq(e1, e2) => eval(e2, eval(e1, env))
```
```elixir {*|1}
def eval_I(e: expr, env): Interval = match e
    ...
    | seq(e1, e2) => eval(e2, eval(e1, env))
```
```elixir {*|1|3}
def eval_rev(e : expr, env_out): Set[str] = match e
    ...
    | seq(e1, e2) => eval(e1, eval(e2, env_out))
```
````

---
layout: two-cols
---

# Domain Generic

```mermaid {scale: 0.75}
graph TD
    B["eval_rev: D \ {I}"]
    C["eval: D \ {I}"]
    I1(("I"))
    I2(("I"))
    I3(("I"))
    D["eval_rev: v̂"]
    E["eval: v"]
    F["eval: v̂"]
    
    B --> I1
    I1 --> D
    
    C --> I2
    I2 --> E
    C --> I3
    I3 --> F
    
    style B fill:#fff,stroke:#333,stroke-width:2px,color:#000
    style C fill:#fff,stroke:#333,stroke-width:2px,color:#000
    style D fill:#fff,stroke:#333,stroke-width:2px,color:#000
    style E fill:#fff,stroke:#333,stroke-width:2px,color:#000
    style F fill:#fff,stroke:#333,stroke-width:2px,color:#000
    style I1 fill:#f0e1ff,stroke:#333,stroke-width:2px,color:#000
    style I2 fill:#f0e1ff,stroke:#333,stroke-width:2px,color:#000
    style I3 fill:#f0e1ff,stroke:#333,stroke-width:2px,color:#000
    
    linkStyle default stroke:#333,stroke-width:2px,color:#000
```

::right::

````md magic-move
```elixir {*|1|3|5}
eval(e: expr, env): D \ {I} = match e
    ...
    | plus(e1, e2) => plusI(eval(e1,env), eval(e2,env))
    ...
    | seq(e1, e2) => eval(e2, eval(e1, env))
```
```elixir {*|3}
eval_rev(e: expr, env): D \ {I} = match e
    ...
    | seq(e1, e2) => eval(e1, eval(e2, env))

```
````

---
layout: two-cols
---

# Complete Parametricity

```mermaid {scale: 0.75}
graph TD
    A["eval: D \ {E, I}"]
    E1(("E"))
    E2(("E"))
    E3(("E ∘ I"))
    B["eval_rev: D \ {I}"]
    C["eval: D \ {I}"]
    I1(("I"))
    I2(("I"))
    I3(("I"))
    D["eval_rev: v̂"]
    E["eval: v"]
    F["eval: v̂"]
    
    A --> E1
    E1 --> B
    A --> E3
    E3 --> E
    A --> E2
    E2 --> C
    
    B --> I1
    I1 --> D
    
    C --> I2
    I2 --> E
    C --> I3
    I3 --> F
    
    style A fill:#fff,stroke:#333,stroke-width:2px,color:#000
    style B fill:#fff,stroke:#333,stroke-width:2px,color:#000
    style C fill:#fff,stroke:#333,stroke-width:2px,color:#000
    style D fill:#fff,stroke:#333,stroke-width:2px,color:#000
    style E fill:#fff,stroke:#333,stroke-width:2px,color:#000
    style F fill:#fff,stroke:#333,stroke-width:2px,color:#000
    style E1 fill:#e1f5ff,stroke:#333,stroke-width:2px,color:#000
    style E2 fill:#e1f5ff,stroke:#333,stroke-width:2px,color:#000
    style E3 fill:#909fe2,stroke:#333,stroke-width:2px,color:#000
    style I1 fill:#f0e1ff,stroke:#333,stroke-width:2px,color:#000
    style I2 fill:#f0e1ff,stroke:#333,stroke-width:2px,color:#000
    style I3 fill:#f0e1ff,stroke:#333,stroke-width:2px,color:#000
    
    linkStyle default stroke:#333,stroke-width:2px,color:#000
```

::right::

````md magic-move
```elixir {*|1|7}
eval(e: expr, env): D \ {E,I} = match e
    | cst(n) => cstE(env, n)
    | var(x) => varE(env, x)
    | plus(e1, e2) => plusE(env, e1, e2)
    | ifnz(e1, e2, e3) =>
        ifE(env, e1, e3, e2)
    | seq(e1, e2) => seqE(env, e1, e2)
```
```elixir {*|5-8}
eval(e: expr, env): D \ {E,I} = match e
    ...
    | seq(e1, e2) => seqE(env, e1, e2)

def seqE(st, e1, e2) =
    st` = k(st, e1)
    st`` = k(st`, e2)
    seqI(st`, st``) 
```
```elixir {5-8}
eval(e: expr, env): D \ {E,I} = match e
    ...
    | seq(e1, e2) => seqE(env, e1, e2)

def seqE(st, e1, e2) =
    st` = k(st, e2)
    st`` = k(st`, e1)
    seqI(st`, st``) 
```
````

---

# Lowering Handlers

````md magic-move
```elixir {3-4}
eval(e: expr, env): D \ {E,I} = match e
    ...
    | ifnz(e1, e2, e3) =>
        ifE(env, e1, e3, e2)
```
```elixir {6-11}
eval(e: expr, env): D \ {E,I} = match e
    ...
    | ifnz(e1, e2, e3) =>
        ifE(env, e1, e3, e2)

def ifE(st, e1, e2, e3) =
    (g, st1) = k(st, e1)
    st2 = k(st1, e2)
    st3 = k(st1, e3)
    ifI(g, st2 , st3)
```
```elixir {7|8|9|10}
eval(e: expr, env): D \ {E,I} = match e
    ...
    | ifnz(e1, e2, e3) =>
        ifE(env, e1, e3, e2)

def ifE(st, e1, e2, e3) =
    (g, st1) = k(st, e1) # e1 ⇓ st
    st2 = k(st1, e2)     # e2 ⇓ st2
    st3 = k(st1, e3)     # e3 ⇓ st3
    ifI(g, st2 , st3) # pass resulting states to intro
```
```elixir {12-14|13|14}
eval(e: expr, env): D \ {E,I} = match e
    ...
    | ifnz(e1, e2, e3) =>
        ifE(env, e1, e3, e2)

def ifE(st, e1, e2, e3) =
    (g, st1) = k(st, e1)
    st2 = k(st1, e2)
    st3 = k(st1, e3)
    ifI(g, st2 , st3) 

def ifI(g, st2, st3) = match g
    | True  -> st2 # only use "then" state
    | False -> st3 # only use "else" state
```
```elixir {12-16|14-15|13}
eval(e: expr, env): D \ {E,I} = match e
    ...
    | ifnz(e1, e2, e3) =>
        ifE(env, e1, e3, e2)

def ifE(st, e1, e2, e3) =
    (g, st1) = k(st, e1)
    st2 = k(st1, e2)
    st3 = k(st1, e3)
    ifI(g, st2 , st3)

def ifI(g, st2, st3) =
    joinL( # deterime how to return / combine states
        assumeL(g, st2), 
        assumenotL(g, st3)
    )
```
````

---

# Cumulative Abstract Semantics

- *Elimination* handlers leverage continuations to eliminate the source syntax 
- *Introduction* witnesses provide abstract-domain specific semantics
- *Lowering* witnesses provide flow insensitive, reusable abstract domain operators

```mermaid
graph TB
    CumulativeSemantics["Cumulative Semantics"]
    CumulativeSemantics --> Witnesses
    CumulativeSemantics --> Handlers
    
    subgraph Witnesses["Introduction Witnesses"]
        Plus["plusI[D](a, b): D"]
        Plus --> PlusInt["plusI[Int](a, b) = a + b"]
        Plus --> PlusInterval["plusI[Interval](a, b) = <br/>  (a.l + b.l, a.h + b.h)"]
    end
    
    subgraph Handlers["Elimination Handlers"]
        Seq["seq"]
        Seq --> SeqForward["seqE(st, e1, e2) = <br/>  k(k(st, e1), e2)"]
        Seq --> SeqReverse["seqE(st, e1, e2) = <br/>  k(k(st, e2), e1)"]
    end
    
    style CumulativeSemantics fill:#e1d5f5,stroke:#6a1b9a,stroke-width:4px,color:#000
    style Plus fill:#e1f5ff,stroke:#0066cc,stroke-width:3px,color:#000
    style PlusInt fill:#e8f5e9,stroke:#4caf50,stroke-width:2px,color:#000
    style PlusInterval fill:#e8f5e9,stroke:#4caf50,stroke-width:2px,color:#000
    
    style Seq fill:#fff4e1,stroke:#ff9800,stroke-width:3px,color:#000
    style SeqForward fill:#ffccbc,stroke:#ff5722,stroke-width:2px,color:#000
    style SeqReverse fill:#ffccbc,stroke:#ff5722,stroke-width:2px,color:#000
    
    style Witnesses fill:#f0f8ff,stroke:#0066cc,stroke-width:2px
    style Handlers fill:#fff8f0,stroke:#ff9800,stroke-width:2px
```

---
layout: two-cols
---
# Changes to the Recipe

Standard Recipe:

 1. Syntax
 2. Concrete Interpreter
 3. Collect Semantics
 4. Abstract Domain
 5. Abstract Interpreter

::right::

<div v-click>

## New Recipe:

 1. Syntax
 2. Generic Interfaces
 3. Concrete (Elim & Intro)
 4. Collecting (Elim)
 5. Abstract Domain (Lowering)
 6. Abstract Interpreter (Intro, *Elim*)

</div>

---

# Performance

- running the following Python program in the **Concrete Domain** with our
    - Lean4 typeclass and CPS implementation *compiles to a C++ binary*
    - Effekt scoped effekt system implementation *compiles to LLVM*
```python
x = 0
while x < 1000000
    x += 1
print(x)
```

````md magic-move
```sh
# running python test code with performance tool 'hyperfine'
hyperfine 'python3 while_perf.py'
```
```sh
Benchmark 1: python3 while_perf.py
  Time (mean ± σ):      53.3 ms ±   6.7 ms    [User: 48.5 ms, System: 3.3 ms]
  Range (min … max):    45.7 ms …  76.8 ms    61 runs
```
```sh
# run lean4 binary with performance tool 'hyperfine'
hyperfine "./.lake/build/bin/cumulativesemantics --while_perf --iterations 1000000"
```
```sh
Benchmark 1: ./.lake/build/bin/cumulativesemantics --while_perf --iterations 1000000
  Time (mean ± σ):     321.2 ms ±   6.3 ms    [User: 315.1 ms, System: 2.7 ms]
  Range (min … max):   313.6 ms … 333.6 ms    10 runs
```
```sh
# run effekt LLVM binary with perfomance tool 'hyperfine'
hyperfine ./out/concrete
```
```sh
Benchmark 1: ./out/concrete
  Time (mean ± σ):     624.9 ms ±  10.1 ms    [User: 622.6 ms, System: 1.9 ms]
  Range (min … max):   605.0 ms … 639.6 ms    10 runs
```
````

---

# Questions?
