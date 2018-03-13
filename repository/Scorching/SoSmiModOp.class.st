"
My arg is guaranteed to be non zero (In addition to my operands being Smis).

"
Class {
	#name : #SoSmiModOp,
	#superclass : #SoAbsSmiArithmeticOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiModOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiModOp: self
]

{ #category : #primitive }
SoSmiModOp >> primitiveNumber [
	^ 2005
]

{ #category : #primitive }
SoSmiModOp >> safePrimitiveNumber [
	^ 11
]
