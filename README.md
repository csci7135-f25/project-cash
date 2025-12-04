[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/KIMhwtUS)
# project

## Organization

This repository is organized as follows:

```
.
├── README.md
├── code
│   └── README.md
├── paper
│   ├── Makefile
│   ├── README.md
│   ├── paper.bib
│   ├── paper.pdf
│   └── paper.tex
└── talk
    ├── README.md
    └── talk.pptx
```

## Assignment

### Repository Instructions

Organize your project into the following directories:
- [code](code/) for your implementation or formalization;
- [paper](paper/) for your project paper; and
- [talk](talk/) for your project presentation slides.

Update this README to explain the organization of your final project. Rename files and edit this file as appropriate with your project name.

This repository has a paper and talk template. You may modify or replace these templates as you see fit.

## Handout

See the assignment [handout](https://pppa-course.github.io/pppa-course/assignments.html#final-projects) for further details and advice.

# Project Proposal

## Cumulative Semantics

- the kernel of the idea for our project remains the same
- this boils down to the accumulation ("cumulative") of semantic domains without creating an interpreter from scratch
- we have some notion of an effect or computation with a "promised implementation"
- this idea isn't locked into effect systems and can be achieved with type classes and CPS (passing around continuations).
- No matter the encapsulation tool two things must be implemented
    + **Elimination**
        - recursively evaluation ("eliminating") syntax
        - where the most nuanced usage of continuations appears
            + multi shot, backwards, forwards, etc...
    + **Introduction**
        - introduce semantics for the language being analyzed
        - called by *Elimination* handlers when the syntactic representation is encountered during evaluation

## Deliverables (artifacts)

- Andrew and I will work on two implementations of the aforementioned idea with a somewhat "real world" subset of either C or Python.
- The goal is to show that this idea is applicable to a real world analysis regardless of the implementation strategy. And then compare the potential benefits of one approach over another.
- must demonstrate the accumulation of semantics ie without changing what we have we can add without subtracting / refactoring.
- **Type classes, CPS, Monads** (Andrew)
    - using Lean4 with type classes, cps, and monads
    - serialize json representations of the source AST into our IR
    - represent a subset of C or Python and write a forwards (concrete will suffice) and backward goal directed analysis
- **Lexical Effect System** (Cade)
    - using Effekt with its lexical effect system
    - serialize json representations of the source AST into our IR
    - represent a subset of Python and write a concrete analysis, forwards interval analysis, and backward goal directed analysis.

## Conclusion

- once we have the two interpreters we can compare and contrast them across several metrics, although subjective
- Ease of implementation
    + effects should offer a "direct style" implementation which is rather easy to understand
    + type classes might be harder, but we don't know how much so. This will be subjective but we can measure with certain metrics
- Lines of code
    + how many lines of code is the "unsubstantiated" interpreter
    + how many lines of code are needed for each new domain
- performance
    + this is possibly the least important metric but it is important in one instance.
    + if one implementation is orders of magnitude slower it should be considered a *failure*
        - ie if it takes a minute to analyze a 10 line program the framework is unusable
    + within a certain boundary we can ignore performance differences
- Lean4
    + we get some aspect of verification with this implementation
    + but if the proofs required would be too terse to be practical that could be a draw back
    + what would we want to prove?
        + right now soundness is the only glaring proof
- Effekt
    + if we get much better performance and a significantly easier implementation this will be a win for effect systems
    + how much easier and how many fewer lines of code would signify this?

## Future / Related work

- In the same way that assembly can do all of the things that C does, monads can do all of the things effects can. However, This does not make C or Effects useless. At some point "quality" of life is worth research and worth pursuing.
    + as long as the underlying theory is behaving as it should, and faithfully implemented the tool of implementation is somewhat irrelevant.
- The purpose of a modular framework is to be extended, added to, hacked on, and built (ideally) by more people than its original creators.
- If the core of the framework is extremely complex this isn't a deal breaker as long as it is simple to extend, in our case this means adding domains. Most future work or contributions would be related to extension, resulting in the accumulation of domains.
- I can see two potential interpreters spawning from this project.
    + "Research Facing"
        - a Lean4 implementation would offer benefits to future research, especially in the world of verification.
        - it might be harder to extend or less performant for "real world" application, but the insights gained / theory proved sound would be extremely valuable
    + "Industry Facing"
        - If the Effekt variant is very performant, simple, and direct style, it would grow and be adopted at a faster rate than a cryptic, monadic implementation.
        - The core engine (elimination / introduction) effects and could be refactored more quickly, domains could be added more easily, and generated code would be more simple.
    + symbiosis
        - I think the most beneficial outcome would be to have two parallel implementations based on the same idea of "cumulative" semantics
        - one verified for soundness but potentially smaller, and not used for analyzing real code
        - one that is more readily extended and leads ahead of the verified implementation, but built with the same theory proven sound by its counterpart. In this way the two implementations would be like Compcert and GCC. Compcert is great but I doubt any of us have a single binary it has compiled across all of our machines.

## Proposal Q&A

- are we assuming this paper "introduces" cumulative effects or does the PEPM paper exist?
    - assume it exists but re-explain main points.
    - new goal from PEPM paper, different contribution.
- *lines of code*, what are we evaluating? 
    - why lines of code for *unsubstantiated*?
        + if fully code gen then it's irrelevant
        + goal is to make mechanical from the BNF
    + how many to add / edit for classic *monolithic interpreter*
- types of interpreters
    + classic monolithic 
    + just introduction
    + elimination + introduction
    + for each configuration how many loc get edited or added
    + need to add a monolithic interpreter in Effekt
- sequencing of things we can do...
    + don't lose sight of writing for implementation
    + goal is concrete and backwards symbolic but if that's not possible it's ok.
    + going more on implementation side then writing side
        * it's ok to be a little handwavy if we can demonstrate that it's possible
    + what is language extension path...
        + *pure expressions (arith) ->*
        + *conditionals (branching) ->*
        + *reading variables ->*
        + *writing variables ->*
        + *loops*
- paper structure
    + contribution is showing cumulative semantics
    + overview shows challenges and solution
    + evaluation metrics summarize case studies
    + implementation is contained in evaluation
    + technical meat of paper
        * structure interpreter in monolithic / non monolithic way what does that mean?
        * **catch up on** what is the technical meat section?
        + is there a translation from monolithic to our implementation?
            + want to **solidify a theory** for translation from one to the other
                * shows that there is a fundamental idea (cumulative semantics) that can be implemented regardless of the manifested implementation techniques.
            + describing generic alg from BNF to unsubstantiated interpretation
            + is it sound? does it preserve specific properties?
            + some sort of category theory diagram?
        * transfer from big step semantics to our semantics
            + natural deduction and sequence calculus
            + **nd**
                * elimination and introduction rules
                + intro rules are very visible
                + elimination rules
            + **sc**
                + elim -> left rules
                + intro -> right rules
                + *could we write big step eval be represented with sequential calculus?*
