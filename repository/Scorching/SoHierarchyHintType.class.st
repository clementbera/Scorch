"
The variable has the type or one of the subtype of the behavior held. It's guessed based on where the method will be installed.

We know the behavior has subclasses (else it would be a final class hint)
"
Class {
	#name : #SoHierarchyHintType,
	#superclass : #SoHintType,
	#category : #'Scorching-Type'
}

{ #category : #operation }
SoHierarchyHintType >> hintTypeWith: anotherType [
	anotherType isKnownType ifFalse: [ 
		"We need to analyse the whole hierarchy. May cost
		 too much time, may use API that the optimiser should not
		 use and this send seems to be unfrequently used."
		 ^ SoUnknownType default ].
	^ SoKnownType forArray: (anotherType behaviors 
			select: [ :each | 
				each == behavior 
				or: [ each inheritsFrom: behavior ] ]) asArray
]
