"
I am similar to InstructionStream, but I have specific dispatch mechanics to catch access to context instance variables, arithmetic sends and bytecode encoded things similar to those that the INstructionStream cannot see.

stackp < Smi > index of the top of the stack.
	
"
Class {
	#name : #SoInstructionStream,
	#superclass : #InstructionStream,
	#instVars : [
		'stackp'
	],
	#category : #'Scorching-Decompiler'
}

{ #category : #opcodes }
SoInstructionStream >> arithmeticSend: selector numArgs: numArgs [
	self send: selector numArgs: numArgs 
]

{ #category : #opcodes }
SoInstructionStream >> callMappedInlinedPrimitive: prim [
	<generated>
	prim = 50 ifTrue: [^ self ensureEnoughSlots ].
	prim = 150 ifTrue: [^ self immCheckPointerAtPut ].
	prim = 151 ifTrue: [^ self immCheckStoreCheckPointerAtPut ].
	prim = 152 ifTrue: [^ self immCheckMaybeContextPointerAtPut ].
	prim = 153 ifTrue: [^ self immCheckMaybeContextStoreCheckPointerAtPut ].
	prim = 154 ifTrue: [^ self immCheckByteAtPut ].
	prim = 155 ifTrue: [^ self immCheckShortAtPut ].
	prim = 156 ifTrue: [^ self immCheckWordAtPut ].
	prim = 157 ifTrue: [^ self immCheckDoubleWordAtPut ].
	prim = 200 ifTrue: [^ self withArgsExecuteMethod ].
	prim = 250 ifTrue: [^ self backjumpAlwaysInterrupt ].

]

{ #category : #opcodes }
SoInstructionStream >> callMethodPrimitive: prim [
	
]

{ #category : #opcodes }
SoInstructionStream >> callPrimitive: primNumber [
	primNumber >= (1 << 15) ifTrue: [ ^ self callUnmappedInlinedPrimitive: (primNumber bitAnd: 1 << 13 - 1) ].  
	^ self callMethodPrimitive: primNumber
]

{ #category : #opcodes }
SoInstructionStream >> callUnmappedInlinedPrimitive: prim [
	<generated>
	prim = 1000 ifTrue: [^ self rawClass ].
	prim = 1001 ifTrue: [^ self numSlots ].
	prim = 1002 ifTrue: [^ self numBytes ].
	prim = 1003 ifTrue: [^ self numShorts ].
	prim = 1004 ifTrue: [^ self numWords ].
	prim = 1005 ifTrue: [^ self numDoubleWords ].
	prim = 1011 ifTrue: [^ self rawNew ].
	prim = 1012 ifTrue: [^ self rawNewNoInit ].
	prim = 1020 ifTrue: [^ self objectIdentityHash ].
	prim = 1021 ifTrue: [^ self smiIdentityHash ].
	prim = 1022 ifTrue: [^ self charIdentityHash ].
	prim = 1023 ifTrue: [^ self smallfloatIdentityHash ].
	prim = 1024 ifTrue: [^ self behaviorIdentityHash ].
	prim = 1030 ifTrue: [^ self characterAsInteger ].
	prim = 1031 ifTrue: [^ self smallFloatAsInteger ].
	prim = 1032 ifTrue: [^ self smiAsFloat ].
	prim = 1040 ifTrue: [^ self unforward ].
	prim = 1041 ifTrue: [^ self possibleRoot ].
	prim = 2000 ifTrue: [^ self smiAdd ].
	prim = 2001 ifTrue: [^ self smiSub ].
	prim = 2002 ifTrue: [^ self smiMul ].
	prim = 2003 ifTrue: [^ self smiDivide ].
	prim = 2004 ifTrue: [^ self smiDiv ].
	prim = 2005 ifTrue: [^ self smiMod ].
	prim = 2006 ifTrue: [^ self smiQuo ].
	prim = 2016 ifTrue: [^ self smiBitAnd ].
	prim = 2017 ifTrue: [^ self smiBitOr ].
	prim = 2018 ifTrue: [^ self smiBitXor ].
	prim = 2019 ifTrue: [^ self smiBitShiftLeft ].
	prim = 2020 ifTrue: [^ self smiBitShiftRight ].
	prim = 2032 ifTrue: [^ self smiGreater ].
	prim = 2033 ifTrue: [^ self smiLess ].
	prim = 2034 ifTrue: [^ self smiGreaterOrEqual ].
	prim = 2035 ifTrue: [^ self smiLessOrEqual ].
	prim = 2036 ifTrue: [^ self smiEquals ].
	prim = 2037 ifTrue: [^ self smiNotEquals ].
	prim = 2038 ifTrue: [^ self rawEqualsEquals ].
	prim = 2039 ifTrue: [^ self rawNotEqualsEquals ].
	prim = 2048 ifTrue: [^ self rawNewColon ].
	prim = 2049 ifTrue: [^ self rawNewColonNoInit ].
	prim = 2064 ifTrue: [^ self pointerAt ].
	prim = 2065 ifTrue: [^ self maybeContextPointerAt ].
	prim = 2066 ifTrue: [^ self byteAt ].
	prim = 2067 ifTrue: [^ self shortAt ].
	prim = 2068 ifTrue: [^ self wordAt ].
	prim = 2069 ifTrue: [^ self doubleWordAt ].
	prim = 3000 ifTrue: [^ self pointerAtPut ].
	prim = 3001 ifTrue: [^ self storeCheckPointerAtPut ].
	prim = 3002 ifTrue: [^ self maybeContextPointerAtPut ].
	prim = 3003 ifTrue: [^ self maybeContextStoreCheckPointerAtPut ].
	prim = 3004 ifTrue: [^ self byteAtPut ].
	prim = 3005 ifTrue: [^ self shortAtPut ].
	prim = 3006 ifTrue: [^ self wordAtPut ].
	prim = 3007 ifTrue: [^ self doubleWordAtPut ].
	prim = 6000 ifTrue: [^ self backjumpNoInterrupt ].
	prim = 7016 ifTrue: [^ self jumpWritable ].
	prim = 7017 ifTrue: [^ self jumpReadOnly ].
	prim = 7018 ifTrue: [^ self jumpYoung ].
	prim = 7019 ifTrue: [^ self jumpOld ].
	prim = 8000 ifTrue: [^ self instanceOfJumpTrue ].
	prim = 8001 ifTrue: [^ self instanceOfJumpFalse ].
	prim = 8002 ifTrue: [^ self instanceOfOneOfJumpTrue ].
	prim = 8003 ifTrue: [^ self instanceOfOneOfJumpFalse ].

]

{ #category : #opcodes }
SoInstructionStream >> drop [
	self drop: 1
]

{ #category : #opcodes }
SoInstructionStream >> drop: n [
	stackp := stackp - n
]

{ #category : #private }
SoInstructionStream >> interpretBytes [
	| endPC |
	endPC := self method size.
	[pc > endPC] whileFalse: [self interpretNextInstructionFor: self]
]

{ #category : #decoding }
SoInstructionStream >> interpretNext2ByteSistaV1Instruction: bytecode for: client extA: extA extB: extB startPC: startPC [
	"Send to the argument, client, a message that specifies the next instruction.
	 This method handles the two-byte codes.
	 For a table of the bytecode set, see EncoderForV1's class comment."

	| byte method |
	method := self method.
	byte := self method at: pc.
	pc := pc + 1.
	"We do an inline quasi-binary search on bytecode"
	bytecode < 234 ifTrue: "pushes"
		[bytecode < 231 ifTrue:
			[bytecode < 229 ifTrue:
				[| literal |
				 bytecode = 226 ifTrue:
					[^client pushMaybeContextReceiverVariable: (extA bitShift: 8) + byte].
				 literal := method literalAt: (extA bitShift: 8) + byte + 1.
				 bytecode = 227 ifTrue:
					[^client pushLiteralVariable: literal].
				 ^client pushConstant: literal].
			bytecode = 229 ifTrue:
				[^client pushTemporaryVariable: byte]. 
			^self unusedBytecode: client at: startPC]. 
		bytecode = 231 ifTrue:
			[^byte < 128
				ifTrue: [client pushNewArrayOfSize: byte]
				ifFalse: [client pushConsArrayWithElements: byte - 128]].
		bytecode = 232 ifTrue:
			[^client pushConstant: (extB bitShift: 8) + byte].
		^client pushConstant: (Character value: (extB bitShift: 8) + byte)].
	bytecode < 240 ifTrue: "sends, trap and jump"
		[bytecode < 236 ifTrue: "sends"
			[(bytecode = 235 and: [extB >= 64]) ifTrue:
				[^client
					directedSuperSend: (method literalAt: (extA bitShift: 5) + (byte // 8) + 1)
					numArgs: (extB - 64 bitShift: 3) + (byte \\ 8)].
			 ^client
				send: (method literalAt: (extA bitShift: 5) + (byte // 8) + 1)
				super: bytecode = 235
				numArgs: (extB bitShift: 3) + (byte \\ 8)].
		 bytecode = 236 ifTrue:
			[^self callMappedInlinedPrimitive: byte].
		bytecode = 237 ifTrue:
			[^client jump: (extB bitShift: 8) + byte].
		 ^client jump: (extB bitShift: 8) + byte if: bytecode = 238].
	bytecode < 243 ifTrue:
		[bytecode = 240 ifTrue:
			[^client popIntoMaybeContextReceiverVariable: (extA bitShift: 8) + byte].
		 bytecode = 241 ifTrue:
			[^client popIntoLiteralVariable: (method literalAt: (extA bitShift: 8) + byte + 1)].
		 ^client popIntoTemporaryVariable: byte].
	bytecode = 243 ifTrue:
		[^client storeIntoMaybeContextReceiverVariable: (extA bitShift: 8) + byte].
	bytecode = 244 ifTrue:
		[^client storeIntoLiteralVariable: (method literalAt: (extA bitShift: 8) + byte + 1)].
	bytecode = 245 ifTrue:
		[^client storeIntoTemporaryVariable: byte].
	"246-247	1111011 i	xxxxxxxx	UNASSIGNED"
	^self unusedBytecode: client at: startPC
]

{ #category : #decoding }
SoInstructionStream >> interpretNext3ByteSistaV1Instruction: bytecode for: client extA: extA extB: extB startPC: startPC [
	"Send to the argument, client, a message that specifies the next instruction.
	 This method handles the three-byte codes.
	 For a table of the bytecode set, see EncoderForSistaV1's class comment."

	| method byte2 byte3 |
	method := self method.
	byte2 := method at: pc.
	byte3 := method at: pc + 1.
	pc := pc + 2.
	"we search the bytecodes by what we expect to be the static frequency."
	bytecode = 248 ifTrue:
		[^client callPrimitive: byte2 + (byte3 bitShift: 8)].
	bytecode = 249 ifTrue: 
		[^client 
			pushFullClosure: (method literalAt: (extA bitShift: 8) + byte2 + 1) 
			numCopied: (byte3 bitAnd: 16r3F) 
			receiverOnStack: (byte3 bitAt: 7) = 1
			ignoreOuterContext: (byte3 bitAt: 8) = 1 ].
	bytecode = 250 ifTrue:
		[SoOldBlockModel signal: 'old block closure not supported'].
	bytecode = 251 ifTrue:
		[^client pushRemoteTemp: byte2 inVectorAt: byte3].
	bytecode = 252 ifTrue:
		[^client storeIntoRemoteTemp: byte2 inVectorAt: byte3].
	bytecode = 253 ifTrue:
		[^client popIntoRemoteTemp: byte2 inVectorAt: byte3].
	"249		11111001 	xxxxxxxx	syyyyyyy	Reserved for Push Float"
	"254-255	1111111 i	xxxxxxxx	yyyyyyyy	UNASSIGNED"
	bytecode = 254 ifTrue: 
		[^client 
			jumpOrPopIfNotInstanceOf: (method literalAt: (extA bitShift: 8) + byte2 + 1) 
			distance: ((extB bitShift: 8) + byte3) ].
	^self unusedBytecode: client at: startPC
]

{ #category : #decoding }
SoInstructionStream >> interpretNextSistaV1InstructionFor: client [
	"Send to the argument, client, a message that specifies the next instruction."

	| byte div16 offset method extA extB savedPC |
	method := self method.
	"For a table of the bytecode set, see EncoderForSistaV1's class comment."
	"consume and compute any extensions first."
	extA := extB := 0.
	savedPC := pc.
	[byte := self method at: pc.
	 pc := pc + 1.
	 byte >= 16rE0 and: [byte <= 16rE1]] whileTrue:
		[| extByte |
		 extByte := self method at: pc.
		 pc := pc + 1.
		 byte = 16rE0
			ifTrue:
				[extA := (extA bitShift: 8) + extByte]
			ifFalse:
				[extB := (extB = 0 and: [extByte > 127])
							ifTrue: [extByte - 256]
							ifFalse: [(extB bitShift: 8) + extByte]]].
	div16 := byte // 16.
	offset := byte \\ 16.
	"We do an inline quasi-binary search on each of the possible 16 values of div16"
	div16 < 11 ifTrue:
		[div16 < 6 ifTrue:
			[div16 < 4 ifTrue:
				[div16 < 2 ifTrue:
					[div16 = 0 ifTrue:
						 [^client pushReceiverVariable: offset].
					^client pushLiteralVariable: (method literalAt: offset + 1)]. "div16 = 1"
				 ^client pushConstant: (method literalAt: byte \\ 32 + 1)].
			 div16 = 4 ifTrue:
				[offset < 12 ifTrue:
					[^client pushTemporaryVariable: offset].
				 offset = 12 ifTrue:
					[^client pushReceiver].
				 offset = 13 ifTrue:
					[^client pushConstant: true].
				 offset = 14 ifTrue:
					[^client pushConstant: false].
				 offset = 15 ifTrue:
					[^client pushConstant: nil]].
			"div16 = 5"
			 offset < 2 ifTrue:
				[^client pushConstant: offset].
			 offset = 2 ifTrue:
				[^self interpretSistaV1ExtendedPush: extB for: client].
			 offset = 3 ifTrue:
				[^client doDup].
				
			 offset = 8 ifTrue:
				[^client methodReturnReceiver].
			 offset = 9 ifTrue:
				[^client methodReturnConstant: true].
			 offset = 10 ifTrue:
				[^client methodReturnConstant: false].
			 offset = 11 ifTrue:
				[^client methodReturnConstant: nil].
			 offset = 12 ifTrue:
				[^client methodReturnTop].
			 offset = 13 ifTrue:
				[^client blockReturnConstant: nil].
			 offset = 14 ifTrue:
				[^client blockReturnTop].
			 offset = 15 ifTrue:
				[^client doNop].
			 ^self unusedBytecode: client at: savedPC].
		"short sends"
		div16 = 6 ifTrue:
			[^client
				arithmeticSend: (Smalltalk specialSelectorAt: offset + 1)
				numArgs: (Smalltalk specialNargsAt: offset + 1)].
		 div16 = 7 ifTrue:
			[^client
				specialSend: (Smalltalk specialSelectorAt: offset + 17)
				numArgs: (Smalltalk specialNargsAt: offset + 17)].
		^client
			send: (method literalAt: offset + 1)
			numArgs: div16 - 8].
	"div16 >= 11; bytecode >= 176"
	div16 < 14 ifTrue:
		[div16 = 11 ifTrue:
			[offset < 8 ifTrue:
				[^client jump: offset + 1].
			 ^client jump: offset - 7 if: true].
		 div16 = 12 ifTrue:
			[offset < 8 ifTrue:
				[^client jump: offset + 1 if: false].
			 ^client popIntoReceiverVariable: offset - 8].
		 "div16 = 13"
		 offset < 8 ifTrue:
		 	[^client popIntoTemporaryVariable: offset].
		 offset = 8 ifTrue: [ ^ client doPop ].
		 offset = 9 ifTrue: [ ^ client trap ].
		 ^self unusedBytecode: client at: savedPC].
	"2 byte and 3 byte codes"
	byte < 248 ifTrue:
		[^self interpretNext2ByteSistaV1Instruction: byte for: client extA: extA extB: extB startPC: savedPC].
	^self interpretNext3ByteSistaV1Instruction: byte for: client extA: extA extB: extB startPC: savedPC
]

{ #category : #opcodes }
SoInstructionStream >> methodReturnConstant: anObject [ 
	self pushConstant: anObject.
	self methodReturnTop.
]

{ #category : #opcodes }
SoInstructionStream >> methodReturnReceiver [
	self pushReceiver.
	self methodReturnTop.
]

{ #category : #opcodes }
SoInstructionStream >> popIntoLiteralVariable: assoc [
	self storeIntoLiteralVariable: assoc.
	self drop
			
]

{ #category : #opcodes }
SoInstructionStream >> popIntoMaybeContextReceiverVariable: index [
	self storeIntoMaybeContextReceiverVariable: index.
	self drop
]

{ #category : #opcodes }
SoInstructionStream >> popIntoReceiverVariable: index [
	self storeIntoReceiverVariable: index.
	self drop
]

{ #category : #opcodes }
SoInstructionStream >> popIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	self storeIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex. 
	self drop
]

{ #category : #opcodes }
SoInstructionStream >> popIntoTemporaryVariable: index [
	self storeIntoTemporaryVariable: index.
	self drop.
			
]

{ #category : #private }
SoInstructionStream >> push [
	^ stackp := stackp + 1
]

{ #category : #opcodes }
SoInstructionStream >> pushContextReceiverVariable: index [
	self pushReceiverVariable: index
	
]

{ #category : #opcodes }
SoInstructionStream >> pushMaybeContextReceiverVariable: index [
	index <= thisContext class instSize "Abstract away from context class."
		ifTrue: [ self pushContextReceiverVariable: index ]
		ifFalse: [ self pushReceiverVariable: index ]
	
]

{ #category : #opcodes }
SoInstructionStream >> send: selector numArgs: na [
]

{ #category : #opcodes }
SoInstructionStream >> send: selector super: sup numArgs: na [
	sup 
		ifTrue: [ self sendSuper: selector numArgs: na]
		ifFalse: [ self send: selector numArgs: na].
]

{ #category : #opcodes }
SoInstructionStream >> sendSuper: selector numArgs: na [
]

{ #category : #accessing }
SoInstructionStream >> shiftedPC [	
	^ pc - self method initialPC + 1
]

{ #category : #opcodes }
SoInstructionStream >> specialSend: selector numArgs: numArgs [
	self send: selector numArgs: numArgs 
]

{ #category : #accessing }
SoInstructionStream >> stackp [
	<generated>
	^ stackp
]

{ #category : #accessing }
SoInstructionStream >> stackp: aValue [
	<generated>
	stackp := aValue
]

{ #category : #opcodes }
SoInstructionStream >> storeIntoContextReceiverVariable: index [
	self storeIntoReceiverVariable: index
]

{ #category : #opcodes }
SoInstructionStream >> storeIntoMaybeContextReceiverVariable: index [
	index <= thisContext class instSize "Abstract away from context class."
		ifTrue: [ self storeIntoContextReceiverVariable: index ]
		ifFalse: [ self storeIntoReceiverVariable: index]
	
	
]
