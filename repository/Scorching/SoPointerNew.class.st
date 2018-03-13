"
Works only with fixed-sized (pointers) objects.

nilInit <boolean> if true, the object has its fields initialized to nil, else it's not initialized (raw data).
"
Class {
	#name : #SoPointerNew,
	#superclass : #SoAbsInstantiation,
	#pools : [
		'SoMemoryManagerConstants'
	],
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #accessing }
SoPointerNew >> instSize [
	^ behavior instSize
]

{ #category : #testing }
SoPointerNew >> isPointerNew [
	^ true
]

{ #category : #traversing }
SoPointerNew >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traversePointerNew: self
]

{ #category : #primitive }
SoPointerNew >> primitiveNumber [
	^ 1011 + needsInit not asBit
]
