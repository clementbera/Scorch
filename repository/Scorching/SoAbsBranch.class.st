"
My instances are branches. Depending on a condition (based on subclasses), the execution flow goes to basicBlock1 or basicBlock2.

trueBasicBlock <BasicBlock>
falseBasicBlock <BasicBlock>
backendCondition <Boolean> annotation used by the backend to find out in which sens it will generate the branch to get the most performance.
"
Class {
	#name : #SoAbsBranch,
	#superclass : #SoAbsJump,
	#instVars : [
		'expression',
		'trueBasicBlock',
		'falseBasicBlock',
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

{ #category : #'bytecode generation' }
SoAbsBranch >> bytecodeSizeFor: distance bytecodeBuilder: builder [
	distance = 0 ifTrue: [ ^ 1 ].
	^ 3 + 4
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

{ #category : #accessing }
SoAbsBranch >> popSize [
	^  1
]

{ #category : #'cfg edition' }
SoAbsBranch >> replaceSuccessor: succ by: bb [
	trueBasicBlock == succ ifTrue: [ ^ self trueBasicBlock: bb ].
	self falseBasicBlock: bb.
	
]

{ #category : #'graph edition' }
SoAbsBranch >> subNodes [
	<generated>
	^ {expression}
]

{ #category : #'graph edition' }
SoAbsBranch >> subNodesAnySatisfy: aBlock [
	"profiling"
	<generated>
	^aBlock value: expression.
	
]

{ #category : #'graph edition' }
SoAbsBranch >> subNodesDo: aBlock [
	"profiling"
	<generated>
	aBlock value: expression
]

{ #category : #'graph edition' }
SoAbsBranch >> subNodesSize [
	<generated>
	^ 1
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
	^ trueBasicBlock
]

{ #category : #accessing }
SoAbsBranch >> trueBasicBlock: bb [
	trueBasicBlock ifNotNil: [ :target |
		target removePredecessor: self basicBlock ].
	self basicTrueBasicBlock: bb
]
