"
Run at the end of the optimization and before bytecode generation, I expand macro instructions (which cannot be generated to bytecode) and reduce canonicalized return instructions.

Currently my main use is to:
- expand the macro instruction trapIfNotInstanceOf to branhcIfNotInstanceOf AND immediate traps.
- move up return instructions across phis, to have multiple return instructions instead of having jumps to returns.
- rotate branchIfNotInstanceOf / boolean branch on boolean for better branch prediction / branch jitting by Cogit.

macros <OrderedCollection of macroInstructions, currently only TrapIfNotINstanceOf>
returns <OrderedCollection of Return> 
"
Class {
	#name : #SoExpandAndReduce,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'macros',
		'returns'
	],
	#classVars : [
		'RESULT'
	],
	#category : #'Scorching-Backend-Analysis'
}

{ #category : #expand }
SoExpandAndReduce >> branchFromTrap: trap [
	(trap isFalseTrap or: [ trap isTrueTrap ])
		ifTrue: [ ^ SoBooleanBranch new
				expression: trap expression;
				yourself  ].
	^ SoBranchIfNotInstanceOf new
		behaviors: trap behaviors;
		expression: trap expression;
		yourself
]

{ #category : #expand }
SoExpandAndReduce >> expandMacros [
	[macros isEmpty] whileFalse: [ self expandTrapIfNotInstanceOf: macros removeFirst ].
]

{ #category : #expand }
SoExpandAndReduce >> expandTrapIfNotInstanceOf: trap [
	"Attempts to merge trap metadata...
	 Hopefully due to inlined primitive (<, <=, etc.)
	 and LICM many traps are next to each other."
	| traps instr |
	traps := OrderedCollection with: trap.
	instr := trap.
	[ instr prevInstr notNil and: [ instr prevInstr isTrapIfNotInstanceOf ] ] whileTrue: 
		[ instr := instr prevInstr.
		  macros remove: instr.
		  traps add: instr ].
	self expandTrapsIfNotInstanceOf: traps
]

{ #category : #expand }
SoExpandAndReduce >> expandTrapsIfNotInstanceOf: traps [
	| prevBBs trapBB deoptInfo |
	"last trap dominates the other"
	deoptInfo := traps last deoptInfo. "cached cause splitting remove the reference"
	prevBBs := traps collect: [ :trap | SoBasicBlockSplitter new splitBasicBlockAt: trap ].
	trapBB := self newTrapBasicBlock: deoptInfo dominator: prevBBs last.
	deoptInfo sunkObjects do: [ :s | s subNodesAddUses ].
	traps withIndexDo: [:trap :index | self patchTrap: trap prevBB: (prevBBs at: index) trapBB: trapBB ]
	
]

{ #category : #initialization }
SoExpandAndReduce >> initialize [

	super initialize.

	macros := OrderedCollection new.
	returns := OrderedCollection new.
]

{ #category : #accessing }
SoExpandAndReduce >> macros [
	<generated>
	^ macros
]

{ #category : #accessing }
SoExpandAndReduce >> macros: aValue [
	<generated>
	macros := aValue
]

{ #category : #expand }
SoExpandAndReduce >> newTrapBasicBlock: deoptInfo dominator: dom [
	| trap bb |
	trap := SoImmediateTrap new deoptInfo: deoptInfo; yourself.
	bb := SoBasicBlock new 
		firstInstr: trap;
		lastInstr: trap;
		dominator: dom;
		yourself.
	dom codeNode addBasicBlock: bb.
	^ bb
]

{ #category : #reduce }
SoExpandAndReduce >> noPhiSplitReturn: ret [ 
	| maybeReturn |
	maybeReturn := ret basicBlock firstInstr.
	maybeReturn isReturn ifFalse: [ ^ self ].
	maybeReturn basicBlock predecessors size > 1 ifFalse: [ ^ self ].
	self splitRet: maybeReturn
]

{ #category : #expand }
SoExpandAndReduce >> patchTrap: trap prevBB: prevBB trapBB: trapBB [
	| jumpIfNotInstance |
	jumpIfNotInstance := self branchFromTrap: trap.
	prevBB lastInstr replaceBy: jumpIfNotInstance.
	trap isTrueTrap 
		ifTrue: 
			[ jumpIfNotInstance trueBasicBlock: trap basicBlock.
			  jumpIfNotInstance falseBasicBlock: trapBB ]
		ifFalse: 
			[ jumpIfNotInstance trueBasicBlock: trapBB.
			  jumpIfNotInstance falseBasicBlock: trap basicBlock ]
	
]

{ #category : #accessing }
SoExpandAndReduce >> returns [
	<generated>
	^ returns
]

{ #category : #accessing }
SoExpandAndReduce >> returns: aValue [
	<generated>
	returns := aValue
]

{ #category : #public }
SoExpandAndReduce >> runOn: codeNode [
	self traversePostorderCode: codeNode.
	self splitReturns. 
	self expandMacros.
	codeNode maintainPostOrder.
]

{ #category : #reduce }
SoExpandAndReduce >> split: ret on: phi [
	phi inputsAndBasicBlocksDo: [ :input :basicBlock |
		basicBlock lastInstr replaceBy: (SoReturn new 
			returnedValue: input;
			numLevels: ret numLevels;
			yourself) ].
	phi removeInstr.
	phi codeNode basicBlocks remove: phi basicBlock.
	phi basicBlockReferences do: [ :each | returns add: each lastInstr ]
]

{ #category : #reduce }
SoExpandAndReduce >> splitRet: return [
	| allFwd |
	allFwd := true.
	return basicBlock predecessors copy do: [ :each |
		each lastInstr isJumpAhead
			ifTrue: [ each lastInstr replaceBy: return copy.
				   	 returns add: each lastInstr ]
			ifFalse: [ allFwd := false ] ].
	allFwd ifFalse: [ ^ self ].
	return removeInstr.
	return codeNode basicBlocks remove: return basicBlock
]

{ #category : #reduce }
SoExpandAndReduce >> splitReturn: ret [ 
	| maybePhi maybeReturn |
	maybePhi := ret basicBlock firstInstr.
	maybePhi isPhi ifFalse: [ ^ self noPhiSplitReturn: ret ].
	maybeReturn := maybePhi nextInstr.
	maybeReturn isReturn ifFalse: [ ^ self ].
	maybeReturn returnedValue == maybePhi ifFalse: [ ^ self ].
	self split: maybeReturn on: maybePhi
]

{ #category : #reduce }
SoExpandAndReduce >> splitReturns [
	[returns isEmpty] whileFalse: [ self splitReturn: returns removeFirst ]
]

{ #category : #traversing }
SoExpandAndReduce >> traverseReturn: ret [
	returns add: ret
]

{ #category : #traversing }
SoExpandAndReduce >> traverseTrapIfNotInstanceOf: trap [
	macros add: trap
]
