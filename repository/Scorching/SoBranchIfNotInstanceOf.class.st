"
If the expression is an instance of one of the behaviors, falls through (falseBasicBlock), else jump to trueBasicBlock.

Instance Variables:
	behaviors <Array of behaviors> 
"
Class {
	#name : #SoBranchIfNotInstanceOf,
	#superclass : #SoAbsBranch,
	#instVars : [
		'behaviors'
	],
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #accessing }
SoBranchIfNotInstanceOf >> behaviors [
	<generated>
	^ behaviors
]

{ #category : #accessing }
SoBranchIfNotInstanceOf >> behaviors: aValue [
	<generated>
	behaviors := aValue
]

{ #category : #'bytecode generation' }
SoBranchIfNotInstanceOf >> bytecodeSizeFor: distance bytecodeBuilder: builder [
	^ backendCondition 
		ifTrue: [ builder encoder 
			sizeBranchIfInstanceOf: (self literalIndexForBuilder: builder) 
			distance: distance ]
		ifFalse: [ builder encoder 
			sizeBranchIfNotInstanceOf: (self literalIndexForBuilder: builder) 
			distance: distance ]
]

{ #category : #testing }
SoBranchIfNotInstanceOf >> canLocallySpecifyType [
	^ true
]

{ #category : #testing }
SoBranchIfNotInstanceOf >> isBranchIfNotInstanceOf [
	^ true
]

{ #category : #traversing }
SoBranchIfNotInstanceOf >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseBranchIfNotInstanceOf: self
]

{ #category : #'bytecode generation' }
SoBranchIfNotInstanceOf >> literalIndexForBuilder: builder [
	^ behaviors size = 1 
		ifTrue: [ builder literalIndexOf: behaviors first ] 
		ifFalse: [ builder literalIndexOf: behaviors ]
]

{ #category : #type }
SoBranchIfNotInstanceOf >> maybeSpecifyType: typeFound for: send [
	(trueBasicBlock dominatesInstr: send) ifTrue: [ 
		"not one of the types trapped"
		typeFound isKnownType ifFalse: [ ^ typeFound ].
		^ (SoKnownType forArray: (typeFound behaviors copyWithoutAll: behaviors)) ].
	(falseBasicBlock dominatesInstr: send) ifTrue: [ 
		"only of of the types" 
		^ typeFound intersection: (SoKnownType forArray: behaviors) ].
	^ typeFound
]

{ #category : #testing }
SoBranchIfNotInstanceOf >> specifyTypeOfExpressionAt: instr [
	^ (trueBasicBlock dominatesInstr: instr) or: [ falseBasicBlock dominatesInstr: instr ]
]
