"
Read operation for heap accesses.

Read operations are side-effect free.
"
Class {
	#name : #SoRead,
	#superclass : #SoAccessStrategy,
	#classInstVars : [
		'default'
	],
	#category : #'Scorching-Nodes-AccessStrategy'
}

{ #category : #accessing }
SoRead class >> default [
	^ default ifNil: [ default := self new ]
]

{ #category : #testing }
SoRead >> isWrite [
	^ false
]

{ #category : #accessing }
SoRead >> subNodes [
	^ #()
]
