"
I represent unknown type information. 

The type of the instruction required to be inferred and cannot be inferred.
"
Class {
	#name : #SoUnknownType,
	#superclass : #SoType,
	#classInstVars : [
		'default'
	],
	#category : #'Scorching-Type'
}

{ #category : #'instance creation' }
SoUnknownType class >> default [
	^ default ifNil: [ default := self new ]
]

{ #category : #operations }
SoUnknownType >> intersection: type [
	^ type
]

{ #category : #operations }
SoUnknownType >> knownIntersection: type [
	^ type
]

{ #category : #operations }
SoUnknownType >> knownUnion: type [
	^ self
]

{ #category : #operations }
SoUnknownType >> union: type [
	^ self
]
