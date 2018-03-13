"
I attempt to inline all the call graph. My strategy is to inline first sends in inner most loops, and last sends not in loop at all. The decompiler has annotated sends with ""loopDepth"" information for this purpose. Each time I inline a send, I add the sends present in that code to the sends to inline (which may be inlined first depending on loop depth). Fortunately, the decompiler annoate code with ""decompSends"" which is the list of sends present in the decompiled code, helping me with this tedious task.

Each primitives requires a special inlining rule. I am able to inline primitives that require **only** type checks. Primitives requiring range checks are inlined by the ABCD pass.

sends <OrderedCollection of ScSend> sends to inline (not processed yet) 

"
Class {
	#name : #SoCallGraphInliner,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'sends',
		'inliningCount'
	],
	#pools : [
		'SoMagicConstants',
		'SoPrimitiveConstants'
	],
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #'inlining sends' }
SoCallGraphInliner >> addNewSends: newSends [
	newSends ifEmpty: [ ^ self ].
	sends addAll: newSends.
	sends sort: [ :a :b | a loopDepth >= b loopDepth ]
]

{ #category : #'inlining sends' }
SoCallGraphInliner >> basicInline: send [
	"Answers the inlined sends to be reprocessed for additional inlining."
	| prim |
	prim := send methodToInline primitive.
	^ (prim = 0 or: [ send methodToInline isQuick ])
		ifTrue: [ self inlineMethod: send ]
		ifFalse: [ self dispatch: prim send: send ]
]

{ #category : #testing }
SoCallGraphInliner >> bonusFor: send [
	| bonus |
	bonus := 0.
	send subNodes do: [ :sub |
		sub isConstant ifTrue: [ bonus := bonus + ConstantInliningBonus ].
		sub isBlockClosure ifTrue: [ bonus := bonus + ClosureInliningBonus ] ].
	^ bonus
]

{ #category : #'inlining PIC' }
SoCallGraphInliner >> canAttemptPICInlining: send [
	"2 types, 2 methods right now."
	send deoptInfo depth < MaxInliningDepth ifFalse: [ ^ false ].
	send sendData mayBeInlinablePIC ifFalse: [ ^ false ].
	send sendData behaviorsAndMethods size ~= 2 ifTrue: [ ^ false ].
	^ send sendData behaviorsAndMethods values anySatisfy: [ :m | self canPICInline: m ]
]

{ #category : #'inlining PIC' }
SoCallGraphInliner >> canPICInline: methodToInline [
	methodToInline isOptimized ifTrue: [ ^ false ].
	methodToInline allowRuntimeOptimizations ifFalse: [ ^ false ].
	^ methodToInline bytecodeSize <= AlwaysInlineSize
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> dispatch: prim send: send [
	"Resorted by frequency... 
	 We know prim is > 0 and not a quick primitive.
	 However this pass can't deal with ranges."
	
	self flag: #refactor. "with the primitive table idea."
	
	"Top 3 most common dealt in this pass"
	prim = Less ifTrue: [ ^ self maybeLess: send ].
	prim = LessOrEqual ifTrue: [ ^ self maybeLessOrEqual: send ].
	
	prim = Size ifTrue: [ ^ self maybeSize: send ].
	
	"Top 1 most common not dealt in this pass"
	prim = Add ifTrue: [ ^ #() ].
	
	"Rest of primitives, less common, order don't matter any more."
	prim = FullBlockClosureEvaluation ifTrue: [ ^ self maybeValue: send ].
	
	prim = Equal ifTrue: [ ^ self maybeEqual: send ].
	prim = NotEqual ifTrue: [ ^ self maybeNotEqual: send ].
	prim = Greater ifTrue: [ ^ self maybeGreater: send ].
	prim = GreaterOrEqual ifTrue: [ ^ self maybeGreaterOrEqual: send ].

	prim = ClassPrim ifTrue: [ ^ self maybeClassPrim: send ].
	prim = PointerEquals ifTrue: [ ^ self maybePointerEquals: send ].
	prim = New ifTrue: [ ^ self maybeNew: send ].
	prim = Perform ifTrue: [ ^ self maybePerform: send ].
	
	prim = ImmediateAsInteger ifTrue: [ ^ self maybeImmediateAsInteger: send ].
	
	prim = BitAnd ifTrue: [ ^ self maybeBitAnd: send ].
	prim = BitOr ifTrue: [ ^ self maybeBitOr: send ].
	prim = BitXor ifTrue: [ ^ self maybeBitXor: send ].
	
	prim = IdentityHash ifTrue: [ ^ self inlineIdentityHash: send ].
	
	^ #()


]

{ #category : #initialization }
SoCallGraphInliner >> initialize [

	super initialize.

	sends := OrderedCollection new.
	inliningCount := 0.
]

{ #category : #'inlining sends' }
SoCallGraphInliner >> inline: send [
	"Answers the inlined sends to be reprocessed for additional inlining."
	send canBeInlined ifFalse: [ 
		(self canAttemptPICInlining: send)
			ifTrue: [ self picInlining: send ]
			ifFalse: [ self maybeLogFailure: send ].
		 ^ #() ].
	^ self basicInline: send
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> inlineIdentityHash: send [
	"Disabled cause not mapped.
	^ self reprocessAndUncheck: send to: (send asUnsafeOp: SoIdentityHashOp)"
	^ #()
]

{ #category : #'inlining sends' }
SoCallGraphInliner >> inlineMethod: send [
	| inliner futureSends |
	(self shouldInline: send) ifFalse: [ ^ #() ].
	inliner := SoMethodInliner new.
	futureSends := inliner inline: send passesBeforeInlining: self passesBeforeInlining.
	inliner lastInliningWasSuccessful ifTrue: [inliningCount := inliningCount + 1].
	^ futureSends
]

{ #category : #public }
SoCallGraphInliner >> inlineQuietlySends: sendToProcess [	
	sendToProcess ifEmpty: [ ^ self ].
	inliningCount := AggressiveInliningCountThreshold. "Make sure inlining is not too aggressive"
	self inlineSends: sendToProcess.
]

{ #category : #public }
SoCallGraphInliner >> inlineSends: sendToProcess [	
	sendToProcess ifEmpty: [ ^ self ].
	self addNewSends: sendToProcess.
	self processSends.
	sendToProcess first codeNode maintainPostOrder.
]

{ #category : #'inlining primitive utils' }
SoCallGraphInliner >> inlineSmiBitOpClass: unsafeOpClass send: send [
	| unsafeOp |
	(send firstArg isConstant and: [ send firstArg isSmiConstant not ]) ifTrue: [ ^ #() ].
	(send receiver isConstant and: [ send receiver isSmiConstant not ]) ifTrue: [ ^ #() ].
	self newSmiTrap: send firstArg beforeSend: send.
	unsafeOp := send asUnsafeOp: unsafeOpClass.
	^ self reprocessAndUncheck: send to: unsafeOp
]

{ #category : #'inlining primitive utils' }
SoCallGraphInliner >> inlineSmiOp: unsafeOp send: send [
	(send firstArg isConstant and: [ send firstArg isSmiConstant not ]) ifTrue: [ unsafeOp subNodesRemoveUses. ^ #() ].
	(send receiver isConstant and: [ send receiver isSmiConstant not ]) ifTrue: [ unsafeOp subNodesRemoveUses. ^ #() ].
	self newSmiTrap: send firstArg beforeSend: send.
	self uncheck: send to: unsafeOp.
	^ #()
]

{ #category : #'inlining primitive utils' }
SoCallGraphInliner >> inlineSmiOpClass: unsafeOpClass send: send [
	^ self inlineSmiOp: (send asUnsafeOp: unsafeOpClass) send: send
	
]

{ #category : #accessing }
SoCallGraphInliner >> inliningCount [
	<generated>
	^ inliningCount
]

{ #category : #accessing }
SoCallGraphInliner >> inliningCount: aValue [
	<generated>
	inliningCount := aValue
]

{ #category : #testing }
SoCallGraphInliner >> maxInliningSize [
	inliningCount < AggressiveInliningCountThreshold ifTrue: [^MaxInlineSize].
	inliningCount < RelaxedInliningCountThreshold ifTrue: [^(MaxInlineSize + AlwaysInlineSize) // 2].
	^ AlwaysInlineSize
]

{ #category : #'inlining sends' }
SoCallGraphInliner >> maybeAddNewSends: newSends [
	self addNewSends: (newSends reject: [ :send | sends includes: send ]).
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeBitAnd: send [
	^ self inlineSmiBitOpClass: SoSmiBitAndOp send: send
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeBitOr: send [
	^ self inlineSmiBitOpClass: SoSmiBitOrOp send: send
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeBitXor: send [
	^ self inlineSmiBitOpClass: SoSmiBitXorOp send: send
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeClassPrim: send [
	^ self reprocessAndUncheck: send toClass: SoClassOp
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeEqual: send [
	^ self inlineSmiOpClass: SoSmiEqualOp send: send
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeGreater: send [
	^ self 
		inlineSmiOp: (SoSmiLessOp 
			withReceiver: send firstArg
			arguments: { send receiver })
		send: send
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeGreaterOrEqual: send [
	^ self 
		inlineSmiOp: (SoSmiLessOrEqualOp withReceiver: send firstArg arguments: { send receiver })
		send: send
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeImmediateAsInteger: send [
	send specializedSendData behaviors size = 1 ifFalse: [ ^ #() ].
	send specializedSendData anyReceiverClass == Character ifFalse: [ ^ #() ].
	self uncheck: send toClass: SoCharacterAsIntegerOp.
	^ #()
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeLess: send [
	^ self inlineSmiOpClass: SoSmiLessOp send: send
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeLessOrEqual: send [
	^ self inlineSmiOpClass: SoSmiLessOrEqualOp send: send
]

{ #category : #'inlining sends' }
SoCallGraphInliner >> maybeLogFailure: send [
"	[SoAbsMessageInliner  
			logInlining: send 
			message: 'not enought type info... ' , ([send specializedSendData behaviors printString] on: Error do: ['unknown']).] 
				on: MessageNotUnderstood do: [ 'dev tool not installed' ]."
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeNew: send [
	| behavior |
	send specializedSendData behaviors size = 1 ifFalse: [ ^ #() ].
	behavior := send specializedSendData behaviors anyOne.
	behavior soleInstance isFixed ifFalse: [ ^ #() ]. "Pointers and not variable."
	behavior soleInstance instSize > MaxInstSizeForInlinedAllocation ifTrue: [ ^ #() ].
	SoEnsureEnoughSpace new
		numWords: behavior soleInstance instSize + 2;
		insertBefore: send.
	^ self 
		reprocessAndUncheck: send 
		to: (SoNewOp withReceiver: (SoConstant constant: behavior soleInstance))
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeNotEqual: send [
	^ self inlineSmiOpClass: SoSmiNotEqualOp send: send
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybePerform: send [
	"we're in perform: but not perform:withArgs:"
	| selector newSend |
	send firstArg isConstant ifFalse: [ ^ #() ].
	(selector := send firstArg constant) isSymbol ifFalse: [ ^ #() ]. 
	send insertTrap.
	newSend := SoSend new
		receiver: send receiver;
		selector: selector;
		loopDepth: send loopDepth;
		sendData: SoUnknownSendData new;
		deoptInfo: send deoptInfo;
		arguments: send arguments allButFirst;
		yourself.
	send replaceBy: newSend.
	newSend deoptInfo sunkObjects do: [ :e | e subNodesAddUses ].
	^ { newSend }
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybePointerEquals: send [
	self uncheck: send toClass: SoPointerEqualsOp.
	^ #() 
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeSize: send [
	| unsafeOpClass rep |
	send specializedSendData hasCoherentReceiverType ifFalse: [ ^ #() ].
	send specializedSendData anyReceiverClass instSpec = 16 ifTrue: 
		[ unsafeOpClass := SoByteSizeOp ].
	send specializedSendData anyReceiverClass instSpec = 2 ifTrue: 
		[ unsafeOpClass := SoPointerSizeOp ].
	unsafeOpClass ifNil: [ ^ #() ].
	^ send receiver hasSizeInformation 
		ifTrue: 
			[ rep := self toReprocess: send.
			  send removeAndReplaceUsesBy: (SoConstant constant: send receiver sizeInformation).
			  rep ]
		ifFalse: 
			[ self reprocessAndUncheck: send toClass: unsafeOpClass ]
	
]

{ #category : #'inlining primitive' }
SoCallGraphInliner >> maybeValue: send [ 
	"In case of multi inlining we have to make sure other sends are going to be inlined too."
	| futureSends inliner |
	inliner := SoBlockInliner new.
	futureSends := inliner inline: send passesBeforeInlining: self passesBeforeInlining.
	inliner lastInliningWasSuccessful 
		ifTrue: [ 
			inliningCount := inliningCount + 1.
			inliner onlyNLR ifTrue: [ self removeDeadSends ].
			self maybeAddNewSends: inliner extraSends ].
	^ futureSends
	


]

{ #category : #'inlining PIC' }
SoCallGraphInliner >> newBasicBlockJumpingTo: bb dominator: dom [
	| jmp newBB |
	newBB := SoBasicBlock new 
		dominator: dom;
		yourself.
	jmp := SoJumpAhead from: newBB to: bb.
	newBB
		firstInstr: jmp;
		lastInstr: jmp.
	dom codeNode addBasicBlock: newBB before: bb.
	^ newBB
]

{ #category : #'inlining primitive utils' }
SoCallGraphInliner >> newSmiTrap: other beforeSend: send [
	other isSmiConstant ifTrue: [ ^ self ].
	(SoTrapIfNotInstanceOf new
		behaviors: {SmallInteger};
		expression: other;
		deoptInfo: (send deoptInfo convertToTrapWith: send);
		yourself) insertBefore: send.
]

{ #category : #accessing }
SoCallGraphInliner >> passesBeforeInlining [
	^ { SoReorderBasicBlocks . SoFindDominators . SoSimplifyPhis }
]

{ #category : #'inlining PIC' }
SoCallGraphInliner >> picInlining: send [
	"Transforms:
	
	...
	send
	...
	
	to:
	
	...
	branchIfNotInstanceOf: X Y
	
	X.1 send
	
	Y.1 send
	
	phi (X.1 Y.1)
	..."
	
	| newSends |
	inliningCount := inliningCount + 1.
	newSends := self picTransform: send.
	newSends do: [ :each | self inline: each ].
	
]

{ #category : #'inlining PIC' }
SoCallGraphInliner >> picTransform: send [
	"Transforms:
	
	...
	send
	...
	
	to:
	
	...
	branchIfNotInstanceOf: X Y
	
	X.1 send
	
	Y.1 send
	
	phi (X.1 Y.1)
	..."
	
	| prevBB nextBB branch1 branch2 dup1 dup2 instBranch |
	dup1 := send copy.
	dup2 := send copy.
	prevBB := SoBasicBlockSplitter new splitBasicBlockAt: send.
	nextBB := prevBB successors first.
	branch2 := self newBasicBlockJumpingTo: nextBB dominator: prevBB.
	branch1 := self newBasicBlockJumpingTo: nextBB dominator: prevBB.
	branch1 addFirstInstruction: dup1.
	branch2 addFirstInstruction: dup2.
	nextBB predecessors remove: prevBB.
	instBranch := SoBranchIfNotInstanceOf new
		basicBlock: prevBB;
		behaviors: {send sendData behaviors first};
		expression: send receiver;
		trueBasicBlock: branch1;
		falseBasicBlock: branch2;
		yourself.
	dup1 sendData behaviorsAndMethods removeKey: send sendData behaviors first.
	dup2 sendData behaviorsAndMethods removeKey: send sendData behaviors second.
	prevBB lastInstr prevInstrNextInstr: instBranch.
	prevBB lastInstr: instBranch.
	send uses ifNotEmpty: [
		nextBB addFirstInstruction: (SoPhi new
			addInput: branch1 firstInstr basicBlock: branch1;
			addInput: branch2 firstInstr basicBlock: branch2;
			yourself).
		send replaceUsesBy: nextBB firstInstr ].
	^ { branch1 firstInstr . branch2 firstInstr  }
	
	
	
]

{ #category : #'inlining sends' }
SoCallGraphInliner >> processSends [
	[sends isEmpty] whileFalse: [self addNewSends: (self inline: sends removeFirst)].
]

{ #category : #'inlining sends' }
SoCallGraphInliner >> removeDeadSends [
	| bbs |
	"A bit hackish... Inlining NLR can sometimes lead to dead sends..."
	sends ifEmpty: [ ^ self ].
	bbs := sends first codeNode basicBlocks.
	sends copy do: [ :s |
		(bbs includes: s basicBlock) ifFalse: [ sends remove: s ] ]
]

{ #category : #'inlining primitive utils' }
SoCallGraphInliner >> reprocessAndUncheck: send to: unsafeOp [
	| toReprocess |
	"In addition to unchecking, we will retry to inline the sends using the unsafe operation as the receiver."
	toReprocess := self toReprocess: send.
	self uncheck: send to: unsafeOp.
	^ toReprocess
]

{ #category : #'inlining primitive utils' }
SoCallGraphInliner >> reprocessAndUncheck: send toClass: unsafeOpClass [
	| toReprocess |
	"In addition to unchecking, we will retry to inline the sends using the unsafe operation as the receiver."
	toReprocess := self toReprocess: send.
	self uncheck: send toClass: unsafeOpClass.
	^ toReprocess
]

{ #category : #public }
SoCallGraphInliner >> runOn: codeNode [
	"Should be run after decompilation, else use the other public API."
	self inlineSends: codeNode decompSends
]

{ #category : #accessing }
SoCallGraphInliner >> sends [
	<generated>
	^ sends
]

{ #category : #accessing }
SoCallGraphInliner >> sends: aValue [
	<generated>
	sends := aValue
]

{ #category : #testing }
SoCallGraphInliner >> shouldInline: send [
	| allowInliningUpToSize methodToInline toInline |
	methodToInline := send methodToInline.
	allowInliningUpToSize := self maxInliningSize + (self bonusFor: send).
	toInline := methodToInline isOptimized 
		ifTrue: [methodToInline metadata unoptimizedMethod]
		ifFalse: [methodToInline].
	^ toInline bytecodeSize <= allowInliningUpToSize	 
]

{ #category : #'inlining primitive utils' }
SoCallGraphInliner >> toReprocess: send [
	"We've inlined an unsafe operation, which result is now typed. As the pass processes the sends from inner most loop to outer most loop, we need to reprocess sends that are in an inner loop that may now be able to be inlined.
	If the send inlined has a use which is the receiver of another send, deeper in the loops, we need to reprocess."
	^ send uses select: [ :use | 
		use isSend and: [ 
			use receiver = send and: [
				use loopDepth > send loopDepth ] ] ].
]

{ #category : #'inlining primitive utils' }
SoCallGraphInliner >> uncheck: send to: unsafeOp [
	send insertTrap.
	send replaceBy: unsafeOp.
	send addDependency.
]

{ #category : #'inlining primitive utils' }
SoCallGraphInliner >> uncheck: send toClass: unsafeOpClass [
	self uncheck: send to: (send asUnsafeOp: unsafeOpClass)
]
