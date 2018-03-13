"
Ensure a specific number of slots is available in Eden or triggers a scavenge.

numSlots <Smi> slots
"
Class {
	#name : #SoEnsureEnoughSlots,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'numSlots'
	],
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #'graph edition' }
SoEnsureEnoughSlots >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	numSlots := anotherNode.
	anotherNode addUse: self
]

{ #category : #testing }
SoEnsureEnoughSlots >> hasEffect [
	^ true
]

{ #category : #testing }
SoEnsureEnoughSlots >> isEnsureEnoughSlots [
	^ true
]

{ #category : #testing }
SoEnsureEnoughSlots >> isMapped [
	^ true
]

{ #category : #traversing }
SoEnsureEnoughSlots >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseEnsureEnoughSlots: self
]

{ #category : #accessing }
SoEnsureEnoughSlots >> numSlots [
	<generated>
	^ numSlots
]

{ #category : #accessing }
SoEnsureEnoughSlots >> numSlots: aValue [
	<generated>
	numSlots := aValue.
	numSlots  addUse: self
]

{ #category : #testing }
SoEnsureEnoughSlots >> primitiveNumber [
	^ 50
]

{ #category : #'graph edition' }
SoEnsureEnoughSlots >> subNodes [
	<generated>
	^ {numSlots}
]

{ #category : #'graph edition' }
SoEnsureEnoughSlots >> subNodesAnySatisfy: aBlock [
	"profiling"
	<generated>
	^aBlock value: numSlots.
	
]

{ #category : #'graph edition' }
SoEnsureEnoughSlots >> subNodesDo: aBlock [
	"profiling"
	<generated>
	aBlock value: numSlots
]

{ #category : #'graph edition' }
SoEnsureEnoughSlots >> subNodesSize [
	<generated>
	^ 1
]
