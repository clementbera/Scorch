"
I represent a write inside an object, such as (object at: 1 put: 1), inst var write, etc.

expression <ScorchNode> value to assign
"
Class {
	#name : #SoAbsObjectWrite,
	#superclass : #SoAbsObjectAccess,
	#instVars : [
		'expression'
	],
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #conversion }
SoAbsObjectWrite >> asInstrWithoutChecks [
	^ self
]

{ #category : #'graph edition' }
SoAbsObjectWrite >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	object == node ifTrue: [ 
		object := anotherNode.
		^ anotherNode addUse: self ].
	index == node ifTrue: [ 
		index := anotherNode.
		^ anotherNode addUse: self ].
	expression := anotherNode.
	anotherNode addUse: self
]

{ #category : #accessing }
SoAbsObjectWrite >> expression [
	<generated>
	^ expression
]

{ #category : #accessing }
SoAbsObjectWrite >> expression: aValue [
	<generated>
	expression := aValue.
	expression  addUse: self
]

{ #category : #traps }
SoAbsObjectWrite >> insertReadOnlyTrap [
	(SoTrapIfReadOnly new
		expression: object;
		deoptInfo: self readOnlyDeoptInfo;
		yourself) insertBefore: self
]

{ #category : #testing }
SoAbsObjectWrite >> isEscapeFor: node [
	^ self hasDeoptInfo and: [ node = expression ]
]

{ #category : #traversing }
SoAbsObjectWrite >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseObjectWrite: self
]

{ #category : #testing }
SoAbsObjectWrite >> isWrite [
	^ true
]

{ #category : #traps }
SoAbsObjectWrite >> readOnlyDeoptInfo [
	self wasPopInto ifTrue: [ 
		^ self deoptInfo convertToTrapWith: self ].
	^ self deoptInfo convertToReadOnlyTrapWith: self
]

{ #category : #accessing }
SoAbsObjectWrite >> storeCheck [
	^ false
]

{ #category : #accessing }
SoAbsObjectWrite >> storeCheck: sc [
	
]

{ #category : #'graph edition' }
SoAbsObjectWrite >> subNodes [
	<generated>
	^ {object . index . expression}
]

{ #category : #'graph edition' }
SoAbsObjectWrite >> subNodesAnySatisfy: aBlock [
	"profiling"
	<generated>
	(aBlock value: object) ifTrue: [^true].
	(aBlock value: index) ifTrue: [^true].
	^aBlock value: expression.
	
]

{ #category : #'graph edition' }
SoAbsObjectWrite >> subNodesDo: aBlock [
	"profiling"
	<generated>
	aBlock value: object.
	aBlock value: index.
	aBlock value: expression
]

{ #category : #'graph edition' }
SoAbsObjectWrite >> subNodesSize [
	<generated>
	^ 3
]

{ #category : #traps }
SoAbsObjectWrite >> transformToReadOnlyTrapAndStore [
	self hasDeoptInfo ifFalse: [ ^self ].
	self insertReadOnlyTrap.
	self replaceBy: (self asInstrWithoutChecks 
		storeCheck: self storeCheck;
		yourself).
]

{ #category : #traps }
SoAbsObjectWrite >> wasPopInto [
	^ false
]
