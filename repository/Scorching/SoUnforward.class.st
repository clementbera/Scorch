"
Unforward the object if this is a forwarder.

(This should generate:
tmp := tmp unforward
except if spilled
or be clever, else it won't work properly)
"
Class {
	#name : #SoUnforward,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'expression'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #'graph edition' }
SoUnforward >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	expression := anotherNode.
	anotherNode addUse: self
]

{ #category : #testing }
SoUnforward >> cannotBeForwarded [
	^ true
]

{ #category : #accessing }
SoUnforward >> expression [
	<generated>
	^ expression
]

{ #category : #accessing }
SoUnforward >> expression: aValue [
	<generated>
	expression := aValue.
	expression  addUse: self
]

{ #category : #testing }
SoUnforward >> hasEffect [
	^ false
]

{ #category : #traversing }
SoUnforward >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseUnforward: self
]

{ #category : #primitive }
SoUnforward >> okForBackEnsureEnoughSlots [
	^ true
]

{ #category : #primitive }
SoUnforward >> primitiveNumber [
	^ 1040
]

{ #category : #comparing }
SoUnforward >> sameExprAs: op [
	op class = self class ifFalse: [ ^ false ].
	^ op expression = expression
]

{ #category : #'graph edition' }
SoUnforward >> subNodes [
	<generated>
	^ {expression}
]

{ #category : #'graph edition' }
SoUnforward >> subNodesAnySatisfy: aBlock [
	"profiling"
	<generated>
	^aBlock value: expression.
	
]

{ #category : #'graph edition' }
SoUnforward >> subNodesDo: aBlock [
	"profiling"
	<generated>
	aBlock value: expression
]

{ #category : #'graph edition' }
SoUnforward >> subNodesSize [
	<generated>
	^ 1
]
