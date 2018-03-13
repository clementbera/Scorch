"
Instruction converting immediate object into an integer
"
Class {
	#name : #SoAbsImmediateAsIntegerOp,
	#superclass : #SoAbsUnsafeOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #type }
SoAbsImmediateAsIntegerOp >> basicTypeInformation [
	^ SoType smi
]

{ #category : #primitive }
SoAbsImmediateAsIntegerOp >> safePrimitiveNumber [
	^ ImmediateAsInteger
]
