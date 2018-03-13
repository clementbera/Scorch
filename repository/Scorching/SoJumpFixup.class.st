"
A fixup is a control flow merge point in the bytecode.

I am the target of at least one jump forward (branch or direct jump). 

targetBasicBlock <BasicBlock> basicBlock to jump to.
"
Class {
	#name : #SoJumpFixup,
	#superclass : #SoDeadFixup,
	#instVars : [
		'targetBasicBlock'
	],
	#category : #'Scorching-Decompiler'
}

{ #category : #initialization }
SoJumpFixup >> initialize [

	super initialize.

	targetBasicBlock := SoBasicBlock new.
]

{ #category : #testing }
SoJumpFixup >> isDeadFixup [
	^ false
]

{ #category : #decompilation }
SoJumpFixup >> reachedFrom: decompiler [
	decompiler reachJumpFixup: self
]

{ #category : #accessing }
SoJumpFixup >> targetBasicBlock [
	<generated>
	^ targetBasicBlock
]

{ #category : #accessing }
SoJumpFixup >> targetBasicBlock: aValue [
	<generated>
	targetBasicBlock := aValue
]
