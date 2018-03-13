"
I represent an access to an object at a given index. This can correspond to multiple operations including #at:, #at:put:, #instVarAt:, #instVarAt:put:, direct inst var accesses.

The index can be a constant but is not necessarily one. The JIT optimises the case where index is a constant (This is quite common, typically for most inst var accesses).

object <ScorchNode> object mutated / read
index <ScorchNode> index of the object in pointers
"
Class {
	#name : #SoAbsObjectAccess,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'object',
		'index'
	],
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #'instance creation' }
SoAbsObjectAccess class >> fromSend: send [
	"at: => access"
	^ self new
		object: send receiver;
		index: send firstArg;
		yourself
]

{ #category : #accessing }
SoAbsObjectAccess >> access [
	^ object
]

{ #category : #'graph edition' }
SoAbsObjectAccess >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	object == node ifTrue: [ 
		object := anotherNode.
		^ anotherNode addUse: self ].
	index := anotherNode.
	anotherNode addUse: self
]

{ #category : #accessing }
SoAbsObjectAccess >> index [
	<generated>
	^ index
]

{ #category : #accessing }
SoAbsObjectAccess >> index: aValue [
	<generated>
	index := aValue.
	index  addUse: self
]

{ #category : #testing }
SoAbsObjectAccess >> isObjectAccess [
	^ true
]

{ #category : #accessing }
SoAbsObjectAccess >> object [
	<generated>
	^ object
]

{ #category : #accessing }
SoAbsObjectAccess >> object: aValue [
	<generated>
	object := aValue.
	object  addUse: self
]

{ #category : #'graph edition' }
SoAbsObjectAccess >> subNodes [
	<generated>
	^ {object . index}
]

{ #category : #'graph edition' }
SoAbsObjectAccess >> subNodesAnySatisfy: aBlock [
	"profiling"
	<generated>
	(aBlock value: object) ifTrue: [^true].
	^aBlock value: index.
	
]

{ #category : #'graph edition' }
SoAbsObjectAccess >> subNodesDo: aBlock [
	"profiling"
	<generated>
	aBlock value: object.
	aBlock value: index
]

{ #category : #'graph edition' }
SoAbsObjectAccess >> subNodesSize [
	<generated>
	^ 2
]
