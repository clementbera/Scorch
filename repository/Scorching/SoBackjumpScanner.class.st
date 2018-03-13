"
I compute the backjump fixups to correctly build the CFG.

Instance Variables:
	fixups			<Array of nil|JumpFixup> 	collection of fixups describing jump targets.

"
Class {
	#name : #SoBackjumpScanner,
	#superclass : #SoAbstractScanner,
	#instVars : [
		'fixups',
		'lastConstant'
	],
	#category : #'Scorching-Decompiler'
}

{ #category : #public }
SoBackjumpScanner class >> scan: compiledCode [
	^ (self on: compiledCode) scan
]

{ #category : #opcodes }
SoBackjumpScanner >> backjumpNoInterrupt [
	self jump: lastConstant
]

{ #category : #accessing }
SoBackjumpScanner >> fixups [
	<generated>
	^ fixups
]

{ #category : #accessing }
SoBackjumpScanner >> fixups: aValue [
	<generated>
	fixups := aValue
]

{ #category : #opcodes }
SoBackjumpScanner >> jump: delta [
	delta < 0 ifFalse: [ ^ self ].
	(fixups at: self shiftedPC + delta)
		ifNil: [ fixups at: self shiftedPC + delta put: SoBackjumpFixup new ]
		ifNotNil: [ :fixup | fixup additionalBackjump ]
]

{ #category : #accessing }
SoBackjumpScanner >> lastConstant [
	<generated>
	^ lastConstant
]

{ #category : #accessing }
SoBackjumpScanner >> lastConstant: aValue [
	<generated>
	lastConstant := aValue
]

{ #category : #opcodes }
SoBackjumpScanner >> pushActiveContext [
	SoContextAccessed signal.
]

{ #category : #opcodes }
SoBackjumpScanner >> pushConstant: cst [
	lastConstant := cst
]

{ #category : #opcodes }
SoBackjumpScanner >> pushContextReceiverVariable: index [
	SoContextAccessed signal.
]

{ #category : #public }
SoBackjumpScanner >> scan [
	fixups := Array new: self method bytecodeSize + 1.
	self interpret.
	^ fixups
]

{ #category : #opcodes }
SoBackjumpScanner >> storeIntoContextReceiverVariable: index [
	SoContextAccessed signal.
]
