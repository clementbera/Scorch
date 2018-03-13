"
No overflow.
"
Class {
	#name : #SoSmiMulOp,
	#superclass : #SoAbsSmiArithmeticOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiMulOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiMulOp: self
]

{ #category : #primitive }
SoSmiMulOp >> primitiveNumber [
	^ 2002
]

{ #category : #primitive }
SoSmiMulOp >> safePrimitiveNumber [
	^ 9
]
