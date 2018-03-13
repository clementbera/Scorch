Class {
	#name : #SoSmiEqualOp,
	#superclass : #SoAbsSmiCompOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #testing }
SoSmiEqualOp >> isSmiEqualOp [
	^ true
]

{ #category : #traversing }
SoSmiEqualOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiEqualOp: self
]

{ #category : #primitive }
SoSmiEqualOp >> primitiveNumber [
	^ 2036
]

{ #category : #primitive }
SoSmiEqualOp >> safePrimitiveNumber [
	^ 7
]
