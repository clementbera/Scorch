"
If the expression type can be inferred, removed the dead branch.

I am used in 3 ways:
- after inlining passes, I remove dead branch on constants (true ifTrue: and co).
- after data passes, I am called on specific branches when the data pass has simplified some value leading to a boolean branch on a boolean constant (1<2 ifTrue: and co).
- From the inliner itself, I am called to remove dead part of the CFG.

I don't remove branches based on counters any more as it leads to issues with loops with rarely taken exits and NLRs.

Removing a branch is not that easy. I need to: 
- maintain the dom tree
- maintain the post order 
- remove dead basicBlocks, their instructions in def-use graph. Clean-up phis having inputs from dead basicBlocks.
- Merge basicBlocks if there's only a forward edge between them

"
Class {
	#name : #SoDeadBranchElimination,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'branches'
	],
	#category : #'Scorching-Pass-Flow'
}

{ #category : #accessing }
SoDeadBranchElimination >> branches [
	<generated>
	^ branches
]

{ #category : #accessing }
SoDeadBranchElimination >> branches: aValue [
	<generated>
	branches := aValue
]

{ #category : #initialization }
SoDeadBranchElimination >> initialize [

	super initialize.

	branches := OrderedCollection new.
]

{ #category : #'branch removal' }
SoDeadBranchElimination >> maintainDomTree: succ [
	| newDom |
	newDom := succ predecessors first.
	succ predecessors allButFirstDo: [ :pred |
		newDom := newDom commonDominatorWith: pred ].
	succ dominator: newDom.
]

{ #category : #'branch removal' }
SoDeadBranchElimination >> processBranch: branch [
	branch isTraversedBy: self
]

{ #category : #public }
SoDeadBranchElimination >> processBranches: br [
	branches := br.
	[branches isEmpty] whileFalse: 
		[self processBranch: branches removeFirst]

]

{ #category : #'branch removal' }
SoDeadBranchElimination >> removeAllInstr: basicBlock [
	basicBlock instructionsDo: 
		[ :instr | 
			instr removeInstr.
			instr isBranch ifTrue: [ self removeBranchFromList: instr ] ]
	
]

{ #category : #'branch removal' }
SoDeadBranchElimination >> removeBranch: branch deadBasicBlock: dead liveBasicBlock: live [ 
	self removeBranchFromList: branch.
	branch replaceBy: (SoJumpAhead from: branch basicBlock to: live).
	self removeDominatedPath: dead.
	SoBasicBlockMerger new mergeIntoPredecessorIfPossible: live.
	live codeNode maintainPostOrder.
]

{ #category : #'branch removal' }
SoDeadBranchElimination >> removeBranchFromList: instr [ 
	[ branches remove: instr ifAbsent: [ ^ self ]. true] whileTrue.
	
]

{ #category : #public }
SoDeadBranchElimination >> removeDominatedPath: basicBlock [
	| bbToRemove |
	bbToRemove := self dominatedPath: basicBlock.
	bbToRemove do: 
		[ :each | 
			self removePathToLiveSuccessors: each deadBasicBlocks: bbToRemove.
			each codeNode basicBlocks remove: each ifAbsent: nil."Can have been removed by basic block merge"
			self removeAllInstr: each ].
	
]

{ #category : #'branch removal' }
SoDeadBranchElimination >> removePathToLiveSuccessors: basicBlock deadBasicBlocks:  bbToRemove [
	basicBlock successors do: 
		[ :succ | (bbToRemove includes: succ) ifFalse: 
			[ self removePredecessor: basicBlock from: succ ] ]
]

{ #category : #'branch removal' }
SoDeadBranchElimination >> removePredecessor: basicBlock from: succ [
	| phis |
	succ removePredecessor: basicBlock.
	phis := OrderedCollection new.
	succ phisDo: [ :phi | 
		phis add: phi.
		phi removeInputForBasicBlock: basicBlock ].
	SoSimplifyPhis new simplifyPhis: phis.
	self maintainDomTree: succ.
	SoBasicBlockMerger new mergeIntoPredecessorIfPossible: succ.
]

{ #category : #public }
SoDeadBranchElimination >> runOn: codeNode [
	| bbWithBranches |
	bbWithBranches :=  codeNode basicBlocks select: 
		[ :each | each lastInstr isBranch ].
	self processBranches: (bbWithBranches collect: [:bb | bb lastInstr]).
]

{ #category : #'branch removal' }
SoDeadBranchElimination >> traverseBooleanBranch: branch [
	| type |
	type := branch expression typeInformationAt: branch.
	(type isOnlyType: True) 
		ifTrue: [self removeBranch: branch deadBasicBlock: branch falseBasicBlock liveBasicBlock: branch trueBasicBlock].
	(type isOnlyType: False) 
		ifTrue: [self removeBranch: branch deadBasicBlock: branch trueBasicBlock liveBasicBlock: branch falseBasicBlock].
]

{ #category : #'branch removal' }
SoDeadBranchElimination >> traverseBranchIfNotInstanceOf: branch [
	| type |
	type := branch expression typeInformationAt: branch.
	type isKnownType ifFalse: [ ^ self ].
	(branch behaviors includesAll: type behaviors) 
		ifTrue: [ self 
			removeBranch: branch 
			deadBasicBlock: branch trueBasicBlock 
			liveBasicBlock: branch falseBasicBlock ].
	(branch behaviors includesAny: type behaviors)
		ifFalse: [ self 
			removeBranch: branch 
			deadBasicBlock: branch falseBasicBlock 
			liveBasicBlock: branch trueBasicBlock ].
]
