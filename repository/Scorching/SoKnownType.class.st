"
I represent known type information of an instruction.

behaviors <Collection of Behavior> list of behaviors the instruction can have as a type. In most case, only one is present.
"
Class {
	#name : #SoKnownType,
	#superclass : #SoType,
	#instVars : [
		'behaviors'
	],
	#pools : [
		'SoMemoryManagerConstants'
	],
	#category : #'Scorching-Type'
}

{ #category : #'instance creation' }
SoKnownType class >> for: behavior [
	^ self new 	
		behaviors: { behavior };
		yourself
]

{ #category : #'instance creation' }
SoKnownType class >> forArray: arrayOfTypes [
	^ self new 	
		behaviors: arrayOfTypes;
		yourself
]

{ #category : #accessing }
SoKnownType >> behaviors [
	<generated>
	^ behaviors
]

{ #category : #accessing }
SoKnownType >> behaviors: aValue [
	<generated>
	behaviors := aValue
]

{ #category : #testing }
SoKnownType >> hasConflict [
	"Can happen after multiple intersections in rare case..."
	^ behaviors isEmpty
]

{ #category : #testing }
SoKnownType >> hasOneType [
	^ behaviors size = 1
]

{ #category : #operations }
SoKnownType >> intersection: type [
	^ type knownIntersection: self
]

{ #category : #testing }
SoKnownType >> isKnownType [
	^ true
]

{ #category : #testing }
SoKnownType >> isOnlyType: type [
	^ behaviors size = 1 and: [ behaviors anyOne == type ]
]

{ #category : #testing }
SoKnownType >> isOnlyTypes: types [
	^ behaviors allSatisfy: [ :t | types includes: t ]
]

{ #category : #operations }
SoKnownType >> knownIntersection: type [
	^ SoKnownType new
		behaviors: (behaviors intersection: type behaviors);
		yourself
]

{ #category : #operations }
SoKnownType >> knownUnion: type [
	^ SoKnownType new
		behaviors: (behaviors , type behaviors) asSet asArray;
		yourself
]

{ #category : #testing }
SoKnownType >> requiresStoreCheck [
	"Answers if an instruction of this type stored into another object requires a store check"
	^ behaviors allSatisfy: [ :behavior |
		NoStoreCheckTypes includes: behavior ]
]

{ #category : #'send data specialization' }
SoKnownType >> specializeSendData: send [
	| theClass bAndM |
	"We should look into the send sendData if there are not already results..."
	theClass := SoAvailableSendData.
	bAndM := Dictionary new.
	behaviors do: [ :b |
		| lookupClass lookupResult |
		lookupResult := send sendData dataFor: b ifNone: [
			lookupClass := send methodClass ifNil: [ b ] ifNotNil: [ :mc | mc superclass ].
			lookupClass lookupSelector: send selector ].
		lookupResult ifNil: [ 
			theClass := SoAvailableSendDataWithDNU.
			lookupResult := #doesNotUnderstand: ].
		bAndM at: b put: lookupResult ].
	^ theClass new
		behaviorsAndMethods: bAndM;
		yourself
	

]

{ #category : #operations }
SoKnownType >> union: type [
	^ type knownUnion: self
]
