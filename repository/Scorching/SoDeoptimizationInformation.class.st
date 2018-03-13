"
My instances hold information to recreate the unoptimised stack at a given point.

sunkObjects <Collection of SunkObjectState> a list of objects to reconstruct. The first object is the bottom context to reconstruct.

"
Class {
	#name : #SoDeoptimizationInformation,
	#superclass : #Object,
	#instVars : [
		'sunkObjects'
	],
	#pools : [
		'SoMemoryManagerConstants'
	],
	#category : #'Scorching-Nodes-Deopt'
}

{ #category : #accessing }
SoDeoptimizationInformation >> addSunkObject: obj [
	sunkObjects add: obj.
	obj node: sunkObjects first node.
]

{ #category : #accessing }
SoDeoptimizationInformation >> addSunkObjects: objects [
	objects do: [ :each | self addSunkObject: each ]
]

{ #category : #converting }
SoDeoptimizationInformation >> asDeoptFor: node [
	sunkObjects first fixPCConstantFor: node.
	^ sunkObjects collect: [ :each | each asDeopt ]
]

{ #category : #converting }
SoDeoptimizationInformation >> convertToTrapWith: node [
	| template newSunkContext |
	template := sunkObjects first.
	newSunkContext := SoPointerSunkObjectState new
		theClass: template theClass;
		marker: template marker;
		fixedFields: template fixedFields copy;
		variableFields: template variableFields copy, node subNodes;
		yourself.
	newSunkContext fixedFields at: 3 put: (SoConstant 
		constant: (newSunkContext fixedFields at: 3) constant + node subNodes size).
	^ SoDeoptimizationInformation new
		addSunkObject: newSunkContext;
		addSunkObjects: (sunkObjects allButFirst collect: [:each | each copy ]);
		yourself
]

{ #category : #accessing }
SoDeoptimizationInformation >> depth [
	^ sunkObjects count: [ :each | each theClass == ContextClass ]
]

{ #category : #initialization }
SoDeoptimizationInformation >> initialize [

	super initialize.

	sunkObjects := OrderedCollection new.
]

{ #category : #'graph edition' }
SoDeoptimizationInformation >> postCopy [
	sunkObjects := sunkObjects collect: [ :sunk | sunk copy ].
]

{ #category : #'graph edition' }
SoDeoptimizationInformation >> removeDeopt [
	sunkObjects do: [ :each | each subNodesRemoveUses  ]
]

{ #category : #accessing }
SoDeoptimizationInformation >> sunkObjects [
	<generated>
	^ sunkObjects
]

{ #category : #accessing }
SoDeoptimizationInformation >> sunkObjects: aValue [
	<generated>
	sunkObjects := aValue
]
