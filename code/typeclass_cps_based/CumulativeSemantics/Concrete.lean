import CumulativeSemantics.Eval
import Lean
-- concrete store as a map
abbrev Store (δ : Type) := Std.HashMap Ident δ

abbrev ConcStore := Store ConcreteValue

instance : BEq ConcreteValue where
  beq v1 v2 := match v1, v2 with
    | .Bot, .Bot => true
    | .Top, .Top => true
    | .Num n1, .Num n2 => n1 == n2
    | .Bool b1, .Bool b2 => b1 == b2
    | .Unit, .Unit => true
    | _, _ => false

instance : BEq ConcStore where
  beq ρ1 ρ2 :=
    if ρ1.size != ρ2.size then false
    else
      ρ1.fold (init := true) (fun acc k v =>
        acc && match ρ2[k]? with
          | some v2 => v == v2
          | none => false)

instance : BEq (ConcreteValue × ConcStore) where
  beq r1 r2 :=
    match r1, r2 with
    | (v1, ρ1), (v2, ρ2) =>
      v1 == v2 && ρ1 == ρ2

instance : Bottom ConcreteValue where
  Bot := .Bot

instance : Bottom ConcStore where
  Bot := Std.HashMap.emptyWithCapacity 0

instance : Get ConcStore ConcreteValue where
  get x s:= match s[x]? with
    | some v => v
    | none => default

instance : Put ConcStore ConcreteValue where
  put  x v s := s.insert x v

-- concrete lowering
instance : β ConcreteValue where
  beta v := v
-- instance : γ ConcreteValue where
--   gamma v := match v with
--     | .Bot =>
--     | .Top => Set.univ
--     | .Num n => { .Num n }
--     | .Bool b => { .Bool b }
--     | .Unit => { .Unit }

instance [Bottom ConcStore]: Assume ConcStore ConcreteValue where
  assume v ρ := match v with
    | .Bool true => ρ
    | .Bool false => ⊥
    | .Bot => ⊥
    | .Num n => if n !=0 then ρ else ⊥
    | _ => ⊥
  assumef v ρ := match v with
    | .Bool false => ρ
    | .Bool true => ⊥
    | .Bot => ⊥
    | .Num n => if n == 0 then ρ else ⊥
    | _ => ρ

instance : Join ConcreteValue where
  join v1 v2 := match v1, v2 with
    | .Bot, v => v
    | v, .Bot => v
    | .Top, _ => .Top
    | _, .Top => .Top
    | v1, v2 => if v1 == v2 then v1 else .Top

instance [Bottom ConcStore]: Join ConcStore where
  join ρ1 ρ2 :=
    if ρ1 == ⊥ then ρ2
    else if ρ2 == ⊥ then ρ1
    else
      let init := Std.HashMap.emptyWithCapacity (ρ1.size + ρ2.size)
      ρ1.fold (init := init) fun acc k v1 =>
        match ρ2[k]? with
        | some v2 => acc.insert k (v1 ⊔ v2)
        | none => acc.insert k v1
      |> fun acc =>
        ρ2.fold (init := acc) fun acc k v2 =>
          match acc[k]? with
          | some _ => acc
          | none => acc.insert k v2

instance : LatOrder ConcreteValue where
  leq v1 v2 := match v1, v2 with
    | .Bot, _ => true
    | _, .Top => true
    | v1, v2 => v1 == v2

instance : LatOrder ConcStore where
  leq ρ1 ρ2 :=
    ρ1.toList.all fun (k, v1) =>
      match ρ2[k]? with
      | some v2 => v1 ⊑ v2
      | none => false


-- instances of elim and intro handlers
instance {σ δ : Type} [CstI δ] : CstE σ δ where
  cst _ v ρ := (CstI.cst v, ρ)
instance : CstI ConcreteValue where
  cst v := v

instance {σ δ : Type} [VarI σ δ] : VarE σ δ where
  var _ x ρ := VarI.var x ρ
instance {σ δ : Type} [Get σ δ] : VarI σ δ where
  var x ρ := (Get.get x ρ, ρ)

instance {σ δ : Type} [BinopI δ] : BinopE σ δ where
  binop eval e1 e2 op ρ :=
    let (v1, ρ') := eval (.Exp e1) ρ
    let (v2, ρ'') := eval (.Exp e2) ρ'
    (BinopI.binop v1 v2 op, ρ'')
instance : BinopI ConcreteValue where
  binop v1 v2 op := match (v1, v2, op) with
    | (.Bot, _, _) => .Bot
    | (_, .Bot, _) => .Bot
    | (.Top, _, _) => .Top
    | (_, .Top, _) => .Top
    | (.Num n1, .Num n2, Op.Plus) => .Num (n1 + n2)
    | (.Num n1, .Num n2, Op.Minus) => .Num (n1 - n2)
    | (.Num n1, .Num n2, Op.Times) => .Num (n1 * n2)
    | (_, .Num 0, Op.Divide) => .Bot
    | (.Num n1, .Num n2, Op.Divide) => .Num (n1 / n2)
    | (.Num n1, .Num n2, Op.Equals) => .Bool (n1 == n2)
    | (.Num n1, .Num n2, Op.Greater) => .Bool (n1 > n2)
    | (.Num n1, .Num n2, Op.Less) => .Bool (n1 < n2)
    | (.Bool b1, .Bool b2, Op.And) => .Bool (b1 && b2)
    | (.Bool b1, .Bool b2, Op.Or) => .Bool (b1 || b2)
    | _ => .Bot

instance {σ δ : Type} [NegI δ] : NegE σ δ where
  neg eval e ρ :=
    let (v, ρ') := eval (.Exp e) ρ
    (NegI.neg v, ρ')
instance : NegI ConcreteValue where
  neg v := match v with
    | .Bot => .Bot
    | .Top => .Top
    | .Num n => .Num (-n)
    | .Bool b => .Bool (!b)
    | _ => .Bot

instance {σ δ : Type} [NamedExprI σ δ] : NamedExprE σ δ where
  namedExpr eval x e ρ :=
    let (v, ρ') := eval (.Exp e) ρ
    NamedExprI.namedExpr x v ρ'
instance {σ δ : Type} [Put σ δ] : NamedExprI σ δ where
  namedExpr x v ρ := (v, Put.put x v ρ)

-- stmts
instance {σ δ : Type}  [Inhabited δ] [SkipI σ δ] : SkipE σ δ where
  skip _ ρ :=
    (default, @SkipI.skip σ δ _ ρ (λ σ => σ))
instance {σ δ : Type} [Inhabited δ] : SkipI σ δ where
  skip ρ k := k ρ

instance {σ δ : Type} [AssignI σ δ] : AssignE σ δ where
  assign eval x e ρ :=
    let (v, ρ') := eval (.Exp e) ρ
    AssignI.assign x v ρ'
instance {σ δ : Type} [Inhabited δ] [Put σ δ] : AssignI σ δ where
  assign x v ρ := (default, Put.put x v ρ)

instance {σ δ : Type} [Inhabited δ] [IfI σ δ] [Assume σ δ] : IfE σ δ where
  if_ eval e t f ρ :=
    let (v, ρ') := eval (.Exp e) ρ
    let tk : σ → σ := λ σ => Assume.assume v (eval (.Stm t) σ).snd
    let fk : σ → σ := λ σ => Assume.assumef v (eval (.Stm f) σ).snd
    (default, @IfI.if_ σ δ _ ρ' tk fk)
instance {σ δ : Type}  [Join σ] : IfI σ δ where
  if_ ρ tk fk :=
    (tk ρ) ⊔ (fk ρ)

partial def lfp {α : Type} (f : α → α) (x : α) [Bottom α] [LatOrder α] : α :=
  let rec aux (current : α) :=
    let next := f current
    if next ⊑ ⊥ then current else
    if next ⊑ current then current
    else aux next
  aux x

instance {σ δ : Type} [Assume σ δ] [WhileI σ δ] [Inhabited δ] : WhileE σ δ where
  while_ eval e body ρ:=
    let k : σ → σ := fun σ =>
      let (v, σ') := eval (.Exp e) σ
      Assume.assume v (eval (.Stm body) σ').snd
    (default, @WhileI.while_ σ δ _ ρ k)

instance{σ δ: Type} [Bottom σ] [LatOrder σ]: WhileI σ δ where
  while_ (ρ:σ) cont := lfp cont ρ


instance {σ δ : Type} [Inhabited δ] [SeqI σ δ] : SeqE σ δ where
  seq eval s1 s2 ρ :=
    let s1k : σ → σ := fun σ => (eval (.Stm s1) σ).snd
    let s2k : σ → σ := fun σ => (eval (.Stm s2) σ).snd
    (default, @SeqI.seq σ δ _ ρ s1k s2k)
instance {σ δ : Type} [Join σ] : SeqI σ δ where
  seq ρ s1k s2k :=
    s2k (s1k ρ)

def conc_eval : Prog → ConcStore → (ConcreteValue × ConcStore) := eval

partial def conc_eval_monolithic : Prog → ConcStore → (ConcreteValue × ConcStore)
  | .Exp e, ρ => match e with
    | .Cst v => (v, ρ)
    | .Var x => match ρ[x]? with
      | some n => (n, ρ)
      | none => (.Bot, ρ)
    | .Binop e1 e2 op =>
      let (v1, ρ') := conc_eval_monolithic (.Exp e1) ρ
      let (v2, ρ'') := conc_eval_monolithic (.Exp e2) ρ'
      match (v1, v2, op) with
        | (.Bot, _, _) => (.Bot, ⊥)
        | (_, .Bot, _) => (.Bot, ⊥)
        | (.Top, _, _) => (.Top, ρ'')
        | (_, .Top, _) => (.Top, ρ'')
        | (.Num n1, .Num n2, Op.Plus) => (.Num (n1 + n2), ρ'')
        | (.Num n1, .Num n2, Op.Minus) => (.Num (n1 - n2), ρ'')
        | (.Num n1, .Num n2, Op.Times) => (.Num (n1 * n2), ρ'')
        | (_, .Num 0, Op.Divide) => (.Bot, ⊥)
        | (.Num n1, .Num n2, Op.Divide) => (.Num (n1 / n2), ρ'')
        | (.Num n1, .Num n2, Op.Equals) => (.Bool (n1 == n2), ρ'')
        | (.Num n1, .Num n2, Op.Greater) => (.Bool (n1 > n2), ρ'')
        | (.Num n1, .Num n2, Op.Less) => (.Bool (n1 < n2), ρ'')
        | (.Bool b1, .Bool b2, Op.And) => (.Bool (b1 && b2), ρ'')
        | (.Bool b1, .Bool b2, Op.Or) => (.Bool (b1 || b2), ρ'')
        | _ => (.Bot, ρ'')
    | .Neg e =>
      let (v, ρ') := conc_eval_monolithic (.Exp e) ρ
      match v with
        | .Bot => (.Bot, ⊥)
        | .Top => (.Top, ρ')
        | .Num n => (.Num (-n), ρ')
        | .Bool b => (.Bool (!b), ρ')
        | _ => (.Bot, ⊥)
    | .NamedExpr x e =>
      let (v, ρ') := conc_eval_monolithic (.Exp e) ρ
      (v, ρ'.insert x v)
  | .Stm s, ρ => match s with
    | .Skip =>
      (.Unit, ρ)
    | .Assign x e =>
      let (v, ρ') := conc_eval_monolithic (.Exp e) ρ
      (.Unit, ρ'.insert x v)
    | .If e t f =>
      let (v, ρ') := conc_eval_monolithic (.Exp e) ρ
      let (_, tρ) := conc_eval_monolithic (.Stm t) ρ'
      let (_, fρ) := conc_eval_monolithic (.Stm f) ρ'
      match v with
        | .Bool true => (.Unit, tρ)
        | .Bool false => (.Unit, fρ)
        | .Bot => (.Unit, ⊥)
        | _ => (.Unit, ⊥)
    | .Seq s1 s2 =>
      let (_, ρ') := conc_eval_monolithic (.Stm s1) ρ
      conc_eval_monolithic (.Stm s2) ρ'
    | .While e body =>
      let (v, ρ') := conc_eval_monolithic (.Exp e) ρ
      match v with
        | .Bool true =>
          let (_, bodyρ) := conc_eval_monolithic (.Stm body) ρ'
          conc_eval_monolithic (.Stm (.While e body)) bodyρ
        | .Bool false => (.Unit, ρ')
        | .Bot => (.Unit, ⊥)
        | .Num n => if n != 0 then
            let (_, bodyρ) := conc_eval_monolithic (.Stm body) ρ'
            conc_eval_monolithic (.Stm (.While e body)) bodyρ
          else (.Unit, ρ')
        | _ => (.Unit, ⊥)
