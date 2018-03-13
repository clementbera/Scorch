"
Load the receiver. Done by stack frame creation. 

type <Behavior> if the class is considered as final, type of the object.
"
Class {
	#name : #SoReceiver,
	#superclass : #SoAbsImmediateUses,
	#pools : [
		'SoMemoryManagerConstants'
	],
	#category : #'Scorching-Nodes'
}

{ #category : #converting }
SoReceiver >> asDeopt [
	^ SoDeoptReceiver new
]

{ #category : #testing }
SoReceiver >> isReceiver [
	^ true
]

{ #category : #traversing }
SoReceiver >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseReceiver: self
]

{ #category : #printing }
SoReceiver >> shortPrintOn: stream [
	stream << 'self'
]
