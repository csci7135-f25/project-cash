import CumulativeSemantics.Concrete

inductive IntervalNum where
  | NegInf : IntervalNum
  | Num : Int → IntervalNum
  | PosInf : IntervalNum
  deriving Repr

inductive IntervalValue where
  | Bot : IntervalValue
  | Top : IntervalValue
  | UnitInterval : IntervalValue
  | Interval : IntervalNum → IntervalNum → IntervalValue
  | BoolInterval : Bool → IntervalValue
  deriving Repr

instance : Inhabited IntervalValue where
  default := IntervalValue.UnitInterval
instance : Bottom IntervalValue where
  Bot := .Bot

instance : BEq IntervalNum where
  beq n1 n2 := match n1, n2 with
    | .NegInf, .NegInf => true
    | .PosInf, .PosInf => true
    | .Num m1, .Num m2 => m1 == m2
    | _, _ => false

instance : Min IntervalNum where
  min n1 n2 := match n1, n2 with
    | .NegInf, _ => .NegInf
    | _, .NegInf => .NegInf
    | .Num x, .Num y => .Num (min x y)
    | .PosInf, .PosInf => .PosInf
    | .PosInf, .Num y => .Num y
    | .Num x, .PosInf => .Num x

instance : Max IntervalNum where
  max n1 n2 := match n1, n2 with
    | .PosInf, _ => .PosInf
    | _, .PosInf => .PosInf
    | .Num x, .Num y => .Num (max x y)
    | .NegInf, .NegInf => .NegInf
    | .NegInf, .Num y => .Num y
    | .Num x, .NegInf => .Num x

instance : HAdd IntervalNum IntervalNum IntervalNum where
  hAdd n1 n2 := match n1, n2 with
    | .NegInf, .PosInf => .NegInf -- undefined, but choose something
    | .PosInf, .NegInf => .NegInf -- undefined, but choose something
    | .NegInf, _ => .NegInf
    | _, .NegInf => .NegInf
    | .PosInf, _ => .PosInf
    | _, .PosInf => .PosInf
    | .Num x, .Num y => .Num (x + y)

instance : HAdd IntervalValue IntervalValue IntervalValue  where
  hAdd n1 n2 := match n1, n2 with
    | .Bot, _ => .Bot
    | _, .Bot => .Bot
    | .Top, _ => .Top
    | _, .Top => .Top
    | .Interval l1 u1, .Interval l2 u2 =>
      .Interval (l1 + l2) (u1 + u2)
    | _, _ => .Bot

instance : HSub IntervalNum IntervalNum IntervalNum where
  hSub n1 n2 := match n1, n2 with
    | .NegInf, .NegInf => .NegInf -- undefined, but choose something
    | .PosInf, .PosInf => .NegInf -- undefined, but choose something
    | .NegInf, _ => .NegInf
    | _, .PosInf => .NegInf
    | .PosInf, _ => .PosInf
    | _, .NegInf => .PosInf
    | .Num x, .Num y => .Num (x - y)

instance : HSub IntervalValue IntervalValue IntervalValue  where
  hSub n1 n2 := match n1, n2 with
    | .Bot, _ => .Bot
    | _, .Bot => .Bot
    | .Top, _ => .Top
    | _, .Top => .Top
    | .Interval l1 u1, .Interval l2 u2 =>
      .Interval (l1 - u2) (u1 - l2)
    | _, _ => .Bot

instance : HDiv IntervalNum IntervalNum IntervalNum where
  hDiv n1 n2 := match n1, n2 with
    | _, .NegInf => .NegInf -- undefined, but choose something
    | _, .PosInf => .NegInf -- undefined, but choose something
    | .NegInf, _ => .NegInf
    | .PosInf, _ => .PosInf
    | .Num x, .Num y =>
      if y == 0 then .NegInf else .Num (x / y)

instance : HDiv IntervalValue IntervalValue IntervalValue  where
  hDiv n1 n2 := match n1, n2 with
    | .Bot, _ => .Bot
    | _, .Bot => .Bot
    | .Top, _ => .Top
    | _, .Top => .Top
    | .Interval l1 u1, .Interval l2 u2 =>
      if l2 == .Num 0 || u2 == .Num 0 then .Bot
      else .Interval (l1 / u2) ( u1 / l2)
    | _, _ => .Bot

instance : HMul IntervalNum IntervalNum IntervalNum where
  hMul n1 n2 := match n1, n2 with
    | .NegInf, .NegInf => .PosInf
    | .PosInf, .PosInf => .PosInf
    | .NegInf, .PosInf => .NegInf
    | .PosInf, .NegInf => .NegInf
    | .NegInf, _ => .NegInf
    | _, .NegInf => .NegInf
    | .PosInf, _ => .PosInf
    | _, .PosInf => .PosInf
    | .Num x, .Num y => .Num (x * y)

instance : HMul IntervalValue IntervalValue IntervalValue  where
  hMul n1 n2 := match n1, n2 with
    | .Bot, _ => .Bot
    | _, .Bot => .Bot
    | .Top, _ => .Top
    | _, .Top => .Top
    | .Interval l1 u1, .Interval l2 u2 =>
      let candidates := [
        l1 * l2,
        l1 * u2,
        u1 * l2,
        u1 * u2
      ]
      .Interval (candidates.foldl min .PosInf) (candidates.foldl max .NegInf)
    | _, _ => .Bot

instance : β IntervalValue where
  beta v := match v with
    | .Bot => .Bot
    | .Top => .Top
    | .Unit => .UnitInterval
    | .Num n1 => .Interval (.Num n1) (.Num n1)
    | .Bool b => .BoolInterval b

-- instance : γ IntervalValue where
--   gamma v := match v with
--     | .Bot => .Bot
--     | .Top => .Top
--     | .UnitInterval => .Unit
--     | .Interval n1 n2 =>
--       match n1, n2 with
--       | .Num m1, .Num m2 =>
--         if m1 == m2 then .Num m1 else .Top
--       | _, _ => .Top
--     | .BoolInterval b => .Bool b

instance : BEq IntervalValue where
  beq v1 v2 := match v1, v2 with
    | .Bot, .Bot => true
    | .Top, .Top => true
    | .UnitInterval, .UnitInterval => true
    | .Interval n1 m1, .Interval n2 m2 => n1 == n2 && m1 == m2
    | .BoolInterval b1, .BoolInterval b2 => b1 == b2
    | _, _ => false

instance : Join IntervalValue where
  join v1 v2 := match v1, v2 with
    | .Bot, v => v
    | v, .Bot => v
    | .Top, _ => .Top
    | _, .Top => .Top
    | .UnitInterval, v => v
    | v, .UnitInterval => v
    | .Interval n1 m1, .Interval n2 m2 => .Interval (min n1 n2) (max m1 m2)
    | .BoolInterval b1, .BoolInterval b2 => if b1 == b2 then .BoolInterval b1 else .Top
    | _, _ => .Top

instance : LatOrder IntervalValue where
  leq v1 v2 := match v1, v2 with
    | .Bot, _ => true
    | _, .Top => true
    | .Top, _ => false
    | _, .Bot => false
    | .UnitInterval, .UnitInterval => true
    | .UnitInterval, _ => false
    | _, .UnitInterval => false
    | .Interval n1 m1, .Interval n2 m2 =>
      let lowerOk := match n1, n2 with
        | .NegInf, _ => true
        | _, .NegInf => false
        | .Num x, .Num y => x >= y
        | .PosInf, _ => false
        | _, .PosInf => true
      let upperOk := match m1, m2 with
        | .PosInf, _ => true
        | _, .PosInf => false
        | .Num x, .Num y => x <= y
        | .NegInf, _ => false
        | _, .NegInf => true
      lowerOk && upperOk
    | .BoolInterval b1, .BoolInterval b2 => b1 == b2
    | _, _ => false

abbrev IntervalStore := Store IntervalValue
instance : Bottom IntervalStore where
  Bot := Std.HashMap.emptyWithCapacity 0
instance : Get IntervalStore IntervalValue where
  get x s:= match s[x]? with
    | some v => v
    | none => default
instance : Put IntervalStore IntervalValue where
  put  x v s := s.insert x v

instance : BEq IntervalStore where
  beq r1 r2 :=
    r1.toList.all fun (k, v) =>
      match r2[k]? with
      | some v2 => v == v2
      | none => false &&
    r2.toList.all fun (k, v) =>
      match r1[k]? with
      | some v2 => v == v2
      | none => false

instance : Join IntervalStore where
  join ρ1 ρ2 :=
    if ρ1 == ⊥  then ρ2
    else if ρ2 == ⊥ then ρ1
    else
      let init := Std.HashMap.emptyWithCapacity (ρ1.size + ρ2.size)
      -- First, add all keys from ρ2 that are not in ρ1
      let acc1 := ρ2.toList.foldl (fun acc (k, v2) =>
        match ρ1[k]? with
        | some _ => acc  -- Will handle in next fold
        | none => acc.insert k v2
      ) init
      -- Then, add all keys from ρ1, joining with ρ2 values where they exist
      ρ1.toList.foldl (fun acc (k, v1) =>
        match ρ2[k]? with
        | some v2 => acc.insert k (v1 ⊔ v2)
        | none => acc.insert k v1
      ) acc1

instance : LatOrder IntervalStore where
  leq ρ1 ρ2 :=
    if ρ1 == ⊥ then true
    else if ρ2 == ⊥ then false
    else
      ρ1.toList.all fun (k, v1) =>
        match ρ2[k]? with
        | some v2 => v1 ⊑ v2
        | none => false

-- intro/elim handlers
-- reuse cstE
instance : CstI IntervalValue where
  cst v := β.beta v

-- reuse VarE
-- reuse VarI

-- reuse BinopE
instance : BinopI IntervalValue where
  binop v1 v2 op := match v1, v2, op with
    | .Bot, _, _ => .Bot
    | _, .Bot, _ => .Bot
    | .Top, _, _ => .Top
    | _, .Top, _ => .Top
    | .Interval l1 u1, .Interval l2 u2, op =>
      match op with
      | Op.Plus => v1 + v2
      | Op.Minus => v1 - v2
      | Op.Times => v1 * v2
      | Op.Divide => v1 / v2
      | Op.Equals => .BoolInterval (v1 == v2)
      | Op.Greater => (match l1, u1, l2, u2 with
          | _, _, .PosInf, _ => .BoolInterval false
          | _, _, _, .NegInf => .BoolInterval true
          | .PosInf, _, _, _ => .BoolInterval true
          | _, .NegInf, _, _ => .BoolInterval false
          | .Num n1, .Num m1, .Num n2, .Num m2 =>
            if m1 <= n2 then .BoolInterval false
            else if n1 > m2 then .BoolInterval true
            else .Top
          | _, _, _, _ => .Top
        )
      | Op.Less => (match l1, u1, l2, u2 with
          | _, _, .NegInf, _ => .BoolInterval false
          | _, _, _, .PosInf => .BoolInterval true
          | .NegInf, _, _, _ => .BoolInterval true
          | _, .PosInf, _, _ => .BoolInterval false
          | .Num n1, .Num m1, .Num n2, .Num m2 =>
            if n1 >= m2 then .BoolInterval false
            else if m1 < n2 then .BoolInterval true
            else .Top
          | _, _, _, _ => .Top
        )
      | _ => .Bot
    | .BoolInterval b1, .BoolInterval b2, Op.And =>
      .BoolInterval (b1 && b2)
    | .BoolInterval b1, .BoolInterval b2, Op.Or =>
      .BoolInterval (b1 || b2)
