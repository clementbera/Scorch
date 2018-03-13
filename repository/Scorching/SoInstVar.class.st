"
Access to the instance variable at indexof the object.

object<ScorchNode>
index <Smi>

"
Class {
	#name : #SoInstVar,
	#superclass : #SoHeapAccess,
	#instVars : [
		'object',
		'index'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #accessing }
SoInstVar >> accessID [
	^ { object . index } 
]

{ #category : #'graph edition' }
SoInstVar >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	object == node ifTrue: [ 
		object := anotherNode.
		^ anotherNode addUse: self ].
	accessStrategy expression: anotherNode.
	anotherNode addUse: self
]

{ #category : #accessing }
SoInstVar >> index [
	<generated>
	^ index
]

{ #category : #accessing }
SoInstVar >> index: aValue [
	<generated>
	index := aValue
]

{ #category : #testing }
SoInstVar >> isInstVar [
	^ true
]

{ #category : #traversing }
SoInstVar >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseInstVar: self
]

{ #category : #accessing }
SoInstVar >> object [
	<generated>
	^ object
]

{ #category : #accessing }
SoInstVar >> object: aValue [
	<generated>
	object := aValue.
	object  addUse: self
]

{ #category : #'graph edition' }
SoInstVar >> subNodes [
	<generated>
	^ {object} , accessStrategy subNodes
]
