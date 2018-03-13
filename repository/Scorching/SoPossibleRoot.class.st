"
Mark the object in the remembered table. The object then does not need any store check until the next interrupt point.
"
Class {
	#name : #SoPossibleRoot,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'expression'
	],
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #accessing }
SoPossibleRoot >> arguments: args [
]

{ #category : #'graph edition' }
SoPossibleRoot >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	expression := anotherNode.
	anotherNode addUse: self
]

{ #category : #accessing }
SoPossibleRoot >> expression [
	<generated>
	^ expression
]

{ #category : #accessing }
SoPossibleRoot >> expression: aValue [
	<generated>
	expression := aValue.
	expression  addUse: self
]

{ #category : #testing }
SoPossibleRoot >> isPossibleRoot [
	^ true
]

{ #category : #traversing }
SoPossibleRoot >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traversePossibleRoot: self
]

{ #category : #primitive }
SoPossibleRoot >> primitiveNumber [
	^ 1041
]

{ #category : #accessing }
SoPossibleRoot >> receiver: obj [
	self expression: obj
]

{ #category : #'graph edition' }
SoPossibleRoot >> subNodes [
	<generated>
	^ {expression}
]

{ #category : #'graph edition' }
SoPossibleRoot >> subNodesAnySatisfy: aBlock [
	"profiling"
	<generated>
	^aBlock value: expression.
	
]

{ #category : #'graph edition' }
SoPossibleRoot >> subNodesDo: aBlock [
	"profiling"
	<generated>
	aBlock value: expression
]

{ #category : #'graph edition' }
SoPossibleRoot >> subNodesSize [
	<generated>
	^ 1
]
