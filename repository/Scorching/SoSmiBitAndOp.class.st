Class {
	#name : #SoSmiBitAndOp,
	#superclass : #SoAbsSmiBitOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiBitAndOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiBitAndOp: self
]

{ #category : #primitive }
SoSmiBitAndOp >> primitiveNumber [
	^ 2016
]

{ #category : #primitive }
SoSmiBitAndOp >> safePrimitiveNumber [
	^ 14
]
