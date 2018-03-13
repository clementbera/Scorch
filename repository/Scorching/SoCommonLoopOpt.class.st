"
I detect small common loops (See CommonLoop comment) and I do 2 things:
1) If there is an exact iteration count, I fully unroll the loop if the iteration count is small enough or peel it.
2) If there is no exact iteration count, I peel the loop and add a guard at the beginning to protect the peel for loop with no iteration at all.

backjumps <OrderedCollection of Backjump> bj collected while iterating over the graph.
"
Class {
	#name : #SoCommonLoopOpt,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'backjumps'
	],
	#pools : [
		'SoMagicConstants'
	],
	#category : #'Scorching-Pass-Loop'
}

{ #category : #accessing }
SoCommonLoopOpt >> backjumps [
	<generated>
	^ backjumps
]

{ #category : #accessing }
SoCommonLoopOpt >> backjumps: aValue [
	<generated>
	backjumps := aValue
]

{ #category : #private }
SoCommonLoopOpt >> commonLoopOpt [
	backjumps do: [ :each | self commonLoopOptOn: each ]
]

{ #category : #private }
SoCommonLoopOpt >> commonLoopOptOn: bj [
	| loop |
	(self isLoopTooBig: bj) ifTrue: [ ^ self ].	
	((loop := SoCommonLoop new) matchesCommonLoop: bj) ifFalse: [ ^self ].
	loop patchCompUses.
	loop hasExactCount ifFalse: [ ^ self safePeel: loop ].
	loop iteratorRange size > MaxFullUnrollCount ifTrue: [ ^ self peel: loop ].
	self unroll: loop
]

{ #category : #initialization }
SoCommonLoopOpt >> initialize [

	super initialize.

	backjumps := OrderedCollection new.
]

{ #category : #private }
SoCommonLoopOpt >> isLoopTooBig: bj [
	| loopSize |
	loopSize := bj basicBlock postOrder - bj targetBasicBlock postOrder.
	^ loopSize > MaxCommonLoopBasicBlocks 
]

{ #category : #peeling }
SoCommonLoopOpt >> newBasicBlockTo: target dominatedBy: basicBlock [ 
	"In this version the basicBlock is added before the target.
	 Due to loop canonicalisation, everything is in the right place."
	| newBB jump |
	newBB := SoBasicBlock new.
	jump := SoJumpAhead from: newBB to: target.
	basicBlock codeNode addBasicBlock: newBB before: target.
	^ newBB
		dominator: basicBlock;
		firstInstr: jump;
		lastInstr: jump;
		yourself
]

{ #category : #peeling }
SoCommonLoopOpt >> peel: loop [
	SoLoopBodyCopier new copyLoopBody: loop.
	loop codeNode maintainPostOrder.
]

{ #category : #peeling }
SoCommonLoopOpt >> protectPeel: loop [
	"We need to protect the case where the loop is *not* executed at all."
	| exit exitSplit exitProtectSplit loopSplit preLoopBB branch comp phiphi |
	self flag: #refactor. "I guess make a full class all varibales are so dependent to each other..."
	
	"Create new cfg."
	exit := loop loopExitBasicBlock.
	preLoopBB := loop preLoopBasicBlock.
	loopSplit := self newBasicBlockTo: loop headBasicBlock dominatedBy: preLoopBB. 
	exitProtectSplit := self newBasicBlockTo: exit dominatedBy: preLoopBB. 
	exitSplit := self newBasicBlockTo: exit dominatedBy: loop headBasicBlock. 
	loop branch replaceSuccessor: exit by: exitSplit. 
	
	"add the protection branch"
	comp := loop comp class 
		withReceiver: loop initialCountConstant
		arguments: { loop compLimit }. 
	branch := SoBooleanBranch new
		expression: comp;
		basicBlock: preLoopBB;
		trueBasicBlock: loopSplit;
		falseBasicBlock: exitProtectSplit;
		yourself.
	preLoopBB lastInstr replaceBy: branch.
	comp insertBefore: branch.
	
	"update phis"
	loop phis do: [ :phi |
		phi replaceBasicBlock: preLoopBB with: loopSplit.
		exit addFirstInstruction: (phiphi := SoPhi new).
		phi uses copy do: [ :use |
			use basicBlock postOrder > loop lastLoopPostOrder ifTrue: [ 
				use replaceSubNode: phi by: phiphi ] ].
		phiphi addInput: phi loopPhiForwardInput basicBlock: exitProtectSplit.
		phiphi addInput: phi basicBlock: exitSplit ].
	
	branch codeNode maintainPostOrder.
]

{ #category : #'full unroll' }
SoCommonLoopOpt >> removeLoop: loop [ 
	| exit map |
	map := loop headBBMapping.
	loop phis do: [ :each | each replaceUsesBy: (map at: each) ].
	exit := loop loopExitBasicBlock.
	loop preLoopBasicBlock lastInstr replaceSuccessor: loop headBasicBlock by: exit.
	SoDeadBranchElimination new removeDominatedPath: loop headBasicBlock
		
]

{ #category : #public }
SoCommonLoopOpt >> runOn: codeNode [
	self traversePostorderCode: codeNode.
	self commonLoopOpt.
]

{ #category : #peeling }
SoCommonLoopOpt >> safePeel: loop [
	self protectPeel: loop.
	self peel: loop.
]

{ #category : #traversing }
SoCommonLoopOpt >> traverseBackjump: bj [
	backjumps add: bj
]

{ #category : #'full unroll' }
SoCommonLoopOpt >> unroll: loop [
	loop iteratorRange do: [ :i | 
		SoLoopBodyCopier new copyLoopBody: loop].
	self removeLoop: loop.
	loop codeNode maintainPostOrder.
]
