"
Expanded at bytecode generation time to a jumpIfReadOnly.

"
Class {
	#name : #SoTrapIfReadOnly,
	#superclass : #SoAbsTrapIf,
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #testing }
SoTrapIfReadOnly >> isTrapIfReadOnly [
	^ true
]

{ #category : #traversing }
SoTrapIfReadOnly >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseTrapIfReadOnly: self
]
