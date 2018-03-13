"
Unconditional jump.

targetBasicBlock <BasicBlock>
"
Class {
	#name : #SoAbsUnconditionalJump,
	#superclass : #SoAbsJump,
	#instVars : [
		'targetBasicBlock'
	],
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #'instance creation' }
SoAbsUnconditionalJump class >> from: basicBlock to: targetBasicBlock [
	^ self new 	
		basicBlock: basicBlock;
		targetBasicBlock: targetBasicBlock;
		yourself
]

{ #category : #'cfg edition' }
SoAbsUnconditionalJump >> basicReplaceSuccessor: succ by: bb [
	self basicTargetBasicBlock: bb
	
]

{ #category : #accessing }
SoAbsUnconditionalJump >> basicTargetBasicBlock: bb [
	targetBasicBlock := bb.
	bb addPredecessor: basicBlock
]

{ #category : #'cfg edition' }
SoAbsUnconditionalJump >> replaceSuccessor: succ by: bb [
	self targetBasicBlock: bb
	
]

{ #category : #accessing }
SoAbsUnconditionalJump >> successors [
	^ { targetBasicBlock }
]

{ #category : #accessing }
SoAbsUnconditionalJump >> targetBasicBlock [
	<generated>
	^ targetBasicBlock
]

{ #category : #accessing }
SoAbsUnconditionalJump >> targetBasicBlock: bb [
	targetBasicBlock ifNotNil: [ :target |
		target removePredecessor: self basicBlock ].
	targetBasicBlock := bb.
	bb addPredecessor: basicBlock
]
