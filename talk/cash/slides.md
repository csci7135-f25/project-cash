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
# Cumulative Semantics

## Generic Interfaces for Abstract Domain Accumulation

<Toc v-click minDepth="1" maxDepth="2"></Toc>

---

# What does it mean to accumulate semantics?

- parametric functions allow for the decoupling of return value
    + but how can you parameterize the direction of evaluation?
    + this goes lower than type level constructs

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
    - A witness is an implementation the obeys this interface


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

# Resumptions and Continuations

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
# forwards
k(k(eval(s1,σ)), s2)
```
```elixir
# forwards
k(σ`, s2)
```
```elixir
# forwards
σ``
```
```elixir
# backwards
k(k(eval(s2,σ)), s1)
```
```elixir
# backwards
k(σ`, s1)
```
```elixir
# backwards
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

```elixir {*|1|12}
eval(e: expr, env): D \ {E,I} = match e
    | cst(n) => cstE(env, n)
    | var(x) => varE(env, x)
    | plus(e1, e2) => plusE(env, e1, e2)
    | ifnz(e1, e2, e3) =>
        ifE(
            env,
            e1,
            e3,
            e2,
        )
    | seq(e1, e2) => seqE(env, e1, e2)
```

---

# State Representations

---

# Cumulative Abstract Semantics

- *Elimination* interfaces eliminate the source syntax and have access to interpretation ecosystem (introduction, lowering interfaces).

- *Introduction* interfaces provide abstract-domain specific semantics to an evaluator.

- *Lowering* interfaces provide abstract domain operators.

---

# Changes to the Recipe

---
