"
Specific operations for variable field access.

Note: these operations are 1-based based on the object's address. One has to shift pointer operations for variable objects with instance variables.
"
Class {
	#name : #SoAbsAccessingOp,
	#superclass : #SoAbsUnsafeOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #accessing }
SoAbsAccessingOp >> accessID [
	^ { receiver . self firstArg }
]

{ #category : #testing }
SoAbsAccessingOp >> isAccessingOp [
	^ true
]
