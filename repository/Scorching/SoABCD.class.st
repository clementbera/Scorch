"
I am an implementation of ABCD: eliminating array bounds checks on demand, PLDI '00, Rastislav Bodík, Rajiv Gupta and Vivek Sarkar.

I perform lazy range analysis on integers to uncheck primitive operations and remove dead branches.

During the pass, the IR is transformed to e-SSA and then transformed back to SSA at the end.

My main task is to:
- remove overflow checks in aritmetic between smis
- resolve smi comparison by folding ranges
- uncheck at:






"
Class {
	#name : #SoABCD,
	#superclass : #SoGraphPreorderLoopTraverser,
	#instVars : [
		'pis',
		'branchesToReprocess',
		'retraversing'
	],
	#pools : [
		'SoPrimitiveConstants'
	],
	#category : #'Scorching-Pass-Data'
}

{ #category : #pi }
SoABCD >> addAndPropagatePi: branch [
	| toAddPi |
	toAddPi := OrderedCollection new: 2.
	"We create pi for non constant if the other operand has range information."
	branch expression receiver hasRangeInformation ifTrue: 
		[ branch expression firstArg isConstant ifFalse: [ toAddPi add: branch expression firstArg ] ].
	branch expression firstArg hasRangeInformation ifTrue: 
		[ branch expression receiver isConstant ifFalse: [ toAddPi add: branch expression receiver ] ].
	toAddPi ifEmpty: [ ^ self ].
	toAddPi do: [ :each |
		self addPiFor: each in:  branch trueBasicBlock.
		self addPiFor: each in:  branch falseBasicBlock ]
	
]

{ #category : #pi }
SoABCD >> addPiFor: node in: basicBlock [ 
	| subGraph toPatch pi |
	subGraph := self dominatedPath: basicBlock.
	toPatch := node uses select: [ :each | each isSunkObject not and: [ subGraph includes: each basicBlock ] ].
	toPatch ifEmpty: [ ^ self ].
	pi := self newPiFor: node startBasicBlock: basicBlock.
	toPatch do: [ :use |
		use replaceSubNode: node by: pi ].
]

{ #category : #accessing }
SoABCD >> branchesToReprocess [
	<generated>
	^ branchesToReprocess
]

{ #category : #accessing }
SoABCD >> branchesToReprocess: aValue [
	<generated>
	branchesToReprocess := aValue
]

{ #category : #testing }
SoABCD >> canUncheckVariableAccess: send [ 
	send specializedSendData hasCoherentReceiverType ifFalse: [ ^ false ].
	send specializedSendData anyReceiverClass instSize = 0 ifFalse: [ ^ false ].
	send firstArg hasRangeInformation ifFalse: [ ^ false ].
	^ send firstArg rangeInformation acceptArray: send receiver
]

{ #category : #'prim dispatch' }
SoABCD >> dispatch: prim send: send [
	prim = Add ifTrue: [ ^ self maybeAdd: send ].
	prim = At ifTrue: [ ^ self maybeAt: send ].
	prim = AtPut ifTrue: [ ^ self maybeAtPut: send ].
	prim = Sub ifTrue: [ ^ self maybeSub: send ].
	prim = BitShift ifTrue: [ ^ self maybeBitShift: send ].

]

{ #category : #private }
SoABCD >> has0Constant: send [
	"Assumes 1 arg"
	(send receiver is0Constant) ifTrue: [ ^ true ].
	^ send firstArg is0Constant
]

{ #category : #initialization }
SoABCD >> initialize [

	super initialize.

	pis := OrderedCollection new.
	branchesToReprocess := OrderedCollection new.
	retraversing := false.
]

{ #category : #pi }
SoABCD >> invertedRangeFor: node in: smiComp [
	^ node == smiComp receiver 	
		ifTrue: 
			[ smiComp firstArg rangeInformation maxArraySize ifNotNil: [ ^ SoRange fullRange ].
			  SoRange new 
				minConstant: (smiComp isSmiLessOp 
						ifTrue: [ smiComp firstArg rangeInformation minConstant ]
						ifFalse: [ smiComp firstArg rangeInformation minConstant + 1 ]);
				maxConstant: SmallInteger maxVal;
				yourself]
		ifFalse: 
			[ SoRange new 
				minConstant: SmallInteger minVal;
				maxConstant: (smiComp isSmiLessOp 
						ifTrue: [ smiComp receiver rangeInformation maxConstant ]
						ifFalse: [ smiComp receiver rangeInformation maxConstant - 1 ]);
				maxArraySize: smiComp receiver rangeInformation maxArraySize;
				yourself]
]

{ #category : #'prim dispatch' }
SoABCD >> maybeAdd: send [
	(self has0Constant: send) ifTrue: [ ^ self uncheck0: send ].
	send receiver hasRangeInformation ifFalse: [ ^ self ].
	send firstArg hasRangeInformation ifFalse: [ ^ self ].
	send receiver rangeInformation addRange: send firstArg rangeInformation onOverflow: [ ^ self ].
	"No range overflow."
	send replaceBy: (send asUnsafeOp: SoSmiAddOp).
	send addDependency
]

{ #category : #'prim dispatch' }
SoABCD >> maybeAt: send [
	(self canUncheckVariableAccess: send) ifFalse: [ ^ self ].
	self uncheckAt: send.
]

{ #category : #'prim dispatch' }
SoABCD >> maybeAtPut: send [
	(self canUncheckVariableAccess: send) ifFalse: [ ^ self ].
	self uncheckAtPut: send.
]

{ #category : #'prim dispatch' }
SoABCD >> maybeBitShift: send [
	(self has0Constant: send) ifTrue: [ ^ self uncheck0Shift: send ].
	send firstArg hasRangeInformation ifFalse: [ ^ self ].
	send firstArg rangeInformation isPositiveOrNegative ifFalse: [ ^ self ]. "Shift right or left ?"
	send firstArg rangeInformation isPositive ifFalse: [ ^ self maybeBitShiftRight: send ]. "We cheat (not using fall back of prim)"
	send receiver hasRangeInformation ifFalse: [ ^ self ].
	send receiver rangeInformation isPositive ifFalse: [ ^ self ]. "Else primitive fails"
	send firstArg rangeInformation isPositive ifTrue: [ self maybeBitShiftLeft: send ]
]

{ #category : #'prim dispatch' }
SoABCD >> maybeBitShiftLeft: send [
	"Can overflow"
	(send receiver rangeInformation shiftLeftOverflow: send firstArg rangeInformation) ifTrue: [ ^ self ].
	"No overflow !"
	send replaceBy: (send asUnsafeOp: SoSmiBitShiftLeftOp).
	send addDependency
]

{ #category : #'prim dispatch' }
SoABCD >> maybeBitShiftRight: send [
	"No overflow !"
	| negated |
	send insertTrap.
	(negated := SoSmiSubOp 
		withReceiver: (SoConstant constant: 0)
		arguments: {send firstArg}) insertBefore: send.
	send replaceSubNode: send firstArg by: negated.
	send replaceBy: (send asUnsafeOp: SoSmiBitShiftRightOp).
	send addDependency
]

{ #category : #traversing }
SoABCD >> maybeReprocess: basicBlock [
	retraversing := true.
	super maybeReprocess: basicBlock.
	retraversing := false.
]

{ #category : #'prim dispatch' }
SoABCD >> maybeSub: send [
	"Not used right now"
	send firstArg is0Constant ifTrue: [ ^ self uncheck0: send ].
	send receiver hasRangeInformation ifFalse: [ ^ self ].
	send firstArg hasRangeInformation ifFalse: [ ^ self ].
	send receiver rangeInformation subRange: send firstArg rangeInformation onOverflow: [ ^ self ].
	"No range overflow."
	send replaceBy: (send asUnsafeOp: SoSmiSubOp).
	send addDependency
]

{ #category : #pi }
SoABCD >> newPiFor: node startBasicBlock: basicBlock [
	| branch range pi |
	branch := basicBlock predecessors anyOne lastInstr.
	range := branch trueBasicBlock == basicBlock
		ifTrue: [ self rangeFor: node in: branch expression ]
		ifFalse: [ self invertedRangeFor: node in: branch expression ].
	pi := SoPi new
		basicBlock: basicBlock;
		expression: node;
		additionalRange: range;
		yourself.
	basicBlock addFirstInstruction: pi.
	pis add: pi.
	^ pi
]

{ #category : #private }
SoABCD >> newSmiTrap: other beforeSend: send [
	other isSmiConstant ifTrue: [ ^ self ].
	(SoTrapIfNotInstanceOf new
		behaviors: {SmallInteger};
		expression: other;
		deoptInfo: (send deoptInfo convertToTrapWith: send);
		yourself) insertBefore: send.
]

{ #category : #accessing }
SoABCD >> pis [
	<generated>
	^ pis
]

{ #category : #accessing }
SoABCD >> pis: aValue [
	<generated>
	pis := aValue
]

{ #category : #pi }
SoABCD >> rangeFor: node in: smiComp [
	^ node == smiComp receiver 	
		ifTrue: 
			[SoRange new 
				minConstant: SmallInteger minVal;
				maxConstant: (smiComp isSmiLessOp 
						ifTrue: [ smiComp firstArg rangeInformation maxConstant - 1 ]
						ifFalse: [ smiComp firstArg rangeInformation maxConstant ]);
				maxArraySize: smiComp firstArg rangeInformation maxArraySize;
				yourself]
		ifFalse: 
			[ smiComp receiver rangeInformation maxArraySize ifNotNil: [ ^ SoRange fullRange ].
			SoRange new 
				minConstant: (smiComp isSmiLessOp 
						ifTrue: [ smiComp receiver rangeInformation minConstant + 1 ]
						ifFalse: [ smiComp receiver rangeInformation minConstant ]);
				maxConstant: SmallInteger maxVal;
				yourself]
]

{ #category : #private }
SoABCD >> removePis [
	pis do: [ :pi |
		pi removeAndReplaceUsesBy: pi expression ]
]

{ #category : #accessing }
SoABCD >> retraversing [
	<generated>
	^ retraversing
]

{ #category : #accessing }
SoABCD >> retraversing: aValue [
	<generated>
	retraversing := aValue
]

{ #category : #public }
SoABCD >> runOn: codeNode [
	self traversePreorderCode: codeNode.
	self removePis.
	self reprocessBranches.
]

{ #category : #traversing }
SoABCD >> traverseBooleanBranch: branch [
	"if expr is unchecked and less or lessOrEqual, add the pi nodes."
	retraversing ifTrue: [ ^ self ].
	branch expression isSmiLessOrLessOrEqual ifFalse: [  ^ self ].
	(branch expression firstArg hasRangeInformation or: 
		[ branch expression receiver hasRangeInformation ]) ifFalse: [ ^ self ].
	self addAndPropagatePi: branch.
]

{ #category : #traversing }
SoABCD >> traverseSend: send [
	| primitive |
	send canBeInlined ifFalse: [ ^ self ].
	primitive := send methodToInline primitive.
	primitive = 0 ifTrue: [ ^ self ].
	self dispatch: primitive send: send
]

{ #category : #traversing }
SoABCD >> traverseSmiEqualOp: op [
	op receiver hasRangeInformation ifFalse: [ ^ self ].
	op firstArg hasRangeInformation ifFalse: [ ^ self ].
	(op receiver rangeInformation alwaysEqualThan: op firstArg rangeInformation)
		ifTrue: [  ^ self replaceCompOp: op withBool: true ].
	(op receiver rangeInformation alwaysNotEqualThan: op firstArg rangeInformation)
		ifTrue: [  ^ self replaceCompOp: op withBool: false ].
	
]

{ #category : #traversing }
SoABCD >> traverseSmiLessOp: op [
	op receiver hasRangeInformation ifFalse: [ ^ self ].
	op firstArg hasRangeInformation ifFalse: [ ^ self ].
	(op receiver rangeInformation alwaysLessThan: op firstArg rangeInformation)
		ifTrue: [ ^ self replaceCompOp: op withBool: true ].
	(op receiver rangeInformation alwaysGreaterOrEqualThan: op firstArg rangeInformation)
		ifTrue: [ ^self replaceCompOp: op withBool: false ].
	
]

{ #category : #traversing }
SoABCD >> traverseSmiLessOrEqualOp: op [
	op receiver hasRangeInformation ifFalse: [ ^ self ].
	op firstArg hasRangeInformation ifFalse: [ ^ self ].
	(op receiver rangeInformation alwaysLessOrEqualThan: op firstArg rangeInformation)
		ifTrue: [  ^ self replaceCompOp: op withBool: true ].
	(op receiver rangeInformation alwaysGreaterThan: op firstArg rangeInformation)
		ifTrue: [  ^ self replaceCompOp: op withBool: false ].
	
]

{ #category : #traversing }
SoABCD >> traverseSmiNotEqualOp: op [
	op receiver hasRangeInformation ifFalse: [ ^ self ].
	op firstArg hasRangeInformation ifFalse: [ ^ self ].
	(op receiver rangeInformation alwaysNotEqualThan: op firstArg rangeInformation)
		ifTrue: [  ^ self replaceCompOp: op withBool: true ].
	(op receiver rangeInformation alwaysEqualThan: op firstArg rangeInformation)
		ifTrue: [  ^ self replaceCompOp: op withBool: false ].
	
]

{ #category : #private }
SoABCD >> uncheck0: send [
	| otherOperand |
	otherOperand := (send receiver is0Constant 
		ifTrue: [  send firstArg ]
		ifFalse: [ send receiver ]).
	self newSmiTrap: otherOperand beforeSend: send.
	send removeAndReplaceUsesBy: otherOperand.
	send addDependency
]

{ #category : #private }
SoABCD >> uncheck0Shift: send [
	self newSmiTrap: send receiver beforeSend: send.
	send removeAndReplaceUsesBy: send receiver.
	send addDependency
]

{ #category : #private }
SoABCD >> uncheckAt: send [
	"trap on receiver, arg already in range."
	| unsafeOpClass |
	send specializedSendData anyReceiverClass instSpec = 16 ifTrue: [ unsafeOpClass := SoByteAtOp ].
	send specializedSendData anyReceiverClass instSpec = 2 ifTrue: [ unsafeOpClass := SoPointerAtOp ].
	unsafeOpClass ifNil: [ ^ self ].
	send insertTrap.
	send replaceBy: (send asUnsafeOp: unsafeOpClass).
	send addDependency
]

{ #category : #private }
SoABCD >> uncheckAtPut: send [
	"trap on receiver, arg already in range."
	| unsafeOpClass |
	"check value range
	send specializedSendData anyReceiverClass instSpec = 16 ifTrue: [ unsafeOpClass := SoByteAtPutOp ]."
	send specializedSendData anyReceiverClass instSpec = 2 ifTrue: [ unsafeOpClass := SoPointerAtPutOp ].
	unsafeOpClass ifNil: [ ^ self ].
	send insertTrap.
	send replaceBy: (send asUnsafeOp: unsafeOpClass).
	send addDependency
]
