Extension { #name : #SoAbsSmiArithmeticOp }

{ #category : #'*ScorchingDev' }
SoAbsSmiArithmeticOp class >> table [
	^ #( 
	"For both operand Smis, careful otherwise !"
	"We know + and - can commute with each other, other operands can commute with themself only"
	" Associatif a * b <=> b * a
	  Commutatif (a * b ) * c <=> a * (b * c)
	  Elem neutre (identity) -> result is other operand
	  Elem absorbant -> result is elem absorbant."
	"Associatif, commutatif, elem neutre gauche, elem neutre droit, elem absorbant gauche, elem absorbant droit."
	(+ true true 0 0 nil nil)
	(- false false nil 0 nil nil)
	(* true true 1 1 0 0)
	(/ false false nil 1 0 nil)
	(\\ false false nil nil 0 nil)
	(bitShift: false false nil 0 0 nil)
	(// false false nil 1 0 nil)
	(bitAnd: true true -1 -1 0 0)
	(bitOr: true true 0 0 nil nil)
	(bitXor: true true 0 0 nil nil)
	)
]
