"
Object to be able to inline with different receiver.
"
Class {
	#name : #SoExamplesDispatch,
	#superclass : #Object,
	#instVars : [
		'remoteIV1'
	],
	#category : #'ScorchingTests-Examples'
}

{ #category : #'as yet unclassified' }
SoExamplesDispatch class >> compiler [
	| comp |
	comp :=  super compiler.
	comp compilationContext usesFullBlockClosure: true.
	comp compilationContext encoderClass: OpalEncoderForSistaV1.
	^ comp
]

{ #category : #'test running facilities' }
SoExamplesDispatch >> = anotherObject [
	anotherObject class == self class ifFalse: [ ^ false ].
	1 to: self class instSize do: [ :i |
		(self instVarAt: i) = (anotherObject instVarAt: i) ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #'test running facilities' }
SoExamplesDispatch >> foo: a bar: a2 [
	remoteIV1 := a printString , a2 printString
]

{ #category : #remoteMethod }
SoExamplesDispatch >> remoteDeadBlock [
	^ [ 5 + 6. self ]
]

{ #category : #remoteMethod }
SoExamplesDispatch >> remoteEval: aBlock [
	self yourself.
	^ aBlock value.
]

{ #category : #accessing }
SoExamplesDispatch >> remoteIV1 [
	^ remoteIV1
]

{ #category : #accessing }
SoExamplesDispatch >> remoteIV1: anObject [
	remoteIV1 := anObject
]

{ #category : #remoteMethod }
SoExamplesDispatch >> remoteMethod [
	self remoteEval: [ 1 + 2. self. ].
	remoteIV1 := 5.
	4 + 5.
	^ self 
]
