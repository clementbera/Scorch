"
Common superclass of the pointer Equals, ie #== operationss
"
Class {
	#name : #SoAbsPointerEqualsOp,
	#superclass : #SoAbsUnsafeOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #type }
SoAbsPointerEqualsOp >> basicTypeInformation [
	^ SoType boolean
]

{ #category : #testing }
SoAbsPointerEqualsOp >> isPointerEquals [
	^ true
]
