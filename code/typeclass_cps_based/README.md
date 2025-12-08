# CumulativeSemantics Lean Build Instructions

This irectory conatins the source code for the typeclass based implementation of cumulative abstract semantics.

## Prerequisites

- Install Lean 4 by following the instructions at <https://leanprover.github.io/>.
- Ensure that you have `lake` (Lean's package manager) installed, which comes with Lean 4.

## Building the Project

1. Open a terminal and navigate to the `typeclass_cps_based` directory.
2. Run the following command to build the project:

   ``` bash
   lake build
   ```

3. If the build is successful, you will see a message indicating that the build completed without errors.

## Running Tests

To view tests comparing the monolothic and concrete interpetation, go to the 'Tests' directory and view the ConcvMono.lean file.

To run a performance test on a while loop program, you can execute the following command in the terminal:

```bash
lake exe cumulativesemantics --while_perf --iterations <iterations>
```

This will run the following loop:

```python
x = 0
while (x < [iterations]) {
    x = x + 1
}
```

You can then profile this with your preferred profiling tool to analyze performance.
