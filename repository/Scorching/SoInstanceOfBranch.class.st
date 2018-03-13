"
If the expression is an instance of one of the behaviors, jumps to trueBasicBlock, else to the other.

Instance Variables:
	behaviors <Array of behaviors> 
"
Class {
	#name : #SoInstanceOfBranch,
	#superclass : #SoAbsBranch,
	#instVars : [
		'behaviors'
	],
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #accessing }
SoInstanceOfBranch >> behaviors [
	<generated>
	^ behaviors
]

{ #category : #accessing }
SoInstanceOfBranch >> behaviors: aValue [
	<generated>
	behaviors := aValue
]

{ #category : #'bytecode generation' }
SoInstanceOfBranch >> bytecodeSizeFor: distance bytecodeBuilder: builder [
	distance = 0 ifTrue: [ ^ 2 ]. "double pop"
	^ 3 + 4
]

{ #category : #testing }
SoInstanceOfBranch >> canLocallySpecifyType [
	^ true
]

{ #category : #accessing }
SoInstanceOfBranch >> invertedPrimitiveNumber [
	^ behaviors size = 1
		ifTrue: [ 8000 ]
		ifFalse: [ 8002 ]
]

{ #category : #testing }
SoInstanceOfBranch >> isInstanceOfBranch [
	^ true
]

{ #category : #traversing }
SoInstanceOfBranch >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseInstanceOfBranch: self
]

{ #category : #'bytecode generation' }
SoInstanceOfBranch >> literalIndexForBuilder: builder [
	^ behaviors size = 1 
		ifTrue: [ builder literalIndexOf: behaviors first ] 
		ifFalse: [ builder literalIndexOf: behaviors ]
]

{ #category : #type }
SoInstanceOfBranch >> maybeSpecifyType: typeFound for: send [
	(falseBasicBlock dominatesInstr: send) ifTrue: [ 
		"not one of the types trapped"
		typeFound isKnownType ifFalse: [ ^ typeFound ].
		^ (SoKnownType forArray: (typeFound behaviors copyWithoutAll: behaviors)) ].
	(trueBasicBlock dominatesInstr: send) ifTrue: [ 
		"only of of the types" 
		^ typeFound intersection: (SoKnownType forArray: behaviors) ].
	^ typeFound
]

{ #category : #accessing }
SoInstanceOfBranch >> primitiveNumber [
	^ self invertedPrimitiveNumber + 1
]

{ #category : #testing }
SoInstanceOfBranch >> specifyTypeOfExpressionAt: instr [
	^ (trueBasicBlock dominatesInstr: instr) or: [ falseBasicBlock dominatesInstr: instr ]
]
