"
I merge a basic block into its predecessor, if and only if they're connected through a forward jump relationship and that the basicBlock has a unique successor.

I am important for many different reasons:
- I help keeping the CFG canonicalized so some passes can be simpler
- I merge instructions allowing passes working on a single basicBlock to perform better
- I decrease the number of basicBlocks so passes working only on basicBlock are faster
- I help debugging as a CFG with fewer basicBlocks is easier to read
"
Class {
	#name : #SoBasicBlockMerger,
	#superclass : #Object,
	#category : #'Scorching-Pass-Flow'
}

{ #category : #private }
SoBasicBlockMerger >> changePhiReferenceFrom: basicBlock to: uniquePredecessor [
	basicBlock successors do: [ :succ |
		succ phisDo: [ :phi |
			phi replaceBasicBlock: basicBlock with: uniquePredecessor ] ]
]

{ #category : #private }
SoBasicBlockMerger >> fixControlFlow: basicBlock to: uniquePredecessor [
	basicBlock successors do: [ :succ |
		succ removePredecessor: basicBlock.
		succ addPredecessor: uniquePredecessor ]
]

{ #category : #private }
SoBasicBlockMerger >> merge: basicBlock intoPredecessor: uniquePredecessor [
	
	"there is a single phi input."
	basicBlock phisDo: [ :phi | phi removeAndReplaceUsesBy: phi inputs anyOne ].
	self mergeInstructions: basicBlock into: uniquePredecessor.
	basicBlock codeNode basicBlocks remove: basicBlock.
	self changePhiReferenceFrom: basicBlock to: uniquePredecessor.
	
	basicBlock successors ifEmpty: [ ^ self ].
	self fixControlFlow: basicBlock to: uniquePredecessor.
	self patchDominatorFrom: basicBlock to: uniquePredecessor.
]

{ #category : #private }
SoBasicBlockMerger >> mergeInstructions: basicBlock into: uniquePredecessor [
	uniquePredecessor lastInstr prevInstrNextInstr: basicBlock firstInstr.
	uniquePredecessor lastInstr: basicBlock lastInstr.
	basicBlock instructionsDo: [ :instr | instr basicBlock: uniquePredecessor ]
]

{ #category : #public }
SoBasicBlockMerger >> mergeIntoPredecessorIfPossible: basicBlock [ 
	| uniquePredecessor |
	basicBlock predecessors size = 1 ifFalse: [ ^ self ].
	"following line filters NLR fake entries"
	(basicBlock firstInstr isPhi and: [ basicBlock firstInstr inputs size > 1 ]) ifTrue: [ ^ self ].
	uniquePredecessor := basicBlock predecessors anyOne.
	uniquePredecessor successors size = 1 ifFalse: [ ^ self ].
	uniquePredecessor lastInstr isJumpAhead ifFalse: [ ^ self ].
	^ self merge: basicBlock intoPredecessor: uniquePredecessor
]

{ #category : #private }
SoBasicBlockMerger >> patchDominatorFrom: basicBlock to: uniquePredecessor [
	basicBlock codeNode basicBlocks do: [ :each |
		each dominator = basicBlock ifTrue: 
			[ each dominator: uniquePredecessor ] ]
]
