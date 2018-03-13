"
My arg is guaranteed to be non zero (In addition to my operands being Smis).

The operation does not check for overflow, basically does not deal with the case:
Smi minVal // -1.
The optimiser needs to prove the arg is non -1 OR that the receiver is not Smi minVal.

"
Class {
	#name : #SoSmiQuoOp,
	#superclass : #SoAbsSmiArithmeticOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiQuoOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiQuoOp: self
]

{ #category : #primitive }
SoSmiQuoOp >> primitiveNumber [
	^ 2006
]

{ #category : #primitive }
SoSmiQuoOp >> safePrimitiveNumber [
	^ 13
]
