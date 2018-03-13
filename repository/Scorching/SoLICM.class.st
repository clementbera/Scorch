"
Loop invariant code motion.

I attempt to hoist code out of loops. Currently I hoist only traps and size ops. I have 2 purposes:
- I am a fall-back to hoist code out of loop if better loop optimisations such as loop peeling cannot be performed.
- I canonicalize the loop, hoisting traps out, so better loop optimisations such as loop peeling can match the loop pattern and be performed.

During the process, I remove loop heads to avoid deoptimization information interferences with the rest of the optimization process. Hence I can be run only *once* as I need loop heads to move code before loops.

loops <OrderedCollection of LoopDescriptor> while traversing the CFG, the current loop we're in in order.
loopHeads <Collection of LoopHead> used to remove them at the end.
"
Class {
	#name : #SoLICM,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'loops',
		'loopHeads'
	],
	#category : #'Scorching-Pass-Data'
}

{ #category : #testing }
SoLICM >> canHoist: trap expression: expression outOf: loopDescr [
	(expression strictlyDominates: loopDescr lastHeadInstr) ifFalse: [ ^ false ].
	(self expression: trap expression inSpecializedBranchAt: trap inside: loopDescr) ifTrue: [ ^ false ].
	expression ~= trap expression ifTrue: [ 
		(self expression: expression inSpecializedBranchAt: trap expression inside: loopDescr) ifTrue: [ ^ false ] ].
	^ true
]

{ #category : #testing }
SoLICM >> expression: expression inSpecializedBranchAt: instr inside: loopDescr [
	^ expression uses anySatisfy: [ :use |
		(use isBranchIfNotInstanceOf 
			and: [ (loopDescr range rangeIncludes: use basicBlock postOrder) 
				and: [ use specifyTypeOfExpressionAt: instr ] ]) ]
]

{ #category : #private }
SoLICM >> fetchLoopHead: headBasicBlock [
	headBasicBlock instructionsButLastReverseDo: [ :instr |
		instr isLoopHead ifTrue: [ ^ instr ] ].
	self error: 'should have a loop head'
]

{ #category : #private }
SoLICM >> hoist: instr in: head [
	| loopHead |
	"('Hoisted trap on ' , instr behaviors printString , ' deopt to ' , ((instr deoptInfo sunkObjects first fixedFields at: 4) constant) printString ) logCr. " 
	instr hasDeoptInfo ifTrue: [ 
		loopHead := self fetchLoopHead: head.
		instr replaceDeoptInfoBy: (loopHead deoptInfo convertToTrapWith: loopHead) ].
	instr prevInstrNextInstr: instr nextInstr.
	instr insertBefore: head lastInstr prevInstr.
]

{ #category : #private }
SoLICM >> hoistInBestLoop: trap withExpression: expression [
	loops do: [ :loopDescr |
		(self canHoist: trap expression: expression outOf: loopDescr)
			ifTrue: [ 
				trap replaceSubNode: trap expression by: expression.
				self hoist: trap in: loopDescr headBasicBlock.
				^ true ] ].
	^ false
]

{ #category : #initialization }
SoLICM >> initialize [

	super initialize.

	loops := OrderedCollection new.
	loopHeads := OrderedCollection new
]

{ #category : #accessing }
SoLICM >> loopHeads [
	<generated>
	^ loopHeads
]

{ #category : #accessing }
SoLICM >> loopHeads: aValue [
	<generated>
	loopHeads := aValue
]

{ #category : #accessing }
SoLICM >> loops [
	<generated>
	^ loops
]

{ #category : #accessing }
SoLICM >> loops: aValue [
	<generated>
	loops := aValue
]

{ #category : #traversing }
SoLICM >> maybeEnterLoop: bb [
	bb hasBackwardPredecessor ifTrue: [ 
		loops add: (SoLoopDescriptor new 	
			headBasicBlock: bb forwardPredecessors anyOne;
			range: (bb postOrder to: bb backwardPredecessor postOrder);
			yourself) ].
]

{ #category : #private }
SoLICM >> phi: phi inputsToCheckAgainst: behaviors [
	| inputsToCheck |
	inputsToCheck := OrderedCollection new.
	phi inputs do: [ :in |
		((in typeInformationAt: phi) isOnlyTypes: behaviors)
			ifFalse: [ inputsToCheck add: in ] ].
	^ inputsToCheck
]

{ #category : #private }
SoLICM >> removeLoopHeads [
	loopHeads do: [ :each | each removeInstr ].
]

{ #category : #public }
SoLICM >> runOn: codeNode [
	self traversePreorderCode: codeNode.
	self removeLoopHeads.
]

{ #category : #traversing }
SoLICM >> safeForwardTraversing: bb [
	| instr nextInstr |
	"We move instructions while iterating so 
	 we need to compute nextInstr first."
	instr := bb firstInstr.
	instr isCFGInstr ifTrue: [ ^ self traverseInstruction: instr ].
	[ nextInstr := instr nextInstr.
	  self traverseInstruction: instr.
	  nextInstr isCFGInstr ]
		whileFalse: [ instr := nextInstr ].
	self traverseInstruction: nextInstr.
]

{ #category : #traversing }
SoLICM >> traverseBackjump: bj [
	loops removeLast
]

{ #category : #traversing }
SoLICM >> traverseForwardBasicBlock: bb [
	self maybeEnterLoop: bb.
	self safeForwardTraversing: bb
]

{ #category : #traversing }
SoLICM >> traverseLoopHead: loopHead [
	loopHeads add: loopHead
]

{ #category : #traversing }
SoLICM >> traverseSizeOp: sizeOp [
	loops do: [ :loopDescr |
		(self tryHoist: sizeOp outOf: loopDescr) ifTrue: [ ^ self ] ]
]

{ #category : #traversing }
SoLICM >> traverseTrapIfNotInstanceOf: trap [
	self tryHoistTrap: trap
]

{ #category : #private }
SoLICM >> tryHoist: sizeOp outOf: loopDescr [
	| trappingRange |
	(sizeOp receiver strictlyDominates: loopDescr lastHeadInstr) ifFalse: [ ^ false ].
	trappingRange := loopDescr headBasicBlock postOrder + 1 to: sizeOp basicBlock postOrder.
	(sizeOp receiver uses anySatisfy: [ :use |
		use canLocallySpecifyType and: [ trappingRange includes: use basicBlock postOrder ] ]) ifTrue: [ ^ false ].
	self hoist: sizeOp in: loopDescr headBasicBlock.
	^ true
]

{ #category : #private }
SoLICM >> tryHoistTrap: trap [
	| inputsToCheck |
	"Attempt 1: hoist directly the trap."
	(self hoistInBestLoop: trap withExpression: trap expression) ifTrue: [ ^ self ].
	
	"Attempt 2: hoist the trap on a single phi inputs that would need the trap."
	trap expression isPhi ifFalse: [ ^ self ].
	inputsToCheck := self phi: trap expression inputsToCheckAgainst: trap behaviors.
	inputsToCheck size = 1 ifFalse: [ ^ self ].
	self hoistInBestLoop: trap withExpression:  inputsToCheck anyOne
]
