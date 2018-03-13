"
I represent a conditional branch happening at the end of the basic block. If expression answers true at runtime, trueBasicBlock is reached, else falseBasicBlock. 

This is the Smalltalk level boolean branch, so it needs to deal with Must be boolean (deoptInfo). If there is no must be boolean, this branch should be changed to InstanceOf branch on True/False. 

Profiling counts from the runtime data feedback is also available.

Instance Variables:
	deoptInfo <DeoptimizationInformation> 
"
Class {
	#name : #SoSmalltalkBooleanBranch,
	#superclass : #SoPipelinedBooleanBranch,
	#instVars : [
		'deoptInfo'
	],
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #converting }
SoSmalltalkBooleanBranch >> asPipelinedBranch [
	^ SoPipelinedBooleanBranch new
		expression: expression;
		basicBlock: basicBlock;
		trueBasicBlock: trueBasicBlock;
		falseBasicBlock: falseBasicBlock;
		trueCount: trueCount;
		falseCount: falseCount;
		yourself
		
]

{ #category : #accessing }
SoSmalltalkBooleanBranch >> deoptInfo [
	<generated>
	^ deoptInfo
]

{ #category : #accessing }
SoSmalltalkBooleanBranch >> deoptInfo: aValue [
	<generated>
	aValue ifNotNil: [aValue instruction: self].
	deoptInfo := aValue
]

{ #category : #testing }
SoSmalltalkBooleanBranch >> isEscapeFor: node [
	^ true
]

{ #category : #testing }
SoSmalltalkBooleanBranch >> isPipelinedBooleanBranch [
	^ false
]

{ #category : #traversing }
SoSmalltalkBooleanBranch >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmalltalkBooleanBranch: self
]
