Class {
	#name : #SoCharacterIdentityHashOp,
	#superclass : #SoAbsHashOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #traversing }
SoCharacterIdentityHashOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseCharacterIdentityHashOp: self
]

{ #category : #primitive }
SoCharacterIdentityHashOp >> primitiveNumber [
	^ 1022
]

{ #category : #primitive }
SoCharacterIdentityHashOp >> safePrimitiveNumber [
	^ 171
]
