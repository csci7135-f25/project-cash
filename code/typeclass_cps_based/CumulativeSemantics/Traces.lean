import CumulativeSemantics.Eval

-- define some simple store ρ, where ρ(x) gives me v, ρ(x←v) stores v at x in rho

-- judegment form is defined as ρ⊢s→ρ'
structure judgement (ρ p δ:Type) where
store : ρ
node : p
value : δ

-- big step derivation has a some number(0+) of premises (which are derivations themselves)
-- and one conclusion, which is a judgment form
inductive Derivation (ρ p δ : Type) where
  | mk : List (Derivation ρ p δ) → judgement ρ p δ → Derivation ρ p δ

-- and a function to print derivations into latex \frac format
