"
I parse a bytecode method and builds a Control Flow Graph (CFG) composed of BasicBlocks.  BasicBlocks are a sequence of instructions. As the bytecode is stack based whereas the sista intermediate representation is TAC, I also spill when required stack location.

I am typically used either to decompile a new method/block OR to decompile a method/block while inlining, in which case I properly generate returns, receiver and arguments depending on the inlined values.

Other features:
- I assign branch and send data informations to send and branch nodes
- The control flow graph decompiled is canonicalized so that loops entry are predecessed only by a single forward jump and a single backward jumps. 

Instance Variables
	arguments < Array of Instructions > arguments of the method / block. If they are unknown, the decompiler ask the builder to create new abstract arguments. In case of inlining, they are known and the decompiler use the known values.
	callerDeoptInfo < DeoptimizationInformation> nil if non inlining. If inlining, the information of the enclosing send, used to correctly generate inner deoptimizationInformation.
	currentLoopDepth < Smi > current depth in the loops (including loops from outer code in case of inlining). Assigned to sends and potentially used as a heuristic by the inliners.
	builder <Builder> used to create new scorch nodes
	currentPC <Smi> pc of the current instruction parsed (first byte pc). This is different than pc (iv from superclass) which corresponds to the pc of the next instruction.
	receiver <Instruction> receiver of the codeNode. If unknown, a receiver node is created. In case of inlining, the actual receiver is stored there.
	sendAndBranchDataHandler <MetadataReader> used to read the metadata from the machine code provided by the VM and assigns it to the instructions.
	simStack < Array > a simulated stack with ScorchNodes to emulate the stack behavior (used to build the CFG)
	fixups < Array (pc -> nil|Fixup) > A fixup is a control flow merge point in the bytecode, this collection allows jumps to be correctly decompiled.
	scopeMarker <Object> unique id representing the context of the code being decompiled. In many cases, the context is represented by multiple ObjectState in deopt metadata. The unique id allows to check between 2 ObjectState if they correspond to the same object. This is used, for example, to identify blockClosure outerContext during hybrid execution (deoptimized code mixed with optimized code)
	context <Context | nil> context of the method to optimise, used to provide hint on types in some cases. Nil if no hints are available.
	
"
Class {
	#name : #SoDecompiler,
	#superclass : #SoInstructionStream,
	#instVars : [
		'arguments',
		'callerDeoptInfo',
		'currentLoopDepth',
		'builder',
		'currentPC',
		'receiver',
		'sendAndBranchDataHandler',
		'simStack',
		'fixups',
		'scopeMarker',
		'context'
	],
	#pools : [
		'SoMemoryManagerConstants',
		'SoSpecialSelectorConstants'
	],
	#category : #'Scorching-Decompiler'
}

{ #category : #public }
SoDecompiler class >> decompile: compiledCode [ 
	^ (self on: compiledCode) decompile
]

{ #category : #public }
SoDecompiler class >> decompile: compiledCode context: context [
	^ (self on: compiledCode) 
		initializeWithContext: context;
		classToInstall: context receiver class;
		decompile 
]

{ #category : #public }
SoDecompiler class >> decompile: compiledCode inliningWith: inliner [
	^ (self on: compiledCode) 
		setUpWithInliner: inliner;
		decompile;
		nodeToReturn
]

{ #category : #fixups }
SoDecompiler >> addAndFillPhis: basicBlock [
	"stackp may be altered if the basicBlock decompiled before is not a predecessor of the currentBasicBlock. We need to fix stackp."
	self restoreStackp: basicBlock predecessors anyOne.
	self addPhis: basicBlock.
	self fillPhis: basicBlock.
]

{ #category : #fixups }
SoDecompiler >> addPhis: basicBlock [
	"TempVector are assigned only once, no phis needed"
	self firstTempIndex to: stackp do: [ :i |
		(simStack at: i) isTempVector ifFalse: [ simStack at: i put: builder phi ] ]. 
]

{ #category : #private }
SoDecompiler >> argumentAssigment: index [
	SoArgumentAssigment signal: 'Argument number ' , index asString , ' was assigned in ' , self method asString 
]

{ #category : #accessing }
SoDecompiler >> arguments [
	<generated>
	^ arguments
]

{ #category : #accessing }
SoDecompiler >> arguments: aValue [
	<generated>
	arguments := aValue
]

{ #category : #'opcodes-sends' }
SoDecompiler >> arithmeticSend: selector numArgs: numArgs [
	(InlinedSmiSelectors includes: selector) ifTrue: [ 
		^ sendAndBranchDataHandler 
			addSendDataAndSmiEntry: (self basicSend: selector numArgs: numArgs) 
			pc: currentPC ].
	(HintInlinedSmiSelectors includes: selector) ifTrue: [ 
		(self stackTop isSmiConstant or: [ (simStack at: stackp - 1) isSmiConstant ]) ifTrue: [ 
			^ sendAndBranchDataHandler 
				addSendDataAndSmiEntry: (self basicSend: selector numArgs: numArgs) 
				pc: currentPC ] ].
	^ self send: selector numArgs: numArgs
	
]

{ #category : #'opcodes-control flow' }
SoDecompiler >> backjump: delta [
	| fixup |
	fixup := fixups at: self shiftedPC + delta.
	fixup backjumpFixedUp.
	self ensureFixupAt: self shiftedPC.
	self saveLiveVariables.
	fixup yetToMerge > 0 ifTrue:
		[ "Multiple back jump to the same target pc, we've 
		not parsed the others."
		  fixup ensureBackJumpBasicBlock.
		  ^ builder jump: fixup backJumpBasicBlock ].
	currentLoopDepth := currentLoopDepth - 1.
	fixup backJumpBasicBlock ifNotNil: [ :bjbb |
		"Multiple back jump to the same pc, we've
		reached the last one. Canonicalization."
		builder jump: fixup backJumpBasicBlock.
		builder switchToBasicBlock: fixup backJumpBasicBlock.
		self addAndFillPhis: fixup backJumpBasicBlock.
		self saveLiveVariables ].
	self recordSunkContext: (builder backjump: fixup targetBasicBlock).
	self fillPhis: fixup targetBasicBlock.
	
]

{ #category : #'opcodes-sends' }
SoDecompiler >> basicSend: selector numArgs: numArgs [ 

	| send |
	send := builder send: selector receiver: (simStack at: stackp - numArgs) args: (self copyStack: numArgs).
	self drop: numArgs + 1.
	self recordSunkContext: send.
	builder codeNode decompSends add: send.
	self push: send.
	send loopDepth: currentLoopDepth.
	^ send
]

{ #category : #'opcodes-control flow' }
SoDecompiler >> branch [
	| jumpInstr |
	jumpInstr := builder branch: self stackTop.
	self drop.
	self recordSunkContext: jumpInstr.
	^ jumpInstr
]

{ #category : #accessing }
SoDecompiler >> builder [
	<generated>
	^ builder
]

{ #category : #accessing }
SoDecompiler >> builder: aValue [
	<generated>
	builder := aValue
]

{ #category : #'opcodes-sends' }
SoDecompiler >> callPrimitive: primitiveIndex [
	builder codeNode primitive: (SoPrimitive newForMethod: self method)
]

{ #category : #accessing }
SoDecompiler >> callerDeoptInfo [
	<generated>
	^ callerDeoptInfo
]

{ #category : #accessing }
SoDecompiler >> callerDeoptInfo: aValue [
	<generated>
	callerDeoptInfo := aValue
]

{ #category : #fixups }
SoDecompiler >> canonicalizeLoopForwardEntries: fixup [
	| loopStart |
	"loop start will be the back jump target"
	loopStart := SoBasicBlock new.
	builder switchToBasicBlock: fixup targetBasicBlock.
	self addAndFillPhis: fixup targetBasicBlock.
	fixup targetBasicBlock: loopStart.
	self saveLiveVariables.
	self splitCriticalEdges.
]

{ #category : #initialization }
SoDecompiler >> classToInstall: classToInstall [
	"There could be a super send just before and we can't overwrite things just like that."
	(classToInstall lookupSelector: self method selector) == self method ifFalse: [ ^self ].
	builder codeNode classToInstall: classToInstall
]

{ #category : #private }
SoDecompiler >> closureClass: compiledBlock ignoreOuterContext: ignoreOuterContext [
	ignoreOuterContext ifTrue: [ ^ SoCreateFullBlock ].
	callerDeoptInfo ifNil: [ ^SoCreateContextFullBlock ].
	^ (SoBlockNLRScanner scan: compiledBlock)
		ifTrue: [ SoCreateNLRFullBlock ]
		ifFalse: [ SoCreateContextFullBlock ] 
]

{ #category : #'sunk objects' }
SoDecompiler >> closureRef [
	^ SoConstant new
]

{ #category : #accessing }
SoDecompiler >> codeNodeClass [
	self subclassResponsibility 
]

{ #category : #private }
SoDecompiler >> copyStack: count [ 
	^ simStack copyFrom: stackp - count + 1 to: stackp
]

{ #category : #accessing }
SoDecompiler >> currentLoopDepth [
	<generated>
	^ currentLoopDepth
]

{ #category : #accessing }
SoDecompiler >> currentLoopDepth: aValue [
	<generated>
	currentLoopDepth := aValue
]

{ #category : #accessing }
SoDecompiler >> currentPC [
	<generated>
	^ currentPC
]

{ #category : #accessing }
SoDecompiler >> currentPC: aValue [
	<generated>
	currentPC := aValue
]

{ #category : #public }
SoDecompiler >> decompile [
	fixups := SoBackjumpScanner scan: self method.
	self initializeWithCode.
	self ensureParametersExist.
	self initSimStack.
	self interpret.
	^ builder terminate
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> doDup [
	self push: self stackTop
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> doPop [
	self drop
]

{ #category : #'opcodes-control flow' }
SoDecompiler >> ensureFixupAt: shiftedPC [
	(fixups at: shiftedPC) ifNotNil: [ :it | ^ it ].
	^ fixups at: shiftedPC put: SoDeadFixup new.
]

{ #category : #'opcodes-control flow' }
SoDecompiler >> ensureJumpFixupAt: shiftedPC [
	(fixups at: shiftedPC) ifNotNil: [ :it | it isDeadFixup ifFalse: [ ^ it ] ].
	^ fixups at: shiftedPC put: SoJumpFixup new.
]

{ #category : #initialization }
SoDecompiler >> ensureParametersExist [
	"values initialized in case of inlining"
	receiver ifNil: [ receiver := builder receiver ].
	self setReceiverType.
	arguments ifNotNil: [ ^ self ]. 
	arguments := (0 to: self method numArgs - 1) collect: 
		[ :numArg | (builder arg: numArg) ].
	context ifNil: [ ^ self ].
	arguments do: [ :arg | 
		arg type: (SoSingleHintType for: (context objectClass: (context tempAt: arg index + 1))) ]
]

{ #category : #fixups }
SoDecompiler >> fillPhis: basicBlock [
	builder fillPhi: basicBlock firstInstr withValues: basicBlock predecessors
]

{ #category : #accessing }
SoDecompiler >> firstTempIndex [
	^ self method numArgs + self numCopied + 1
]

{ #category : #accessing }
SoDecompiler >> fixups [
	<generated>
	^ fixups
]

{ #category : #accessing }
SoDecompiler >> fixups: aValue [
	<generated>
	fixups := aValue
]

{ #category : #private }
SoDecompiler >> hasInstVar: value [
	^ value class instSpec = 1 or: [ value class instSpec = 3 ]
]

{ #category : #initialization }
SoDecompiler >> initSimStack [
	simStack := Array new: self method frameSize.
	arguments do: [ :arg | self push: arg ].
	self copiedValues do: [ :copied | self push: copied ].
	1 to: (self method numTemps - self copiedValues size - arguments size) do: [ :i | 
		self push: (builder constant: nil) ].
]

{ #category : #initialization }
SoDecompiler >> initialize [
	super initialize.
	currentLoopDepth := 1.
	builder := SoBuilder on: self codeNodeClass.
	scopeMarker := SoSunkObjectMarker new.
	stackp := 0.
	sendAndBranchDataHandler := SoMetadataReader new.
]

{ #category : #initialization }
SoDecompiler >> initializeWithCode [
	builder codeNode 
		compiledCode: self method;
		bytecodeApproximateSize: self method bytecodeSize.
]

{ #category : #initialization }
SoDecompiler >> initializeWithContext: ctxt [
	context := ctxt
]

{ #category : #fixups }
SoDecompiler >> interpret [
	| endPC skip |
	endPC := self method endPC.
	[currentPC := pc. pc > endPC] whileFalse: 
		[skip := false.
		(fixups at: self shiftedPC) ifNotNil: [ :fix |
			skip := fix isDeadFixup.
			fix reachedFrom: self ].
		 skip ifFalse: [self interpretNextInstructionFor: self] ]
	
]

{ #category : #private }
SoDecompiler >> isReadOnlyObject: literal [
	"We can remove that method when patched.
	
	^ literal isReadOnlyObject"
	^ true
]

{ #category : #'opcodes-control flow' }
SoDecompiler >> jump: delta [
	delta < 0
		ifTrue: [ self backjump: delta ]
		ifFalse: [ self jumpForward: delta ]
]

{ #category : #'opcodes-control flow' }
SoDecompiler >> jump: delta if: boolean [
	boolean
		ifTrue: [ self jumpTrue: delta ]
		ifFalse: [ self jumpFalse: delta ]
]

{ #category : #'opcodes-control flow' }
SoDecompiler >> jumpFalse: delta [ 
	| jumpInstr data |
	jumpInstr := self branch.
	jumpInstr trueBasicBlock: (self ensureJumpFixupAt: self shiftedPC) targetBasicBlock.
	jumpInstr falseBasicBlock: (self ensureJumpFixupAt: self shiftedPC + delta) targetBasicBlock.
	data := sendAndBranchDataHandler getBranchData: currentPC.
	jumpInstr trueCount: data second.
	jumpInstr falseCount: data first
]

{ #category : #'opcodes-control flow' }
SoDecompiler >> jumpForward: delta [
	| fixup |
	fixup := self ensureJumpFixupAt: self shiftedPC + delta.
	builder jump: fixup targetBasicBlock.
	self ensureFixupAt: self shiftedPC.
]

{ #category : #'opcodes-control flow' }
SoDecompiler >> jumpTrue: delta [
	| jumpInstr data |
	jumpInstr := self branch.
	jumpInstr trueBasicBlock: (self ensureJumpFixupAt: self shiftedPC + delta) targetBasicBlock.
	jumpInstr falseBasicBlock: (self ensureJumpFixupAt: self shiftedPC) targetBasicBlock.
	data := sendAndBranchDataHandler getBranchData: currentPC.
	jumpInstr trueCount: data first.
	jumpInstr falseCount: data second
]

{ #category : #initialization }
SoDecompiler >> method: method pc: startPC [
	super method: method pc: startPC.
	sendAndBranchDataHandler sendAndBranchData: method sendAndBranchData
]

{ #category : #'opcodes-control flow' }
SoDecompiler >> methodReturnTop [
	builder localReturn: self stackTop.
	self ensureFixupAt: self shiftedPC.
]

{ #category : #accessing }
SoDecompiler >> nodeToReturn [
	^ builder codeNode 
]

{ #category : #accessing }
SoDecompiler >> numCopied [
	^ self copiedValues size
]

{ #category : #'opcodes-sends' }
SoDecompiler >> pointerEquals [
	| node |
	node := builder pointerEquals: (simStack at: stackp - 1) with: self stackTop.
	self drop: 2.
	self push: node.
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> popIntoLiteralVariable: assoc [ 
	builder store: self stackTop global: assoc.
	self drop
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> popIntoReceiverVariable: index [
	builder store: self stackTop instVar: index of: receiver.
	self drop
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> popIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	"can be an external inst var or a temp vect access"
	| varHolder |
	varHolder := simStack at: tempVectorIndex + 1.
	varHolder isTempVector ifFalse: [ self error: 'shoulf be a temp vector' ].
	builder 
		store: self stackTop 
		indirectTemp: remoteTempIndex 
		vector: varHolder.
	self drop
]

{ #category : #private }
SoDecompiler >> push: node [
	stackp + 1 > simStack size ifTrue: [ self stackOverflow ].
	^ simStack at: self push put: node
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> pushActiveContext [
	self push: builder context.
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> pushClosureCopyNumCopiedValues: numCopied numArgs: numArgs blockSize: blockSize [
	SoOldBlockModel signal: 'new block model supported. See full block closure'
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> pushConsArrayWithElements: numOfElems [
	| array |
	array := builder array: (self copyStack: numOfElems).
	self drop: numOfElems.
	self push: array
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> pushConstant: value [
	"Literal with instance variables, i.e., ScaledDecimal, are a problem for the back-end
	as we can end up with a case with inst var read of a literal which is not supported.
	We need to change thiis for clean blocks."
	self push: ((self isReadOnlyObject: value)
		ifTrue: [ builder constant: value ]
		ifFalse: [ builder mutableLiteral: value ])
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> pushContextReceiverVariable: index [
	self push: (builder contextInstVar: index of: receiver)
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> pushFullClosure: compiledBlock numCopied: numCopied receiverOnStack: recOnStack ignoreOuterContext: ignoreOuterContext [
	| closureClass copiedValues rcvr blockInstr |
	closureClass := self closureClass: compiledBlock ignoreOuterContext: ignoreOuterContext.
	copiedValues := self copyStack: numCopied.
	self drop: numCopied.
	recOnStack 
		ifTrue: [ rcvr := self stackTop. self drop ]
		ifFalse: [ rcvr := receiver ].
	self push: (blockInstr := builder fullBlock: compiledBlock receiver: rcvr copiedValues: copiedValues class: closureClass).
	blockInstr outerContextMarker: self scopeMarker.
	blockInstr hasNLR ifFalse: [ ^ self ]. 
	builder addFakeConstant: blockInstr fakeConstant fakeBasicBlock: blockInstr fakeBasicBlock.
	blockInstr nlrPhi: builder returnPhi.
		
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> pushLiteralVariable: value [ 

	self push: (builder global: value).
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> pushNewArrayOfSize: size [
	self push: (builder createTempVector: size).
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> pushReceiver [
	self push: receiver
			
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> pushReceiverVariable: index [ 
	| instVarRead currentValue |
	instVarRead := builder instVar: index of: receiver.
	self push: instVarRead.
	context ifNotNil: [ 
		currentValue := context object: context receiver instVarAt: index + 1.
		self setTypeTo: instVarRead fromValue: currentValue ]
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> pushRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [ 
	"Either an indirect temp access, or an external inst var access"
	| varHolder indirectTmpRead currentValue |
	varHolder := simStack at: tempVectorIndex + 1.
	varHolder isTempVector ifFalse: [ self error: 'should be a temp vector' ].
	indirectTmpRead := builder indirectTemp: remoteTempIndex vector: varHolder.
	self push: indirectTmpRead.
	"Seemingly too unreliable...
	context ifNotNil: [ 
		currentValue := (context at: tempVectorIndex + 1) at: remoteTempIndex + 1.
		self setTypeTo: indirectTmpRead fromValue: currentValue ]"
	
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> pushTemporaryVariable: index [
	
	self push: (simStack at: index + 1)
]

{ #category : #fixups }
SoDecompiler >> reachBackjumpFixup: fixup [
	
	self saveLiveVariables.
	"If other predecessors than the fall through path, needs canonicalization"
	fixup targetBasicBlock predecessors size > 0 ifTrue: 
		[ self canonicalizeLoopForwardEntries: fixup ].
	self recordSunkContext: builder loopHead.
	builder switchToBasicBlock: fixup targetBasicBlock.
	currentLoopDepth := currentLoopDepth + 1.
	self 
		assert: fixup targetBasicBlock predecessors size = 1
		description: 'decompilation for a backjump looks fishy'.
	self restoreStackp: fixup targetBasicBlock predecessors anyOne.
	self addPhis: fixup targetBasicBlock.
]

{ #category : #fixups }
SoDecompiler >> reachDeadFixup: fixup [
	"We've reached dead code.
	We look for the next fixup to resume decompilation there.
	If there is no more fixups, the end of the compiled code is dead."
	| start |
	start := fixups indexOf: fixup.
	start + 1 to: fixups size do: [ :i |
		(fixups at: i) ifNotNil: [ :fix |
			^ pc := i + self method initialPC - 1 ] ].
	pc := self method endPC + 1
]

{ #category : #fixups }
SoDecompiler >> reachJumpFixup: fixup [
	| prevBasicBlock |
	self saveLiveVariables.
	prevBasicBlock := builder currentBasicBlock.
	builder switchToBasicBlock: fixup targetBasicBlock.
	self 
		assert: fixup targetBasicBlock predecessors size > 0
		description: 'decompilation for a jump forward looks fishy'.
	fixup targetBasicBlock predecessors size = 1 ifTrue: 
		[ ^ self restoreStackFrom: prevBasicBlock to: fixup targetBasicBlock ].
	self addAndFillPhis: fixup targetBasicBlock.
	self splitCriticalEdges.
]

{ #category : #accessing }
SoDecompiler >> receiver [
	<generated>
	^ receiver
]

{ #category : #accessing }
SoDecompiler >> receiver: aValue [
	<generated>
	receiver := aValue
]

{ #category : #'sunk objects' }
SoDecompiler >> recordSunkContext: node [
	
	| ctxt |
	ctxt := SoPointerSunkObjectState new
		theClass: ContextClass;
		marker: self scopeMarker;
		fixedFields: { 
			callerDeoptInfo ifNil: [ SoConstant new ] ifNotNil: [ :deopt | deopt sunkObjects first marker ].
			SoPCConstant new instrPC: currentPC; nextPC: pc; yourself.
			SoConstant new constant: stackp.
			SoConstant new constant: self method.
			self closureRef.
			receiver };
		variableFields: (self copyStack: stackp).
	node deoptInfo: (SoDeoptimizationInformation new addSunkObject: ctxt).
	callerDeoptInfo ifNotNil: 
		[ :deopt | 
		 	deopt sunkObjects do: [ :sunk |
				node deoptInfo addSunkObject: sunk copy ] ].
	
]

{ #category : #fixups }
SoDecompiler >> restoreStackFrom: prevBasicBlock to: currentBasicBlock [
	"prevBasicBlock is the basicBlock we've just decompiled, 
	by opposition to uniquePredecessor which is the 
	basicblock that should be executed before 
	currentBasicBlock in the control flow"
	
	| uniquePredecessor |
	uniquePredecessor := currentBasicBlock predecessors anyOne.
	uniquePredecessor = prevBasicBlock ifTrue: [ ^ self ]. 
	"We've decompiled code in-between the two basicblocks that may have altered the stack.
	We restore the stack"
	uniquePredecessor lastInstr isJumpAhead 
		ifTrue: [ builder switchBackToBasicBlock: uniquePredecessor ].
	self restoreStackp: uniquePredecessor.
	uniquePredecessor tempData withIndexDo: [ :val :i |
		simStack at: self firstTempIndex + i - 1 put: val ] 
]

{ #category : #fixups }
SoDecompiler >> restoreStackp: predecessor [
	stackp := self firstTempIndex + predecessor tempData size - 1
]

{ #category : #fixups }
SoDecompiler >> saveLiveVariables [
	"Live variables are saved to fill the phis later on 
	and to restore the stack in the case of conditional jumps"
	builder saveLiveVariables: (simStack copyFrom: self firstTempIndex to: self stackp)
]

{ #category : #accessing }
SoDecompiler >> scopeMarker [
	<generated>
	^ scopeMarker
]

{ #category : #accessing }
SoDecompiler >> scopeMarker: aValue [
	<generated>
	scopeMarker := aValue
]

{ #category : #'opcodes-sends' }
SoDecompiler >> send: selector numArgs: numArgs [ 

	| expr |
	expr := self basicSend: selector numArgs: numArgs.
	sendAndBranchDataHandler addSendData: expr pc: currentPC
]

{ #category : #accessing }
SoDecompiler >> sendAndBranchDataHandler [
	<generated>
	^ sendAndBranchDataHandler
]

{ #category : #accessing }
SoDecompiler >> sendAndBranchDataHandler: aValue [
	<generated>
	sendAndBranchDataHandler := aValue
]

{ #category : #'opcodes-sends' }
SoDecompiler >> sendSuper: selector numArgs: numArgs [

	| expr |
	expr := self basicSend: selector numArgs: numArgs.
	sendAndBranchDataHandler addSendData: expr pc: currentPC.
	expr methodClass: self method methodClass
]

{ #category : #initialization }
SoDecompiler >> setReceiverType [
	| cls |
	receiver isReceiver ifFalse: [ ^ self ]. 
	receiver type ifNotNil: [ ^ self ]. "From self send inlining."
	cls := builder codeNode classToInstall.
	receiver type: ((NoStoreCheckTypes includes: cls)
		ifTrue: [ SoKnownType for: cls ]
		ifFalse: [ cls subclasses isEmpty 
					ifTrue: [ SoFinalClassHintType for: cls ]
					ifFalse: [ SoHierarchyHintType for: cls ] ])
	
]

{ #category : #private }
SoDecompiler >> setTypeTo: instruction fromValue: currentValue [ 
	currentValue ifNil: [ "Could be just not initialized, no idea aout that type" ^ self ].
	instruction 
		type: (SoSingleHintType 
			for: (context 
				objectClass: currentValue)) 
]

{ #category : #initialization }
SoDecompiler >> setUpWithInliner: inliner [
	receiver := inliner receiver.
	arguments := inliner arguments.
	callerDeoptInfo := inliner send deoptInfo.
	currentLoopDepth := inliner send loopDepth.
	inliner send hasReliableInlinedRuntimeInformation 
		ifFalse: [ sendAndBranchDataHandler sendAndBranchData: #() ]
]

{ #category : #accessing }
SoDecompiler >> simStack [
	<generated>
	^ simStack
]

{ #category : #accessing }
SoDecompiler >> simStack: aValue [
	<generated>
	simStack := aValue
]

{ #category : #'opcodes-sends' }
SoDecompiler >> specialSend: selector numArgs: numArgs [

	selector == #==
		ifTrue: [ self pointerEquals ]
		ifFalse: [ self send: selector numArgs: numArgs ]
]

{ #category : #fixups }
SoDecompiler >> splitCriticalEdges [
	builder currentBasicBlock predecessors copy do: [ :each |
		each lastInstr isBranch ifTrue: [ self splitEdge: each to: builder currentBasicBlock  ]  ]
]

{ #category : #fixups }
SoDecompiler >> splitEdge: bb1 to: bb2 [
	"Assumes the edge between bb1 and bb2 is critical and split it."
	| split |
	bb1 codeNode addBasicBlock: (split := SoBasicBlock new).
	split firstInstr: (SoJumpAhead from: split to: bb2).
	split lastInstr: split firstInstr.
	bb1 lastInstr replaceSuccessor: bb2 by: split.
	bb2 phisDo: [ :phi |
		phi replaceBasicBlock:  bb1 with: split ].
]

{ #category : #private }
SoDecompiler >> stackOverflow [
	SoStackOverflow signal
]

{ #category : #private }
SoDecompiler >> stackTop [
	^ simStack at: stackp
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> storeIntoLiteralVariable: assoc [ 
	| top |
	top := self stackTop.
	self popIntoLiteralVariable: assoc.
	self push: top
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> storeIntoReceiverVariable: index [ 
	| top |
	top := self stackTop.
	self popIntoReceiverVariable: index.
	self push: top
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> storeIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	| top |
	top := self stackTop.
	self popIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex.
	self push: top
]

{ #category : #'opcodes-data movement' }
SoDecompiler >> storeIntoTemporaryVariable: index [
	
	index < self method numArgs ifTrue: [ self argumentAssigment: index ].
	
	simStack at: index + 1 put: self stackTop.
]
