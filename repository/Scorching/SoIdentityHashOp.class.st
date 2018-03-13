"
Specific hash for non immediates and non behavior.
"
Class {
	#name : #SoIdentityHashOp,
	#superclass : #SoAbsHashOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #traversing }
SoIdentityHashOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseIdentityHashOp: self
]

{ #category : #primitive }
SoIdentityHashOp >> primitiveNumber [
	^ UIdentityHash
]

{ #category : #types }
SoIdentityHashOp >> rangeInformation [
	"Needs to be 22 for Pharo identityHash uncheck nonsense."
	^ SoRange new
		minConstant: 0;
		maxConstant: 1 << 22 - 1;
		yourself
]

{ #category : #primitive }
SoIdentityHashOp >> safePrimitiveNumber [
	^ IdentityHash
]
