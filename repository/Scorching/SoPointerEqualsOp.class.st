"
operation for #==

Encoded inlined in the default bytecode sets.

Note that this operation still checks for forwarders. Maybe we''ll have 2 in the future.
"
Class {
	#name : #SoPointerEqualsOp,
	#superclass : #SoAbsUnsafeOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #type }
SoPointerEqualsOp >> basicTypeInformation [
	^ SoType boolean
]

{ #category : #traversing }
SoPointerEqualsOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traversePointerEqualsOp: self
]

{ #category : #primitive }
SoPointerEqualsOp >> safePrimitiveNumber [
	^ PointerEquals  
]
