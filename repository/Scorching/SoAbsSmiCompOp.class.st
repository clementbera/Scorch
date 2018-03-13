"
Uncheck comp operation: = < <= ~=.

> and >= are canonicalized as < or <=.

Machine code always compile a quick path when directly followed by a branch.
"
Class {
	#name : #SoAbsSmiCompOp,
	#superclass : #SoAbsSmiOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #type }
SoAbsSmiCompOp >> basicTypeInformation [
	^ SoType boolean
]

{ #category : #testing }
SoAbsSmiCompOp >> isSmiCompOp [
	^ true
]
