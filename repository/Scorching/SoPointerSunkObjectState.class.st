"
I am a specific version for pointer objects.

The nodes referenced are either nodes in the graph OR SunkObjectMarker. 

If I reference markers, they should be present in the deoptimization information I am in, except if the marker represent the dead outer context of a closure.

fixedFields <SequenceableCollection of Instruction|Marker>
variableFields <SequenceableCollection of Instruction|Marker>
"
Class {
	#name : #SoPointerSunkObjectState,
	#superclass : #SoAbsSunkObjectState,
	#instVars : [
		'fixedFields',
		'variableFields'
	],
	#category : #'Scorching-Nodes-Deopt'
}

{ #category : #accessing }
SoPointerSunkObjectState >> allFieldsDo: aBlock [
	fixedFields do: aBlock.
	variableFields do: aBlock.
]

{ #category : #'graph edition' }
SoPointerSunkObjectState >> basicReplaceSubNode: node1 by: anotherNode [
	fixedFields
		at: (fixedFields indexOf: node1 ifAbsent: [ 
			variableFields 
				at: (variableFields indexOf: node1)
				put: anotherNode.
			^ anotherNode addUse: self ])
		put: anotherNode.
	anotherNode addUse: self.
]

{ #category : #conversion }
SoPointerSunkObjectState >> convertToDeoptNode [
	^ SoDeoptPointerObject new
		theClass: theClass;
		marker: marker;
		fixedFields: (fixedFields collect: [ :f | f asDeopt ]);
		variableFields: (variableFields collect: [ :f | f asDeopt ]);
		yourself
]

{ #category : #conversion }
SoPointerSunkObjectState >> fixPCConstantFor: node [
	(fixedFields at: 2) fixPCConstantIn: self for: node at: 2
]

{ #category : #accessing }
SoPointerSunkObjectState >> fixedFields [
	<generated>
	^ fixedFields
]

{ #category : #accessing }
SoPointerSunkObjectState >> fixedFields: aValue [
	<generated>
	fixedFields := aValue.
	fixedFields do: [  :each | each addUse: self ]
]

{ #category : #'graph edition' }
SoPointerSunkObjectState >> postCopy [
	fixedFields := fixedFields copy.
	variableFields := variableFields copy.
	self subNodesAddUses.
]

{ #category : #'graph edition' }
SoPointerSunkObjectState >> subNodes [
	^ (fixedFields , variableFields) reject: [ :node | node isMarker ]
]

{ #category : #accessing }
SoPointerSunkObjectState >> subNodesAddUses [
	self allFieldsDo: [ :f | f addUse: self ]
]

{ #category : #accessing }
SoPointerSunkObjectState >> subNodesRemoveUses [
	self allFieldsDo: [ :f | f removeUse: self ]
]

{ #category : #accessing }
SoPointerSunkObjectState >> variableFields [
	<generated>
	^ variableFields
]

{ #category : #accessing }
SoPointerSunkObjectState >> variableFields: aValue [
	<generated>
	variableFields := aValue.
	variableFields do: [  :each | each addUse: self ]
]
