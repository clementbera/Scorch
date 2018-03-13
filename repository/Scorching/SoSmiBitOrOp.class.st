Class {
	#name : #SoSmiBitOrOp,
	#superclass : #SoAbsSmiBitOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiBitOrOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiBitOrOp: self
]

{ #category : #primitive }
SoSmiBitOrOp >> primitiveNumber [
	^ 2017
]

{ #category : #primitive }
SoSmiBitOrOp >> safePrimitiveNumber [
	^ 15
]
