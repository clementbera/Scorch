"
Common superclass of the branches. The branch is an operation which moves the execution flow to a basic block or another based on a condition.

    Instance Variables
	expression:		<ScorchNode> 
	falseBasicBlock:		<BasicBlock> reached if expression is false.
	trueBasicBlock:		<BasicBlock> reached if expression is true.
	backendCondition <Boolean> used at bytecode gen time to find out if it will be compiled to a jumpTrue or jumpFalse (or jumpIfInstanceOf: / jumpifNotInstanceOf:.

"
Class {
	#name : #SoAbsBranch,
	#superclass : #SoAbsJump,
	#instVars : [
		'expression',
		'falseBasicBlock',
		'trueBasicBlock',
		'backendCondition'
	],
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #accessing }
SoAbsBranch >> backendCondition [
	<generated>
	^ backendCondition
]

{ #category : #accessing }
SoAbsBranch >> backendCondition: aValue [
	<generated>
	backendCondition := aValue
]

{ #category : #accessing }
SoAbsBranch >> basicFalseBasicBlock: bb [
	falseBasicBlock := bb.
	bb addPredecessor: basicBlock.
]

{ #category : #'graph edition' }
SoAbsBranch >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	expression := anotherNode.
	anotherNode addUse: self
]

{ #category : #'cfg edition' }
SoAbsBranch >> basicReplaceSuccessor: succ by: bb [
	trueBasicBlock == succ ifTrue: [ ^ self basicTrueBasicBlock: bb ].
	self basicFalseBasicBlock: bb.
	
]

{ #category : #accessing }
SoAbsBranch >> basicTrueBasicBlock: bb [
	trueBasicBlock := bb.
	bb addPredecessor: basicBlock.
]

{ #category : #accessing }
SoAbsBranch >> expression [
	<generated>
	^ expression
]

{ #category : #accessing }
SoAbsBranch >> expression: aValue [
	<generated>
	expression := aValue.
	expression  addUse: self
]

{ #category : #accessing }
SoAbsBranch >> falseBasicBlock [
	<generated>
	^ falseBasicBlock
]

{ #category : #accessing }
SoAbsBranch >> falseBasicBlock: bb [
	falseBasicBlock ifNotNil: [ :target |
		target removePredecessor: self basicBlock ].
	self basicFalseBasicBlock: bb
]

{ #category : #testing }
SoAbsBranch >> isBranch [
	^ true
]

{ #category : #testing }
SoAbsBranch >> maybeWorthSplitting [
	^ true
]

{ #category : #'cfg edition' }
SoAbsBranch >> replaceSuccessor: succ by: bb [
	trueBasicBlock == succ ifTrue: [ ^ self trueBasicBlock: bb ].
	self falseBasicBlock: bb.
	
]

{ #category : #accessing }
SoAbsBranch >> splitSubNode [
	^ expression 
]

{ #category : #'graph edition' }
SoAbsBranch >> subNodes [
	<generated>
	^ {expression}
]

{ #category : #accessing }
SoAbsBranch >> successors [
	^ {  trueBasicBlock . falseBasicBlock }
]

{ #category : #accessing }
SoAbsBranch >> targetBasicBlock [
	^ backendCondition 
		ifFalse: [ trueBasicBlock ]
		ifTrue: [ falseBasicBlock ]
]

{ #category : #accessing }
SoAbsBranch >> trueBasicBlock [
	<generated>
	^ trueBasicBlock
]

{ #category : #accessing }
SoAbsBranch >> trueBasicBlock: bb [
	trueBasicBlock ifNotNil: [ :target |
		target removePredecessor: self basicBlock ].
	self basicTrueBasicBlock: bb
]
