"
Answers the number of slots including the inst var fields. 

Therefore, on some variable pointer objects, the inlined primitive needs to be substracted by a constant, the number of fixed field of the class, to inline the primitive for size. 

"
Class {
	#name : #SoAbsSizeOp,
	#superclass : #SoAbsUnsafeOp,
	#pools : [
		'SoMemoryManagerConstants'
	],
	#category : #'Scorching-Nodes-Op'
}

{ #category : #types }
SoAbsSizeOp >> basicTypeInformation [
	^ SoType smi
]

{ #category : #types }
SoAbsSizeOp >> hasRangeInformation [
	^ true
	
]

{ #category : #testing }
SoAbsSizeOp >> isSizeOp [
	^ true
]

{ #category : #types }
SoAbsSizeOp >> rangeInformation [
	^ SoRange new
		minConstant: 0;
		maxConstant: 0;
		maxArraySize: self;
		yourself
]
