"
I represent an input of a phi. Even though I am not in the CFG because I am always accessed through the phi itself in the CFG, I am conceptually at the end of the basicBlock I refer to. I may also be accessed through the def-use graph so from the use one can know which basicBlock I come from.

input <Instruction> 
basicBlock <BasicBlock> basicBlock the input comes from
phi <Phi> phi I belong to (unique)
"
Class {
	#name : #SoPhiInput,
	#superclass : #SoAbsNode,
	#instVars : [
		'input',
		'basicBlock',
		'phi'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #'instance creation' }
SoPhiInput class >> input: input basicBlock: basicBlock phi: phi [
	^ self new
		input: input;
		basicBlock: basicBlock;
		phi: phi;
		yourself
]

{ #category : #accessing }
SoPhiInput >> basicBlock [
	<generated>
	^ basicBlock
]

{ #category : #accessing }
SoPhiInput >> basicBlock: aValue [
	<generated>
	basicBlock := aValue
]

{ #category : #'graph edition' }
SoPhiInput >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	input := anotherNode.
	anotherNode addUse: self
]

{ #category : #accessing }
SoPhiInput >> codeNode [
	^ phi codeNode
]

{ #category : #testing }
SoPhiInput >> inBasicBlock: bb1 or: bb2 [
	^ basicBlock = bb1 or: [ basicBlock = bb2 ]
]

{ #category : #accessing }
SoPhiInput >> input [
	<generated>
	^ input
]

{ #category : #accessing }
SoPhiInput >> input: aValue [
	<generated>
	input := aValue.
	input  addUse: self
]

{ #category : #dominator }
SoPhiInput >> isDominatedByBasicBlock: bb [
	^ bb dominates: basicBlock 
]

{ #category : #testing }
SoPhiInput >> isPhiInput [
	^ true
]

{ #category : #accessing }
SoPhiInput >> phi [
	<generated>
	^ phi
]

{ #category : #accessing }
SoPhiInput >> phi: aValue [
	<generated>
	phi := aValue
]

{ #category : #copying }
SoPhiInput >> postCopy [
	super postCopy.
	self subNodesDo: [ :each | each addUse: self ].
]

{ #category : #'graph edition' }
SoPhiInput >> subNodes [
	<generated>
	^ {input}
]

{ #category : #'graph edition' }
SoPhiInput >> subNodesAnySatisfy: aBlock [
	"profiling"
	<generated>
	^aBlock value: input.
	
]

{ #category : #'graph edition' }
SoPhiInput >> subNodesDo: aBlock [
	"profiling"
	<generated>
	aBlock value: input
]

{ #category : #'graph edition' }
SoPhiInput >> subNodesSize [
	<generated>
	^ 1
]
