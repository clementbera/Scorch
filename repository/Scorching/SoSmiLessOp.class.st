Class {
	#name : #SoSmiLessOp,
	#superclass : #SoAbsSmiCompOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #testing }
SoSmiLessOp >> isSmiLessOp [
	^ true
]

{ #category : #testing }
SoSmiLessOp >> isSmiLessOrLessOrEqual [
	^ true
]

{ #category : #traversing }
SoSmiLessOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiLessOp: self
]

{ #category : #primitive }
SoSmiLessOp >> primitiveNumber [
	^ 2033
]

{ #category : #primitive }
SoSmiLessOp >> safePrimitiveNumber [
	^ 3
]
