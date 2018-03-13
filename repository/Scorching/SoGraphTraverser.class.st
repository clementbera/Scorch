"
I am an abstract superclass of all objects that needs to be able to traverse the CFG graph.
 
By default, traversing an instruction forwards the traverse logic to the instruction's superclass traverse method. For example, InstVar inherits from HeapAccess which inherits from body instruction, so the default behavior of traversing InstVar forwards to traverse HeapAccess which forwards to traverse Body instruction. This way, if a pass overrides only traverseHeapAccess:, it catches all the subclasses of Heap access traversing.

I also, and unfortunately, include some convenient methods in utils.
"
Class {
	#name : #SoGraphTraverser,
	#superclass : #Object,
	#category : #'Scorching-Pass-FrontEnd'
}

{ #category : #utils }
SoGraphTraverser >> dominatedPath: basicBlock [
	"Answers a list of basicBlocks dominated by the given basicBlock."
	| result workList bb |
	result := Set with: basicBlock.
	workList := basicBlock successors asOrderedCollection.
	[ workList isEmpty ] whileFalse: 
		[ bb := workList removeFirst.
		  ((result includes: bb) not and: [result includesAll: bb forwardPredecessors]) 
			ifTrue: 
				[ result add: bb.
				  workList addAll: bb successors ] ].
	^ result 
]

{ #category : #utils }
SoGraphTraverser >> logDebug: msg class: cls at: instruction [
	| theClass |
	theClass := Smalltalk globals at: cls ifAbsent: [ ^ self ].
	instruction codeNode debugInfo add: ((Smalltalk globals at: cls) new 
		message: msg;
		stackOrNil: (instruction deoptInfo ifNotNil: [ :d | d asDebugStack ]);
		yourself) 
]

{ #category : #traversing }
SoGraphTraverser >> traverseArg: anArg [
	<generated>
	^ self traverseImmediateUses: anArg
]

{ #category : #public }
SoGraphTraverser >> traverseBackwardBasicBlock: basicBlock [
	basicBlock instructionsReverseDo: [ :instr |
		self traverseInstruction: instr ].
]

{ #category : #traversing }
SoGraphTraverser >> traverseBehaviorIdentityHashOp: aBehaviorIdentityHashOp [
	<generated>
	^ self traverseHashOp: aBehaviorIdentityHashOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseBodyInstruction: aBodyInstruction [
	<generated>
	
]

{ #category : #traversing }
SoGraphTraverser >> traverseBranch: aBranch [
	<generated>
	^ self traverseJump: aBranch
]

{ #category : #traversing }
SoGraphTraverser >> traverseByteEqualOp: aByteEqualOp [
	<generated>
	^ self traverseUnsafeOp: aByteEqualOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseByteNewColon: aByteNewColon [
	<generated>
	^ self traverseNewColon: aByteNewColon
]

{ #category : #traversing }
SoGraphTraverser >> traverseByteRead: aByteRead [
	<generated>
	^ self traverseObjectRead: aByteRead
]

{ #category : #traversing }
SoGraphTraverser >> traverseByteSizeOp: aByteSizeOp [
	<generated>
	^ self traverseSizeOp: aByteSizeOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseByteWrite: aByteWrite [
	<generated>
	^ self traverseObjectWrite: aByteWrite
]

{ #category : #traversing }
SoGraphTraverser >> traverseCFGInstruction: aCFGInstruction [
	<generated>
	
]

{ #category : #traversing }
SoGraphTraverser >> traverseCall: aCall [
	<generated>
	^ self traverseOp: aCall
]

{ #category : #traversing }
SoGraphTraverser >> traverseCharacterAsIntegerOp: aCharacterAsIntegerOp [
	<generated>
	^ self traverseImmediateAsIntegerOp: aCharacterAsIntegerOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseCharacterIdentityHashOp: aCharacterIdentityHashOp [
	<generated>
	^ self traverseHashOp: aCharacterIdentityHashOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseConstant: aConstant [
	<generated>
	^ self traverseImmediate: aConstant
]

{ #category : #traversing }
SoGraphTraverser >> traverseCopiedTemp: aCopiedTemp [
	<generated>
	^ self traverseImmediateUses: aCopiedTemp
]

{ #category : #traversing }
SoGraphTraverser >> traverseCreateContextFullBlock: aCreateContextFullBlock [
	<generated>
	^ self traverseCreateFullBlock: aCreateContextFullBlock
]

{ #category : #traversing }
SoGraphTraverser >> traverseCreateFullBlock: aCreateFullBlock [
	<generated>
	^ self traverseBodyInstruction: aCreateFullBlock
]

{ #category : #traversing }
SoGraphTraverser >> traverseCreateNLRFullBlock: aCreateNLRFullBlock [
	<generated>
	^ self traverseCreateContextFullBlock: aCreateNLRFullBlock
]

{ #category : #traversing }
SoGraphTraverser >> traverseDeoptImmediate: aDeoptImmediate [
	<generated>
	^ self traverseImmediate: aDeoptImmediate
]

{ #category : #traversing }
SoGraphTraverser >> traverseDirectCall: aDirectCall [
	<generated>
	^ self traverseCall: aDirectCall
]

{ #category : #traversing }
SoGraphTraverser >> traverseEnsureEnoughSlots: anEnsureEnoughSlots [
	<generated>
	^ self traverseBodyInstruction: anEnsureEnoughSlots
]

{ #category : #public }
SoGraphTraverser >> traverseForwardBasicBlock: basicBlock [
	basicBlock instructionsDo: [ :instr |
		self traverseInstruction: instr ].
]

{ #category : #traversing }
SoGraphTraverser >> traverseHashOp: aHashOp [
	<generated>
	^ self traverseUnsafeOp: aHashOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseImmediate: anImmediate [
	<generated>
	
]

{ #category : #traversing }
SoGraphTraverser >> traverseImmediateAsIntegerOp: anImmediateAsIntegerOp [
	<generated>
	^ self traverseUnsafeOp: anImmediateAsIntegerOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseImmediateTrap: anImmediateTrap [
	<generated>
	^ self traverseCFGInstruction: anImmediateTrap
]

{ #category : #traversing }
SoGraphTraverser >> traverseImmediateUses: anImmediateUses [
	<generated>
	^ self traverseImmediate: anImmediateUses
]

{ #category : #traversing }
SoGraphTraverser >> traverseInstanceOfBranch: anInstanceOfBranch [
	<generated>
	^ self traverseBranch: anInstanceOfBranch
]

{ #category : #traversing }
SoGraphTraverser >> traverseInstantiation: anInstantiation [
	<generated>
	^ self traverseBodyInstruction: anInstantiation
]

{ #category : #public }
SoGraphTraverser >> traverseInstruction: instr [
	^ instr isTraversedBy: self
]

{ #category : #traversing }
SoGraphTraverser >> traverseJump: aJump [
	<generated>
	^ self traverseCFGInstruction: aJump
]

{ #category : #traversing }
SoGraphTraverser >> traverseJumpAhead: aJumpAhead [
	<generated>
	^ self traverseUnconditionalJump: aJumpAhead
]

{ #category : #traversing }
SoGraphTraverser >> traverseLoopHead: aLoopHead [
	<generated>
	^ self traverseBodyInstruction: aLoopHead
]

{ #category : #traversing }
SoGraphTraverser >> traverseMaybeContextPointerRead: aMaybeContextPointerRead [
	<generated>
	^ self traversePointerRead: aMaybeContextPointerRead
]

{ #category : #traversing }
SoGraphTraverser >> traverseMaybeContextPointerWrite: aMaybeContextPointerWrite [
	<generated>
	^ self traversePointerWrite: aMaybeContextPointerWrite
]

{ #category : #traversing }
SoGraphTraverser >> traverseMutableLiteralRead: aMutableLiteralRead [
	<generated>
	^ self traverseBodyInstruction: aMutableLiteralRead
]

{ #category : #traversing }
SoGraphTraverser >> traverseNewColon: aNewColon [
	<generated>
	^ self traverseInstantiation: aNewColon
]

{ #category : #traversing }
SoGraphTraverser >> traverseNoInterruptBackjump: aNoInterruptBackjump [
	<generated>
	^ self traverseUnconditionalJump: aNoInterruptBackjump
]

{ #category : #traversing }
SoGraphTraverser >> traverseObjectAccess: anObjectAccess [
	<generated>
	^ self traverseBodyInstruction: anObjectAccess
]

{ #category : #traversing }
SoGraphTraverser >> traverseObjectIdentityHashOp: anObjectIdentityHashOp [
	<generated>
	^ self traverseHashOp: anObjectIdentityHashOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseObjectRead: anObjectRead [
	<generated>
	^ self traverseObjectAccess: anObjectRead
]

{ #category : #traversing }
SoGraphTraverser >> traverseObjectWrite: anObjectWrite [
	<generated>
	^ self traverseObjectAccess: anObjectWrite
]

{ #category : #traversing }
SoGraphTraverser >> traverseOp: anOp [
	<generated>
	^ self traverseBodyInstruction: anOp
]

{ #category : #traversing }
SoGraphTraverser >> traversePCConstant: aPCConstant [
	<generated>
	^ self traverseDeoptImmediate: aPCConstant
]

{ #category : #traversing }
SoGraphTraverser >> traversePhi: aPhi [
	<generated>
	^ self traverseBodyInstruction: aPhi
]

{ #category : #traversing }
SoGraphTraverser >> traversePi: aPi [
	<generated>
	^ self traverseBodyInstruction: aPi
]

{ #category : #traversing }
SoGraphTraverser >> traversePipelinedBooleanBranch: aPipelinedBooleanBranch [
	<generated>
	^ self traverseBranch: aPipelinedBooleanBranch
]

{ #category : #traversing }
SoGraphTraverser >> traversePointerEqualsOp: aPointerEqualsOp [
	<generated>
	^ self traverseUnsafeOp: aPointerEqualsOp
]

{ #category : #traversing }
SoGraphTraverser >> traversePointerNew: aPointerNew [
	<generated>
	^ self traverseInstantiation: aPointerNew
]

{ #category : #traversing }
SoGraphTraverser >> traversePointerNewColon: aPointerNewColon [
	<generated>
	^ self traverseNewColon: aPointerNewColon
]

{ #category : #traversing }
SoGraphTraverser >> traversePointerRead: aPointerRead [
	<generated>
	^ self traverseObjectRead: aPointerRead
]

{ #category : #traversing }
SoGraphTraverser >> traversePointerSizeOp: aPointerSizeOp [
	<generated>
	^ self traverseSizeOp: aPointerSizeOp
]

{ #category : #traversing }
SoGraphTraverser >> traversePointerWrite: aPointerWrite [
	<generated>
	^ self traverseObjectWrite: aPointerWrite
]

{ #category : #traversing }
SoGraphTraverser >> traversePossibleRoot: aPossibleRoot [
	<generated>
	^ self traverseBodyInstruction: aPossibleRoot
]

{ #category : #public }
SoGraphTraverser >> traversePostorderCode: code [
	code basicBlocks reverseDo: [ :basicBlock |
		self traverseBackwardBasicBlock: basicBlock ].
]

{ #category : #public }
SoGraphTraverser >> traversePreorderCode: code [
	code basicBlocks do: [ :basicBlock |
		self traverseForwardBasicBlock: basicBlock ].
]

{ #category : #traversing }
SoGraphTraverser >> traverseRawClassOp: aRawClassOp [
	<generated>
	^ self traverseUnsafeOp: aRawClassOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseRawPointerEqualsOp: aRawPointerEqualsOp [
	<generated>
	^ self traversePointerEqualsOp: aRawPointerEqualsOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseRawPointerNotEqualsOp: aRawPointerNotEqualsOp [
	<generated>
	^ self traversePointerEqualsOp: aRawPointerNotEqualsOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseReadOnlyBranch: aReadOnlyBranch [
	<generated>
	^ self traverseBranch: aReadOnlyBranch
]

{ #category : #traversing }
SoGraphTraverser >> traverseReadOnlyCheckByteWrite: aReadOnlyCheckByteWrite [
	<generated>
	^ self traverseByteWrite: aReadOnlyCheckByteWrite
]

{ #category : #traversing }
SoGraphTraverser >> traverseReadOnlyCheckPointerWrite: aReadOnlyCheckPointerWrite [
	<generated>
	^ self traversePointerWrite: aReadOnlyCheckPointerWrite
]

{ #category : #traversing }
SoGraphTraverser >> traverseReceiver: aReceiver [
	<generated>
	^ self traverseImmediateUses: aReceiver
]

{ #category : #traversing }
SoGraphTraverser >> traverseReturn: aReturn [
	<generated>
	^ self traverseCFGInstruction: aReturn
]

{ #category : #traversing }
SoGraphTraverser >> traverseSend: aSend [
	<generated>
	^ self traverseCall: aSend
]

{ #category : #traversing }
SoGraphTraverser >> traverseSizeOp: aSizeOp [
	<generated>
	^ self traverseUnsafeOp: aSizeOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmallFloatAsIntegerOp: aSmallFloatAsIntegerOp [
	<generated>
	^ self traverseImmediateAsIntegerOp: aSmallFloatAsIntegerOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmallFloatIdentityHashOp: aSmallFloatIdentityHashOp [
	<generated>
	^ self traverseHashOp: aSmallFloatIdentityHashOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmalltalkBackjump: aSmalltalkBackjump [
	<generated>
	^ self traverseNoInterruptBackjump: aSmalltalkBackjump
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmalltalkBooleanBranch: aSmalltalkBooleanBranch [
	<generated>
	^ self traversePipelinedBooleanBranch: aSmalltalkBooleanBranch
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiAddOp: aSmiAddOp [
	<generated>
	^ self traverseSmiArithmeticOp: aSmiAddOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiArithmeticOp: aSmiArithmeticOp [
	<generated>
	^ self traverseSmiOp: aSmiArithmeticOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiBitAndOp: aSmiBitAndOp [
	<generated>
	^ self traverseSmiBitOp: aSmiBitAndOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiBitOp: aSmiBitOp [
	<generated>
	^ self traverseSmiOp: aSmiBitOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiBitOrOp: aSmiBitOrOp [
	<generated>
	^ self traverseSmiBitOp: aSmiBitOrOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiBitShiftLeftOp: aSmiBitShiftLeftOp [
	<generated>
	^ self traverseSmiBitShiftOp: aSmiBitShiftLeftOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiBitShiftOp: aSmiBitShiftOp [
	<generated>
	^ self traverseSmiBitOp: aSmiBitShiftOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiBitShiftRightOp: aSmiBitShiftRightOp [
	<generated>
	^ self traverseSmiBitShiftOp: aSmiBitShiftRightOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiBitXorOp: aSmiBitXorOp [
	<generated>
	^ self traverseSmiBitOp: aSmiBitXorOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiCompOp: aSmiCompOp [
	<generated>
	^ self traverseSmiOp: aSmiCompOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiDivOp: aSmiDivOp [
	<generated>
	^ self traverseSmiArithmeticOp: aSmiDivOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiEqualOp: aSmiEqualOp [
	<generated>
	^ self traverseSmiCompOp: aSmiEqualOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiLessOp: aSmiLessOp [
	<generated>
	^ self traverseSmiCompOp: aSmiLessOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiLessOrEqualOp: aSmiLessOrEqualOp [
	<generated>
	^ self traverseSmiCompOp: aSmiLessOrEqualOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiModOp: aSmiModOp [
	<generated>
	^ self traverseSmiArithmeticOp: aSmiModOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiMulOp: aSmiMulOp [
	<generated>
	^ self traverseSmiArithmeticOp: aSmiMulOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiNotEqualOp: aSmiNotEqualOp [
	<generated>
	^ self traverseSmiCompOp: aSmiNotEqualOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiOp: aSmiOp [
	<generated>
	^ self traverseUnsafeOp: aSmiOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiQuoOp: aSmiQuoOp [
	<generated>
	^ self traverseSmiArithmeticOp: aSmiQuoOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseSmiSubOp: aSmiSubOp [
	<generated>
	^ self traverseSmiArithmeticOp: aSmiSubOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseThisClosure: aThisClosure [
	<generated>
	^ self traverseDeoptImmediate: aThisClosure
]

{ #category : #traversing }
SoGraphTraverser >> traverseTrapIf: aTrapIf [
	<generated>
	^ self traverseBodyInstruction: aTrapIf
]

{ #category : #traversing }
SoGraphTraverser >> traverseTrapIfNotInstanceOf: aTrapIfNotInstanceOf [
	<generated>
	^ self traverseTrapIf: aTrapIfNotInstanceOf
]

{ #category : #traversing }
SoGraphTraverser >> traverseTrapIfReadOnly: aTrapIfReadOnly [
	<generated>
	^ self traverseTrapIf: aTrapIfReadOnly
]

{ #category : #traversing }
SoGraphTraverser >> traverseUnconditionalJump: anUnconditionalJump [
	<generated>
	^ self traverseJump: anUnconditionalJump
]

{ #category : #traversing }
SoGraphTraverser >> traverseUnforward: anUnforward [
	<generated>
	^ self traverseBodyInstruction: anUnforward
]

{ #category : #traversing }
SoGraphTraverser >> traverseUnforwardNonImmediate: anUnforwardNonImmediate [
	<generated>
	^ self traverseUnforward: anUnforwardNonImmediate
]

{ #category : #traversing }
SoGraphTraverser >> traverseUnsafeOp: anUnsafeOp [
	<generated>
	^ self traverseOp: anUnsafeOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseYoungBranch: aYoungBranch [
	<generated>
	^ self traverseBranch: aYoungBranch
]
