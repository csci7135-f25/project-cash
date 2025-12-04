
abbrev Ident := String
abbrev Num := Int

inductive ConcreteValue where
  | Top
  | Num : Int → ConcreteValue
  | Bool : Bool → ConcreteValue
  | Unit
  | Bot
deriving Repr

instance : Inhabited ConcreteValue where
  default := ConcreteValue.Unit

inductive Op where
  | Plus
  | Minus
  | Times
  | Divide
  | Equals
  | Greater
  | Less
  | And
  | Or

inductive Expr where
  | Cst: ConcreteValue → Expr --computation
  | Var: Ident → Expr -- state
  | Binop: Expr → Expr → Op → Expr --computation
  | Neg: Expr → Expr --computation
  | NamedExpr: Ident → Expr → Expr --state

inductive Stmt where
  | Assign: Ident → Expr → Stmt --state
  | If: Expr → Stmt → Stmt → Stmt --ctrl flow
  | Seq: Stmt → Stmt → Stmt -- structure?
  | While: Expr → Stmt → Stmt --ctrl flow

inductive Prog where
  | Exp: Expr → Prog --δ
  | Stm: Stmt → Prog --State
