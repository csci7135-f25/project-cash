import CumulativeSemantics.Concrete

-- Test Program 1: Expression-heavy program using all binops
def testProg1 : Prog :=
  .Exp (
    (.Binop (.NamedExpr "x" (
      .NamedExpr "y" (
        .Binop
          (.Binop
            (.Cst (.Num 10))
            (.Cst (.Num 5))
            Op.Plus)
          (.Binop
            (.Cst (.Num 8))
            (.Cst (.Num 2))
            Op.Minus)
          Op.Times)))
        (.NamedExpr "z" (
          .Binop
            (.Cst (.Num 20))
            (.Binop
              (.Cst (.Num 4))
              (.Cst (.Num 2))
              Op.Times)
            Op.Divide))
        Op.Less))
/- In python:
(x := (y := (10 + 5) * (8 - 2))) < (z := (20/(4 *2))))
-/

-- Test Program 2: Statements with sequencing, if, and three variables
def testProg2 : Prog :=
  .Stm (
    .Seq
      (.Seq
        (.Assign "x" (.Cst (.Num 10)))
        (.Assign "z" (.Cst (.Num 0)))
      )
      (.Seq
        (.Assign "y" (.Binop (.Var "x") (.Cst (.Num 5)) Op.Plus))
        (.Seq
          (.If
            (.Binop (.Var "x") (.Var "y") Op.Less)
            (.Assign "z" (.Binop (.Var "y") (.Cst (.Num 2)) Op.Times))
            (.Assign "z" (.Binop (.Var "x") (.Cst (.Num 3)) Op.Divide)))
          (.Seq
            (.If
              (.Binop (.Var "z") (.Cst (.Num 20)) Op.Greater)
              (.Assign "x" (.Binop (.Var "z") (.Var "y") Op.Minus))
              (.Assign "x" (.Binop (.Var "y") (.Var "z") Op.Plus)))
            (.If
              (.Binop
                (.Binop (.Var "x") (.Cst (.Num 15)) Op.Equals)
                (.Binop (.Var "z") (.Cst (.Num 0)) Op.Greater)
                Op.And)
              (.Assign "y" (.Cst (.Num 100)))
              (.Assign "y" (.Cst (.Num 0))))))))

/- In python:
x = 10
y = x + 5
if x < y:
    z = y * 2
else:
    z = x / 3
if z > 20:
    x = z - y
else:
    x = y + z
if (x == 15) and (z > 0):
    y = 100
else:
    y = 0
-/
-- Test Program 3: Different structure with three variables and all remaining binops
def testProg3 : Prog :=
  .Stm (
    .Seq
      (.Assign "a" (.Cst (.Num 7)))
      (.Seq
        (.Assign "b" (.NamedExpr "x" (.Binop (.Var "a") (.Cst (.Num 3)) Op.Times)))
        (.Seq
          (.If
            (.NamedExpr "y" (
              .Binop
                (.Binop (.Var "a") (.Cst (.Num 5)) Op.Greater)
                (.Binop (.Var "b") (.Cst (.Num 25)) Op.Less)
                Op.Or)
            )
            (.Assign "c" (.Binop (.Var "b") (.Var "a") Op.Divide))
            (.Assign "c" (.Binop (.Var "a") (.Var "b") Op.Minus)))
          (.Seq
            (.If
              (.Binop (.Var "c") (.Cst (.Num 3)) Op.Equals)
              (.Assign "b" (.NamedExpr "z" (.Binop (.Var "c") (.Cst (.Num 10)) Op.Plus)))
              (.Assign "a" (.Neg (.Var "c"))))
            (.Seq
              (.Assign "c" (.Binop (.Var "a") (.Cst (.Num 2)) Op.Times))
              (.If
                (.NamedExpr "w" (
                  .Binop
                    (.Binop (.Var "b") (.Var "c") Op.Greater)
                    (.Binop (.Var "a") (.Cst (.Num 0)) Op.Equals)
                    Op.And)
                )
                (.Assign "a" (.Binop (.Var "b") (.Var "c") Op.Divide))
                (.Assign "b" (.Binop (.Var "c") (.Var "a") Op.Minus)))
            )
          )
        )
      )
  )
/- In python:
a = 7
b = (x := a * 3)
if (y := (a > 5) or (b < 25)):
    c = b / a
else:
    c = a - b
if c == 3:
    b = (z := c + 10)
else:
    a = -c
c = a * 2
if (w := (b > c) and (a == 0)):
    a = b / c
else:
    b = c - a
-/

-- Test Program 4: While loop test
def testProg4 : Prog :=
  .Stm (
    .Seq
      (.Seq
          (.Assign "i" (.Cst (.Num 0)))
          (.Assign "sum" (.Cst (.Num 0)))
      )
      (.While
        (.Binop (.Var "i") (.Cst (.Num 5)) Op.Less)
        (.Seq
          (.Assign "i" (.Binop (.Var "i") (.Cst (.Num 1)) Op.Plus))
          (.Assign "sum" (.Binop (.Var "sum") (.Var "i") Op.Plus))
        )
      )
  )
/- In python:
i = 0
sum = 0
while i < 5:
    i = i + 1
    sum = sum + i
-/

def emptyState : ConcStore := Std.HashMap.emptyWithCapacity 10

def result1 := conc_eval_monolithic testProg1 emptyState
def result2 := conc_eval_monolithic testProg2 emptyState
def result3 := conc_eval_monolithic testProg3 emptyState
def result4 := conc_eval_monolithic testProg4 emptyState

#eval result1
#eval result2
#eval result3
#eval result4

def cumulative_result1 := conc_eval testProg1 emptyState
def cumulative_result2 := conc_eval testProg2 emptyState
def cumulative_result3 := conc_eval testProg3 emptyState
def cumulative_result4 := conc_eval testProg4 emptyState

#eval cumulative_result1
#eval cumulative_result2
#eval cumulative_result3
#eval cumulative_result4

#guard result1 == cumulative_result1
#guard result2 == cumulative_result2
#guard result3 == cumulative_result3
#guard result4 == cumulative_result4
