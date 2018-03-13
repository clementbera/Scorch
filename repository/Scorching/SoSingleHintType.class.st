"
I have a hint about a single type the value has. This is usde in two cases, I have a hint on global types based on their current value and from the stack to optimise I may have the type of a value (an argument, etc.)

"
Class {
	#name : #SoSingleHintType,
	#superclass : #SoHintType,
	#category : #'Scorching-Type'
}

{ #category : #operation }
SoSingleHintType >> hintTypeWith: anotherType [
	anotherType isKnownType ifFalse: [ 
		^ SoKnownType for: behavior ].
	^ (anotherType behaviors includes: behavior)
		ifTrue: [ anotherType ]
		ifFalse: [ SoUnknownType default ]
]
