"
I compute the backjump fixups to correctly build the CFG.

Instance Variables:
	fixups			<Array of nil|JumpFixup> 	collection of fixups describing jump targets.

"
Class {
	#name : #SoBackjumpScanner,
	#superclass : #SoAbstractScanner,
	#instVars : [
		'fixups'
	],
	#category : #'Scorching-Decompiler'
}

{ #category : #public }
SoBackjumpScanner class >> scan: compiledCode [
	^ (self on: compiledCode) scan
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

{ #category : #opcodes }
SoBackjumpScanner >> pushActiveContext [
	SoContextAccessed signal.
]

{ #category : #public }
SoBackjumpScanner >> scan [
	self setUpScanner.
	self interpret.
	^ fixups
]

{ #category : #initialization }
SoBackjumpScanner >> setUpScanner [
	stackp := self method numTemps.
	fixups := Array new: self method bytecodeSize + 1.
]
