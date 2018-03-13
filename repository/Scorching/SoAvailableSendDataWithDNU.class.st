"
In addition to my superclass, one of the look-up result is a DNU. Right now I am not handled by the optimiser (I am considered as non inlinable).
"
Class {
	#name : #SoAvailableSendDataWithDNU,
	#superclass : #SoAvailableSendData,
	#category : #'Scorching-SendData'
}

{ #category : #converting }
SoAvailableSendDataWithDNU >> asType [
	^ SoUnknownType default
]

{ #category : #testing }
SoAvailableSendDataWithDNU >> canBeInlined [
	^ false
]

{ #category : #accessing }
SoAvailableSendDataWithDNU >> dataFor: behavior ifNone: aBlock [
	^ aBlock value
]

{ #category : #testing }
SoAvailableSendDataWithDNU >> mayBeInlinablePIC [
	^ false
]
