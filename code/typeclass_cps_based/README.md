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

To view tests comparing the monolithic and concrete interpretation, go to the 'Tests' directory and view the `ConcvMono.lean` file.

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

To compare to a monolithic interpreter in lean, use the `--mono` flag:

```bash
lake exe cumulativesemantics --while_perf --mono --iterations <iterations>
```

This will run the same loop using the monolithic interpreter implementation.

## File Structure

- `CumulativeSemantics/Grammar.lean`: Contains the grammar for the language.
- `CumulativeSemantics/Eval.lean`: Contains the top level unsubstantiated interpreter.
- `CumulativeSemantics/Classes.lean`: Contains the typeclass defintions for the syntax.
- `CumulativeSemantics/Concrete.lean`: Contains the instances for concrete evaluation, as well as a concrete monolithic interpreter.
- `CumulativeSemantics/Tests/`: Contains test files for the cumulative semantics implementation.
- `Main.lean`: The main entry point for running the cumulative semantics tests and programs.
