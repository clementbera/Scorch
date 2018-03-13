"
Works only with fixed-sized (pointers) objects.

nilInit <boolean> if true, the object has its fields initialized to nil, else it's not initialized (raw data).
"
Class {
	#name : #SoNewOp,
	#superclass : #SoAbsInstantiationOp,
	#instVars : [
		'nilInit'
	],
	#pools : [
		'SoMemoryManagerConstants'
	],
	#category : #'Scorching-Nodes-Op'
}

{ #category : #accessing }
SoNewOp >> basicTypeInformation [
	self 
		assert: receiver isConstant
		description: 'Invalid UNew'.
	^ SoKnownType for: receiver constant
]

{ #category : #initialization }
SoNewOp >> initialize [

	super initialize.

	nilInit := true.
]

{ #category : #testing }
SoNewOp >> isNew [
	^ true
]

{ #category : #traversing }
SoNewOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseNewOp: self
]

{ #category : #accessing }
SoNewOp >> nilInit [
	<generated>
	^ nilInit
]

{ #category : #accessing }
SoNewOp >> nilInit: aValue [
	<generated>
	nilInit := aValue
]

{ #category : #accessing }
SoNewOp >> primitiveNumber [
	^ UPointerNew
]

{ #category : #accessing }
SoNewOp >> safePrimitiveNumber [
	^ New
]
