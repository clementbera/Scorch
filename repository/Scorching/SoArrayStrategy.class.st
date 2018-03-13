"
Specific strategy for array like objects. Since many accesses in arrays are on an unknown index (i.e., in loops), we assume that all the fields of the array have the same type or none of the fields can be typed. type is the single type dealt with.

type <Type>


"
Class {
	#name : #SoArrayStrategy,
	#superclass : #SoTypingStrategy,
	#instVars : [
		'type'
	],
	#category : #'Scorching-Pass-Heap'
}

{ #category : #merging }
SoArrayStrategy >> mergeWith: typingStrat [
	typingStrat class = self class ifFalse: [ ^SoNoStrategy new ].
	typingStrat type ifNil: [ ^ self]. 
	typingStrat type isKnownType ifFalse: [ ^SoNoStrategy new ].
	type isKnownType ifFalse: [ ^SoNoStrategy new ].
	typingStrat type behaviors = type behaviors ifFalse: [ ^ SoNoStrategy new ].
	^ self
]

{ #category : #accessing }
SoArrayStrategy >> type [
	<generated>
	^ type
]

{ #category : #accessing }
SoArrayStrategy >> type: aValue [
	<generated>
	type := aValue
]

{ #category : #types }
SoArrayStrategy >> typeRead: read [
	read type: type
]

{ #category : #types }
SoArrayStrategy >> typeWrite: write [
	| type2 |
	type2 := (write expression typeInformationAt: write).
	type2 hasOneType ifFalse: [ ^ type := SoUnknownType default ].
	type ifNil: [ ^ type := type2 ].
	type isKnownType ifFalse: [ ^ self ].
	type2 behaviors = type behaviors ifTrue: [ ^ self ].
	type := SoUnknownType default
]
