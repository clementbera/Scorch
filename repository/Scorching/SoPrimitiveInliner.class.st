"
I am a specific inliner version for primitive methods. 

There is a class-side table describing how to inline primitives. The primitive bytecode is generated at development time and stored class-side.
"
Class {
	#name : #SoPrimitiveInliner,
	#superclass : #SoMethodInliner,
	#classVars : [
		'DescriptorCache',
		'PrimitiveDescriptors'
	],
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #constant }
SoPrimitiveInliner class >> byteDescriptors [ 
	<generated>
	"header literals bytes"
	^ self descriptorCacheFrom: #(
	(-1056702462 #(#primSmiAddNoOverflow: false) #[76 64 248 208 135 92])
	(-1056702462 #(#primNotPointerEquals: false) #[76 64 248 16 132 248 247 135 92])
	(-1055916030 #(#primByteAtAllPut: false) #[81 76 248 234 131 81 216 210 209 65 66 248 243 135 239 23 76 65 64 248 188 139 216 65 225 0 232 1 248 208 135 209 225 255 232 226 248 112 151 81 216 76 92])
	(-1073741822 #(#primClass false) #[76 248 232 131 92])
	(-1056702462 #(#primPointerEquals: false) #[76 64 248 16 132 248 246 135 92])
	(-1056702462 #(#primSmiBitShiftRight: false) #[76 80 64 248 209 135 248 228 135 92])
	(-1056702462 #(#primSmiQuoNoOverflowNoZero: false) #[76 64 248 214 135 92])
	(-1039663102 #(#primByteAt:put: false) #[76 64 65 248 188 139 92])
	(-1056702462 #(#primSmiGreaterOrEqual: false) #[64 76 248 243 135 92])
	(-1039663102 #(#primPointerAt:put: false) #[76 64 65 248 185 139 92])
	(-1056702462 #(#primByteAt: false) #[76 64 248 18 136 92])
	(-1056702462 #(#primSmiEquals: false) #[76 64 248 244 135 92])
	(-1056702462 #(#primSmiSubNoOverflow: false) #[76 64 248 209 135 92])
	(-1056702462 #(#primSmiBitShiftLeft: false) #[76 64 248 227 135 92])
	(-1073741822 #(#primByteSize false) #[76 248 234 131 92])
	(-1056702462 #(#primSmiBitAnd: false) #[76 64 248 224 135 92])
	(-1056702462 #(#primSmiMod: false) #[76 64 248 213 135 92])
	(-1004535806 #(#primArrayReplaceFrom:to:with:startingAt: true) #[81 64 248 243 135 239 96 81 67 248 243 135 239 89 65 76 248 233 131 248 243 135 239 79 65 64 248 209 135 67 248 208 135 66 248 233 131 248 243 135 239 61 76 248 17 132 216 67 64 248 209 135 245 4 216 64 65 81 216 214 213 69 70 248 243 135 239 31 76 69 66 68 69 248 208 135 248 16 136 248 184 139 216 69 225 0 232 1 248 208 135 213 225 255 232 218 248 112 151 64 216 76 92 95])
	(-1056702462 #(#primSmiMulNoOverflow: false) #[76 64 248 210 135 92])
	(-1073479678 #(#primHashMultiply false) #[76 225 63 232 255 248 224 135 245 0 216 225 38 232 13 64 248 210 135 225 38 232 13 76 232 14 248 227 135 248 210 135 232 101 64 248 210 135 248 208 135 225 63 232 255 248 224 135 225 64 232 0 248 210 135 248 208 135 92])
	(-1056702462 #(#primSmiDivNoOverflowNoZero: false) #[76 64 248 212 135 92])
	(-1056702462 #(#primSmiBitXor: false) #[76 64 248 226 135 92])
	(-1055653886 #(#primByteEquals: false) #[64 248 16 132 245 1 216 81 76 248 233 131 81 216 211 210 66 67 248 243 135 239 33 76 66 248 16 136 65 66 248 16 136 248 244 135 185 78 92 216 66 225 0 232 1 248 208 135 210 225 255 232 216 248 112 151 81 216 77 92])
	(-1056702462 #(#primSmiNotEquals: false) #[76 64 248 245 135 92])
	(-1073741822 #(#primPointerSize false) #[76 248 233 131 92])
	(-1056702462 #(#primSmiBitOr: false) #[76 64 248 225 135 92])
	(-1056702462 #(#primSmiLess: false) #[76 64 248 241 135 92])
	(-1073741822 #(#primCharacterAsInteger false) #[76 248 6 132 92])
	(-1056702462 #(#primSmiLessOrEqual: false) #[76 64 248 243 135 92])
	(-1004535806 #(#primByteReplaceFrom:to:with:startingAt: true) #[81 64 248 243 135 239 91 81 67 248 243 135 239 84 65 76 248 234 131 248 243 135 239 74 65 64 248 209 135 67 248 208 135 66 248 234 131 248 243 135 239 56 67 64 248 209 135 245 4 216 64 65 81 216 214 213 69 70 248 243 135 239 31 76 69 66 68 69 248 208 135 248 18 136 248 188 139 216 69 225 0 232 1 248 208 135 213 225 255 232 218 248 112 151 64 216 76 92 95])
	(-1056702462 #(#primPointerAt: false) #[76 64 248 16 136 92])
	(-1056702462 #(#primSmiGreater: false) #[64 76 248 241 135 92])
	)
]

{ #category : #utils }
SoPrimitiveInliner class >> descriptorCacheFrom: array [
	"the array is in a block to avoid repetitive execution."
	DescriptorCache ifNotNil: [ ^ DescriptorCache ].
	^ DescriptorCache := (array collect: [ :each |
		| cm |
		cm := CompiledMethodTrailer empty  createMethod: each last size class: CompiledMethod header: each first.
		(WriteStream with: cm)
			position: cm initialPC - 1;
			nextPutAll: each last.
		each second withIndexDo: [:obj :i | cm literalAt: i put: obj].
		cm selector -> cm ]) asDictionary
]

{ #category : #utils }
SoPrimitiveInliner class >> flushCaches [
	"
	self flushCaches.
	"
	DescriptorCache := PrimitiveDescriptors := nil.
]

{ #category : #utils }
SoPrimitiveInliner class >> primitiveDescriptorCacheFrom: arrayOfArrays [
	"remaps everything efficiently to an array"
	| max |
	PrimitiveDescriptors ifNotNil: [ ^ PrimitiveDescriptors ].
	max := 0.
	arrayOfArrays do: [ :each |
		max := max max: each first ].
	PrimitiveDescriptors := Array new: max.
	arrayOfArrays do: [ :each |
		PrimitiveDescriptors at: each first put: each allButFirst ].
	PrimitiveDescriptors withIndexDo: [ :each :i |
		each ifNil: [ PrimitiveDescriptors at: i put: #() ] ].
	^ PrimitiveDescriptors
]

{ #category : #constant }
SoPrimitiveInliner class >> primitiveDescriptors [
	"Describes all primitives.
	 Each description includes a list of the following pattern:
		Condition to inline . inlining function
	 in the form of selectors implemented in the primitive inliner.
	
	Default behavior would be
		#canInline . #inlineFallBackCode
	Which means:
	-> I can be inlined that way if inlining heuristic says so based on the bytecode size of the method targetted by the send.
	-> The code to inline is the method targetted, without any primitive.
	
	Another behavior would be:
		 #receiverIsByteFormat . #inlinePrimByteSize
	Which means:
	-> I can be inlined that way if the receiver has a byte format
	-> The code to inline is the given primitive descriptor, which may includes the original method to inline as fall-back code (depends on descriptors).
	
	Note: If all available strategies fail, switch the send to a direct call."

	^ self primitiveDescriptorCacheFrom: #(
	"0 is conceptual" 
	"(0 		(canInline inlineFallBackCode))"
	"Add"
	(1		(anyOperandNonSmi 							inlineFallBackCode)
			(identityAbsorbingElement 						replaceIdentityAbsorbingElement)
			(noRangeAddOverflow 							inlinePrimSmiAddNoOverflow))
	"Sub "
	(2 		(anyOperandNonSmi 							inlineFallBackCode)
			(identityAbsorbingElement 						replaceIdentityAbsorbingElement)
			(noRangeSubOverflow 							inlinePrimSmiSubNoOverflow))
	"<"
	(3 		(anyOperandNonSmi 							inlineFallBackCode)
			(alwaysInline 									inlinePrimSmiLess))
	">"
	(4 		(anyOperandNonSmi 					 		inlineFallBackCode)
			(alwaysInline 									inlinePrimSmiGreater))
	"<="
	(5 		(anyOperandNonSmi 					 		inlineFallBackCode)
			(alwaysInline 									inlinePrimSmiLessOrEqual))
	">="
	(6 		(anyOperandNonSmi 					 		inlineFallBackCode)
			(alwaysInline 									inlinePrimSmiGreaterOrEqual))
	"="
	(7 		(anyOperandNonSmi 					 		inlineFallBackCode)
			(alwaysInline 									inlinePrimSmiEqual))
	"~="
	(8 		(anyOperandNonSmi 					 		inlineFallBackCode)
			(alwaysInline 									inlinePrimSmiNotEqual))
	"Mul"
	(9 		(anyOperandNonSmi 					 		inlineFallBackCode)
			(identityAbsorbingElement 						replaceIdentityAbsorbingElement)
			(noRangeMulOverflow 							inlinePrimSmiMulNoOverflow))
	"/"
	(10 	(anyOperandNonSmi 					 		inlineFallBackCode)
			(identityAbsorbingElement 						replaceIdentityAbsorbingElement))
	"\\"
	(11 	(anyOperandNonSmi 					 		inlineFallBackCode)
			(identityAbsorbingElement 						replaceIdentityAbsorbingElement)
			(argNonZero 									inlinePrimSmiMod))
	"//"
	(12 	(anyOperandNonSmi 					 		inlineFallBackCode)
			(identityAbsorbingElement 						replaceIdentityAbsorbingElement)
			(okForDivision 									inlinePrimSmiDivNoOverflowNoZero))
	"quo:"
	(13 	(anyOperandNonSmi 					 		inlineFallBackCode)
			(identityAbsorbingElement 						replaceIdentityAbsorbingElement)
			(okForDivision 									inlinePrimSmiQuoNoOverflowNoZero))
	"BitAnd"
	(14 	(anyOperandNonSmi 					 		inlineFallBackCode)
			(identityAbsorbingElement 						replaceIdentityAbsorbingElement)
			(alwaysInline 									inlinePrimSmiBitAnd))
	"BitOr"
	(15 	(anyOperandNonSmi 					 		inlineFallBackCode)
			(identityAbsorbingElement 						replaceIdentityAbsorbingElement)
			(alwaysInline 									inlinePrimSmiBitOr))
	"BitXor"
	(16 	(anyOperandNonSmi 					 		inlineFallBackCode)
			(identityAbsorbingElement 						replaceIdentityAbsorbingElement)
			(alwaysInline 									inlinePrimSmiBitXor))
	"Bitshift"
	(17 	(anyOperandNonSmi 					 		inlineFallBackCode)
			(identityAbsorbingElement 						replaceIdentityAbsorbingElement)
			(firstArgNegative 								inlinePrimSmiBitShiftRight)
			(okForShiftLeft 									inlinePrimSmiBitShiftLeft))
	"MakePoint"
	(18 	(anyOperandNonSmiNonFloat 					inlineFallBackCode))
	"19 Simulation guard. cannot inline" 
	"LargeInteger Primitives (20-37)"
	"Float Primitives (38-59)"
	"At"		
	(60 	(receiverIsByteFormatAndFirstArgInBounds 	inlinePrimByteAt)
			(receiverIsArrayFormatAndFirstArgInBounds 	inlinePrimPointerAt)
			(receiverIsFixedFormatAndCanInline 			inlineFallBackCode))
	"AtPut"	
	(61 	(okForByteAtPut 								inlinePrimByteAtPut)
			(receiverIsArrayFormatAndFirstArgInBounds 	inlinePrimPointerAtPut)
			(receiverIsFixedFormatAndCanInline			inlineFallBackCode))
	"Size"	
 	(62 	(receiverIsByteFormat 							inlinePrimByteSize)
			(receiverIsArrayFormat 							inlinePrimPointerSize)
			(receiverIsFixedFormatAndCanInline 			inlineFallBackCode)) 
	"StringAt StringAtPut 63 64"		
	
	"Old stream prim - always fail"
	(65		(canInline 										inlineFallBackCode))
	(66		(canInline 										inlineFallBackCode)) 
	(67		(canInline 										inlineFallBackCode))		
	
	"68 69 literal access in compiledcode"
	
	"new"
 	(70 	(receiverNotMetaFixedFormat 					inlineFallBackCode)
			(receiverOkForInlineNew 						inlinePrimNew))
	"new:"
	(71 	(receiverIsMetaFixedFormat 					inlineFallBackCode)
			(receiverOkForInlineNewColon 					inlinePrimNewColon)) "We know first arg has a range so a smi."
	"becomeForward 72"
	"instVarAt: / put: 73 74"
	
	"identityHash"
	
	"perform"
	(83 	(firstArgSymbolConstant 						inlinePrimPerform))
	"performWithArgs 84"
	
	"replace"
	(105 	(okForReplaceArrayFormat 						inlinePrimArrayReplace)
			(okForReplaceByteFormat 						inlinePrimByteReplace)
			(okForFallBackReplace							inlineFallBackCode)						)
	
	"=="
 	(110 	(alwaysInline 									inlinePrimPointerEquals)) 
	"class"
 	(111 	(alwaysInline 									inlinePrimClass)) 
	
	"ShortAt: / put: 143 144"
	
	"Constant fill 145"
	(145 	(okForFillByteFormat 							inlinePrimByteAtAllPut) )
	
	"clone 148"
	
	"Hashmultiply"
 	(159 	(alwaysInline 									inlinePrimHashMultiply)) 
	
	"Immutability 163 164"
	
	"(165 primitiveIntegerAt) 166"	
	"168 copyObject"
	"169 ~~"
	(169 	(alwaysInline 									inlinePrimNotPointerEquals)) 
	"170 asCharacter"
	"ImmediateAsInteger"
 	(171 	(receiverIsCharacter 							inlinePrimCharacterAsInteger)) 
	"173 174 slotAt:/put:"
	
	"175 behaviorHash"
	"188 189 withArgs:executeMethod:"
	"FullBlock value - this is dealt in BlockInlininer"
	(207 	(alwaysInline 									inlinePrimFullBlockValue))
	"208 209 valueWithArgs, no contextSwitch"
	"540 559 SmallFloat primitives"
	)

]

{ #category : #conditions }
SoPrimitiveInliner >> alwaysInline [
	^ true
]

{ #category : #conditions }
SoPrimitiveInliner >> anyOperandBasicTypeInformationNonSmiNonFloat [
	"Answers false if one operand cannot be a smi based on basicTypeInformation.
	Also does a shouldInline since this is for fall-back code"
	| type types |
	types := {SmallInteger . SmallFloat64 . BoxedFloat64}.
	type := SoKnownType forArray: types.
	send subNodesDo: [ :sub |
		type := type intersection: sub basicTypeInformation ].
	^ (type isOnlyTypes: types) not and: [ self canInline ]
]

{ #category : #conditions }
SoPrimitiveInliner >> anyOperandNonSmi [
	"Answers false if one operand cannot be a smi based on basicTypeInformation.
	Also does a shouldInline since this is for fall-back code"
	^ send subNodesAnySatisfy: [ :sub | self opNonSmi: sub ]
]

{ #category : #conditions }
SoPrimitiveInliner >> anyOperandNonSmiNonFloat [
	"Answers false if one operand cannot be a smi based on basicTypeInformation.
	Also does a shouldInline since this is for fall-back code"
	| type types |
	types := {SmallInteger . SmallFloat64 . BoxedFloat64}.
	type := SoKnownType forArray: types.
	send subNodesDo: [ :sub |
		type := type intersection: (sub typeInformationAt: send) ].
	^ (type isOnlyTypes: types) not and: [ self canInline ]
]

{ #category : #conditions }
SoPrimitiveInliner >> argNonZero [
	send firstArg hasRangeInformation ifFalse: [ ^ false ].
	^ send firstArg rangeInformation isNonZero 
]

{ #category : #public }
SoPrimitiveInliner >> basicInline: message [
	| descr primNum |
	send := message.
	primNum := send methodToInline primitive.
	send methodToInline isQuick ifTrue: [ ^ super basicInline: send ]. 
	descr := (primNum > self class primitiveDescriptors size 
		ifTrue: [ #() ]
		ifFalse: [ (self class primitiveDescriptors at: primNum) ifNil: [#()] ]).
	descr do: [ :each |
		"conditions, traps, codeToInline"
		(self perform: each first) "Can I use this strategy ?"
			ifTrue: [ ^ self perform: each second ] ]. "inline"
	"No descr work. Tries to switch to direct call."
	^self inlineAsDirectCall
]

{ #category : #inlining }
SoPrimitiveInliner >> basicReplaceIdentityAbsorbingElement: descr [
	send receiver isSmiConstant ifTrue: [ 
		send receiver constant = descr leftIdentity ifTrue: [ ^ send removeAndReplaceUsesBy: send firstArg ].
		send receiver constant = descr leftAbsorbing ifTrue: [ ^ send removeAndReplaceUsesBy: send receiver ] ].
	send firstArg isSmiConstant ifTrue: [ 
		send firstArg constant = descr rightIdentity ifTrue: [ ^ send removeAndReplaceUsesBy: send receiver ].
		send firstArg constant = descr rightAbsorbing ifTrue: [ ^ send removeAndReplaceUsesBy: send firstArg ] ]
	
]

{ #category : #traps }
SoPrimitiveInliner >> bothOperandsSmiTrap [
	self trapFor: send receiver class: SmallInteger.
	self trapFor: (send arguments at: 1) class: SmallInteger.
]

{ #category : #'inlining - utils' }
SoPrimitiveInliner >> concatenate: prim with: method [ 
	"One bb in prim has no CFG instr"
	| bbEnd instr |
	bbEnd := prim basicBlocks detect: [ :bb | bb lastInstr isNil ].
	bbEnd lastInstr: (SoJumpAhead from: bbEnd to: inlinedCodeNode entry).
	instr := bbEnd firstInstr.
	[ instr nextInstr isNil ] whileFalse: [ instr := instr nextInstr ].
	instr nextInstr: bbEnd lastInstr.
	SoBasicBlockMerger new mergeIntoPredecessorIfPossible: inlinedCodeNode entry.
	inlinedCodeNode basicBlocks addAllFirst: prim basicBlocks.
	prim basicBlocks do: [ :each | each codeNode: inlinedCodeNode ].
	self patchMultiReturn.
	inlinedCodeNode maintainPostOrder.
]

{ #category : #conditions }
SoPrimitiveInliner >> firstArgNegative [
	^ send firstArg hasRangeInformation and: [send firstArg rangeInformation isNegative]
]

{ #category : #conditions }
SoPrimitiveInliner >> firstArgSymbolConstant [
	^ send firstArg isConstant and: [ send firstArg constant class == ByteSymbol ]
]

{ #category : #conditions }
SoPrimitiveInliner >> identityAbsorbingElement [
	| descr |
	descr := SoArithmeticDescriptor arithmeticDescriptors at: send methodToInline primitive.
	send receiver isSmiConstant ifTrue: [ 
		send receiver constant = descr leftIdentity ifTrue: [ ^ true ].
		send receiver constant = descr leftAbsorbing ifTrue: [ ^ true ] ].
	send firstArg isSmiConstant ifTrue: [ 
		send firstArg constant = descr rightIdentity ifTrue: [ ^ true ].
		send firstArg constant = descr rightAbsorbing ifTrue: [ ^ true ] ].
	^ false
	
]

{ #category : #public }
SoPrimitiveInliner >> inlineAccessWithNoRangeCheck: message [
	| descr primNum |
	"First arg is guaranteed in bounds from size analysis"
	send := message.
	primNum := send methodToInline primitive.
	self assert: (primNum = 60 or: [ primNum = 61 ]).
	descr := primNum = 60
		ifTrue: [ #((receiverIsByteFormat 			inlinePrimByteAt)
					(receiverIsArrayFormat 			inlinePrimPointerAt)) ]
		ifFalse: [ #((okForByteAtPutNoRangeCheck 	inlinePrimByteAtPut)
					(receiverIsArrayFormat 			inlinePrimPointerAtPut)) ].
	descr do: [ :each |
		"conditions, traps, codeToInline"
		(self perform: each first) "Can I use this strategy ?"
			ifTrue: [ ^ self perform: each second ] ]. "inline"
]

{ #category : #inlining }
SoPrimitiveInliner >> inlineAsDirectCall [
	^ #()
]

{ #category : #'inlining - utils' }
SoPrimitiveInliner >> inlineFailingPrimitive: descr [
	| prim |
	self basicParseInlinedCode ifFalse: [ ^ false ].
	self class logInlining: send message: 'Inlined f-prim: ' , descr selector.
	"Prim has inconsistent state at this point."
	prim := SoPrimitiveDecompiler
		decompile: descr
		inliningWith: self.
	futureSendsToInline := inlinedCodeNode decompSends.
	self concatenate: prim with: inlinedCodeNode.
	"InlinedCodeNode has consistent state again"
	self prepareInlinedCode: inlinedCodeNode.
	^ self finishInlining
]

{ #category : #inlining }
SoPrimitiveInliner >> inlineFallBackCode [
	^ super basicInline: send
]

{ #category : #'inlining - utils' }
SoPrimitiveInliner >> inlineNonFailingPrimitive: descr [
	self class logInlining: send message: 'Inlined n-fprim: ' , descr selector.
	inlinedCodeNode := SoPrimitiveDecompiler
		decompile: descr
		inliningWith: self.
	self prepareInlinedCode: inlinedCodeNode.
	futureSendsToInline := #().
	^ self finishInlining
		
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimArrayReplace [
	self replaceTrapsForClass: {Array}. 
	^ self inlinePrimitive: #primArrayReplaceFrom:to:with:startingAt: 
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimByteAt [
	self receiverSendTrap.
	^ self inlinePrimitive: #primByteAt:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimByteAtAllPut [
	"arg is smi within correct range"
	self receiverSendTrap.
	self receiverReadOnlyTrap.
	^ self inlinePrimitive: #primByteAtAllPut:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimByteAtPut [
	self receiverSendTrap.
	self receiverReadOnlyTrap.
	^ self inlinePrimitive: #primByteAt:put:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimByteReplace [
	self replaceTrapsForClass: {ByteString.ByteSymbol.ByteArray}. 
	^ self inlinePrimitive: #primByteReplaceFrom:to:with:startingAt: 
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimByteSize [
	self receiverSendTrap.
	^ self inlinePrimitive: #primByteSize 
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimCharacterAsInteger [
	self receiverSendTrap.
	^ self inlinePrimitive: #primCharacterAsInteger
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimClass [
	self receiverSendTrap.
	^ self inlinePrimitive: #primClass 
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimFullBlockValue [
	"What happens if only NLR huhum"
	self error: 'Does this happen ? What if only NLR ?'.
	^ SoBlockInliner new inline: send 
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimHashMultiply [
	self receiverSendTrap.
	^ self inlinePrimitive: #primHashMultiply
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimNew [
	| behavior |
	self receiverSendTrap.
	behavior := send specializedSendData anyReceiverClass soleInstance.
	SoEnsureEnoughSlots new
		numSlots: (SoConstant constant: behavior instSize + 2);
		insertBefore: send.
	send replaceBy: (SoPointerNew new
		behavior: behavior;
		yourself).
	^ #()
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimNewColon [
	| behavior size numSlots cls |	
	self receiverSendTrap.
	size := send firstArg constant.
	behavior := send specializedSendData anyReceiverClass soleInstance.
	numSlots := (behavior instSpec = 2 
		ifTrue: [ cls := SoPointerNewColon. size ]
		ifFalse: [ cls := SoByteNewColon. size // Smalltalk wordSize ]).
	SoEnsureEnoughSlots new
		numSlots: (SoConstant constant: numSlots + 2);
		insertBefore: send.
	send replaceBy: (cls new
		behavior: behavior;
		sized: send firstArg;
		yourself).
	^ #()
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimNotPointerEquals [
	self receiverSendTrap.
	^ self inlinePrimitive: #primNotPointerEquals:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimPerform [
	"we're in perform: but not perform:withArgs:"
	| selector newSend |
	selector := send firstArg constant.
	self receiverSendTrap.
	newSend := SoSend new
		receiver: send receiver;
		selector: selector;
		loopDepth: send loopDepth;
		sendData: SoUnknownSendData new;
		deoptInfo: send deoptInfo copy;
		arguments: send arguments allButFirst;
		yourself.
	send replaceBy: newSend.
	^ { newSend }
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimPointerAt [
	self receiverSendTrap.
	^ self inlinePrimitive: #primPointerAt:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimPointerAtPut [
	self receiverSendTrap.
	self receiverReadOnlyTrap.
	^ self inlinePrimitive: #primPointerAt:put:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimPointerEquals [
	self receiverSendTrap.
	^ self inlinePrimitive: #primPointerEquals:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimPointerSize [
	self receiverSendTrap.
	^ self inlinePrimitive: #primPointerSize 
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiAddNoOverflow [
	^ self inlinePrimitive: #primSmiAddNoOverflow:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiBitAnd [
	self bothOperandsSmiTrap.
	^ self inlinePrimitive: #primSmiBitAnd:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiBitOr [
	self bothOperandsSmiTrap.
	^ self inlinePrimitive: #primSmiBitOr:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiBitShiftLeft [
	self bothOperandsSmiTrap.
	^ self inlinePrimitive: #primSmiBitShiftLeft:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiBitShiftRight [
	self bothOperandsSmiTrap.
	^ self inlinePrimitive: #primSmiBitShiftRight:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiBitXor [
	self bothOperandsSmiTrap.
	^ self inlinePrimitive: #primSmiBitXor:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiDivNoOverflowNoZero [
	self receiverSendTrap. "range not necessarily checked on receiver"
	^ self inlinePrimitive: #primSmiDivNoOverflowNoZero:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiEqual [
	self bothOperandsSmiTrap.
	^ self inlinePrimitive: #primSmiEquals:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiGreater [
	self bothOperandsSmiTrap.
	^ self inlinePrimitive: #primSmiGreater:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiGreaterOrEqual [
	self bothOperandsSmiTrap.
	^ self inlinePrimitive: #primSmiGreaterOrEqual:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiLess [
	self bothOperandsSmiTrap.
	^ self inlinePrimitive: #primSmiLess:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiLessOrEqual [
	self bothOperandsSmiTrap.
	^ self inlinePrimitive: #primSmiLessOrEqual: 
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiMod [
	self receiverSendTrap.
	^ self inlinePrimitive: #primSmiMod:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiMulNoOverflow [
	^ self inlinePrimitive: #primSmiMulNoOverflow:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiNotEqual [
	self bothOperandsSmiTrap.
	^ self inlinePrimitive: #primSmiNotEquals:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiQuoNoOverflowNoZero [
	self receiverSendTrap. "range not necessarily checked on receiver"
	^ self inlinePrimitive: #primSmiQuoNoOverflowNoZero:
]

{ #category : #inlining }
SoPrimitiveInliner >> inlinePrimSmiSubNoOverflow [
	^ self inlinePrimitive: #primSmiSubNoOverflow:
]

{ #category : #'inlining - utils' }
SoPrimitiveInliner >> inlinePrimitive: selector [
	| descr |
	descr := self class byteDescriptors at: selector.
	^ descr methodClass 
		ifFalse: [ self inlineNonFailingPrimitive: descr ]
		ifTrue: [ self inlineFailingPrimitive: descr ].
	
]

{ #category : #conditions }
SoPrimitiveInliner >> noRangeAddOverflow [
	send receiver hasRangeInformation ifFalse: [ ^ false ].
	send firstArg hasRangeInformation ifFalse: [ ^ false ].
	send receiver rangeInformation addRange: send firstArg rangeInformation onOverflow: [ ^ false ].
	^ true
]

{ #category : #conditions }
SoPrimitiveInliner >> noRangeMulOverflow [
	send receiver hasRangeInformation ifFalse: [ ^ false ].
	send firstArg hasRangeInformation ifFalse: [ ^ false ].
	send receiver rangeInformation mulRange: send firstArg rangeInformation onOverflow: [ ^ false ].
	^ true
]

{ #category : #conditions }
SoPrimitiveInliner >> noRangeSubOverflow [
	send receiver hasRangeInformation ifFalse: [ ^ false ].
	send firstArg hasRangeInformation ifFalse: [ ^ false ].
	send receiver rangeInformation subRange: send firstArg rangeInformation onOverflow: [ ^ false ].
	^ true
]

{ #category : #conditions }
SoPrimitiveInliner >> okForByteAtPut [
	self receiverIsByteFormatAndFirstArgInBounds ifFalse: [ ^ false ].
	send arguments second hasRangeInformation ifFalse: [ ^ false ].
	^ send arguments second rangeInformation isByte
]

{ #category : #conditions }
SoPrimitiveInliner >> okForByteAtPutNoRangeCheck [
	self receiverIsByteFormat ifFalse: [ ^ false ].
	send arguments second hasRangeInformation ifFalse: [ ^ false ].
	^ send arguments second rangeInformation isByte
]

{ #category : #conditions }
SoPrimitiveInliner >> okForDivision [
	"2 cases:
	- no 0 divide
	- no minVal divide by -1"
	| argRange |
	send firstArg hasRangeInformation ifFalse: [ ^ false ].
	argRange := send firstArg rangeInformation.
	argRange isNonZero ifFalse: [ ^ false ].
	argRange isNonMinusOne ifTrue: [ ^ true ].
	send receiver hasRangeInformation ifFalse: [ ^ false ].
	^ send receiver rangeInformation isNonSmiMinVal 
]

{ #category : #conditions }
SoPrimitiveInliner >> okForFallBackReplace [
	"Under specific conditions we know the primitive replace fails and we can use fall back code directly."
	| typeInfo1 typeInfo2 |
	(self opNonSmi: (send arguments at: 1)) ifTrue: [ ^ true ].
	(self opNonSmi: (send arguments at: 2)) ifTrue: [ ^ true ].
	(self opNonSmi: (send arguments at: 4)) ifTrue: [ ^ true ].
	typeInfo1 := send receiver typeInformationAt: send.
	typeInfo1 isKnownType ifTrue: [ (typeInfo1 behaviors anySatisfy: [ :b | b isFixed ]) ifTrue: [ ^ true ] ].
	typeInfo2 := (send arguments at: 3) typeInformationAt: send.
	typeInfo2 isKnownType ifTrue: [ (typeInfo2 behaviors anySatisfy: [ :b | b isFixed ]) ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #conditions }
SoPrimitiveInliner >> okForFillByteFormat [
	^ self receiverIsByteFormat 
		and: [ send firstArg hasRangeInformation 
		and: [ send firstArg rangeInformation isByte ] ]
]

{ #category : #conditions }
SoPrimitiveInliner >> okForReplace: expectedTypes [
	| typeInfo1 typeInfo2 |
	"first check we don't have non smis, operand type can be unknown OR Smi but not another type."
	(self opNonSmi: (send arguments at: 1)) ifTrue: [ ^ false ].
	(self opNonSmi: (send arguments at: 2)) ifTrue: [ ^ false ].
	(self opNonSmi: (send arguments at: 4)) ifTrue: [ ^ false ].
	"At least one of the array needs to be an expected type, the other one can be unknown OR the expectedType"
	typeInfo1 := send receiver typeInformationAt: send.
	typeInfo2 := (send arguments at: 3) typeInformationAt: send.
	typeInfo1 isKnownType ifFalse: [ ^ typeInfo2 isOnlyTypes: expectedTypes ].
	typeInfo2 isKnownType ifFalse: [ ^ typeInfo1 isOnlyTypes: expectedTypes ].
	^ (typeInfo1 isOnlyTypes: expectedTypes) and: [typeInfo2 isOnlyTypes: expectedTypes]
]

{ #category : #conditions }
SoPrimitiveInliner >> okForReplaceArrayFormat [
	^ self okForReplace: {Array}
]

{ #category : #conditions }
SoPrimitiveInliner >> okForReplaceByteFormat [
	^ self okForReplace: {ByteString . ByteSymbol . ByteArray}
]

{ #category : #conditions }
SoPrimitiveInliner >> okForShiftLeft [
	(send receiver hasRangeInformation and: [send receiver rangeInformation isPositive]) ifFalse: [ ^ false ].
	(send firstArg hasRangeInformation and: [send firstArg rangeInformation isPositive]) ifFalse: [ ^ false ].
	(send receiver rangeInformation shiftLeftOverflow: send firstArg rangeInformation) ifTrue: [ ^ false ].
	^ true
]

{ #category : #conditions }
SoPrimitiveInliner >> opNonSmi: op [
	"Answers false if the operand cannot be a smi.
	Also does a shouldInline since this is for fall-back code"
	| basicTypeInfo |
	basicTypeInfo := op typeInformationAt: send.
	^ basicTypeInfo isKnownType and: [ 
		(basicTypeInfo behaviors includes: SmallInteger) not ]
]

{ #category : #'inlining - utils' }
SoPrimitiveInliner >> patchMultiReturn [
	"inlinedCodeNode has multiple returns. Needs to be fixed for inlining."
	| returns retBB phi |
	returns := inlinedCodeNode basicBlocks select: [ :each | each lastInstr isReturn ].
	returns size = 1 ifTrue: [ ^ self ].
	retBB := SoBasicBlock new.
	retBB codeNode: inlinedCodeNode.
	retBB firstInstr: (phi := SoPhi new).
	phi nextInstr: (SoReturn new
		returnedValue: phi;
		numLevels: 2; "This is a method"
		yourself).
	retBB lastInstr: phi nextInstr.
	inlinedCodeNode basicBlocks addLast: retBB.
	returns do: [ :bb |
		phi addInput: bb lastInstr returnedValue basicBlock: bb.
		bb lastInstr replaceBy: (SoJumpAhead from: bb to: retBB) ].
	
]

{ #category : #conditions }
SoPrimitiveInliner >> receiverIsArrayFormat [
	^ send specializedSendData hasCoherentReceiverType
		and: [ send specializedSendData anyReceiverClass instSpec = 2 ] 
	
	
]

{ #category : #conditions }
SoPrimitiveInliner >> receiverIsArrayFormatAndFirstArgInBounds [
	self receiverIsArrayFormat ifFalse: [ ^ false ].
	send firstArg hasRangeInformation ifFalse: [ ^ false ].
	^ send firstArg rangeInformation acceptArray: send receiver
]

{ #category : #conditions }
SoPrimitiveInliner >> receiverIsByteFormat [
	^ send specializedSendData hasCoherentReceiverType
		and: [ send specializedSendData anyReceiverClass instSpec = 16 ] 
	
	
]

{ #category : #conditions }
SoPrimitiveInliner >> receiverIsByteFormatAndFirstArgInBounds [
	self receiverIsByteFormat ifFalse: [ ^ false ].
	send firstArg hasRangeInformation ifFalse: [ ^ false ].
	^ send firstArg rangeInformation acceptArray: send receiver
]

{ #category : #conditions }
SoPrimitiveInliner >> receiverIsCharacter [
	send specializedSendData behaviors size = 1 ifFalse: [ ^ false ].
	^ send specializedSendData anyReceiverClass == Character 
]

{ #category : #conditions }
SoPrimitiveInliner >> receiverIsFixedFormat [
	^ send specializedSendData hasCoherentReceiverType
		and: [ send specializedSendData anyReceiverClass isFixed ] 
	
	
]

{ #category : #conditions }
SoPrimitiveInliner >> receiverIsFixedFormatAndCanInline [
	^ self receiverIsFixedFormat and: [ self canInline ]
]

{ #category : #conditions }
SoPrimitiveInliner >> receiverIsMetaFixedFormat [
	| behavior |
	send specializedSendData behaviors size = 1 ifFalse: [ ^ false ].
	send specializedSendData anyReceiverClass isMeta ifFalse: [ ^ false ].
	behavior := send specializedSendData anyReceiverClass soleInstance.
	^ behavior isFixed
]

{ #category : #conditions }
SoPrimitiveInliner >> receiverNotFixedFormat [
	^ send specializedSendData hasCoherentReceiverType
		and: [ send specializedSendData anyReceiverClass isFixed not ] 
	
]

{ #category : #conditions }
SoPrimitiveInliner >> receiverNotMetaFixedFormat [
	| behavior |
	send specializedSendData behaviors size = 1 ifFalse: [ ^ false ].
	send specializedSendData anyReceiverClass isMeta ifFalse: [ ^ false ].
	behavior := send specializedSendData anyReceiverClass soleInstance.
	^ behavior isFixed not
	
]

{ #category : #conditions }
SoPrimitiveInliner >> receiverOkForInlineNew [
	| behavior |
	send specializedSendData behaviors size = 1 ifFalse: [ ^ false ].
	send specializedSendData anyReceiverClass isMeta ifFalse: [ ^ false ].
	behavior :=  send specializedSendData anyReceiverClass soleInstance.
	behavior instSpec <= 1 ifFalse: [ ^ false ].
	^ behavior instSize < MaxInstSizeForInlinedAllocation
]

{ #category : #conditions }
SoPrimitiveInliner >> receiverOkForInlineNewColon [
	"Right now VM does not implement variable sized inlined allocation without constant"
	| behavior |
	send specializedSendData behaviors size = 1 ifFalse: [ ^ false ].
	send specializedSendData anyReceiverClass isMeta ifFalse: [ ^ false ].
	behavior := send specializedSendData anyReceiverClass soleInstance.
	(behavior instSpec = 2 or: [ behavior instSpec = 16 ]) ifFalse: [ ^ false ].
	send firstArg isSmiConstant ifFalse: [ ^ false ].
	^ send firstArg constant < MaxInstSizeForInlinedAllocation
]

{ #category : #traps }
SoPrimitiveInliner >> receiverReadOnlyTrap [
	(SoTrapIfReadOnly new
		expression: send receiver;
		deoptInfo: (send deoptInfo convertToTrapWith: send);
		yourself) insertBefore: send 
]

{ #category : #traps }
SoPrimitiveInliner >> receiverSendTrap [
	send insertTrap
]

{ #category : #inlining }
SoPrimitiveInliner >> replaceIdentityAbsorbingElement [
	| descr |
	self bothOperandsSmiTrap.
	descr := SoArithmeticDescriptor arithmeticDescriptors at: send methodToInline primitive.
	self basicReplaceIdentityAbsorbingElement: descr.
	^ #()
	
]

{ #category : #traps }
SoPrimitiveInliner >> replaceTrapsForClass: classes [
	self trapFor: send receiver classes: classes.
	self trapFor: (send arguments at: 3) classes: classes.
	self trapFor: (send arguments at: 1) class: SmallInteger.
	self trapFor: (send arguments at: 2) class: SmallInteger.
	self trapFor: (send arguments at: 4) class: SmallInteger.
	self receiverReadOnlyTrap.
]

{ #category : #traps }
SoPrimitiveInliner >> trapFor: instr class: class [ 
	self trapFor: instr classes: { class }
]

{ #category : #traps }
SoPrimitiveInliner >> trapFor: instr classes: classes [
	"Added the guard for performance - deopt info def-use management can be expensive"
	| type |
	"guard"
	type := instr typeInformationAt: send.
	type isKnownType ifTrue: 
		[ (classes includesAll: type behaviors) ifTrue: [ ^ self "don't need trap" ] ].
	"actual trap"
	SoTrapIfNotInstanceOf new
		behaviors: classes;
		expression: instr;
		deoptInfo: (send deoptInfo convertToTrapWith: send);
		insertBefore: send.
	
]
