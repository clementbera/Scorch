"
Smi addition with no overflow check.

"
Class {
	#name : #SoSmiAddOp,
	#superclass : #SoAbsSmiArithmeticOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #types }
SoSmiAddOp >> hasRangeInformation [
	"Can be true when unchecking but not now without E-SSA"
	^ receiver hasRangeInformation and: [ self firstArg hasRangeInformation ]
]

{ #category : #'loop analysis' }
SoSmiAddOp >> isIteratorMutator: phi [
	self isUncheckedAddConstant ifTrue: [ ^ true ].
	(self isSub: receiver thePhi: phi) ifTrue: [ 
		^ self isPosOrNegRange: self firstArg ].
	(self isSub: self firstArg thePhi: phi) ifFalse: [ ^ false ].
	^ self isPosOrNegRange: receiver
]

{ #category : #'loop analysis' }
SoSmiAddOp >> isPosOrNegRange: sub [
	sub hasRangeInformation ifFalse: [ ^ false ].
	^ sub rangeInformation isPositiveOrNegative
]

{ #category : #testing }
SoSmiAddOp >> isSmiAddOp [
	^ true
]

{ #category : #'loop analysis' }
SoSmiAddOp >> isSub: sub thePhi: phi [ 
	| instr |
	"Take a short-cut here not to loop too much in range analysis"
	instr := sub.
	[ instr isPi ] whileTrue: [ instr := instr expression ].
	^ instr = phi
]

{ #category : #traversing }
SoSmiAddOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiAddOp: self
]

{ #category : #testing }
SoSmiAddOp >> isUncheckedAddConstant [
	"Due to canonicalization"
	^ self firstArg isSmiConstant
]

{ #category : #'loop analysis' }
SoSmiAddOp >> iteratorMutatorValue: phi [
	self isUncheckedAddConstant ifTrue: [ ^ self firstArg constant ].
	^ self iteratorMutatorValueOf: ((self isSub: receiver thePhi: phi) ifTrue: [ self firstArg ] ifFalse: [ receiver ])
]

{ #category : #'loop analysis' }
SoSmiAddOp >> iteratorMutatorValueOf: sub [
	| range |
	^ (range := sub rangeInformation) isPositive 
		ifTrue: [ range actualMaxVal ]
		ifFalse: [ range actualMinVal ] 
]

{ #category : #'loop analysis' }
SoSmiAddOp >> nextIterator: phi [
	self isUncheckedAddConstant ifTrue: [ ^ receiver ].
	^ (self isSub: receiver thePhi: phi)
		ifTrue: [ receiver ]
		ifFalse: [ self firstArg ]
]

{ #category : #primitive }
SoSmiAddOp >> primitiveNumber [
	^ 2000
]

{ #category : #types }
SoSmiAddOp >> rangeInformation [
	^ receiver rangeInformation 
		addRange: self firstArg rangeInformation
		onOverflow: [ 
			"Due to the way the cfg was edited, the correct range can't be solved any more by the range solver."
			^ SoRange fullRange ]
]

{ #category : #primitive }
SoSmiAddOp >> safePrimitiveNumber [
	^  1
]
