"
My arg is guaranteed to be non zero (In addition to my operands being Smis).

The operation does not check for overflow, basically does not deal with the case:
Smi minVal // -1.
The optimiser needs to prove the arg is non -1 OR that the receiver is not Smi minVal.

"
Class {
	#name : #SoSmiDivOp,
	#superclass : #SoAbsSmiArithmeticOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiDivOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiDivOp: self
]

{ #category : #primitive }
SoSmiDivOp >> primitiveNumber [
	^ 2004
]

{ #category : #primitive }
SoSmiDivOp >> safePrimitiveNumber [
	^ 12
]
