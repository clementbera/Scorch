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
SoPointerSunkObjectState >> convertToDeoptNodeFor: node [
	| fixedFieldPatched |
	fixedFieldPatched := fixedFields copy.
	fixedFieldPatched at: 2 put: ((node isImmediateTrap 
		or: [node isBackjump])
			ifTrue: [SoConstant constant: (fixedFields at: 2) instrPC ]
			ifFalse: [SoConstant constant: (fixedFields at: 2) nextPC ]).
	^ SoDeoptPointerObject new
		theClass: theClass;
		marker: marker;
		fixedFields: (fixedFieldPatched collect: [ :f | f asDeopt ]);
		variableFields: (variableFields collect: [ :f | f asDeopt ]);
		yourself
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
	super postCopy.
	fixedFields := fixedFields copy.
	variableFields := variableFields copy.
	self subNodesAddUses.
]

{ #category : #accessing }
SoPointerSunkObjectState >> subNodes [
	^ fixedFields , variableFields reject: [ :each | each isMarker ]
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
