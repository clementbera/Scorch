Class {
	#name : #SoAbsHashOp,
	#superclass : #SoAbsUnsafeOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #types }
SoAbsHashOp >> basicTypeInformation [
	^ SoType smi
]

{ #category : #testing }
SoAbsHashOp >> hasRangeInformation [
	^ true
]

{ #category : #types }
SoAbsHashOp >> rangeInformation [
	"Needs to be 22 for Pharo identityHash uncheck nonsense."
	^ SoRange new
		minConstant: 0;
		maxConstant: 1 << 22 - 1;
		yourself
]
