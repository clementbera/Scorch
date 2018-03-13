"
In this case, the message's receiver can have a limited number of concrete types (1 to 6 different types). These sends are currrently optimized only if all the concrete types target the same compiled method or if there are only 2 cases.

behaviorsAndMethods <Dictionary<Behavior->CompiledMethod>> dictionary with as keys the possible classes and with as values the associated compiledMethod

"
Class {
	#name : #SoAvailableSendData,
	#superclass : #SoSendData,
	#instVars : [
		'behaviorsAndMethods'
	],
	#pools : [
		'SoSpecialSelectorConstants'
	],
	#category : #'Scorching-SendData'
}

{ #category : #'instance creation' }
SoAvailableSendData class >> fromArray: array [
	| cl dict |
	cl := self.
	dict := Dictionary new.
	array pairsDo: [ :behavior :meth |
		meth == DNUSelector ifTrue: [ cl := SoAvailableSendDataWithDNU ].
		dict at: behavior put: meth ].
	^ cl new 
		behaviorsAndMethods: dict;
		yourself
]

{ #category : #accessing }
SoAvailableSendData >> anyReceiverClass [
	^ behaviorsAndMethods keys first
]

{ #category : #converting }
SoAvailableSendData >> asType [
	^ SoKnownType forArray: self behaviors
]

{ #category : #accessing }
SoAvailableSendData >> behaviors [
	^ behaviorsAndMethods keys
]

{ #category : #accessing }
SoAvailableSendData >> behaviorsAndMethods [
	<generated>
	^ behaviorsAndMethods
]

{ #category : #accessing }
SoAvailableSendData >> behaviorsAndMethods: aValue [
	<generated>
	behaviorsAndMethods := aValue
]

{ #category : #testing }
SoAvailableSendData >> canBeInlined [
	behaviorsAndMethods size = 1 ifTrue: [ ^ true ].
	behaviorsAndMethods values overlappingPairsDo: [ :a :b |
		a == b ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #accessing }
SoAvailableSendData >> dataFor: behavior ifNone: aBlock [
	^ behaviorsAndMethods 
		at: behavior
		ifPresent: [ :method | method ]
		ifAbsent: aBlock
]

{ #category : #testing }
SoAvailableSendData >> hasCoherentReceiverType [
	"Ensure that all the classes have the same layout type (i.e., cannot be ByteArray and Array as receivers), and in addition, that the number of inst vars of the variable sized object is the same between all the potential receiver classes"
	| spec |
	spec := behaviorsAndMethods keys first instSpec.
	(spec = ByteArray instSpec or: [ spec = Array instSpec ]) ifFalse: [ ^ false ].
	behaviorsAndMethods size = 1 ifTrue: [ ^ true ].
	behaviorsAndMethods keys overlappingPairsDo: [ :a :b |
		a format = b format ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #testing }
SoAvailableSendData >> isAvailable [
	^ true
]

{ #category : #testing }
SoAvailableSendData >> mayBeInlinablePIC [
	^ true
]

{ #category : #accessing }
SoAvailableSendData >> methodToInline [
	"Assumes that all methods are the same"
	^ behaviorsAndMethods anyOne
]

{ #category : #copying }
SoAvailableSendData >> postCopy [
	super postCopy.
	behaviorsAndMethods := behaviorsAndMethods copy
]

{ #category : #traps }
SoAvailableSendData >> trapFor: object [
	^ SoTrapIfNotInstanceOf new
		behaviors: self behaviors;
		expression: object;
		yourself
]
