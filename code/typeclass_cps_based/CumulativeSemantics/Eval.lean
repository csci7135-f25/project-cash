import CumulativeSemantics.Classes

-- generic unsubstantiated interpreter
partial def eval {σ δ : Type}
  [Inhabited δ]
  [CstE σ δ] [VarE σ δ] [BinopE σ δ] [NegE σ δ] [NamedExprE σ δ]
  [AssignE σ δ] [SkipE σ δ] [IfE σ δ] [SeqE σ δ]
  [WhileE σ δ]
  : Prog → σ → (δ × σ)
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
