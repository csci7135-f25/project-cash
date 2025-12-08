import CumulativeSemantics.Concrete

def test_while(iter:Nat) : IO Nat := do
  let test_prog : Prog :=
    .Stm (
      .Seq
        (.Assign "x" (.Cst (.Num 0)))
        (.While
          (.Binop (.Var "x") (.Cst (.Num iter)) Op.Less)
          (.Assign "x" (.Binop (.Var "x") (.Cst (.Num 1)) Op.Plus))
        )
    )
  let emptyState : ConcStore := Std.HashMap.emptyWithCapacity 10

  IO.println s!"Running while loop with {iter} iterations..."
  -- run the program
  let (_, _) :=  conc_eval test_prog emptyState

  IO.println s!"Completed while loop with {iter} iterations"
  return iter
