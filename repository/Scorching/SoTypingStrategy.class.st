"
The typing strategy is used by the escape optimisation to type objects instantiated in the codeNode until they escape (or until the end of the code if they don't)


"
Class {
	#name : #SoTypingStrategy,
	#superclass : #Object,
	#category : #'Scorching-Pass-Heap'
}

{ #category : #'instance creation' }
SoTypingStrategy class >> for: alloc [
	^ self new 	
		initializeWith: alloc;
		yourself
]
