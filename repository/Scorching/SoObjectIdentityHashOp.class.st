"
Specific hash for non immediates and non behavior.
Other versions exist for behaviors and immediates
"
Class {
	#name : #SoObjectIdentityHashOp,
	#superclass : #SoAbsHashOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #traversing }
SoObjectIdentityHashOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseObjectIdentityHashOp: self
]

{ #category : #primitive }
SoObjectIdentityHashOp >> primitiveNumber [
	^ 1020
]

{ #category : #primitive }
SoObjectIdentityHashOp >> safePrimitiveNumber [
	^ 75
]
