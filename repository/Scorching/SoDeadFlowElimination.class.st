"
I remove dead control flows (dead diamonds and dead loops).

To do so, I collect all the merge points (directly basicBlock, no merge point analysis), then I check if it's merging a tight loop or a diamond and if there are useful instructions in it. If nothing looks important, I remove the diamond  / loop.
"
Class {
	#name : #SoDeadFlowElimination,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'backwardMerges',
		'forwardMerges'
	],
	#category : #'Scorching-Pass-Flow'
}

{ #category : #accessing }
SoDeadFlowElimination >> backwardMerges [
	<generated>
	^ backwardMerges
]

{ #category : #accessing }
SoDeadFlowElimination >> backwardMerges: aValue [
	<generated>
	backwardMerges := aValue
]

{ #category : #private }
SoDeadFlowElimination >> extractMergePoints: codeNode [
	codeNode basicBlocks do: [ :each | 
		each predecessors size > 1 ifTrue: [ 
			each hasBackwardPredecessor 
				ifTrue: [ backwardMerges add: each ]
				ifFalse: [ forwardMerges add: each ] ] ].
]

{ #category : #accessing }
SoDeadFlowElimination >> forwardMerges [
	<generated>
	^ forwardMerges
]

{ #category : #accessing }
SoDeadFlowElimination >> forwardMerges: aValue [
	<generated>
	forwardMerges := aValue
]

{ #category : #initialization }
SoDeadFlowElimination >> initialize [

	super initialize.

	backwardMerges := OrderedCollection new.
	forwardMerges := OrderedCollection new.
]

{ #category : #'private - backward' }
SoDeadFlowElimination >> processBackwardMerge: merge [
	"Dead loop detection."
	"Inner control flow should have been removed by dead diamond elimination."
	
	"We don't do it on behavior branches because it's not clear what are the constraints for the rest of the code,
	 Is the type then fixed ?"
	merge lastInstr isBooleanBranch ifFalse: [ ^ self ].
	"Is it a tight loop ?"
	(merge successors includes: merge backwardPredecessor) ifFalse: [ ^self ].
	
	"only unsafe op than can be removed"
	merge backwardPredecessor instructionsButLastDo: [ :instr |
		instr isUnsafeOp ifFalse: [ ^ self ].
		instr hasEffect ifTrue: [ ^self ] ].
	
	"phis we don't care. But now USmiLess and phi needds to replace uses. All instrs unsafe ops."
	merge instructionsButLastDo: [ :instr |
		((instr isPhi and: [ instr uses allSatisfy: [ :use | use basicBlock == merge or: [ use basicBlock == merge backwardPredecessor ] ] ])
			 or: [ instr isUnsafeOp and: [ instr hasEffect not ] ]) ifFalse: [ ^self ] ].
	
	self removeDeadLoop: merge
]

{ #category : #'private - backward' }
SoDeadFlowElimination >> processBackwardMerges [
	"Reverse do to remove inner most to outermost, allows to remove nested dead loops"
	backwardMerges reverseDo: [ :each | self processBackwardMerge: each ].
]

{ #category : #'private - forward' }
SoDeadFlowElimination >> processForwardMerge: merge [
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
SoDeadFlowElimination >> processForwardMerges [
	forwardMerges do: [ :each | self processForwardMerge: each ].
]

{ #category : #'private - forward' }
SoDeadFlowElimination >> removeDeadDiamond: merge [
	merge codeNode basicBlocks removeAll: merge predecessors.
	merge predecessors removeAll.
	merge dominator lastInstr replaceBy: (SoJumpAhead from: merge dominator to: merge).
	SoBasicBlockMerger new mergeIntoPredecessorIfPossible: merge.
]

{ #category : #'private - backward' }
SoDeadFlowElimination >> removeDeadLoop: merge [
	| remainingBranch |
	merge backwardPredecessor instructionsDo: [ :i | i removeInstr ].
	remainingBranch := (merge backwardPredecessor = merge lastInstr trueBasicBlock
		ifTrue: [ merge lastInstr falseBasicBlock ]
		ifFalse: [ merge lastInstr trueBasicBlock ]).
	merge codeNode basicBlocks remove: merge backwardPredecessor.
	merge predecessors remove: merge backwardPredecessor.
	merge phisDo: [ :phi | phi removeAndReplaceUsesBy: (phi inputForBasicBlock: merge predecessors anyOne) ].
	merge lastInstr replaceBy: (SoJumpAhead from: merge to: remainingBranch).
	SoBasicBlockMerger new 
		mergeIntoPredecessorIfPossible: merge;
		mergeIntoPredecessorIfPossible: merge successors anyOne.
]

{ #category : #public }
SoDeadFlowElimination >> runOn: codeNode [
	self extractMergePoints: codeNode.
	self processForwardMerges.
	self processBackwardMerges.
	codeNode maintainPostOrder.
]
