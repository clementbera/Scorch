"
I take as input a primitive descriptor described in SoFullPrimitiveDescriptor.
I generate a descriptor, ahead of time, and put them in SoFullPrimitiveDescriptor class for runtime.
"
Class {
	#name : #SoIntrinsicCompiler,
	#superclass : #Object,
	#instVars : [
		'ast',
		'allVars',
		'fallThrough',
		'encoder',
		'literals'
	],
	#category : #'ScorchingDev-primitive'
}

{ #category : #'known selectors' }
SoIntrinsicCompiler class >> invertMapBinary [
	^ #(#jumpWritable: #jumpReadOnly: 
	 	#jumpYoung: #jumpOld: )
]

{ #category : #'known selectors' }
SoIntrinsicCompiler class >> invertMapTrinary [
	^ #(instanceOf:jumpTrue: #instanceOf:jumpFalse:
	 	instanceOfOneOf:jumpTrue: #instanceOfOneOf:jumpFalse:)
]

{ #category : #'known selectors' }
SoIntrinsicCompiler class >> mappedSelectors [
	^#(ensureEnoughSlots 50 #immCheckPointerAt:put: 150 #immCheckStoreCheckPointerAt:put: 151 #immCheckMaybeContextPointerAt:put: 152 #immCheckMaybeContextStoreCheckPointerAt:put: 153 #immCheckByteAt:put: 154 #immCheckShortAt:put: 155 #immCheckWordAt:put: 156 #immCheckDoubleWordAt:put: 157 #directCall 200 #backjumpAlwaysInterrupt 250)
]

{ #category : #'known selectors' }
SoIntrinsicCompiler class >> trapSelector [
	^#trap
]

{ #category : #'known selectors' }
SoIntrinsicCompiler class >> unmappedSelectors [
	^#(#rawClass 1000 #numSlots 1001 #numBytes 1002 #numShorts 1003 #numWords 1004 #numDoubleWords 1005 #rawNew 1011 #rawNewNoInit 1012 #objectIdentityHash 1020 #smiIdentityHash 1021 #charIdentityHash 1022 #smallfloatIdentityHash 1023 #behaviorIdentityHash 1024 #characterAsInteger 1030 #smallFloatAsInteger 1031 #smiAsFloat 1032 #unforwardNonImmediate 1039 #unforward 1040 #possibleRoot 1041 #smiAdd: 2000 #smiSub: 2001 #smiMul: 2002 #smiDivide: 2003 #smiDiv: 2004 #smiMod: 2005 #smiQuo: 2006 #smiBitAnd: 2016 #smiBitOr: 2017 #smiBitXor: 2018 #smiBitShiftLeft: 2019 #smiBitShiftRight: 2020 #smiGreater: 2032 #smiLess: 2033 #smiGreaterOrEqual: 2034 #smiLessOrEqual: 2035 #smiEquals: 2036 #smiNotEquals: 2037 #rawEqualsEquals: 2038 #rawNotEqualsEquals: 2039 #rawNewColon: 2048 #rawNewColonNoInit: 2049 #pointerAt: 2064 #maybeContextPointerAt: 2065 #byteAt: 2066 #shortAt: 2067 #wordAt: 2068 #doubleWordAt: 2069 #pointerAt:put: 3000 #storeCheckPointerAt:put: 3001 #maybeContextPointerAt:put: 3002 #maybeContextStoreCheckPointerAt:put: 3003 #byteAt:put: 3004 #shortAt:put: 3005 #wordAt:put: 3006 #doubleWordAt:put: 3007 #backjumpNoInterrupt 6000 #jumpWritable: 7016 #jumpReadOnly: 7017 #jumpYoung: 7018 #jumpOld: 7019 #instanceOf:jumpTrue: 8000 #instanceOf:jumpFalse: 8001 #instanceOfOneOf:jumpTrue: 8002 #instanceOfOneOf:jumpFalse: 8003)
]

{ #category : #compiling }
SoIntrinsicCompiler >> compile: source [
	ast := RBParser parseMethod: source contents.
	ast acceptVisitor: self.
	^ self endMethod
	
]

{ #category : #compiling }
SoIntrinsicCompiler >> compileAllAsString: methods [
	^String streamContents: [ :s |
		methods do: [ :m |
			 s tab.
			 s << (self compileAsString: m sourceCode).
			 s cr ] ]
]

{ #category : #compiling }
SoIntrinsicCompiler >> compileAsString: source [
	ast := RBParser parseMethod: source contents.
	ast acceptVisitor: self.
	^ self endString
	
]

{ #category : #private }
SoIntrinsicCompiler >> endMethod [
	| cm header |
	literals addLast: ast selector.
	literals addLast: fallThrough.
	literals := literals asArray.
	header := (CompiledMethod headerFlagForEncoder: EncoderForSistaV1) +	(ast selector numArgs bitShift: 24) +
		(allVars size bitShift: 18) +
		literals size.
	cm := (CompiledMethodTrailer new sourceCode: ast sourceCode) 
		createMethod: encoder bytecodes size 
		class: CompiledMethod 
		header: header.
	(WriteStream with: cm)
		position: cm initialPC - 1;
		nextPutAll: encoder bytecodes.
	literals withIndexDo: [:obj :i | cm literalAt: i put: obj].
	cm needsFrameSize: 3. "(trinary op implemented max)"
	^ cm
]

{ #category : #private }
SoIntrinsicCompiler >> endString [
	| cm |
	cm := self endMethod.
	^ String streamContents: [ :s |	
		s << '('.
		cm header printOn: s.
		s << ' '.
		cm literals printOn: s.
		s << ' '.
		encoder bytecodes printOn: s.
		s << ')' ]
]

{ #category : #checks }
SoIntrinsicCompiler >> ensureMappedSelectorCorrect: send [ 
	| descr num |
	descr := self class mappedSelectors.
	num := descr at: (descr indexOf: send selector) + 1.
	num < 50 ifTrue: [ ^ self ensureNullary: send ].
	num < 200 ifTrue: [ 
		send selector numArgs = (num // 50 - 1)
			ifFalse: [ ^ self parseError: send ]
			ifTrue: [ ^ self ] ].
	self parseError: send
]

{ #category : #checks }
SoIntrinsicCompiler >> ensureMethodCorrect: method [
	method  lastIsReturn ifFalse: [ ^ self error: 'prim descriptors end with explicit return (^self or ^#fallThrough)' ].
	
]

{ #category : #checks }
SoIntrinsicCompiler >> ensureNullary: send [
	(send receiver isLiteralNode and: [ send receiver value = #null ])
		ifFalse: [ self parseError: 'nullary operation ' , send selector , ' on non #null object' ]
]

{ #category : #checks }
SoIntrinsicCompiler >> ensureUnmappedSelectorCorrect: send [
	"Always correct"
	| descr num |
	descr := self class unmappedSelectors.
	num := descr at: (descr indexOf: send selector) + 1.
	num < 1000 ifTrue: [ ^ self ensureNullary: send ].
	num < 6000 ifTrue: [ 
		send selector numArgs = (num // 1000 - 1)
			ifFalse: [ ^ self parseError: send ]
			ifTrue: [ ^ self ] ].
	self parseError: send
]

{ #category : #visiting }
SoIntrinsicCompiler >> generateBlock: block [
	| outerEncoder bytes |
	outerEncoder := encoder.
	allVars := allVars , (block arguments collect: #name).
	encoder := OpalEncoderForSistaV1 new.
	encoder stream: (ByteArray new: 20) writeStream.
	block body acceptVisitor: self.
	bytes := encoder bytecodes.
	encoder := outerEncoder.
	^ bytes
]

{ #category : #private }
SoIntrinsicCompiler >> numFor: sel in: col [
	^ col at: (col indexOf: sel) + 1
]

{ #category : #checks }
SoIntrinsicCompiler >> parseError: msg [
	self error: 'PrimitiveDescriptorCompiler does not recognize ' , msg selector , ' and therefore cannot compile the template.'
]

{ #category : #visiting }
SoIntrinsicCompiler >> pushIfEffect: node [
	node parent isSequence ifTrue: [encoder genPushSpecialLiteral: nil] . "dummy value for the pop..."
	
]

{ #category : #private }
SoIntrinsicCompiler >> pushLiteral: lit [
	literals add: lit.
	encoder genPushLiteral: (literals indexOf: lit) - 1
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitArrayNode: arrayNode [ 
	"For instanceOfOneOf:..."
	self pushLiteral: (arrayNode statements collect: [ :each | Smalltalk globals at: each name ]) asArray.
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitAssignmentNode: assign [ 
	| idx |
	assign value acceptVisitor: self.
	idx := (allVars indexOf: assign variable name) - 1.
	encoder genStoreTemp: idx
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitBinaryJump: msg selector: selector [ 
	"we need to invert the jump. Everything is push on stack except the jump size"
	| realJump num bytes |
	msg parent isSequence ifFalse: [ self error: 'branch for effect only' ].
	self class invertMapBinary pairsDo: [ :jmp :invJmp |
		selector == jmp ifTrue: [ realJump := invJmp ].
		selector == invJmp ifTrue: [ realJump := jmp ] ].
	num := self numFor: realJump in: self class unmappedSelectors.
	bytes := self generateBlock: msg arguments last.
	encoder genPushIntegerLong: bytes size.
	encoder genCallInlinePrimitive: num.
	encoder stream nextPutAll: bytes.
	
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitBlockNode: node [
	"should be inlined, do nothing"
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitIfBoolean: msg [ 
	| realJump bytes |
	msg parent isSequence ifFalse: [ self error: 'branch for effect only' ].
	msg selector = #ifTrue: ifTrue: [ realJump := #genBranchPopFalse: ].
	msg selector = #ifFalse: ifTrue: [ realJump := #genBranchPopTrue: ].
	bytes := self generateBlock: msg arguments last.
	encoder perform: realJump with: bytes size.
	encoder stream nextPutAll: bytes.
	
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitIfBooleanDouble: msg [ 
	| realJump bytes1 bytes2 effectOnly |
	effectOnly := msg parent isSequence.
	msg selector = #ifTrue:ifFalse: ifTrue: [ realJump := #genBranchPopFalse: ].
	msg selector = #ifFalse:ifTrue: ifTrue: [ realJump := #genBranchPopTrue: ].
	bytes1:= self generateBlock: msg arguments first.
	bytes2 := self generateBlock: msg arguments last.
	encoder perform: realJump with: bytes1 size + 3.
	encoder stream nextPutAll: bytes1.
	effectOnly ifTrue: [ encoder genPop ] ifFalse: [ encoder genNop ].
	encoder genJumpLong: bytes2 size + 1.
	encoder stream nextPutAll: bytes2.
	effectOnly ifTrue: [ encoder genPop ] ifFalse: [ encoder genNop ].
	
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitLiteralNode: literalNode [ 
	literalNode value == #null ifTrue: [ ^ self ]. "nullary opcodes, #null receiver for parser compatibility"
	(#(1 0 nil true false) includes: literalNode value) ifTrue: [ ^ encoder genPushSpecialLiteral: literalNode value  ].
	literalNode value isInteger ifTrue: [ ^ encoder genPushInteger: literalNode value ].
	self pushLiteral: literalNode value
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitMapped: msg [ 
	| num |
	num := self numFor: msg selector in: self class mappedSelectors.
	encoder genCallMappedInlinedPrimitive: num
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitMessageNode: msg [ 
	| sel |
	
	msg selector = #flag: ifTrue: [ ^ self ].
	
	msg receiver acceptVisitor: self.
	msg arguments do: [:each | each acceptVisitor: self].
	
	sel := msg selector.
	
	"trap"
	sel = self class trapSelector ifTrue: [ 
		self ensureNullary: msg.
		^ self visitTrap: msg ].
	
	"mapped -> error"
	(self class mappedSelectors includes: sel) ifTrue: [ 
		self ensureMappedSelectorCorrect: msg.
		^ self visitMapped: msg ].
	
	"unmapped -> check"
	(self class unmappedSelectors includes: sel) ifTrue: [ 
		self ensureUnmappedSelectorCorrect: msg.
		^ self visitUnmapped: msg ].
	
	"loop -> check"
	(#(to:by:noInterruptDo: to:by:alwaysInterruptDo:) includes: sel) ifTrue: [ 
		^ self visitUnsafeLoop: msg ].
	
	"IfTrue ifFalse"
	(#(ifTrue: ifFalse:) includes: sel) ifTrue: [ 
		^self visitIfBoolean: msg ].
	(#(ifTrue:ifFalse: ifFalse:ifTrue:) includes: sel) ifTrue: [ 
		^self visitIfBooleanDouble: msg ].
	
	"binary branch -> check"	
	(sel beginsWith: 'if') ifTrue: [ 
		| newSel |
		newSel := (#jump ,(sel allButFirst: 2)) asSymbol.
		(self class unmappedSelectors includes: newSel) ifTrue: [ 
			^ self visitBinaryJump: msg selector: newSel ] ].
	
	"trinary branch -> check"
	(sel beginsWith: 'instance') ifTrue: [
		| idx newSel |
		idx := sel indexOf: $:.
		newSel := ((sel first: idx) , #jump , (sel last: sel size - idx - 2)) asSymbol.
		(self class unmappedSelectors includes: newSel) ifTrue: [
			^ self visitTrinaryJump: msg selector: newSel ] ].
	
	^ self parseError: msg
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitMethodNode: method [
	self ensureMethodCorrect: method.
	fallThrough := false.
	literals := OrderedCollection new.
	allVars := method arguments collect: #name.
	encoder := OpalEncoderForSistaV1 new.
	encoder stream: (ByteArray new: 20) writeStream.
	method body acceptVisitor: self
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitReturnNode: ret [
	(ret value isLiteralNode and: [ ret value value = #fallThrough ]) ifTrue: [ 
		fallThrough := true.
		encoder genNop. "to map for decompilation"
		^ self ].
	ret value acceptVisitor: self.
	encoder genReturnTop.
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitSelfNode: selfNode [ 
	encoder genPushReceiver.
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitSequenceNode: seq [ 
	allVars := allVars , (seq temporaries collect: #name).
	seq statements withIndexDo: [ :each :index | 
		each acceptVisitor: self.
		index = seq statements size ifFalse: [ 
			(each isMessage 
				and: [ (each selector beginsWith: 'if')
				or: [ each selector beginsWith: 'instance' ] ])
				ifFalse: [ encoder genPop ] ] ]
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitTrap: msg [ 
	encoder genTrap
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitTrinaryJump: msg selector: selector [ 
		"we need to invert the jump. Everything is push on stack except the jump size"
	| realJump num bytes |
	msg parent isSequence ifFalse: [ self error: 'branch for effect only' ].
	self class invertMapTrinary pairsDo: [ :jmp :invJmp |
		selector == jmp ifTrue: [ realJump := invJmp ].
		selector == invJmp ifTrue: [ realJump := jmp ] ].
	num := self numFor: realJump in: self class unmappedSelectors.
	bytes := self generateBlock: msg arguments last.
	encoder genPushIntegerLong: bytes size.
	encoder genCallInlinePrimitive: num.
	encoder stream nextPutAll: bytes.
	
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitUnmapped: msg [
	| num |
	num := self numFor: msg selector in: self class unmappedSelectors.
	encoder genCallInlinePrimitive: num
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitUnsafeLoop: msg [ 
	msg selector = #to:by:noInterruptDo: ifTrue: [ ^ self visitUnsafeToByDo: msg backjump: #backjumpNoInterrupt ].
	msg selector = #to:by:alwaysInterruptDo: ifTrue: [ ^ self visitUnsafeToByDo: msg backjump: #backjumpAlwaysInterrupt ].
	self parseError: 'to implement'.
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitUnsafeToByDo: msg backjump: selector [
	| pos idx num bytes bjSize |
	"Bytecode is correct and decompilation ignores all the bullshit, multiple unused bytes generated."
	msg arguments last isBlock ifFalse: [ ^ self parseError: 'invalid to:by:uncheckedDo:' ].
	allVars := allVars , {msg arguments last arguments first name . (msg arguments last arguments first name , 'Limit') }.
	idx := allVars size - 2.
	encoder genPop. "by:"
	encoder genStorePopTemp: idx + 1. "limit"
	encoder genStorePopTemp: idx. "iterator init value"
	pos := encoder stream position. 
	encoder genPushTemp: idx. "iterator"
	encoder genPushTemp: idx + 1. "limit"
	"Cmp"
	num := self numFor: #smiLessOrEqual: in: self class unmappedSelectors.
	encoder genCallInlinePrimitive: num.
	"branch + block"
	bytes := self generateBlock: msg arguments last.
	encoder genBranchPopFalse: bytes size + 1 + 9 + 7. "pop - incr - bjSize."
	encoder stream nextPutAll: bytes.
	encoder genPop.
	"Increment - we make sure this is 7 bytes"
	encoder genPushTemp: idx. "iterator"
	self assert: idx < 12. "else incorrect bytes"
	encoder genPushIntegerLong: msg arguments second value. "increment"
	num := self numFor: #smiAdd: in: self class unmappedSelectors.
	encoder genCallInlinePrimitive: num.
	encoder genStorePopTemp: idx. "store incr"
	bjSize := 7 "backjump size" + encoder stream position - pos.
	encoder genPushIntegerLong: bjSize negated.
	"backjump"
	selector ~= #backjumpAlwaysInterrupt 
		ifTrue: [ 
			num := self numFor: selector in: self class unmappedSelectors.
			encoder genCallInlinePrimitive: num ]
		ifFalse: [ 
			encoder genNop. "num Byte correction"
			num := self numFor: selector in: self class mappedSelectors.
			encoder genCallMappedInlinedPrimitive: num ].
	"in case for value"
	msg receiver acceptVisitor: self.
	
	
	
	
]

{ #category : #visiting }
SoIntrinsicCompiler >> visitVariableNode: var [ 
	"self is handled separatedly."
	| idx |
	idx := (allVars indexOf: var name) - 1.
	idx = -1 ifTrue: ["class for instanceOf:" 
		^self pushLiteral: (Smalltalk globals at: var name).].
	encoder genPushTemp: idx
]
