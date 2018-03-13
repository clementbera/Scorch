"
I sink objects (I deffer their allocation from runtime to deoptimization time).

Warning: Experimental pass.
"
Class {
	#name : #SoObjectSinker,
	#superclass : #SoGraphTraverser,
	#pools : [
		'SoMagicConstants'
	],
	#category : #'Scorching-Pass-Heap'
}

{ #category : #'private - sink' }
SoObjectSinker >> maybeSinkObject: node [
	1halt. "Not working ."
	self assert: node class = SoCreateArray. "Temporarily"
	node sizeInformation > MaxObjectSizeToStackAllocation ifTrue: [ ^ self ].
	(node uses allSatisfy: [ :use |
		use isAccessingOp or: [ use isSunkObject ] ]) ifFalse: [ ^ self ].
	self sinkObject: node
]

{ #category : #'private - sink' }
SoObjectSinker >> quickSinkObject: node [
	"fast path... The object is not muted after creation (runtime array)"
	
]

{ #category : #public }
SoObjectSinker >> runOn: codeNode [
]

{ #category : #'private - sink' }
SoObjectSinker >> sinkObject: node [
	"we need to propagate all state along the thing..."
	(node uses allSatisfy: [ :use | use isSunkObject or: [ use isAt ] ]) ifTrue: [ ^ self quickSinkObject: node ].
	1halt.
]
