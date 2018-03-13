"
I optimise diamonds, i.e., 4 basicblocks branch-merges according to this CFG pattern:
	[1]
     /    \
   [2]   [3]
     \    /
      [4]

4 Step process:
1) I collect all the merge basic blocks in backwardMerges & forwardMerges collections and process them separatedly.
2) I detect for each forward merges if it's a diamond, if so I look if the diamond is side-effect free (empty basicBlocks, no phis) and remove it if it is the case
3) I detect for each backward merge if it's a tight loop with no loop variant side-effect. If there's none, I transform the tight loop into a diamond.
4) If a loop has been successfully transformed to a diamond, I take a slow path restarting the optimisation to deal with nested cases.

Note: Removal of 0 iterations counted loops are done in GoldLoop optimiser.

backwardMerges <OrderedCollection of BasicBlocks>
forwardMerges <OrderedCollection of BasicBlocks>
hasRemovedLoop <Boolean> (step 4)
"
Class {
	#name : #SoDiamondOptimiser,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'backwardMerges',
		'forwardMerges',
		'hasRemovedLoop'
	],
	#category : #'Scorching-Pass-Flow'
}

{ #category : #accessing }
SoDiamondOptimiser >> backwardMerges [
	<generated>
	^ backwardMerges
]

{ #category : #accessing }
SoDiamondOptimiser >> backwardMerges: aValue [
	<generated>
	backwardMerges := aValue
]

{ #category : #private }
SoDiamondOptimiser >> extractMergePoints: codeNode [
	codeNode basicBlocks do: [ :each | 
		each predecessors size > 1 ifTrue: [ 
			each hasBackwardPredecessor 
				ifTrue: [ backwardMerges add: each ]
				ifFalse: [ forwardMerges add: each ] ] ].
]

{ #category : #accessing }
SoDiamondOptimiser >> forwardMerges [
	<generated>
	^ forwardMerges
]

{ #category : #accessing }
SoDiamondOptimiser >> forwardMerges: aValue [
	<generated>
	forwardMerges := aValue
]

{ #category : #accessing }
SoDiamondOptimiser >> hasRemovedLoop [
	<generated>
	^ hasRemovedLoop
]

{ #category : #accessing }
SoDiamondOptimiser >> hasRemovedLoop: aValue [
	<generated>
	hasRemovedLoop := aValue
]

{ #category : #'private - backward' }
SoDiamondOptimiser >> loopToDiamond: merge [
	"Try to convert a tight loop into a diamond"
	| exit newExit |
	hasRemovedLoop := true.
	self logDebug: 'LoopToDiamond' class: #SoDeadFlowLog at: merge backwardPredecessor lastInstr.
	exit := merge lastInstr successors detect: [ :s | s ~= merge backwardPredecessor ] .
	newExit := self newBasicBlockAfter: merge backwardPredecessor to: exit dom: merge.
	merge lastInstr replaceSuccessor: exit by: newExit.
	self remapAllInstrIn: merge forwardInput: merge phis.
	self remapAllInstrIn: merge backwardPredecessor forwardInput: merge phis.
	merge backwardPredecessor lastInstr replaceBy: (SoJumpAhead from: merge backwardPredecessor to: exit).
	merge phis reverseDo: [ :phi |
		phi insertBefore: exit firstInstr.
		phi replaceBasicBlock: merge predecessors anyOne with: newExit ].
	merge instructionsReverseDo: [ :each | (each prevInstr notNil and: [ each prevInstr isPhi]) ifTrue: [ merge firstInstr: each ] ].
	SoBasicBlockMerger new mergeIntoPredecessorIfPossible: merge
]

{ #category : #'private - backward' }
SoDiamondOptimiser >> newBasicBlockAfter: bb to: target dom: dom [
	| newBB jump |
	newBB := SoBasicBlock new.
	jump := SoJumpAhead from: newBB to: target.
	bb codeNode addBasicBlock: newBB after: bb.
	^ newBB
		dominator: dom;
		firstInstr: jump;
		lastInstr: jump;
		yourself
]

{ #category : #'private - backward' }
SoDiamondOptimiser >> phi: phi okForLoopToDiamond: merge [
	"phi on only loop invariant, the diamond will remap correctly."
	(phi inputs allSatisfy: [ :in | 
		in isImmediate or: [ (in inBasicBlock: merge or: merge backwardPredecessor) not ] ]) ifTrue: [ ^ true ].
	"phi on loop variant. Can remove only if phi does not escape the loop."
	^ (phi uses allSatisfy: [ :use |
		use inBasicBlock: merge or: merge backwardPredecessor ])
]

{ #category : #'private - backward' }
SoDiamondOptimiser >> processBackwardMerge: merge [
	"Dead loop detection."
	"Inner control flow should have been removed by dead diamond elimination."

	"We don't do it on behavior branches because it's not clear what are the constraints for the rest of the code,
	 Is the type then fixed ?"
	merge lastInstr isBooleanBranch ifFalse: [ ^ self ].
	"Is it a tight loop ?"
	(merge successors includes: merge backwardPredecessor) ifFalse: [ ^self ].
	"Is the loop side-effect free"
	(self sideEffectIn: merge merge: merge) ifTrue: [ ^ self ].
	(self sideEffectIn: merge backwardPredecessor merge: merge) ifTrue: [ ^ self ].

	self loopToDiamond: merge
]

{ #category : #'private - backward' }
SoDiamondOptimiser >> processBackwardMerges [
	backwardMerges reverseDo: [ :each | self processBackwardMerge: each ].
]

{ #category : #'private - forward' }
SoDiamondOptimiser >> processForwardMerge: merge [
	"Dead diamond detection."
	"Not dead if a phi"
	merge firstInstr isPhi ifTrue: [ ^ self ].
	"Diamond detection"
	merge predecessors size = 2 ifFalse: [ ^ self ].
	(merge predecessors includesAll: merge dominator successors) ifFalse: [ ^ self ].
	"Because critical edges are split and we're in postOrder, predecessors are necessarily
	 in-between and end with forward unconditional jump to the merge point.
	 Hence if they've got only the last instruction it's a dead diamond."
	(merge predecessors allSatisfy: [ :pred | pred firstInstr == pred lastInstr ]) ifFalse: [ ^ self ].
	self removeDeadDiamond: merge.
]

{ #category : #'private - forward' }
SoDiamondOptimiser >> processForwardMerges [
	forwardMerges do: [ :each | self processForwardMerge: each ].
]

{ #category : #'private - backward' }
SoDiamondOptimiser >> remapAllInstrIn: bb forwardInput: phis [
	bb instructionsDo: [ :each |
		self remapSubNodes: each forwardInput:  phis.
		each hasDeoptInfo ifTrue: [ 
			each deoptInfo copyForSubGraphTransformation.
			each deoptInfo sunkObjects do: [ :s |self remapSubNodes: s forwardInput:  phis ] ] ]
]

{ #category : #'private - backward' }
SoDiamondOptimiser >> remapSubNodes: instr forwardInput: phis [
	instr subNodesDo: [ :sub |
			phis do: [ :phi | phi = sub ifTrue: [ instr replaceSubNode: phi by: phi loopPhiForwardInput ] ] ]
]

{ #category : #'private - forward' }
SoDiamondOptimiser >> removeDeadDiamond: merge [
	merge codeNode basicBlocks removeAll: merge predecessors.
	merge predecessors removeAll.
	merge dominator lastInstr replaceBy: (SoJumpAhead from: merge dominator to: merge).
	SoBasicBlockMerger new mergeIntoPredecessorIfPossible: merge.
]

{ #category : #initialization }
SoDiamondOptimiser >> reset [
	backwardMerges := OrderedCollection new.
	forwardMerges := OrderedCollection new.
	hasRemovedLoop := false.
]

{ #category : #public }
SoDiamondOptimiser >> runOn: codeNode [
	self reset.
	self extractMergePoints: codeNode.
	self processForwardMerges.
	self processBackwardMerges.
	codeNode maintainPostOrder.
	
]

{ #category : #public }
SoDiamondOptimiser >> runOn: codeNode untilFixedPointOrRetryAfter: block [
	 [self runOn: codeNode.
	  hasRemovedLoop] whileTrue: [ 
		block cull: codeNode ]
]

{ #category : #'private - backward' }
SoDiamondOptimiser >> sideEffectIn: basicBlock merge: merge [ 
	basicBlock instructionsButLastDo: [ :instr |
		(instr isPhi and: [ (self phi: instr okForLoopToDiamond: merge) not ]) ifTrue: [ ^ true ].
		(instr isCall or: [instr isWrite and: [self write: instr variesInLoop: merge]]) ifTrue: [ ^ true ]].
	^ false
]

{ #category : #'private - backward' }
SoDiamondOptimiser >> write: write variesInLoop: merge [
	^ write subNodesAnySatisfy: [ :each |
		each isImmediate
			ifTrue: [ false ]
			ifFalse: [each basicBlock = merge or: [ each basicBlock = merge backwardPredecessor ]] ]
]
