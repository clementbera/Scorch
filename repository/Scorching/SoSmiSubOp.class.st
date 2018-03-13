"
Smi substraction with no overflow check.

For canonicalization purpose, if it's variable - cst, it should be canonicalized to SmiAddOp.
"
Class {
	#name : #SoSmiSubOp,
	#superclass : #SoAbsSmiArithmeticOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #'instance creation' }
SoSmiSubOp class >> fromSend: send [
	"Canonicalization"
	send firstArg isConstant ifTrue: 
		[ ^ SoSmiAddOp 	
				withReceiver: send receiver
				arguments: { SoConstant constant: (send firstArg constant negated) } ].
	^ super fromSend: send
]

{ #category : #testing }
SoSmiSubOp >> hasRangeInformation [
	"This is the most useful case right now"
	^ true
]

{ #category : #traversing }
SoSmiSubOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiSubOp: self
]

{ #category : #primitive }
SoSmiSubOp >> primitiveNumber [
	<script>
	^ USmiSub
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
	<script>
	^ Sub
]
