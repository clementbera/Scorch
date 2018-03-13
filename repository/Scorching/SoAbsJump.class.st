"
Common superclass to all jumps. A jump is an operation that moves the execution flow from a basic block to another basic block.

backEndJumpSize <Smi> used by the backend to compute the size of the jump.
"
Class {
	#name : #SoAbsJump,
	#superclass : #SoAbsCFGInstruction,
	#instVars : [
		'backEndJumpSize'
	],
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #accessing }
SoAbsJump >> backEndJumpSize [
	<generated>
	^ backEndJumpSize
]

{ #category : #accessing }
SoAbsJump >> backEndJumpSize: aValue [
	<generated>
	backEndJumpSize := aValue
]

{ #category : #testing }
SoAbsJump >> isJump [
	^ true
]
