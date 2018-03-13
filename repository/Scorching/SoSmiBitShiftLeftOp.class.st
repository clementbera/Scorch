Class {
	#name : #SoSmiBitShiftLeftOp,
	#superclass : #SoAbsSmiBitShiftOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiBitShiftLeftOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiBitShiftLeftOp: self
]

{ #category : #primitive }
SoSmiBitShiftLeftOp >> primitiveNumber [
	^ USmiBitShiftLeft
]

{ #category : #range }
SoSmiBitShiftLeftOp >> rangeInformation [
	^ receiver rangeInformation shiftLeft: self firstArg rangeInformation
]
