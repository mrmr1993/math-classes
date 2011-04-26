Require
  stdlib_binary_integers Field QArith.Qfield theory.rationals.
Require Import
  Program Ring Morphisms QArith_base Qabs Qpower
  abstract_algebra interfaces.rationals 
  interfaces.orders interfaces.additional_operations
  field_of_fractions.

(* canonical names for relations/operations/constants: *)
Instance Q_eq: Equiv Q := Qeq.
Instance Q_0 : RingZero Q := 0%Q.
Instance Q_1 : RingOne Q := 1%Q.
Instance Q_opp : GroupInv Q := Qopp.
Instance Q_plus : RingPlus Q := Qplus.
Instance Q_mult : RingMult Q := Qmult.
Instance Q_mult_inv : DecMultInv Q := Qinv.

(* properties: *)
Instance: Setoid Q := {}.

Instance: DecField Q.
Proof dec_fields.from_stdlib_field_theory Qfield.Qsft eq_refl.

(* misc: *)
Instance: ∀ x y: Q, Decision (x = y) := Qeq_dec.

Instance inject_Z_Q: Coerce Z Q := inject_Z.

Instance: Proper ((=) ==> (=)) inject_Z. 
Proof. intros x y H. unfold inject_Z. repeat red. simpl. now rewrite H. Qed.

Instance: SemiRing_Morphism inject_Z. 
Proof.
  repeat (split; try apply _).
  intros x y. repeat red. simpl. now rewrite ?Zmult_1_r.
Qed.

Instance: Injective inject_Z.
Proof.
 constructor. 2: apply _.
 intros x y. change (x * 1 = y * 1 → x = y). rewrite 2!rings.mult_1_r. intuition.
Qed.

Program Definition Q_to_fracZ (x : Q) : Frac Z := frac (Qnum x) (Zpos (Qden x)) _.

Instance: Proper ((=) ==> (=)) Q_to_fracZ.
Proof. intros ? ? E. easy. Qed.

Instance: SemiRing_Morphism Q_to_fracZ.
Proof. repeat (split; try apply _). Qed.

Instance: Injective Q_to_fracZ.
Proof. split; try apply _. intros ? ? E. easy. Qed.

Instance: RationalsToFrac Q := rationals.alt_to_frac Q_to_fracZ.
Instance: Rationals Q := rationals.alt_Build_Rationals Q_to_fracZ inject_Z.

(* order: *)
Instance Q_le: Le Q := Qle.
Instance Q_lt: Lt Q := Qlt.

Instance: SemiRingOrder Q_le.
Proof.
  assert (PartialOrder Q_le).
   repeat (split; try apply _).
      exact Qle_refl.
    exact Qle_trans.
   exact Qle_antisym.
  apply (rings.from_ring_order (Rle:=Q_le)).
   repeat (split; try apply _).
   intros. apply Qplus_le_compat. now apply Qle_refl. easy.
  intros. now apply Qmult_le_0_compat.
Qed.

Instance: TotalRelation Q_le.
Proof.
  intros x y.
  destruct (Qlt_le_dec x y); auto.
  left. now apply Qlt_le_weak.
Qed.

Instance: FullPseudoSemiRingOrder Q_le Q_lt.
Proof.
  rapply (semirings.dec_full_pseudo_srorder (A:=Q)).
  split.
   intro. split. now apply Zorder.Zlt_le_weak. now apply Zorder.Zlt_not_eq.
  intros [E1 E2]. destruct (Zorder.Zle_lt_or_eq _ _ E1). easy. now destruct E2.
Qed.

Program Instance: ∀ x y: Q, Decision (x ≤ y) := λ y x, 
  match Qlt_le_dec x y with
  | left _ => right _
  | right _ => left _
  end.
Next Obligation. now apply Qlt_not_le. Qed. 

(* additional operations *)
Program Instance: Abs Q := Qabs.
Next Obligation.
  split; intros E.
   now apply Qabs_pos.
  now apply Qabs_neg.
Qed.

Instance Q_pow: Pow Q Z := Qpower.

Instance: IntPowSpec Q Z Q_pow.
Proof.
  split.
     apply _.
    reflexivity.
   exact Qpower_0. 
  intros. now apply Qpower_plus.
Qed.
