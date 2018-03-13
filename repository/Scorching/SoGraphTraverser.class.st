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
SoGraphTraverser >> branchesToReprocess [
	self subclassResponsibility 
]

{ #category : #utils }
SoGraphTraverser >> dominatedPath: basicBlock [
	| result workList bb |
	result := OrderedCollection with: basicBlock.
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
SoGraphTraverser >> replaceCompOp: op withBool: bool [ 
	
	self branchesToReprocess addAll: (op uses select: [ :each | each isBooleanBranch ]).
	op removeAndReplaceUsesBy: (SoConstant new constant: bool; yourself).
]

{ #category : #utils }
SoGraphTraverser >> reprocessBranches [
	SoDeadBranchElimination new processBranches: self branchesToReprocess
]

{ #category : #traversing }
SoGraphTraverser >> traverseAccessingOp: anAccessingOp [
	<generated>
	^ self traverseUnsafeOp: anAccessingOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseArg: anArg [
	<generated>
	^ self traverseImmediateUses: anArg
]

{ #category : #traversing }
SoGraphTraverser >> traverseArrayCopyOp: anArrayCopyOp [
	<generated>
	^ self traverseUnsafeOp: anArrayCopyOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseBackjump: aBackjump [
	<generated>
	^ self traverseUnconditionalJump: aBackjump
]

{ #category : #public }
SoGraphTraverser >> traverseBackwardBasicBlock: basicBlock [
	basicBlock instructionsReverseDo: [ :instr |
		self traverseInstruction: instr ].
]

{ #category : #traversing }
SoGraphTraverser >> traverseBodyInstruction: aBodyInstruction [
	<generated>
	
]

{ #category : #traversing }
SoGraphTraverser >> traverseBooleanBranch: aBooleanBranch [
	<generated>
	^ self traverseBranch: aBooleanBranch
]

{ #category : #traversing }
SoGraphTraverser >> traverseBranch: aBranch [
	<generated>
	^ self traverseJump: aBranch
]

{ #category : #traversing }
SoGraphTraverser >> traverseBranchIfNotInstanceOf: aBranchIfNotInstanceOf [
	<generated>
	^ self traverseBranch: aBranchIfNotInstanceOf
]

{ #category : #traversing }
SoGraphTraverser >> traverseByteAtOp: aByteAtOp [
	<generated>
	^ self traverseAccessingOp: aByteAtOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseByteAtPutOp: aByteAtPutOp [
	<generated>
	^ self traverseAccessingOp: aByteAtPutOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseByteEqual: aByteEqual [
	<generated>
	^ self traverseUnsafeOp: aByteEqual
]

{ #category : #traversing }
SoGraphTraverser >> traverseByteEqualOp: aByteEqualOp [
	<generated>
	^ self traverseUnsafeOp: aByteEqualOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseByteSizeOp: aByteSizeOp [
	<generated>
	^ self traverseSizeOp: aByteSizeOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseCFGInstruction: aCFGInstruction [
	<generated>
	
]

{ #category : #traversing }
SoGraphTraverser >> traverseCharacterAsIntegerOp: aCharacterAsIntegerOp [
	<generated>
	^ self traverseImmediateAsIntegerOp: aCharacterAsIntegerOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseClassOp: aClassOp [
	<generated>
	^ self traverseUnsafeOp: aClassOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseConstant: aConstant [
	<generated>
	^ self traverseImmediate: aConstant
]

{ #category : #traversing }
SoGraphTraverser >> traverseContextInstVar: aContextInstVar [
	<generated>
	^ self traverseInstVar: aContextInstVar
]

{ #category : #traversing }
SoGraphTraverser >> traverseCopiedTemp: aCopiedTemp [
	<generated>
	^ self traverseImmediateUses: aCopiedTemp
]

{ #category : #traversing }
SoGraphTraverser >> traverseCreateArray: aCreateArray [
	<generated>
	^ self traverseBodyInstruction: aCreateArray
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
SoGraphTraverser >> traverseCreateTempVect: aCreateTempVect [
	<generated>
	^ self traverseBodyInstruction: aCreateTempVect
]

{ #category : #traversing }
SoGraphTraverser >> traverseDeoptImmediate: aDeoptImmediate [
	<generated>
	^ self traverseImmediate: aDeoptImmediate
]

{ #category : #traversing }
SoGraphTraverser >> traverseEnsureEnoughSpace: anEnsureEnoughSpace [
	<generated>
	^ self traverseBodyInstruction: anEnsureEnoughSpace
]

{ #category : #public }
SoGraphTraverser >> traverseForwardBasicBlock: basicBlock [
	basicBlock instructionsDo: [ :instr |
		self traverseInstruction: instr ].
]

{ #category : #traversing }
SoGraphTraverser >> traverseGlobal: aGlobal [
	<generated>
	^ self traverseHeapAccess: aGlobal
]

{ #category : #traversing }
SoGraphTraverser >> traverseHashOp: aHashOp [
	<generated>
	^ self traverseUnsafeOp: aHashOp
]

{ #category : #traversing }
SoGraphTraverser >> traverseHeapAccess: aHeapAccess [
	<generated>
	^ self traverseBodyInstruction: aHeapAccess
]

{ #category : #traversing }
SoGraphTraverser >> traverseIdentityHashOp: anIdentityHashOp [
	<generated>
	^ self traverseHashOp: anIdentityHashOp
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
SoGraphTraverser >> traverseInstVar: anInstVar [
	<generated>
	^ self traverseHeapAccess: anInstVar
]

{ #category : #traversing }
SoGraphTraverser >> traverseInstantiationOp: anInstantiationOp [
	<generated>
	^ self traverseUnsafeOp: anInstantiationOp
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
SoGraphTraverser >> traverseMutableLiteral: aMutableLiteral [
	<generated>
	^ self traverseHeapAccess: aMutableLiteral
]

{ #category : #traversing }
SoGraphTraverser >> traverseNewOp: aNewOp [
	<generated>
	^ self traverseInstantiationOp: aNewOp
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
SoGraphTraverser >> traversePointerAtOp: aPointerAtOp [
	<generated>
	^ self traverseAccessingOp: aPointerAtOp
]

{ #category : #traversing }
SoGraphTraverser >> traversePointerAtPutOp: aPointerAtPutOp [
	<generated>
	^ self traverseAccessingOp: aPointerAtPutOp
]

{ #category : #traversing }
SoGraphTraverser >> traversePointerEqualsOp: aPointerEqualsOp [
	<generated>
	^ self traverseUnsafeOp: aPointerEqualsOp
]

{ #category : #traversing }
SoGraphTraverser >> traversePointerSizeOp: aPointerSizeOp [
	<generated>
	^ self traverseSizeOp: aPointerSizeOp
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
SoGraphTraverser >> traverseReceiver: aReceiver [
	<generated>
	^ self traverseImmediateUses: aReceiver
]

{ #category : #traversing }
SoGraphTraverser >> traverseRemoteTemp: aRemoteTemp [
	<generated>
	^ self traverseHeapAccess: aRemoteTemp
]

{ #category : #traversing }
SoGraphTraverser >> traverseReturn: aReturn [
	<generated>
	^ self traverseCFGInstruction: aReturn
]

{ #category : #traversing }
SoGraphTraverser >> traverseSend: aSend [
	<generated>
	^ self traverseOp: aSend
]

{ #category : #traversing }
SoGraphTraverser >> traverseSizeOp: aSizeOp [
	<generated>
	^ self traverseUnsafeOp: aSizeOp
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
SoGraphTraverser >> traverseTrapIfNotInstanceOf: aTrapIfNotInstanceOf [
	<generated>
	^ self traverseBodyInstruction: aTrapIfNotInstanceOf
]

{ #category : #traversing }
SoGraphTraverser >> traverseUnconditionalJump: anUnconditionalJump [
	<generated>
	^ self traverseJump: anUnconditionalJump
]

{ #category : #traversing }
SoGraphTraverser >> traverseUnsafeOp: anUnsafeOp [
	<generated>
	^ self traverseOp: anUnsafeOp
]
