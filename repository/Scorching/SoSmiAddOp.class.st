"
Smi addition with no overflow check.

Note: for canonicalization purpose, if there's a constant it's the first operand

Ex:
t + 1 -> t USmiAdd: 1
1 + t -> t USmiAdd: 1
t - 1 -> t USmiAdd: -1 
...
"
Class {
	#name : #SoSmiAddOp,
	#superclass : #SoAbsSmiArithmeticOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #'instance creation' }
SoSmiAddOp class >> fromSend: send [
	"Canonicalization"
	send receiver isConstant ifTrue: 
		[ ^ self new 	
				receiver: send firstArg;
				arguments: { send receiver };
				yourself ].
	^ super fromSend: send
]

{ #category : #types }
SoSmiAddOp >> hasRangeInformation [
	^  true
]

{ #category : #testing }
SoSmiAddOp >> isIteratorMutator [
	^ self isUncheckedAddConstant
]

{ #category : #testing }
SoSmiAddOp >> isSmiAddOp [
	^ true
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

{ #category : #types }
SoSmiAddOp >> nextIterator [
	^ receiver
]

{ #category : #primitive }
SoSmiAddOp >> primitiveNumber [
	<script>
	^ USmiAdd
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
	<script>
	^ Add
]
