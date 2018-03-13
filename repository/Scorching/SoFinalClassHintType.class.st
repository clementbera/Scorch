"
If a class is final (i.e., it has currently no subclasses or none of the subclasses have instances), we can assume that methods installed in the class have this exact type. We still need traps unless we hook in the class builder.
"
Class {
	#name : #SoFinalClassHintType,
	#superclass : #SoHintType,
	#category : #'Scorching-Type'
}

{ #category : #testing }
SoFinalClassHintType >> hasReliableHint [
	^ true
]

{ #category : #accessing }
SoFinalClassHintType >> hint [
	^ SoKnownType for: behavior 
]

{ #category : #operation }
SoFinalClassHintType >> hintTypeWith: anotherType [
	^ self hint
]
