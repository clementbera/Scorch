"
Represent an access to a value on heap (not a value on stack). Such access needs to be scheduled.

If wrapped by a store, it's a store, else it's a read.


"
Class {
	#name : #SoHeapAccess,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'accessStrategy',
		'type'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #accessing }
SoHeapAccess >> accessID [
	^ self subclassResponsibility 
]

{ #category : #accessing }
SoHeapAccess >> accessStrategy [
	<generated>
	^ accessStrategy
]

{ #category : #accessing }
SoHeapAccess >> accessStrategy: aValue [
	<generated>
	accessStrategy := aValue
]

{ #category : #'graph edition' }
SoHeapAccess >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	accessStrategy expression: anotherNode.
	anotherNode addUse: self
]

{ #category : #type }
SoHeapAccess >> basicTypeInformation [
	^ type
]

{ #category : #accessing }
SoHeapAccess >> beWrite [
	accessStrategy := SoWrite new.
]

{ #category : #accessing }
SoHeapAccess >> deoptInfo [
	^ accessStrategy deoptInfo
]

{ #category : #accessing }
SoHeapAccess >> deoptInfo: x [
	accessStrategy deoptInfo: x
]

{ #category : #accessing }
SoHeapAccess >> expression [
	^ accessStrategy expression
]

{ #category : #accessing }
SoHeapAccess >> expression: expr [
	accessStrategy expression: expr.
	expr addUse: self
]

{ #category : #testing }
SoHeapAccess >> hasImmutabilityCheck [
	^ self hasDeoptInfo
]

{ #category : #initialization }
SoHeapAccess >> ignoreStoreCheck [
	^ accessStrategy ignoreStoreCheck
]

{ #category : #initialization }
SoHeapAccess >> ignoreStoreCheck: bool [
	^ accessStrategy ignoreStoreCheck: bool
]

{ #category : #initialization }
SoHeapAccess >> initialize [

	super initialize.

	accessStrategy := SoRead default.
	type := SoUnknownType default
]

{ #category : #initialization }
SoHeapAccess >> initializeStoreChecks: store [
	store ignoreStoreCheck: false.
]

{ #category : #testing }
SoHeapAccess >> isContextStore [
	^ false
]

{ #category : #testing }
SoHeapAccess >> isDefaultStore [
	"Answers false if the store needs specific flags in the bytecode, i.e., 
	the store check or immutability check is ignored."
	^ accessStrategy isDefaultStore and: [ self isContextStore not ]
]

{ #category : #testing }
SoHeapAccess >> isRead [
	^ self isWrite not
]

{ #category : #traversing }
SoHeapAccess >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseHeapAccess: self
]

{ #category : #testing }
SoHeapAccess >> isWrite [
	^ accessStrategy isWrite
]

{ #category : #'graph edition' }
SoHeapAccess >> postCopy [
	accessStrategy := accessStrategy copy.
	super postCopy
]

{ #category : #'graph edition' }
SoHeapAccess >> subNodes [
	<generated>
	^ accessStrategy subNodes
]

{ #category : #accessing }
SoHeapAccess >> type [
	^ type
]

{ #category : #accessing }
SoHeapAccess >> type: anObject [
	^ type := anObject
]
