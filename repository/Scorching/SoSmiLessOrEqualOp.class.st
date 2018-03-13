Class {
	#name : #SoSmiLessOrEqualOp,
	#superclass : #SoAbsSmiCompOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #testing }
SoSmiLessOrEqualOp >> isSmiLessOrLessOrEqual [
	^ true
]

{ #category : #traversing }
SoSmiLessOrEqualOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiLessOrEqualOp: self
]

{ #category : #primitive }
SoSmiLessOrEqualOp >> primitiveNumber [
	^ 2035
]

{ #category : #primitive }
SoSmiLessOrEqualOp >> safePrimitiveNumber [
	^ 5
]
