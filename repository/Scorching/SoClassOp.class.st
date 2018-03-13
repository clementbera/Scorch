"
I represent class access operation
"
Class {
	#name : #SoClassOp,
	#superclass : #SoAbsUnsafeOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #traversing }
SoClassOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseClassOp: self
]

{ #category : #primitive }
SoClassOp >> safePrimitiveNumber [
	^ ClassPrim
]
