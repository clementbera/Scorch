"
operation for #~~

This operation does NOT check for forwarders.
"
Class {
	#name : #SoRawPointerNotEqualsOp,
	#superclass : #SoAbsPointerEqualsOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #traversing }
SoRawPointerNotEqualsOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseRawPointerNotEqualsOp: self
]

{ #category : #primitive }
SoRawPointerNotEqualsOp >> primitiveNumber [
	^ 2039
]

{ #category : #primitive }
SoRawPointerNotEqualsOp >> safePrimitiveNumber [
	^ 169
]
