Class {
	#name : #SoBehaviorIdentityHashOp,
	#superclass : #SoAbsHashOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #traversing }
SoBehaviorIdentityHashOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseBehaviorIdentityHashOp: self
]

{ #category : #primitive }
SoBehaviorIdentityHashOp >> primitiveNumber [
	^ 1024
]

{ #category : #primitive }
SoBehaviorIdentityHashOp >> safePrimitiveNumber [
	^ 175
]
