"
unconditional jump at the end of the basic block that jumps backward. Smalltalk level operation, it checks for interrupt once every 40 backjumps.

deoptInfo is there if the backjump is interrupted.

deoptInfo <DeoptimizationInformation>
"
Class {
	#name : #SoSmalltalkBackjump,
	#superclass : #SoNoInterruptBackjump,
	#instVars : [
		'deoptInfo'
	],
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #'bytecode generation' }
SoSmalltalkBackjump >> bytecodeSizeFor: distance bytecodeBuilder: builder [
	^ 4
]

{ #category : #accessing }
SoSmalltalkBackjump >> deoptInfo [
	<generated>
	^ deoptInfo
]

{ #category : #accessing }
SoSmalltalkBackjump >> deoptInfo: aValue [
	<generated>
	aValue ifNotNil: [aValue instruction: self].
	deoptInfo := aValue
]

{ #category : #testing }
SoSmalltalkBackjump >> hasInterruptCheck [
	^ true
]

{ #category : #traversing }
SoSmalltalkBackjump >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmalltalkBackjump: self
]
