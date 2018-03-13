"
Peel, Remove Or Full unroll loops with exact count.

This is quite naive but is very important for common tight loops, including the ones from inlined primitives. 

Does not work well with loop heads (remove them before)

The term gold loop is correct : gold loops are rare but if you find one you've found the golden nugget which speeds greatly performance

retry <Boolean>
"
Class {
	#name : #SoGoldLoopOptimiser,
	#superclass : #Object,
	#instVars : [
		'retry'
	],
	#pools : [
		'SoMagicConstants'
	],
	#category : #'Scorching-Pass-Flow'
}

{ #category : #identification }
SoGoldLoopOptimiser >> ensureNaiveLoop: goldLoop [
	"loop has body2. Ensure pattern:
	    A
	     |
	    B
	   /  \ 
	 E1   C
	  |    /  \
	  |  E2  D (bj)
	  \  /
	   X
	E1 simple basicBlock.
	E2 is just empty.
	"
	| exit1 exit2 secondBranch |
	secondBranch := goldLoop body1 lastInstr.
	secondBranch isInstanceOfBranch ifTrue: [ ^ false ].
	(secondBranch trueBasicBlock postOrder = (secondBranch basicBlock postOrder + 1)
	or: [secondBranch falseBasicBlock postOrder = (secondBranch basicBlock postOrder + 1) ]) ifFalse: [ ^false ].
	exit1 := goldLoop branch falseBasicBlock.
	exit2 := secondBranch successors detect: [:succ | succ postOrder > goldLoop backjump basicBlock postOrder].
	exit1 successors size = 1 ifFalse: [ ^ false ].
	exit2 successors size = 1 ifFalse: [ ^ false ].
	exit2 firstInstr = exit2 lastInstr ifFalse: [ ^ false ].
	^ exit1 successors anyOne = exit2 successors anyOne
]

{ #category : #private }
SoGoldLoopOptimiser >> findAndOptimise: codeNode [
	| bbs goldLoops |  
	bbs := codeNode basicBlocks select: [ :each | each lastInstr isBackjump ].
	goldLoops := self identifyGoldLoops: bbs.
	self optimiseGoldLoops: goldLoops.
]

{ #category : #identification }
SoGoldLoopOptimiser >> flawedGoldLoop: goldLoop [
	| limit cmp branch |
	limit := 	goldLoop comp firstArg.
	"common case is size op, basicType info is correct, actualMax val too high"
	(limit hasRangeInformation and: [ limit rangeInformation actualMaxVal <= MaxNoInterruptCount ])
		ifTrue: [ goldLoop flawedLimit: limit rangeInformation actualMaxVal. ^ true ].
	(limit basicTypeInformation isOnlyType: SmallInteger) ifFalse: [ ^ false]. 
	 "kind of duplicated e-SSA analysis, but eSSA has other conflicts with gold loops optimisations so..."
	cmp := limit uses detect: [ :use | use isSmiLessOrLessOrEqual ] ifNone: [^false].
	branch := cmp uses detect: [ :use | use isBooleanBranch ] ifNone: [^false].
	cmp receiver = limit
		ifTrue: [ 
			cmp firstArg isConstant ifFalse: [ ^ false ].
			(branch trueBasicBlock dominates: goldLoop body0) ifFalse: [ ^ false ].
			goldLoop flawedLimit: cmp firstArg constant ]
		ifFalse: [  
			cmp receiver isConstant ifFalse: [ ^ false ].
			(branch falseBasicBlock dominates: goldLoop body0) ifFalse: [ ^ false ].
			goldLoop flawedLimit: cmp receiver constant  ].
	^ true
]

{ #category : #optimisation }
SoGoldLoopOptimiser >> fullUnroll: goldLoop [
	"Note: exactCount may be 0."
	goldLoop exactCount timesRepeat: [ goldLoop copyBodyBefore ].
	goldLoop patchAfterCode.
	self removeGoldLoop: goldLoop
]

{ #category : #identification }
SoGoldLoopOptimiser >> identifyCarefully: bj into: goldLoops [
	| goldLoop |
	"Hardcore pattern matching."
	bj peeled ifTrue: [ ^ self ].
	goldLoop := SoGoldLoop new.
	goldLoop backjump: bj.
	goldLoop body0: bj targetBasicBlock.
	goldLoop phis: goldLoop body0 phis.
	goldLoop comp: (goldLoop phis
		ifEmpty: [ goldLoop body0 firstInstr ]
		ifNotEmpty: [ goldLoop phis last nextInstr ]).
	goldLoop comp isSmiLessOrLessOrEqual ifFalse: [ ^self ].
	goldLoop branch: goldLoop comp nextInstr.
	goldLoop branch isBooleanBranch ifFalse: [ ^ self ].
	(goldLoop branch trueBasicBlock postOrder = (goldLoop branch basicBlock postOrder + 1)) ifFalse: [ ^false ].
	goldLoop addCst: bj prevInstr.
	goldLoop addCst ifNil: [ ^self ].
	goldLoop addCst isUncheckedAddConstant ifFalse: [ ^self ].
	bj basicBlock predecessors anyOne = goldLoop body0 
		ifTrue: [ goldLoop body1: bj basicBlock ]
		ifFalse: [ goldLoop body1: bj basicBlock predecessors anyOne.
				goldLoop body2: bj basicBlock ].
	goldLoop loopPhi: (goldLoop phis
		detect: [ :phi | 
			goldLoop comp receiver = phi 
				and: [ goldLoop addCst receiver = phi
				and: [ phi loopPhiForwardInput isSmiConstant ] ] ] 
		ifFound: [ :elem | elem ]
		ifNone: [ ^ self ]).
	goldLoop addCst receiver = goldLoop loopPhi ifFalse: [ ^ self ].
	goldLoop comp receiver = goldLoop loopPhi ifFalse: [ ^ self ].
	goldLoop increment > 0 ifFalse: [ ^ self ].
	goldLoop body2 ifNotNil: [ (self ensureNaiveLoop: goldLoop) ifFalse: [ ^ self ] ].
	goldLoop numDeoptInfo > 3 ifTrue: [ ^ self ].
	goldLoop comp firstArg isSmiConstant ifFalse: [ 
		(self flawedGoldLoop: goldLoop) ifFalse: [ ^ self ] ].
	goldLoops add: goldLoop.
]

{ #category : #identification }
SoGoldLoopOptimiser >> identifyGoldLoops: bbs [
	| goldLoops |
	goldLoops := OrderedCollection new.
	bbs do: [ :each |
		| bj |
		bj := each lastInstr.
		bj basicBlock postOrder - bj targetBasicBlock postOrder <= 2 
			ifTrue: [ self identifyCarefully: bj into: goldLoops ] ].
	^ goldLoops
	
]

{ #category : #initialization }
SoGoldLoopOptimiser >> initialize [

	super initialize.

	retry := false.
]

{ #category : #debug }
SoGoldLoopOptimiser >> logDebug: msg class: cls at: instruction [
	| theClass |
	theClass := Smalltalk globals at: cls ifAbsent: [ ^ self ].
	instruction codeNode debugInfo add: ((Smalltalk globals at: cls) new 
		message: msg;
		stackOrNil: (instruction deoptInfo ifNotNil: [ :d | d asDebugStack ]);
		yourself) 
]

{ #category : #optimisation }
SoGoldLoopOptimiser >> maybeRemoveArrayInit: goldLoop [ 
	"If the loop is writting everything of the array, 
	 has no interrupt check and the array is instantiated 
	just before, we can remove the init"
	| instantiations allInsts |
	self assert: goldLoop backjump hasInterruptCheck not.
	goldLoop backjump peeled ifTrue: [ ^self ]. "Won't work once peeled"
	goldLoop body2 ifNotNil: [ ^ self ].
	allInsts := goldLoop extractArrayInstantiations.
	(goldLoop reworkForNoDeoptWith: allInsts) ifFalse: [ ^ self ].
	instantiations := allInsts select: [ :each | each needsInit ].
	instantiations ifEmpty: [ ^ self ].
	goldLoop start = 1 ifFalse: [ ^ self ].
	goldLoop increment = 1 ifFalse: [ ^ self ].
	instantiations := instantiations select: [ :inst | inst sized isConstant and: [ inst sized constant = goldLoop limit ] ].
	instantiations ifEmpty: [ ^ self ].
	"check writes all fields obj then remove"
	instantiations do: [ :inst | (goldLoop hasLoopWriteInto: inst) ifTrue: [ inst needsInit: false ] ].

	
	
]

{ #category : #optimisation }
SoGoldLoopOptimiser >> optimiseFlawedGoldLoop: goldLoop [
	"I removed everything here since nothing could work easily."
	goldLoop flawedLimit  <= MaxNoInterruptCount ifTrue: [ 
		self logDebug: 'flawed IC RM' class: #SoGoldLoopLog at: goldLoop backjump.
		self removeInterruptCheck: goldLoop.
		"abused the peel marker not to reprocess..."
		goldLoop backjump peeled: true ].
]

{ #category : #optimisation }
SoGoldLoopOptimiser >> optimiseGoldLoop: goldLoop [
	| count |
	count := goldLoop exactCount.
	count <= MaxFullUnrollCount
		ifTrue: [ 
			self logDebug: 'Full unroll' class: #SoGoldLoopLog at: goldLoop backjump.
			self fullUnroll: goldLoop ]
		ifFalse: [ 
			self logDebug: 'PeelAndUnroll' class: #SoGoldLoopLog at: goldLoop backjump.
			count <= MaxNoInterruptCount ifTrue: [ 
				self removeInterruptCheck: goldLoop.
				self maybeRemoveArrayInit: goldLoop ].
			self peelAndUnroll: goldLoop. ].
]

{ #category : #optimisation }
SoGoldLoopOptimiser >> optimiseGoldLoops: goldLoops [
	goldLoops do: [ :each | 
		each hasExactCount 
			ifTrue: [ self optimiseGoldLoop: each ]
			ifFalse: [ self optimiseFlawedGoldLoop: each ] ]
]

{ #category : #optimisation }
SoGoldLoopOptimiser >> peelAndUnroll: goldLoop [
	| it |
	goldLoop backjump peeled ifTrue: [ ^self ].
	goldLoop backjump peeled: true.
	goldLoop aboutToPeelTransformation.
	"unroll"
	(it := self unrollFactor: goldLoop) ~= 0 ifTrue: [ self unroll: goldLoop iteration: it ].
	"peel"
	goldLoop copyBodyBefore.
	goldLoop branch codeNode maintainPostOrder.
	"retry unroll if failed before"
	it = 0 ifFalse: [ ^ self ].
	"Addition to solve"
	SoSubexpressionElimination new traverseInstruction: goldLoop loopPhi loopPhiForwardInput.
	it := self unrollFactor: goldLoop.
	it = 0 ifTrue: [ ^ self ].
 	self unroll: goldLoop iteration: it 
]

{ #category : #optimisation }
SoGoldLoopOptimiser >> removeGoldLoop: goldLoop [
	| ahead |
	ahead := goldLoop beforeBody.
	ahead lastInstr replaceBy: (SoJumpAhead from: ahead to: goldLoop normalExit).
	SoDeadBranchElimination new removeDominatedPath: goldLoop body0. 
	goldLoop branch codeNode maintainPostOrder.
	retry := true.
]

{ #category : #optimisation }
SoGoldLoopOptimiser >> removeInterruptCheck: goldLoop [
	| bj fastBj |
	bj := goldLoop backjump.
	bj hasInterruptCheck ifFalse: [ ^self ].
	bj replaceBy: (fastBj := SoNoInterruptBackjump
		from: bj basicBlock 
		to: bj targetBasicBlock).
	goldLoop backjump: fastBj.
]

{ #category : #accessing }
SoGoldLoopOptimiser >> retry [
	<generated>
	^ retry
]

{ #category : #accessing }
SoGoldLoopOptimiser >> retry: aValue [
	<generated>
	retry := aValue
]

{ #category : #public }
SoGoldLoopOptimiser >> runOn: codeNode [
	self findAndOptimise: codeNode
]

{ #category : #public }
SoGoldLoopOptimiser >> runOn: codeNode retryAfter: block [
	self runOn: codeNode.
	retry ifFalse: [ ^ self ]. 
	block value.
	self runOn: codeNode 
]

{ #category : #optimisation }
SoGoldLoopOptimiser >> unroll: goldLoop iteration: iteration [
	"only body1. we need to remap the unroll val."
	goldLoop copyMap: Dictionary new.
	goldLoop unrollBody1: iteration.
	goldLoop copyMap: Dictionary new.
]

{ #category : #optimisation }
SoGoldLoopOptimiser >> unrollFactor: goldLoop [ 
	goldLoop body2 ifNotNil: [ ^ 0 ].
	goldLoop increment = 1 ifFalse: [ ^ 0 ].
	#(8 4 3 2) do: [ :it | 
		goldLoop exactCount \\ it = 0 ifTrue: [ ^ it ] ].
	^ 0
]
