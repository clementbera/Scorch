"
I wrap an array created by the VM that corresponds to inline cache data for a send.

"
Class {
	#name : #SoSendData,
	#superclass : #Object,
	#category : #'Scorching-SendData'
}

{ #category : #'instance creation' }
SoSendData class >> fromArray: array [
	self subclassResponsibility 
]

{ #category : #testing }
SoSendData >> canBeInlined [
	self subclassResponsibility 
]

{ #category : #accessing }
SoSendData >> dataFor: behavior ifNone: aBlock [
	^ aBlock value
]

{ #category : #testing }
SoSendData >> isAvailable [
	^ false
]
