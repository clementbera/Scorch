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
