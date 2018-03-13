"
Gold loops are unsafe to:by:do: like loops. It's a very specific subclass of loops (exact count) but very important for performance in some cases.

Gold loop follow these constraints:
1) up to 3 basic blocks in the loop.
2) body0 is first basicBlock and is structured exactly as follow:
phis
smiComp (< or <=) [LoopPhi against EXACT count]
branch with loop exit or body1
3) body1 last instr is either
- backjump to body0
- branch with loop exit or body2
4) body2 last instr is jump back to body0

The term gold loop is correct : gold loops are rare but if you find one you've found the golden nugget which speeds greatly performance
"
Class {
	#name : #SoGoldLoop,
	#superclass : #Object,
	#instVars : [
		'backjump',
		'loopPhi',
		'phis',
		'comp',
		'addCst',
		'branch',
		'body0',
		'body1',
		'body2',
		'copyMap',
		'unrolling',
		'flawedLimit'
	],
	#category : #'Scorching-Pass-Flow'
}

{ #category : #arrays }
SoGoldLoop >> aboutToPeelTransformation [
	" If the all loop interrupt points are writes, we can move immChecks ahead"
	| toTrap |
	toTrap := OrderedCollection new.
	(self collectTraps: body1 in: toTrap) ifFalse: [ ^ self ].
	body2 ifNotNil: [(self collectTraps: body2 in: toTrap) ifFalse: [ ^ self ]].
	toTrap do: [ :instr |
		instr transformToReadOnlyTrapAndStore ]
]

{ #category : #accessing }
SoGoldLoop >> addCst [
	<generated>
	^ addCst
]

{ #category : #accessing }
SoGoldLoop >> addCst: aValue [
	<generated>
	addCst := aValue
]

{ #category : #accessing }
SoGoldLoop >> backjump [
	<generated>
	^ backjump
]

{ #category : #accessing }
SoGoldLoop >> backjump: aValue [
	<generated>
	backjump := aValue
]

{ #category : #'accessing indirect' }
SoGoldLoop >> basicExactCount [
	| i res |
	self increment = 1 ifTrue: [ ^ self limit - self start + 1 ].
	"... no comments ..."
	i := self start.
	res := 0.
	[ i <= self limit ] whileTrue: [ 
		i := i + self increment.
	 	res := res + 1 ].
	^ res
	
]

{ #category : #'accessing indirect' }
SoGoldLoop >> beforeBody [
	^ body0 forwardPredecessors anyOne
]

{ #category : #accessing }
SoGoldLoop >> body0 [
	<generated>
	^ body0
]

{ #category : #accessing }
SoGoldLoop >> body0: aValue [
	<generated>
	body0 := aValue
]

{ #category : #accessing }
SoGoldLoop >> body1 [
	<generated>
	^ body1
]

{ #category : #accessing }
SoGoldLoop >> body1: aValue [
	<generated>
	body1 := aValue
]

{ #category : #accessing }
SoGoldLoop >> body2 [
	<generated>
	^ body2
]

{ #category : #accessing }
SoGoldLoop >> body2: aValue [
	<generated>
	body2 := aValue
]

{ #category : #accessing }
SoGoldLoop >> branch [
	<generated>
	^ branch
]

{ #category : #accessing }
SoGoldLoop >> branch: aValue [
	<generated>
	branch := aValue
]

{ #category : #copy }
SoGoldLoop >> collectBody1Instructions [
	| instrs |
	instrs := OrderedCollection new.
	body1 instructionsButLastDo: [ :instr |
		instrs add: instr ].
	^ instrs
]

{ #category : #arrays }
SoGoldLoop >> collectTraps: basicBlock in: toTrap [ 
	basicBlock instructionsDo: [ :instr |
		instr hasDeoptInfo ifTrue: [ 
			instr isWrite 
				ifTrue: [ toTrap add: instr ]
				ifFalse: [ ^ false ] ] ].
	^ true

]

{ #category : #accessing }
SoGoldLoop >> comp [
	<generated>
	^ comp
]

{ #category : #accessing }
SoGoldLoop >> comp: aValue [
	<generated>
	comp := aValue
]

{ #category : #copy }
SoGoldLoop >> copyBodyBefore [
	copyMap at: comp put:  (SoConstant constant: true).
	self copyBodyBefore: body1.
	body2 ifNotNil: [
		self copyBranch.
		self copyBodyBefore: body2 ].
	self finishBodyCopy.
	
]

{ #category : #copy }
SoGoldLoop >> copyBodyBefore: body [
	body instructionsButLastDo: [ :instr |
		| copy |
		copy := instr copy.
		copyMap at: instr put: copy.
		copy insertBefore: self beforeBody lastInstr.
		self maybeReplaceFull: copy.
		phis do: [ :phi | 
			phi loopPhiBackInput == instr
				ifTrue: [ phi replaceSubNode: phi loopPhiForwardInput by: copy ] ] ].
]

{ #category : #copy }
SoGoldLoop >> copyBranch [
	"This assumes second exit is empty and immediately merges with normal exit."
	| before b bb1 bb2 |
	before := self beforeBody.
	bb1 := self newBasicBlockBeforeLoopDom: before.
	body0 phisDo: [ :phi | phi replaceBasicBlock: before with: bb1 ].
	bb2 := self newBasicBlockAfterLoopDom: before.
	b := body1 lastInstr copy.
	self maybeReplaceFull: b.
	before lastInstr replaceBy: b.
	self secondExit = body1 lastInstr trueBasicBlock 
		ifTrue: [ b basicFalseBasicBlock: bb1.
				 b basicTrueBasicBlock: bb2 ]
		ifFalse: [ b basicFalseBasicBlock: bb2.
				 b basicTrueBasicBlock: bb1 ].
	"post phi patch."
	self mergeBasicBlock phis do: [ :phi |
		phi addInput: (self replacementFor: (phi inputForBasicBlock: self secondExit)) basicBlock: bb2 ].

]

{ #category : #accessing }
SoGoldLoop >> copyMap [
	<generated>
	^ copyMap
]

{ #category : #accessing }
SoGoldLoop >> copyMap: aValue [
	<generated>
	copyMap := aValue
]

{ #category : #'accessing indirect' }
SoGoldLoop >> exactCount [
	^ self basicExactCount max: 0
]

{ #category : #arrays }
SoGoldLoop >> extractArrayInstantiations [
	| insts |
	insts := OrderedCollection new.
	self beforeBody instructionsButLastReverseDo: [ :instr |
		instr hasDeoptInfo ifTrue: [ ^ insts ].
		(instr isPointerNewColon or: [ instr isByteNewColon ])
			ifTrue: [ insts add: instr ] ].
	 ^ insts
]

{ #category : #copy }
SoGoldLoop >> finishBodyCopy [
	"At the end of first iteration when copying bodies ahead, phis
	 on loop invariants needs to be removed (only first iteration of loop was
	 different, and it's now ahead"
	phis copy do: [ :each | 
		 (self isLoopInvariant: each loopPhiBackInput) ifTrue: [ 
			each removeAndReplaceUsesBy: each loopPhiBackInput.
			phis remove: each ] ]
]

{ #category : #accessing }
SoGoldLoop >> flawedLimit [
	<generated>
	^ flawedLimit
]

{ #category : #accessing }
SoGoldLoop >> flawedLimit: aValue [
	<generated>
	flawedLimit := aValue
]

{ #category : #'accessing indirect' }
SoGoldLoop >> hasExactCount [
	^ flawedLimit isNil
]

{ #category : #arrays }
SoGoldLoop >> hasLoopWriteInto: array [
	self assert: body2 isNil.
	body1 instructionsButLastDo: [ :instr |
		(instr isWrite 
			and: [ instr object = array
			and: [ instr index = loopPhi ] ])
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'accessing indirect' }
SoGoldLoop >> increment [
	^ addCst firstArg constant
]

{ #category : #copy }
SoGoldLoop >> initialize [

	super initialize.
	
	copyMap := Dictionary new.
	unrolling := false.
]

{ #category : #copy }
SoGoldLoop >> isLoopInvariant: input [
	input isImmediate ifTrue: [ ^ true ].
	input basicBlock = body0 ifTrue: [ ^ false ].
	input basicBlock = body1 ifTrue: [ ^ false ].
	input basicBlock = body2 ifTrue: [ ^ false ].
	^ true
]

{ #category : #'accessing indirect' }
SoGoldLoop >> limit [
	| limit |
	limit := comp firstArg constant.
	^ comp isSmiLessOp
		ifTrue: [ limit - 1 ]
		ifFalse: [ limit ]
]

{ #category : #accessing }
SoGoldLoop >> loopPhi [
	<generated>
	^ loopPhi
]

{ #category : #accessing }
SoGoldLoop >> loopPhi: aValue [
	<generated>
	loopPhi := aValue
]

{ #category : #copy }
SoGoldLoop >> maybeReplace: instr in: node [
	| rep |
	rep := self replacementFor: instr.
	rep == instr ifTrue: [ ^ self ].
	node replaceSubNode: instr by: rep
]

{ #category : #copy }
SoGoldLoop >> maybeReplaceFull: instr [ 
	self maybeReplaceSubNodes: instr.
	instr hasDeoptInfo ifFalse: [ ^ self ]. 
	instr deoptInfo copyForSubGraphTransformation.
	instr deoptInfo sunkObjects do: [ :each | self maybeReplaceSubNodes: each ] 
]

{ #category : #copy }
SoGoldLoop >> maybeReplaceSubNodes: instr [ 
	instr subNodesDo: [ :sub |
		self maybeReplace: sub in: instr ]
]

{ #category : #'accessing indirect' }
SoGoldLoop >> mergeBasicBlock [
	^ branch falseBasicBlock successors anyOne
]

{ #category : #copy }
SoGoldLoop >> newBasicBlockAfterLoopDom: dom [
	| newBB jump |
	newBB := SoBasicBlock new.
	jump := SoJumpAhead from: newBB to: self mergeBasicBlock.
	body0 codeNode addBasicBlock: newBB after: backjump basicBlock.
	^ newBB
		dominator: dom;
		firstInstr: jump;
		lastInstr: jump;
		yourself
]

{ #category : #copy }
SoGoldLoop >> newBasicBlockBeforeLoopDom: dom [
	| newBB jump |
	newBB := SoBasicBlock new.
	jump := SoJumpAhead from: newBB to: body0.
	body0 codeNode addBasicBlock: newBB before: body0.
	^ newBB
		dominator: dom;
		firstInstr: jump;
		lastInstr: jump;
		yourself
]

{ #category : #'accessing indirect' }
SoGoldLoop >> normalExit [
	^ branch falseBasicBlock
]

{ #category : #'accessing indirect' }
SoGoldLoop >> numDeoptInfo [
	| numDeoptInfo |
	numDeoptInfo := 0.
	body1 instructionsButLastDo: [ :i |
		i hasDeoptInfo ifTrue: [ numDeoptInfo := numDeoptInfo + 1 ] ].
	body2 ifNil: [ ^ numDeoptInfo ].
	body2 instructionsButLastDo: [ :i |
		i hasDeoptInfo ifTrue: [ numDeoptInfo := numDeoptInfo + 1 ] ].
	^ numDeoptInfo
]

{ #category : #copy }
SoGoldLoop >> patchAfterCode [
	phis do: [ :phi | phi replaceUsesBy: phi loopPhiForwardInput ].
	comp replaceUsesBy: (SoConstant constant: false).
]

{ #category : #copy }
SoGoldLoop >> patchPhis [
	phis do: [ :phi | phi replaceUsesBy: phi loopPhiForwardInput ].
]

{ #category : #accessing }
SoGoldLoop >> phis [
	<generated>
	^ phis
]

{ #category : #accessing }
SoGoldLoop >> phis: aValue [
	<generated>
	phis := aValue
]

{ #category : #arrays }
SoGoldLoop >> removeAllChecks: instr [
	| newInstr |
	newInstr := instr asInstrWithoutChecks.
	newInstr ~~ instr ifTrue: [ instr replaceBy: newInstr ].
]

{ #category : #arrays }
SoGoldLoop >> removeImmChecks: instr [
	| newInstr |
	newInstr := instr asInstrWithoutChecks.
	newInstr storeCheck: instr storeCheck.
	newInstr ~~ instr ifTrue: [ instr replaceBy: newInstr ].
]

{ #category : #copy }
SoGoldLoop >> replacementFor: instr [
	unrolling ifFalse: [ 
		phis 
			detect: [ :phi | phi = instr ]
			ifFound: [ :phi | ^ phi loopPhiForwardInput ] ].
	^ copyMap at: instr ifPresent: [ :elem | elem ] ifAbsent: [ instr ]

]

{ #category : #arrays }
SoGoldLoop >> reworkForNoDeoptWith: instantiations [
	"Answers true if the loop has no deopt point at all.
	
	 Instantiations are allocations just before the loop (no deopt point
	 in-between the alloc and the loop), so they're young and mutable. 
	 If the loop has no deopt point, also removes all checks on stores
	 on the instantiations.
	
	 Note: We cannot move readonly checks ahead since we don't have 
	 loopHead info anymore at this point, so we just deal with instantiations.
	 Maybe something to improve later on ..."
	
	| writes |
	self assert: body2 isNil.
	self assert: backjump hasInterruptCheck not.
	writes := OrderedCollection new.
	body1 instructionsButLastDo: [ :instr |
		(instr isWrite and: [ instantiations includes: instr object ])
			ifTrue: [ writes add: instr ]
			ifFalse: [ instr hasDeoptInfo ifTrue: [ ^ false ] ] ].
	writes do: [ :each | self removeAllChecks: each ].
	^ true
]

{ #category : #'accessing indirect' }
SoGoldLoop >> secondExit [
	^ body1 lastInstr successors detect: [:succ | succ postOrder > backjump basicBlock postOrder]
]

{ #category : #'accessing indirect' }
SoGoldLoop >> start [
	^ loopPhi loopPhiForwardInput constant
]

{ #category : #copy }
SoGoldLoop >> unrollBody1: iteration [
	"we know body1 is backjump."
	| i instructions |
	i := body1 firstInstr.
	instructions := self collectBody1Instructions.
	unrolling := true.
	iteration - 1 timesRepeat: [ 
		instructions do: [ :instr | 
			| copy |
			copy := instr copy.
			copy insertBefore: i.
			copyMap at: instr put: copy.
			self maybeReplaceFull: copy.
			phis do: [ :phi | 
				phi loopPhiBackInput == instr
					ifTrue: [ copyMap at: phi put: copy ] ] ] ].
	instructions do: [ :instr | 
			copyMap at: instr put: instr.
			self maybeReplaceFull: instr ].
	unrolling := false.
]

{ #category : #accessing }
SoGoldLoop >> unrolling [
	<generated>
	^ unrolling
]

{ #category : #accessing }
SoGoldLoop >> unrolling: aValue [
	<generated>
	unrolling := aValue
]
