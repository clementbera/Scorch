"
I am stored in deoptimized optimized context to recover block outer contexts.
"
Class {
	#name : #SoOuterContextMap,
	#superclass : #SoAbsDeopt,
	#instVars : [
		'map'
	],
	#pools : [
		'SoMemoryManagerConstants'
	],
	#category : #'Scorching-Deoptimization'
}

{ #category : #'instance creation' }
SoOuterContextMap class >> from: deoptObjects [
	^ self new
		fromDeoptObjects: deoptObjects;
		yourself
	
]

{ #category : #initialization }
SoOuterContextMap >> fromDeoptObjects: deoptObjects [
	map := SoDeoptDictionary new.
	deoptObjects keysAndValuesDo: [ :key :value | 
		value class == ContextClass ifTrue: [ 
			map at: key put: value ] ]
]

{ #category : #accessing }
SoOuterContextMap >> map [
	<generated>
	^ map
]

{ #category : #accessing }
SoOuterContextMap >> map: aValue [
	<generated>
	map := aValue
]
