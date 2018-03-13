"
Smi substraction with no overflow check.

"
Class {
	#name : #SoSmiSubOp,
	#superclass : #SoAbsSmiArithmeticOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #testing }
SoSmiSubOp >> hasRangeInformation [
	"Can be true when unchecking but not now without E-SSA"
	^ receiver hasRangeInformation and: [ self firstArg hasRangeInformation ]
]

{ #category : #traversing }
SoSmiSubOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiSubOp: self
]

{ #category : #primitive }
SoSmiSubOp >> primitiveNumber [
	^ 2001
]

{ #category : #types }
SoSmiSubOp >> rangeInformation [
	^ receiver rangeInformation 
		subRange: self firstArg rangeInformation
		onOverflow: [ 
			"Due to the way the cfg was edited, the correct range can't be solved any more by the range solver."
			^ SoRange fullRange ]
]

{ #category : #primitive }
SoSmiSubOp >> safePrimitiveNumber [
	^ 2
]
