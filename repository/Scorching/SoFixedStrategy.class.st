"
Specific strategy for fixed objects. We type separatedly each instance variable with the met types. Each field of the arrayOfTypes deals with the corresponding inst var index.

arrayOfTypes <Array of Type>


"
Class {
	#name : #SoFixedStrategy,
	#superclass : #SoTypingStrategy,
	#instVars : [
		'arrayOfTypes'
	],
	#category : #'Scorching-Pass-Heap'
}

{ #category : #accessing }
SoFixedStrategy >> arrayOfTypes [
	<generated>
	^ arrayOfTypes
]

{ #category : #accessing }
SoFixedStrategy >> arrayOfTypes: aValue [
	<generated>
	arrayOfTypes := aValue
]

{ #category : #initialization }
SoFixedStrategy >> initializeWith: alloc [
	arrayOfTypes := Array new: alloc behavior instSize.
	alloc needsInit ifFalse: [ ^self ].
	arrayOfTypes withIndexDo: [ :each :index |
		arrayOfTypes at: index put: (SoKnownType for: UndefinedObject) ]
]

{ #category : #merging }
SoFixedStrategy >> mergeWith: typingStrat [
	arrayOfTypes withIndexDo: [ :type1 :index |
		| type2 |
		type2 := typingStrat arrayOfTypes at: index.
		arrayOfTypes at: index put: (type1 union: type2) ]
]

{ #category : #copying }
SoFixedStrategy >> postCopy [
	arrayOfTypes := arrayOfTypes copy
]

{ #category : #types }
SoFixedStrategy >> typeRead: read [
	read index isConstant ifFalse: [ ^ self ].
	read type: (arrayOfTypes at: read index constant)
]

{ #category : #types }
SoFixedStrategy >> typeWrite: write [
	write index isConstant ifFalse: [ ^ self ].
	arrayOfTypes at: write index constant put: (write expression typeInformationAt: write)
]
