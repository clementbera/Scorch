"
operation for #==

This operation does NOT check for forwarders.
"
Class {
	#name : #SoRawPointerEqualsOp,
	#superclass : #SoAbsPointerEqualsOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #traversing }
SoRawPointerEqualsOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseRawPointerEqualsOp: self
]

{ #category : #primitive }
SoRawPointerEqualsOp >> primitiveNumber [
	^ 2038
]

{ #category : #primitive }
SoRawPointerEqualsOp >> safePrimitiveNumber [
	^ 110  
]
