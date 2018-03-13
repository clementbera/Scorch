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
		'node',
		'deoptNode',
		'theClass',
		'marker'
	],
	#category : #'Scorching-Nodes-Deopt'
}

{ #category : #conversion }
SoAbsSunkObjectState >> asDeopt [
	^ deoptNode ifNil: [ deoptNode := self convertToDeoptNode ]
]

{ #category : #accessing }
SoAbsSunkObjectState >> basicBlock [
	^ node basicBlock
]

{ #category : #accessing }
SoAbsSunkObjectState >> codeNode [
	^ self basicBlock codeNode
]

{ #category : #conversion }
SoAbsSunkObjectState >> convertToDeoptNode [
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

{ #category : #dominator }
SoAbsSunkObjectState >> isDominatedByBasicBlock: bb [
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

{ #category : #accessing }
SoAbsSunkObjectState >> node [
	<generated>
	^ node
]

{ #category : #accessing }
SoAbsSunkObjectState >> node: aValue [
	<generated>
	node := aValue
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
