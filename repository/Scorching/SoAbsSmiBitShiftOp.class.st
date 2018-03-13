"
I represent bitShift without overflow between small integers.

Receiver >= 0.
Result >= 0 and result <= some value depending on subclass.



"
Class {
	#name : #SoAbsSmiBitShiftOp,
	#superclass : #SoAbsSmiBitOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #testing }
SoAbsSmiBitShiftOp >> hasRangeInformation [
	"Can be true when unchecking but not now without E-SSA"
	^ receiver hasRangeInformation and: [ self firstArg hasRangeInformation ]
]

{ #category : #traversing }
SoAbsSmiBitShiftOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiBitShiftOp: self
]

{ #category : #primitive }
SoAbsSmiBitShiftOp >> safePrimitiveNumber [
	^ 17
]
