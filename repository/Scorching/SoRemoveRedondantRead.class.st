"
I traverse the basic block in preorder and keep a live set of heap accesses without immutability checks. If I reach an instruction that could lead to external heap access (send, branch, write with immutability check, etc..) I free the live set. If I reach an heap access without immutabilityCheck I add it to the live set. If I reach a heap read that is in the live set, I remove it and use the previous value. 
"
Class {
	#name : #SoRemoveRedondantRead,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'liveSet'
	],
	#category : #'Scorching-Pass-Heap'
}

{ #category : #private }
SoRemoveRedondantRead >> checkAgainstLiveSet: access [
	"Access may be read or write but without immutability check"
	liveSet 
		detect: [ :node | node accessID = access accessID ]
		ifFound: [ :elem | self simplify: access thankTo: elem ]
		ifNone: [ liveSet add: access ]
]

{ #category : #private }
SoRemoveRedondantRead >> freeLiveSet [
	^ liveSet := OrderedCollection new
]

{ #category : #accessing }
SoRemoveRedondantRead >> liveSet [
	<generated>
	^ liveSet
]

{ #category : #accessing }
SoRemoveRedondantRead >> liveSet: aValue [
	<generated>
	liveSet := aValue
]

{ #category : #private }
SoRemoveRedondantRead >> mergeLiveSets: sets [
	self freeLiveSet.
	liveSet addAll: sets first.
	sets allButFirstDo: [ :s |
		liveSet := liveSet intersection: s ]
]

{ #category : #public }
SoRemoveRedondantRead >> runOn: codeNode [
	self traversePreorderCode: codeNode.
]

{ #category : #private }
SoRemoveRedondantRead >> simplify: access thankTo: elem [
	access isRead 	
		ifTrue: [ self simplifyRead: access thankTo: elem ]
		ifFalse: [ self simplifyWrite: access thankTo: elem ]
]

{ #category : #private }
SoRemoveRedondantRead >> simplifyRead: access thankTo: elem [
	"Access is a read. We replace it by previous read / value written."
	elem isWrite
		ifTrue: [ ^ access removeAndReplaceUsesBy: elem expression ].
	access removeAndReplaceUsesBy: elem.
]

{ #category : #private }
SoRemoveRedondantRead >> simplifyWrite: access thankTo: elem [
	"Access is a write.
	If elem is a write, that's a redondant store.
	If elem is a read, it may be used and we can't do anything."
	liveSet remove: elem.
	elem isRead ifTrue: [ ^self ].
	liveSet add: access.
	"The access may be in a branch so elem cannot be removed. We could analyse 
	 that somehow, but we need reverse dominator and I am not sure it would 
	 improve that much performance."
	elem basicBlock = access basicBlock ifFalse: [ ^ self ].
	elem removeInstr.
]

{ #category : #traversing }
SoRemoveRedondantRead >> traverseBodyInstruction: instr [
	instr hasDeoptInfo ifTrue: [ self freeLiveSet ].
]

{ #category : #traversing }
SoRemoveRedondantRead >> traverseBooleanBranch: instr [
	instr hasDeoptInfo ifTrue: [ self freeLiveSet ].
]

{ #category : #traversing }
SoRemoveRedondantRead >> traverseByteAtOp: access [
	self checkAgainstLiveSet: access
]

{ #category : #traversing }
SoRemoveRedondantRead >> traverseForwardBasicBlock: basicBlock [
	self updateLiveSet: basicBlock.
	super traverseForwardBasicBlock: basicBlock.
	basicBlock tempData: liveSet.
]

{ #category : #traversing }
SoRemoveRedondantRead >> traverseHeapAccess: access [
	access hasImmutabilityCheck
		ifTrue: [ self freeLiveSet ]
		ifFalse: [ self checkAgainstLiveSet: access ]
]

{ #category : #traversing }
SoRemoveRedondantRead >> traversePointerAtOp: access [
	self checkAgainstLiveSet: access
]

{ #category : #traversing }
SoRemoveRedondantRead >> traverseTrapIfNotInstanceOf: instr [
]

{ #category : #private }
SoRemoveRedondantRead >> updateLiveSet: basicBlock [
	basicBlock hasBackwardPredecessor ifTrue: [ ^ self freeLiveSet ].
	basicBlock predecessors ifEmpty: [ ^ self freeLiveSet ].
	basicBlock predecessors size = 1 ifTrue: [ liveSet := basicBlock predecessors anyOne tempData copy ].
	self mergeLiveSets: (basicBlock predecessors collect: [:e | e tempData])
]
