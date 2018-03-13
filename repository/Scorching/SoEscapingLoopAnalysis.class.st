"
Used by the escape optimisation, I analyse loops to find out escapes and liveSet. This analysis is used to set up the liveSet and escapes at the end of basicBlocks with backjumps so that escape optimisation can optimise across loops. See EscapeOptimisation subclass for more information on instance variables.
"
Class {
	#name : #SoEscapingLoopAnalysis,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'liveSet',
		'escapes'
	],
	#pools : [
		'SoMagicConstants',
		'SoMemoryManagerConstants'
	],
	#category : #'Scorching-Pass-Heap'
}

{ #category : #'private - updating' }
SoEscapingLoopAnalysis >> breakingDeoptPointAt: instr [
	self freeLiveSet.
	self checkSubNodesEscape: instr
]

{ #category : #'private - escape' }
SoEscapingLoopAnalysis >> checkEscape: instr [
	instr isNew ifTrue: [
		(escapes keys includes: instr)
			ifTrue: [ escapes removeKey: instr ] ]
]

{ #category : #'private - escape' }
SoEscapingLoopAnalysis >> checkSubNodesEscape: node [
	node subNodesDo: [ :instr |
		self checkEscape: instr ]
]

{ #category : #accessing }
SoEscapingLoopAnalysis >> escapes [
	<generated>
	^ escapes
]

{ #category : #accessing }
SoEscapingLoopAnalysis >> escapes: aValue [
	<generated>
	escapes := aValue
]

{ #category : #'private - updating' }
SoEscapingLoopAnalysis >> freeAll [
	self freeLiveSet.
	escapes := Dictionary new
]

{ #category : #'private - updating' }
SoEscapingLoopAnalysis >> freeLiveSet [
	liveSet := OrderedCollection new
]

{ #category : #accessing }
SoEscapingLoopAnalysis >> liveSet [
	<generated>
	^ liveSet
]

{ #category : #accessing }
SoEscapingLoopAnalysis >> liveSet: aValue [
	<generated>
	liveSet := aValue
]

{ #category : #'private - updating' }
SoEscapingLoopAnalysis >> mergeEscapes: anotherDict [
	"keys creates a copy, don't use keysDo:"
	escapes keys do: [ :key |
		(anotherDict includesKey: key) ifFalse: [ escapes removeKey: key ] ].
	escapes keysAndValuesDo: [ :key :type1 |
		escapes at: key put: (type1 mergeWith: (anotherDict at: key)) ]
]

{ #category : #'private - updating' }
SoEscapingLoopAnalysis >> rememberFromBasicBlock: basicBlock [
	liveSet := basicBlock tempData first copy.
	escapes := basicBlock tempData second copy.
	escapes keysAndValuesDo: [ :key :value |
		escapes at: key put: value copy ]
]

{ #category : #'private - updating' }
SoEscapingLoopAnalysis >> rememberFromBasicBlocks: basicBlocks [
	self rememberFromBasicBlock: basicBlocks first.
	basicBlocks allButFirstDo: [ :bb |
		liveSet := liveSet intersection: bb tempData first.
		self mergeEscapes: bb tempData second ]
]

{ #category : #'private - updating' }
SoEscapingLoopAnalysis >> rememberIn: basicBlock liveSet: set escapes: dict [
	basicBlock tempData: {set.dict}.
]

{ #category : #'private - live set' }
SoEscapingLoopAnalysis >> removeReadWritesMatching: write [
	liveSet copy do: [ :e |
		(e isObjectAccess 
			and: [ e object = write object
			and: [ e index = write index ] ]) ifTrue: [ liveSet remove: e ] ]
]

{ #category : #'private - updating' }
SoEscapingLoopAnalysis >> startBasicBlock: basicBlock [
	"That optimisation does not use postOrder fields of basicBlock, so we abuse it."
	basicBlock predecessors ifEmpty: [ ^ self freeAll ].
	basicBlock predecessors size = 1 ifTrue: [ ^ self rememberFromBasicBlock: basicBlock predecessors anyOne ].
	basicBlock hasBackwardPredecessor ifTrue: [ 
		"Sets the backward predecessor information"
		SoEscapingLoopAnalysis new trackLoopAt: basicBlock ].
	self rememberFromBasicBlocks: basicBlock predecessors
]

{ #category : #public }
SoEscapingLoopAnalysis >> trackLoopAt: merge [
	"Computes liveSet and escapes at the end of the loop"
	self rememberFromBasicBlock: merge forwardPredecessors anyOne.
	super traverseForwardBasicBlock: merge.
	self rememberIn: merge liveSet: liveSet escapes: escapes.
	(merge codeNode basicBlocks 
		copyFrom: merge postOrder + 1
		to: merge backwardPredecessor postOrder) do: [ :basicBlock |	
			self traverseForwardBasicBlock: basicBlock ]
]

{ #category : #traversing }
SoEscapingLoopAnalysis >> traverseBodyInstruction: instr [
	instr hasBreakingDeoptPoint ifFalse: [ ^ self ].
	self breakingDeoptPointAt: instr.
]

{ #category : #traversing }
SoEscapingLoopAnalysis >> traverseCreateFullBlock: block [
	self checkSubNodesEscape: block
]

{ #category : #traversing }
SoEscapingLoopAnalysis >> traverseEnsureEnoughSlots: slot [
	"This may trigger a GC - object may not be root anymore, young"
	liveSet := liveSet reject: [ :e |
		e isNew or: [ e isYoungBranch or: [ e isPossibleRoot ] ] ]
]

{ #category : #traversing }
SoEscapingLoopAnalysis >> traverseForwardBasicBlock: basicBlock [
	self startBasicBlock: basicBlock.
	super traverseForwardBasicBlock: basicBlock.
	self rememberIn: basicBlock liveSet: liveSet escapes: escapes
]

{ #category : #traversing }
SoEscapingLoopAnalysis >> traverseObjectWrite: write [
	(write hasDeoptInfo and: [ (escapes keys includes: write object) not ]) ifFalse: [ 
		self removeReadWritesMatching: write.
		self checkEscape: write expression.
		^ liveSet add: write ].
	self breakingDeoptPointAt: write.
]

{ #category : #traversing }
SoEscapingLoopAnalysis >> traversePhi: phi [
	self checkSubNodesEscape: phi
]

{ #category : #traversing }
SoEscapingLoopAnalysis >> traverseUnforward: unfwd [
	"Normally CSE removes it, but in it can be there temporarilty, and we need to deal with the uses."
	self checkEscape: unfwd expression
]
