"
I copy once a loop body and insert it just before the loop. Used in loop exact unrolling and loop peeling.

loop <CommonLoop> loop being modified.
mapping <Dictionary(Instruction -> Instruction> mapping between the original loop body instructions and the copied instructions to remap things like def-uses.
tempCriticalEdges <OrderedCollection of BasicBlocks> remapping branch going out of the loop from a loop create critical edges that are collected and split at the end of the loop body copy.
instrsUsedAfterLoop <OrderedCollection of Instruction> instructions requiring a phi in critical edges to correctly remap the value for each version.
lastLoopNum <Smi> postOrder of the last basicBlock in loop body, changes during the process as basicBlocks are added.
"
Class {
	#name : #SoLoopBodyCopier,
	#superclass : #Object,
	#instVars : [
		'loop',
		'mapping',
		'tempCriticalEdges',
		'instrsUsedAfterLoop',
		'lastLoopNum'
	],
	#category : #'Scorching-Pass-Loop'
}

{ #category : #private }
SoLoopBodyCopier >> copyLoopBody [
	self initPhiMapping.
	self initBBMapping.
	self mapDominators.
	self patchCFG.
	self fillBasicBlocks.
	self insertBasicBlocks.
	self mapInstructions.
	self patchLoopHeadPhis.
	self mergeEntryCopy.
	loop codeNode maintainPostOrder.
	self patchCriticalEdges.
	loop codeNode maintainPostOrder.
]

{ #category : #public }
SoLoopBodyCopier >> copyLoopBody: theLoop [
	loop := theLoop.
	mapping := loop headBBMapping.
	lastLoopNum := loop lastLoopPostOrder.
	self copyLoopBody.
	^ mapping
]

{ #category : #'private - critical edges' }
SoLoopBodyCopier >> createPhiForCriticalEdge: bb [
	instrsUsedAfterLoop do: [ :instrUsedAfterLoop |
		instrUsedAfterLoop value: SoPhi new.
		bb addFirstInstruction: instrUsedAfterLoop value.
		(instrUsedAfterLoop key uses select: [ :each | 
			each basicBlock postOrder > lastLoopNum ]) do: [ :use |
				use replaceSubNode: instrUsedAfterLoop key by: instrUsedAfterLoop value ] ].
	
]

{ #category : #'private - bb filling' }
SoLoopBodyCopier >> fillBasicBlock: basicBlock [
	self fillLastBasicBlock: basicBlock to: nil
]

{ #category : #'private - bb filling' }
SoLoopBodyCopier >> fillBasicBlocks [
	self fillBasicBlocks: loop loopBody allButLast.
	self fillLastBasicBlock: loop lastLoopBody to: loop headBasicBlock.
]

{ #category : #'private - bb filling' }
SoLoopBodyCopier >> fillBasicBlocks: basicBlocks [ 
	basicBlocks do: [ :each | self fillBasicBlock: each ]
]

{ #category : #'private - bb filling' }
SoLoopBodyCopier >> fillLastBasicBlock: basicBlock to: targetOrNil [
	| newBB instr instrCopy |
	newBB := mapping at: basicBlock.
	
	"Init loop, firstInstr is different..."
	newBB firstInstr: basicBlock firstInstr copy.
	instr := basicBlock firstInstr.
	instrCopy := newBB firstInstr.
	self patchCopy: instrCopy from: instr.
	
	"main loop copy all instructions..."
	[instr isCFGInstr] whileFalse:	
		[instr := instr nextInstr.
		"last BB of loop is copied differently ..."
		(instr isCFGInstr and: [ targetOrNil notNil ])
			ifTrue: [ ^ self replaceBackjumpAfter: instrCopy targetingInstead: targetOrNil  ].
		instrCopy nextInstr: instr copy.
		instrCopy := instrCopy nextInstr.
		self patchCopy: instrCopy from: instr ] .
	
	newBB lastInstr: instrCopy.
	
]

{ #category : #'access - other' }
SoLoopBodyCopier >> firstLoopBodyCopy [
	^ mapping at: loop firstLoopBody
]

{ #category : #initialization }
SoLoopBodyCopier >> initBBMapping [
	loop loopBody do: [ :each | 
		mapping 
			at: each 
			put: (SoBasicBlock new
				codeNode: each codeNode;
				yourself) ].
	mapping at: loop preLoopBasicBlock put: loop preLoopBasicBlock.
	mapping at: loop headBasicBlock put: loop headBasicBlock.
]

{ #category : #initialization }
SoLoopBodyCopier >> initPhiMapping [
	loop phis do: [ :phi | self remapInstrIfUsedAfterLoop: phi ].
]

{ #category : #initialization }
SoLoopBodyCopier >> initialize [

	super initialize.

	mapping := Dictionary new.
	tempCriticalEdges := OrderedCollection new.
	instrsUsedAfterLoop := OrderedCollection new.
]

{ #category : #private }
SoLoopBodyCopier >> insertBasicBlocks [
	loop loopBody do: [ :each | 
		loop codeNode 
			addBasicBlock: (mapping at: each) 
			before: loop headBasicBlock ].
]

{ #category : #accessing }
SoLoopBodyCopier >> instrsUsedAfterLoop [
	<generated>
	^ instrsUsedAfterLoop
]

{ #category : #accessing }
SoLoopBodyCopier >> instrsUsedAfterLoop: aValue [
	<generated>
	instrsUsedAfterLoop := aValue
]

{ #category : #'access - other' }
SoLoopBodyCopier >> lastLoopBodyCopy [
	^ mapping at: loop lastLoopBody
]

{ #category : #accessing }
SoLoopBodyCopier >> lastLoopNum [
	<generated>
	^ lastLoopNum
]

{ #category : #accessing }
SoLoopBodyCopier >> lastLoopNum: aValue [
	<generated>
	lastLoopNum := aValue
]

{ #category : #accessing }
SoLoopBodyCopier >> loop [
	<generated>
	^ loop
]

{ #category : #accessing }
SoLoopBodyCopier >> loop: aValue [
	<generated>
	loop := aValue
]

{ #category : #'private - instr mapping' }
SoLoopBodyCopier >> mapBBInstructions: bb [
	bb instructionsDo: [ :instr |
		self mapSubNodes: instr.
		instr hasDeoptInfo ifTrue: [ 
			instr deoptInfo sunkObjects do: [ :each |
				self mapSubNodes: each ] ] ].
	self mapBBLastInstr: bb
]

{ #category : #'private - instr mapping' }
SoLoopBodyCopier >> mapBBLastInstr: bb [
	bb lastInstr successors do: [ :succ |
		mapping at: succ 
			ifPresent: [ :replacement | bb lastInstr basicReplaceSuccessor: succ by: replacement  ]
			ifAbsent: [
				tempCriticalEdges add: succ.
				succ addPredecessor: bb ] ]
]

{ #category : #private }
SoLoopBodyCopier >> mapDominators [
	loop loopBody do: [ :bb |
		(mapping at: bb) dominator: (mapping at: bb dominator) ].
	loop headBasicBlock dominator: self lastLoopBodyCopy.
]

{ #category : #'private - instr mapping' }
SoLoopBodyCopier >> mapInstructions [
	loop loopBody do: [ :each | self mapBBInstructions: (mapping at: each) ]
]

{ #category : #'private - instr mapping' }
SoLoopBodyCopier >> mapSubNodes: instr [
	instr subNodes do: [ :each |
		mapping at: each ifPresent: [ :newVal |
			instr replaceSubNode: each by: newVal ] ].
]

{ #category : #accessing }
SoLoopBodyCopier >> mapping [
	<generated>
	^ mapping
]

{ #category : #accessing }
SoLoopBodyCopier >> mapping: aValue [
	<generated>
	mapping := aValue
]

{ #category : #private }
SoLoopBodyCopier >> mergeEntryCopy [
	SoBasicBlockMerger new mergeIntoPredecessorIfPossible: self firstLoopBodyCopy
]

{ #category : #private }
SoLoopBodyCopier >> patchCFG [
	loop preLoopBasicBlock lastInstr replaceSuccessor: loop headBasicBlock by: self firstLoopBodyCopy.
]

{ #category : #'private - bb filling' }
SoLoopBodyCopier >> patchCopy: instrCopy from: instr [
	instrCopy isPhi ifTrue: [ self remapPhi: instrCopy ].
	mapping at: instr put: instrCopy.
	self remapInstrIfUsedAfterLoop: instr.

]

{ #category : #'private - critical edges' }
SoLoopBodyCopier >> patchCriticalEdge: bb InLoopBody: basicBlocks [
	"bb is the target of multiple branches. Should split the edges."
	self createPhiForCriticalEdge: bb.
	"copy because splitting edge mess things up"
	bb predecessors copy do: [ :predecessor | 
		| inLoop |
		inLoop := basicBlocks includes: predecessor.
		self patchCriticalEdgeFrom: predecessor to: bb InLoop: inLoop ] 
]

{ #category : #'private - critical edges' }
SoLoopBodyCopier >> patchCriticalEdgeFrom: predecessor to: bb InLoop: inLoop [
	| newBB |
	newBB := self splitEdgeFrom: predecessor to: bb.
	instrsUsedAfterLoop do: [ :instrUsedAfterLoop |
		| phiInput |
		phiInput := inLoop
			ifTrue: [ instrUsedAfterLoop key ] "from loop body"
			ifFalse: [ mapping at: instrUsedAfterLoop key ]. "from peeled copy"
		instrUsedAfterLoop value addInput: phiInput basicBlock: newBB ] 
]

{ #category : #'private - critical edges' }
SoLoopBodyCopier >> patchCriticalEdges [
	lastLoopNum := loop lastLoopPostOrder.
	tempCriticalEdges do: [:bb |
		self patchCriticalEdge: bb InLoopBody: loop loopBody ]
]

{ #category : #private }
SoLoopBodyCopier >> patchLoopHeadPhis [
	loop phis do: [ :phi |
		phi replaceSubNode: phi loopPhiForwardInput by: (mapping at: phi loopPhiBackInput).
		phi 
			replaceBasicBlock: phi loopPhiForwardPredecessor
			with: self lastLoopBodyCopy ]
]

{ #category : #private }
SoLoopBodyCopier >> remapInstrIfUsedAfterLoop: instr [
	instr isCFGInstr ifTrue: [^ self].
	(instr uses anySatisfy: [ :use | 
		"First condition is false if unrolling nested loops (instr is used in the copied graph)"
		use basicBlock postOrder notNil and: [ 
		use basicBlock postOrder > lastLoopNum ] ])
		ifTrue: [ instrsUsedAfterLoop add: instr -> nil ]
	
]

{ #category : #'private - bb filling' }
SoLoopBodyCopier >> remapPhi: instr [
	instr basicBlockReferences do: [ :bbRef |
		instr replaceBasicBlock: bbRef with: (mapping at: bbRef ) ]
]

{ #category : #'private - bb filling' }
SoLoopBodyCopier >> replaceBackjumpAfter: instrCopy targetingInstead: target [ 
	| newBB |
	newBB := instrCopy basicBlock.
	instrCopy nextInstr: (SoJumpAhead from: instrCopy basicBlock to: target).
	target removePredecessor: newBB.
	newBB lastInstr: instrCopy nextInstr 
	
]

{ #category : #'private - critical edges' }
SoLoopBodyCopier >> splitEdgeFrom: predecessor to: bb [
	| newBB |
	newBB := SoBasicBlock new.
	newBB firstInstr: (SoJumpAhead from: newBB to: bb).
	newBB lastInstr: newBB firstInstr.
	bb codeNode addBasicBlock: newBB before: bb.
	newBB dominator: predecessor.
	predecessor lastInstr replaceSuccessor: bb by: newBB.
	^ newBB
]

{ #category : #accessing }
SoLoopBodyCopier >> tempCriticalEdges [
	<generated>
	^ tempCriticalEdges
]

{ #category : #accessing }
SoLoopBodyCopier >> tempCriticalEdges: aValue [
	<generated>
	tempCriticalEdges := aValue
]
