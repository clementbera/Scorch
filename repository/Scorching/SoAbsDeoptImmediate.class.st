"
Common superclass for immediate values used *only* in sunk objects.
"
Class {
	#name : #SoAbsDeoptImmediate,
	#superclass : #SoAbsImmediate,
	#category : #'Scorching-Nodes-Deopt'
}

{ #category : #printing }
SoAbsDeoptImmediate >> shortPrintOn: s [
	s << (self class name allButFirst: 2)
]
