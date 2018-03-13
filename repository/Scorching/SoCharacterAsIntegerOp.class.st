"
Instruction converting Character instances into an integer (Char unboxing)
"
Class {
	#name : #SoCharacterAsIntegerOp,
	#superclass : #SoAbsImmediateAsIntegerOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #type }
SoCharacterAsIntegerOp >> hasRangeInformation [
	^ true
]

{ #category : #traversing }
SoCharacterAsIntegerOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseCharacterAsIntegerOp: self
]

{ #category : #primitive }
SoCharacterAsIntegerOp >> primitiveNumber [
	^ UCharacterAsInteger
]

{ #category : #type }
SoCharacterAsIntegerOp >> rangeInformation [
	^ SoRange new
		minConstant: 0;
		maxConstant: (1 << 30) - 1;
		yourself
		
]
