Class {
	#name : #SoSmiBitXorOp,
	#superclass : #SoAbsSmiBitOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiBitXorOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiBitXorOp: self
]

{ #category : #primitive }
SoSmiBitXorOp >> primitiveNumber [
	^ 2018
]

{ #category : #primitive }
SoSmiBitXorOp >> safePrimitiveNumber [
	^ 16
]
