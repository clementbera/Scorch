Class {
	#name : #SoDebugLog,
	#superclass : #Object,
	#instVars : [
		'message',
		'stackOrNil',
		'num'
	],
	#category : #'ScorchingDev-debug'
}

{ #category : #comparing }
SoDebugLog >> <= anotherDebugLog [
	| index val1 val2 |
	stackOrNil ifNil: [ ^ false ].
	anotherDebugLog stackOrNil ifNil: [ ^ true ].
	index := 0.
	40 timesRepeat: [ 
		val1 := self pcFromLast: index.
		val2 := anotherDebugLog pcFromLast: index.
		val1 = val2 ifFalse: [^ val1 <= val2 ].
		val1 = 0 ifTrue: [^ true "equal"].
		index := index + 1 ].
	self error: 'infinite loop'
	
]

{ #category : #printing }
SoDebugLog >> crTabPrintOn: stream [
	stream cr.
	stackOrNil ifNil: [ ^ self printOn: stream ].
	stackOrNil size timesRepeat: [ stream tab ].
	self printOn: stream
]

{ #category : #accessing }
SoDebugLog >> message [
	^ message
]

{ #category : #accessing }
SoDebugLog >> message: anObject [
	message := anObject
]

{ #category : #accessing }
SoDebugLog >> num [
	^ num
]

{ #category : #accessing }
SoDebugLog >> num: anObject [
	num := anObject
]

{ #category : #comparing }
SoDebugLog >> pcFromLast: index [
	^ (stackOrNil at: stackOrNil size - index ifAbsent: [ 0 ]) value.
	
	
]

{ #category : #printing }
SoDebugLog >> printOn: stream [
	stackOrNil ifNil: [ ^ self basicPrintOn: stream ].
	stackOrNil first value printOn: stream.
	stream  << ') '.
	self basicPrintOn: stream.
	stream << ' ['.
	num printOn: stream.
	stream << ']'
]

{ #category : #accessing }
SoDebugLog >> stackOrNil [
	^ stackOrNil
]

{ #category : #accessing }
SoDebugLog >> stackOrNil: anObject [
	stackOrNil := anObject
]
