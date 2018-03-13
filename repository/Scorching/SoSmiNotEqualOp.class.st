Class {
	#name : #SoSmiNotEqualOp,
	#superclass : #SoAbsSmiCompOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiNotEqualOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiNotEqualOp: self
]

{ #category : #primitive }
SoSmiNotEqualOp >> primitiveNumber [
	^ 2037
]

{ #category : #primitive }
SoSmiNotEqualOp >> safePrimitiveNumber [
	^ 8
]
