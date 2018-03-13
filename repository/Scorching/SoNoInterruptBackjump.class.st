"
unconditional jump at the end of the basic block that jumps backward. No interrupt check, no deopt info.

peeled <Boolean> true if the loop has been peeled (not to do it again)
"
Class {
	#name : #SoNoInterruptBackjump,
	#superclass : #SoAbsUnconditionalJump,
	#instVars : [
		'peeled'
	],
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #'bytecode generation' }
SoNoInterruptBackjump >> bytecodeSizeFor: distance bytecodeBuilder: builder [
	^ 3 + 4
]

{ #category : #testing }
SoNoInterruptBackjump >> hasInterruptCheck [
	^ false
]

{ #category : #initialization }
SoNoInterruptBackjump >> initialize [

	super initialize.

	peeled := false.
]

{ #category : #testing }
SoNoInterruptBackjump >> isBackjump [
	^ true
]

{ #category : #traversing }
SoNoInterruptBackjump >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseNoInterruptBackjump: self
]

{ #category : #accessing }
SoNoInterruptBackjump >> peeled [
	<generated>
	^ peeled
]

{ #category : #accessing }
SoNoInterruptBackjump >> peeled: aValue [
	<generated>
	peeled := aValue
]
