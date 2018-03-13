"
I am a specific subclass to represent that the variable has likely a type, even if there is no guarantee that this type is exact. It is used for inlining to tip Scorch on better types.
"
Class {
	#name : #SoHintType,
	#superclass : #SoUnknownType,
	#instVars : [
		'behavior'
	],
	#category : #'Scorching-Type'
}

{ #category : #'instance creation' }
SoHintType class >> for: behavior [
	^ self new
		behavior: behavior;
		yourself
]

{ #category : #accessing }
SoHintType >> behavior [
	<generated>
	^ behavior
]

{ #category : #accessing }
SoHintType >> behavior: aValue [
	<generated>
	behavior := aValue
]

{ #category : #testing }
SoHintType >> hasHint [
	^ true
]
