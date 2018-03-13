"
raised when validation failed by validator


"
Class {
	#name : #SoValidationFailure,
	#superclass : #Error,
	#instVars : [
		'failingPass',
		'method',
		'listOfPasses'
	],
	#category : #'ScorchingTests-Validation'
}

{ #category : #accessing }
SoValidationFailure >> failingPass [
	^ failingPass
]

{ #category : #accessing }
SoValidationFailure >> failingPass: anObject [
	failingPass := anObject
]

{ #category : #accessing }
SoValidationFailure >> listOfPasses [
	^ listOfPasses
]

{ #category : #accessing }
SoValidationFailure >> listOfPasses: anObject [
	listOfPasses := anObject
]

{ #category : #accessing }
SoValidationFailure >> method [
	^ method
]

{ #category : #accessing }
SoValidationFailure >> method: anObject [
	method := anObject
]
