"
I represent a conditional branch happening at the end of the basic block. If expression answers true at runtime, trueBasicBlock is reached, else falseBasicBlock. 

The deoptInfo is here to handle mustBeBoolean.

Instance Variables:
	trueCount/falseCount <SmallInteger> number of times the execution has taken the corresponding basicblock.
	deoptInfo <DeoptimizationInformation> 
"
Class {
	#name : #SoBooleanBranch,
	#superclass : #SoAbsBranch,
	#instVars : [
		'trueCount',
		'falseCount',
		'deoptInfo'
	],
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #'bytecode generation' }
SoBooleanBranch >> bytecodeSizeFor: distance bytecodeBuilder: builder [
	| flag |
	flag := "self hasDeoptInfo ifTrue: [ 0 ] ifFalse: [ 2 ]." 0.
	^ (backendCondition 
		ifTrue: [ builder encoder sizeBranchPopFalse: distance ]
		ifFalse: [ builder encoder sizeBranchPopTrue: distance ]) + flag.
]

{ #category : #accessing }
SoBooleanBranch >> deoptInfo [
	<generated>
	^ deoptInfo
]

{ #category : #accessing }
SoBooleanBranch >> deoptInfo: aValue [
	<generated>
	aValue ifNotNil: [aValue sunkObjects do: [ :sunkObj | sunkObj node: self ] ].
	deoptInfo := aValue
]

{ #category : #accessing }
SoBooleanBranch >> falseCount [
	<generated>
	^ falseCount
]

{ #category : #accessing }
SoBooleanBranch >> falseCount: aValue [
	<generated>
	falseCount := aValue
]

{ #category : #testing }
SoBooleanBranch >> isBooleanBranch [
	^ true
]

{ #category : #traversing }
SoBooleanBranch >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseBooleanBranch: self
]

{ #category : #accessing }
SoBooleanBranch >> trueCount [
	<generated>
	^ trueCount
]

{ #category : #accessing }
SoBooleanBranch >> trueCount: aValue [
	<generated>
	trueCount := aValue
]
