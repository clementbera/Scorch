"
My instances hold information to recreate the unoptimised stack at a given point.

sunkObjects <Collection of SunkObjectState> a list of objects to reconstruct. The first object is the bottom context to reconstruct.
instruction <Instruction> instruction I am attached to.
"
Class {
	#name : #SoDeoptimizationInformation,
	#superclass : #Object,
	#instVars : [
		'sunkObjects',
		'instruction'
	],
	#pools : [
		'SoMemoryManagerConstants'
	],
	#category : #'Scorching-Nodes-Deopt'
}

{ #category : #accessing }
SoDeoptimizationInformation >> addSunkObject: obj [
	sunkObjects add: obj.
	obj addUse: self
]

{ #category : #accessing }
SoDeoptimizationInformation >> addSunkObjects: objects [
	objects do: [ :each | self addSunkObject: each ]
]

{ #category : #converting }
SoDeoptimizationInformation >> asDeoptFor: node [
	^ {sunkObjects first asDeoptFor: node} ,
		(sunkObjects allButFirst collect: [ :each | each asDeopt ])
]

{ #category : #converting }
SoDeoptimizationInformation >> convertToReadOnlyTrapWith: node [
	| template newSunkContext |
	template := sunkObjects first.
	newSunkContext := SoPointerSunkObjectState new
		theClass: template theClass;
		marker: template marker;
		fixedFields: template fixedFields copy;
		variableFields: template variableFields copy allButLast, node subNodes;
		yourself.
	"stackp patch"
	newSunkContext fixedFields at: 3 put: (SoConstant 
		constant: (newSunkContext fixedFields at: 3) constant - 1 + node subNodesSize).
	^ SoDeoptimizationInformation new
		addSunkObject: newSunkContext;
		addSunkObjects: sunkObjects allButFirst;
		yourself
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
	"stackp patch"
	newSunkContext fixedFields at: 3 put: (SoConstant 
		constant: (newSunkContext fixedFields at: 3) constant + node subNodesSize).
	^ SoDeoptimizationInformation new
		addSunkObject: newSunkContext;
		addSunkObjects: sunkObjects allButFirst;
		yourself
]

{ #category : #'graph edition' }
SoDeoptimizationInformation >> copyForSubGraphTransformation [
	sunkObjects := sunkObjects collect: [ :sunk |
		sunk uses size = 1 "this is the use"
			ifTrue: [ sunk ]
			ifFalse: [ 
				| copy |
				copy := sunk copy.
				sunk removeUse: self.
				copy addUse: self.
				copy ] ]
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

{ #category : #accessing }
SoDeoptimizationInformation >> instruction [
	<generated>
	^ instruction
]

{ #category : #accessing }
SoDeoptimizationInformation >> instruction: aValue [
	<generated>
	instruction := aValue
]

{ #category : #'graph edition' }
SoDeoptimizationInformation >> postCopy [
	sunkObjects := sunkObjects copy.
	sunkObjects do: [ :s | s addUse: self ].
]

{ #category : #'graph edition' }
SoDeoptimizationInformation >> removeDeopt [
	sunkObjects do: [ :each | each removeUse: self ]
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
