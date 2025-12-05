import CumulativeSemantics.Classes

-- generic unsubstantiated interpreter
partial def eval {State δ : Type}
  [Inhabited δ]
  [CstE State δ] [VarE State δ] [BinopE State δ] [NegE State δ] [NamedExprE State δ]
  [AssignE State δ] [SkipE State δ] [IfE State δ] [SeqE State δ]
  [WhileE State δ]
  : Prog → State → (δ × State)
  | (.Exp e) => match e with
    | .Cst v => CstE.cst eval v
    | .Var x => VarE.var eval x
    | .Binop e1 e2 op => BinopE.binop eval e1 e2 op
    | .Neg e => NegE.neg eval e
    | .NamedExpr x e => NamedExprE.namedExpr eval x e
  | (.Stm s) => match s with
    | .Skip => SkipE.skip eval
    | .Assign x e => AssignE.assign eval x e
    | .If e t f => IfE.if_ eval e t f
    | .Seq s1 s2 => SeqE.seq eval s1 s2
    | .While e s1 => WhileE.while_ eval e s1
