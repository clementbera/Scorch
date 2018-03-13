"
Same as superclass with immutability check on write.
"
Class {
	#name : #SoReadOnlyCheckPointerWrite,
	#superclass : #SoPointerWrite,
	#instVars : [
		'deoptInfo',
		'wasPopInto'
	],
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #conversion }
SoReadOnlyCheckPointerWrite >> asInstrWithoutChecks [
	^ SoPointerWrite new 	
		object: object;
		index: index;
		expression: expression;
		storeCheck: false;
		yourself
]

{ #category : #accessing }
SoReadOnlyCheckPointerWrite >> deoptInfo [
	<generated>
	^ deoptInfo
]

{ #category : #accessing }
SoReadOnlyCheckPointerWrite >> deoptInfo: aValue [
	<generated>
	aValue ifNotNil: [aValue instruction: self].
	deoptInfo := aValue
]

{ #category : #initialization }
SoReadOnlyCheckPointerWrite >> initialize [

	super initialize.

	wasPopInto := false.
]

{ #category : #testing }
SoReadOnlyCheckPointerWrite >> isMapped [
	^ true
]

{ #category : #traversing }
SoReadOnlyCheckPointerWrite >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseReadOnlyCheckPointerWrite: self
]

{ #category : #primitive }
SoReadOnlyCheckPointerWrite >> primitiveNumber [
	^ 150 + storeCheck asBit
]

{ #category : #accessing }
SoReadOnlyCheckPointerWrite >> wasPopInto [
	<generated>
	^ wasPopInto
]

{ #category : #accessing }
SoReadOnlyCheckPointerWrite >> wasPopInto: aValue [
	<generated>
	wasPopInto := aValue
]
