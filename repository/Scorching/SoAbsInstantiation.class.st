"
Instantiates an object, usually there is a exnsureEnoughSlots before.

needsInit <Boolean> ifTrue, the object is initiaized to 0 or nil, if false, the object initialization needs to be taken care in the instructions before the next interrupt point
"
Class {
	#name : #SoAbsInstantiation,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'behavior',
		'needsInit'
	],
	#pools : [
		'SoMemoryManagerConstants'
	],
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #accessing }
SoAbsInstantiation >> access [
	^ self
]

{ #category : #accessing }
SoAbsInstantiation >> basicTypeInformation [
	^ SoKnownType for: behavior
]

{ #category : #accessing }
SoAbsInstantiation >> behavior [
	<generated>
	^ behavior
]

{ #category : #accessing }
SoAbsInstantiation >> behavior: aValue [
	<generated>
	behavior := aValue
]

{ #category : #testing }
SoAbsInstantiation >> cannotBeForwarded [
	^ true
]

{ #category : #testing }
SoAbsInstantiation >> hasExactSize [
	^ true
]

{ #category : #accessing }
SoAbsInstantiation >> initConstant [
	^ SoConstant new
]

{ #category : #accessing }
SoAbsInstantiation >> initWriteAt: i [
	^ SoPointerWrite new
		object: self;
		index: (SoConstant constant: i);
		expression: (SoConstant new);
		storeCheck: false;
		yourself
]

{ #category : #initialization }
SoAbsInstantiation >> initialize [

	super initialize.

	needsInit := true.
]

{ #category : #testing }
SoAbsInstantiation >> isNew [
	^ true
]

{ #category : #testing }
SoAbsInstantiation >> isPointers [
	^ true
]

{ #category : #accessing }
SoAbsInstantiation >> needsInit [
	<generated>
	^ needsInit
]

{ #category : #accessing }
SoAbsInstantiation >> needsInit: aValue [
	<generated>
	needsInit := aValue
]

{ #category : #graphEdition }
SoAbsInstantiation >> removeInstr [
	self tryToPatchEnsureEnoughSlots.
	super removeInstr.
]

{ #category : #graphEdition }
SoAbsInstantiation >> tryToPatchEnsureEnoughSlots [
	| backwardInstr |
	self hasExactSize ifFalse: [ ^ self ].
	backwardInstr := self prevInstr.
	[ backwardInstr ifNil: [ ^ self ].
	 backwardInstr isEnsureEnoughSlots ifTrue: [ 
		backwardInstr numSlots isConstant ifFalse: [ ^ self ].
		backwardInstr numSlots: (SoConstant constant: backwardInstr numSlots constant - self instSize - 2).
		 ^ self ].
	 backwardInstr hasBreakingDeoptPoint ifTrue: [ ^ self ].
	 true ] whileTrue: [ backwardInstr := backwardInstr prevInstr ]
]
