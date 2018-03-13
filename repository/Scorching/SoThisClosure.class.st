"
I represent the closureOrNil field of the context. Used only in deopt node when the outer most closure is decompiled. 

Currently unused.
"
Class {
	#name : #SoThisClosure,
	#superclass : #SoAbsDeoptImmediate,
	#category : #'Scorching-Nodes-Deopt'
}

{ #category : #traversing }
SoThisClosure >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseThisClosure: self
]
