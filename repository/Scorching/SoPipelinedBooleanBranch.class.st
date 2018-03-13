"
I represent a conditional branch happening at the end of the basic block. If expression answers true at runtime, trueBasicBlock is reached, else falseBasicBlock. 

In this case, I am different from a Smalltalk boolean branch since I don't implement must be boolean. My expression *must* be a smiComp or pointerComp

	trueCount/falseCount <Smi> number of times the execution has taken the corresponding basicblock.
"
Class {
	#name : #SoPipelinedBooleanBranch,
	#superclass : #SoAbsBranch,
	#instVars : [
		'trueCount',
		'falseCount'
	],
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #'bytecode generation' }
SoPipelinedBooleanBranch >> bytecodeSizeFor: distance bytecodeBuilder: builder [
	^ (backendCondition 
		ifTrue: [ builder encoder sizeBranchPopFalse: distance ]
		ifFalse: [ builder encoder sizeBranchPopTrue: distance ]).
]

{ #category : #accessing }
SoPipelinedBooleanBranch >> falseCount [
	<generated>
	^ falseCount
]

{ #category : #accessing }
SoPipelinedBooleanBranch >> falseCount: aValue [
	<generated>
	falseCount := aValue
]

{ #category : #initialization }
SoPipelinedBooleanBranch >> initialize [

	super initialize.

	falseCount := 0.
	trueCount := 0.
]

{ #category : #testing }
SoPipelinedBooleanBranch >> isBooleanBranch [
	^ true
]

{ #category : #testing }
SoPipelinedBooleanBranch >> isPipelinedBooleanBranch [
	^ true
]

{ #category : #traversing }
SoPipelinedBooleanBranch >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traversePipelinedBooleanBranch: self
]

{ #category : #accessing }
SoPipelinedBooleanBranch >> trueCount [
	<generated>
	^ trueCount
]

{ #category : #accessing }
SoPipelinedBooleanBranch >> trueCount: aValue [
	<generated>
	trueCount := aValue
]
