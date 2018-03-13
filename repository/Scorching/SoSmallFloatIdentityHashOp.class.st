Class {
	#name : #SoSmallFloatIdentityHashOp,
	#superclass : #SoAbsHashOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #traversing }
SoSmallFloatIdentityHashOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmallFloatIdentityHashOp: self
]

{ #category : #primitive }
SoSmallFloatIdentityHashOp >> primitiveNumber [
	^ 1023
]

{ #category : #primitive }
SoSmallFloatIdentityHashOp >> safePrimitiveNumber [
	^ 171
]
