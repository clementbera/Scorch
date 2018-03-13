"
Common superclass of sunk objects. An object is considered as sunk if it is not allocated in the optimized code but recreated by the deoptimization metadata if the optimized context is deoptimized.

node <Instruction> node to which the deopt data isattached.
deoptNode <DeoptNode> node generated in deopt metadata (after the backend has done it)
theClass <Behavior> class of the object to restore.
marker < SunkObjectMarker> identity of the sunk object
"
Class {
	#name : #SoAbsSunkObjectState,
	#superclass : #SoAbsNode,
	#instVars : [
		'uses',
		'deoptNode',
		'theClass',
		'marker'
	],
	#category : #'Scorching-Nodes-Deopt'
}

{ #category : #graphEdition }
SoAbsSunkObjectState >> addUse: use [
	uses add: use
]

{ #category : #conversion }
SoAbsSunkObjectState >> asDeopt [
	^ deoptNode ifNil: [ deoptNode := self convertToDeoptNode ]
]

{ #category : #conversion }
SoAbsSunkObjectState >> asDeoptFor: node [
	^ self convertToDeoptNodeFor: node
]

{ #category : #accessing }
SoAbsSunkObjectState >> basicBlocks [
	^ (self uses collect: [ :use | use instruction basicBlock ]) asSet asArray
]

{ #category : #accessing }
SoAbsSunkObjectState >> codeNode [
	^ self basicBlocks 
		ifNotEmpty: [ self basicBlocks anyOne codeNode ]
		ifEmpty: [ "debugging only" SoMethod new ]
]

{ #category : #conversion }
SoAbsSunkObjectState >> convertToDeoptNode [
	self subclassResponsibility 
]

{ #category : #conversion }
SoAbsSunkObjectState >> convertToDeoptNodeFor: node [
	self subclassResponsibility 
]

{ #category : #accessing }
SoAbsSunkObjectState >> deoptNode [
	<generated>
	^ deoptNode
]

{ #category : #accessing }
SoAbsSunkObjectState >> deoptNode: aValue [
	<generated>
	deoptNode := aValue
]

{ #category : #testing }
SoAbsSunkObjectState >> inBasicBlock: bb1 or: bb2 [
	^ self basicBlocks allSatisfy: [ :basicBlock |
		basicBlock = bb1 or: [ basicBlock = bb2 ] ]
]

{ #category : #initialization }
SoAbsSunkObjectState >> initialize [

	super initialize.

	uses := OrderedCollection new.
]

{ #category : #dominator }
SoAbsSunkObjectState >> isDominatedByBasicBlock: bb [
	1halt.
	^ bb dominatesInstr: node
]

{ #category : #testing }
SoAbsSunkObjectState >> isSunkObject [
	^ true
]

{ #category : #accessing }
SoAbsSunkObjectState >> marker [
	<generated>
	^ marker
]

{ #category : #accessing }
SoAbsSunkObjectState >> marker: aValue [
	<generated>
	marker := aValue
]

{ #category : #graphEdition }
SoAbsSunkObjectState >> postCopy [
	super postCopy.
	uses := OrderedCollection new
]

{ #category : #graphEdition }
SoAbsSunkObjectState >> removeUse: use [
	uses remove: use.
	uses ifEmpty: [ self subNodesRemoveUses ].
	"If uses drop to 0 then back to 1, program need to manually reAdd uses..."
]

{ #category : #accessing }
SoAbsSunkObjectState >> theClass [
	<generated>
	^ theClass
]

{ #category : #accessing }
SoAbsSunkObjectState >> theClass: aValue [
	<generated>
	theClass := aValue
]

{ #category : #accessing }
SoAbsSunkObjectState >> uses [
	<generated>
	^ uses
]

{ #category : #accessing }
SoAbsSunkObjectState >> uses: aValue [
	<generated>
	uses := aValue
]
