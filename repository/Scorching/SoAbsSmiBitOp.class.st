"
I represent bit operations on Smis. 
Returned value is always a Smi.

Except bitShift, bit operation cant overflow.
"
Class {
	#name : #SoAbsSmiBitOp,
	#superclass : #SoAbsSmiOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #type }
SoAbsSmiBitOp >> hasRangeInformation [
	^ false
	"^ receiver hasRangeInformation and: [ self firstArg hasRangeInformation ]"
		
]

{ #category : #type }
SoAbsSmiBitOp >> rangeInformation [
	"just handle common case"
	(receiver rangeInformation isPositive and: [ self firstArg rangeInformation isPositive ]) ifFalse: [ ^ SoRange fullRange ].
	^SoRange new
		minConstant: 0;
		maxConstant: (receiver rangeInformation actualMaxVal 
			tryPrimitive: self safePrimitiveNumber 
			withArgs: {self firstArg rangeInformation actualMaxVal});
		yourself
]
