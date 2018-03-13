"
Does not check for forwarder. If the object's type is known, replace this node by a constant.
"
Class {
	#name : #SoRawClassOp,
	#superclass : #SoAbsUnsafeOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #testing }
SoRawClassOp >> cannotBeForwarded [
	^ false
]

{ #category : #traversing }
SoRawClassOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseRawClassOp: self
]

{ #category : #primitive }
SoRawClassOp >> primitiveNumber [
	^ 1000
]

{ #category : #primitive }
SoRawClassOp >> safePrimitiveNumber [
	^ 111
]
