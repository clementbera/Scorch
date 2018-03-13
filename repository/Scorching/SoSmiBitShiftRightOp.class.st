Class {
	#name : #SoSmiBitShiftRightOp,
	#superclass : #SoAbsSmiBitShiftOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #static }
SoSmiBitShiftRightOp >> computeStatically [ 
	^ SoConstant constant: (receiver constant 
		tryPrimitive: self safePrimitiveNumber 
		withArgs: {self firstArg constant negated})
]

{ #category : #traversing }
SoSmiBitShiftRightOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiBitShiftRightOp: self
]

{ #category : #primitive }
SoSmiBitShiftRightOp >> primitiveNumber [
	^ USmiBitShiftRight
]

{ #category : #range }
SoSmiBitShiftRightOp >> rangeInformation [
	^ receiver hasRangeInformation 
		ifTrue: [ receiver rangeInformation shiftRight: self firstArg rangeInformation ]
		ifFalse: [ | max min |
			min := SmallInteger minVal >> (self firstArg rangeInformation actualMaxVal).
			max := SmallInteger maxVal >> (self firstArg rangeInformation actualMaxVal).
			SoRange new
				minConstant: min;
				maxConstant: max;
				yourself  ]
]
