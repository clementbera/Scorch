Class {
	#name : #SoSmallFloatAsIntegerOp,
	#superclass : #SoAbsImmediateAsIntegerOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #traversing }
SoSmallFloatAsIntegerOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmallFloatAsIntegerOp: self
]

{ #category : #primitive }
SoSmallFloatAsIntegerOp >> primitiveNumber [
	^ 1031
]
