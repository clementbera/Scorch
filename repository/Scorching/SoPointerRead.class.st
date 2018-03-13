"
This instruction reads a pointer at the given index. This is typically used for inst var reads or #at:.

The object is guaranteed to be a pointer object and not a context. This can work on CompiledCode (optimiser responsible to deal with literal range).


"
Class {
	#name : #SoPointerRead,
	#superclass : #SoAbsObjectRead,
	#instVars : [
		'type'
	],
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #types }
SoPointerRead >> basicTypeInformation [
	| cst cls |
	object isConstant ifFalse: [ ^ type ]. 
	type hasOneType ifTrue: [ ^ type ].
	cst := object constant.
	cst isArray ifFalse: [ ^ type ].
	cst size > 1000 ifTrue: [ ^ type ]. "can't waste too much time"
	cls := cst first class.
	(cst allSatisfy: [ :e | e class = cls ]) ifFalse: [ ^ type ].
	^ type := SoKnownType for: cls
]

{ #category : #initialization }
SoPointerRead >> initialize [

	super initialize.

	type := SoUnknownType default
]

{ #category : #traversing }
SoPointerRead >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traversePointerRead: self
]

{ #category : #primitive }
SoPointerRead >> primitiveNumber [
	^ 2064
]

{ #category : #accessing }
SoPointerRead >> type [
	<generated>
	^ type
]

{ #category : #accessing }
SoPointerRead >> type: aValue [
	<generated>
	type := aValue
]
