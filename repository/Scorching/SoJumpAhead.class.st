"
I jump ahead to the target basic block. I may be a zero-sized jump in practice.
"
Class {
	#name : #SoJumpAhead,
	#superclass : #SoAbsUnconditionalJump,
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #'bytecode generation' }
SoJumpAhead >> bytecodeSizeFor: distance bytecodeBuilder: builder [
	^ builder encoder sizeJump: distance
]

{ #category : #testing }
SoJumpAhead >> isJumpAhead [
	^ true
]

{ #category : #traversing }
SoJumpAhead >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseJumpAhead: self
]
