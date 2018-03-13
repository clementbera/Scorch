"
This instruction writes a pointer at the given index. This is typically used for inst var writes or #at:put:.

The object is guaranteed to be a pointer object and not a context. This can work on CompiledCode (optimiser responsible to deal with literal range).

storeCheck <Boolean> true if a store chekc is required. Note that the JIT assumes the optimiser is responsible in dealing with store checks, hence this needs to be set to false for immediates and things like that.
"
Class {
	#name : #SoPointerWrite,
	#superclass : #SoAbsObjectWrite,
	#instVars : [
		'storeCheck'
	],
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #conversion }
SoPointerWrite >> asInstrWithoutChecks [
	storeCheck := false
]

{ #category : #initialization }
SoPointerWrite >> checkStoreCheck [
	expression isConstant ifTrue: [ storeCheck := false ].
	(expression isRead and: [expression object = object]) ifTrue: [ storeCheck := false ].
]

{ #category : #initialization }
SoPointerWrite >> initialize [

	super initialize.

	storeCheck := true.
]

{ #category : #traversing }
SoPointerWrite >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traversePointerWrite: self
]

{ #category : #primitive }
SoPointerWrite >> primitiveNumber [
	^ 3000 + storeCheck asBit
]

{ #category : #accessing }
SoPointerWrite >> storeCheck [
	<generated>
	^ storeCheck
]

{ #category : #accessing }
SoPointerWrite >> storeCheck: aValue [
	<generated>
	storeCheck := aValue
]
