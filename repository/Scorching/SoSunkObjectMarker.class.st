"
I represent the identity of a sunk object. I am referenced from Sunk objects AND closures requiring an outer context.
"
Class {
	#name : #SoSunkObjectMarker,
	#superclass : #Object,
	#category : #'Scorching-Nodes-Deopt'
}

{ #category : #visiting }
SoSunkObjectMarker >> accept: visitor [
	^ visitor visitMarker: self
]

{ #category : #compatibility }
SoSunkObjectMarker >> addUse: use [
	
]

{ #category : #conversion }
SoSunkObjectMarker >> asDeopt [
	^ self
]

{ #category : #testing }
SoSunkObjectMarker >> isMarker [
	^ true
]

{ #category : #compatibility }
SoSunkObjectMarker >> removeUse: use [
]
