"
Specific nodes for Smi arithmetic. They expect receiver and argument1 to be a SmallInteger.

These nodes does *not* check for overflow in machine code and do not check the types of receiver and arguments.
"
Class {
	#name : #SoAbsSmiOp,
	#superclass : #SoAbsUnsafeOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #type }
SoAbsSmiOp >> basicTypeInformation [
	^ SoType smi
]

{ #category : #'value numbering' }
SoAbsSmiOp >> commute [
	"Assumes operation is commutative"
	| temp |
	temp := self firstArg.
	arguments := { receiver }.
	receiver := temp
]
