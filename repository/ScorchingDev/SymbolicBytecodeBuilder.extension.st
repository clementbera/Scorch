Extension { #name : #SymbolicBytecodeBuilder }

{ #category : #'*ScorchingDev' }
SymbolicBytecodeBuilder >> callMappedInlinedPrimitive: primNumber [
	"Print the callPrimitive bytecode."

	self addBytecode: (self mappedNameFromPrim: primNumber)	
]

{ #category : #'*ScorchingDev' }
SymbolicBytecodeBuilder >> callPrimitive: primNumber [
	"Print the callPrimitive bytecode."

	| isInlined |
	isInlined := primNumber >= (1 << 15)
		ifTrue: [ 'Inlined' ]
		ifFalse: [ '' ].
	primNumber >= (1 << 15)
		ifTrue: [^self addBytecode: (self nameFromPrim: (primNumber bitAnd: (1 << 13 - 1))) ].
	self addBytecode: 'call' , isInlined , 'Primitive: ' , primNumber printString
]

{ #category : #'*ScorchingDev' }
SymbolicBytecodeBuilder >> mappedNameFromPrim: prim [
	<generated>
	prim = 50 ifTrue: [^ #ensureEnoughSlots ].
	prim = 150 ifTrue: [^ #immCheckPointerAt:put: ].
	prim = 151 ifTrue: [^ #immCheckStoreCheckPointerAt:put: ].
	prim = 152 ifTrue: [^ #immCheckMaybeContextPointerAt:put: ].
	prim = 153 ifTrue: [^ #immCheckMaybeContextStoreCheckPointerAt:put: ].
	prim = 154 ifTrue: [^ #immCheckByteAt:put: ].
	prim = 155 ifTrue: [^ #immCheckShortAt:put: ].
	prim = 156 ifTrue: [^ #immCheckWordAt:put: ].
	prim = 157 ifTrue: [^ #immCheckDoubleWordAt:put: ].
	prim = 200 ifTrue: [^ #withArgs:executeMethod: ].
	prim = 250 ifTrue: [^ #backjumpAlwaysInterrupt ].
	^ #undefinedMappedUnsafeOp
]

{ #category : #'*ScorchingDev' }
SymbolicBytecodeBuilder >> nameFromPrim: prim [
	<generated>
	prim = 1000 ifTrue: [^ #rawClass ].
	prim = 1001 ifTrue: [^ #numSlots ].
	prim = 1002 ifTrue: [^ #numBytes ].
	prim = 1003 ifTrue: [^ #numShorts ].
	prim = 1004 ifTrue: [^ #numWords ].
	prim = 1005 ifTrue: [^ #numDoubleWords ].
	prim = 1011 ifTrue: [^ #rawNew ].
	prim = 1012 ifTrue: [^ #rawNewNoInit ].
	prim = 1020 ifTrue: [^ #objectIdentityHash ].
	prim = 1021 ifTrue: [^ #smiIdentityHash ].
	prim = 1022 ifTrue: [^ #charIdentityHash ].
	prim = 1023 ifTrue: [^ #smallfloatIdentityHash ].
	prim = 1024 ifTrue: [^ #behaviorIdentityHash ].
	prim = 1030 ifTrue: [^ #characterAsInteger ].
	prim = 1031 ifTrue: [^ #smallFloatAsInteger ].
	prim = 1032 ifTrue: [^ #smiAsFloat ].
	prim = 1039 ifTrue: [^ #unforwardNonImmediate ].
	prim = 1040 ifTrue: [^ #unforward ].
	prim = 1041 ifTrue: [^ #possibleRoot ].
	prim = 2000 ifTrue: [^ #smiAdd: ].
	prim = 2001 ifTrue: [^ #smiSub: ].
	prim = 2002 ifTrue: [^ #smiMul: ].
	prim = 2003 ifTrue: [^ #smiDivide: ].
	prim = 2004 ifTrue: [^ #smiDiv: ].
	prim = 2005 ifTrue: [^ #smiMod: ].
	prim = 2006 ifTrue: [^ #smiQuo: ].
	prim = 2016 ifTrue: [^ #smiBitAnd: ].
	prim = 2017 ifTrue: [^ #smiBitOr: ].
	prim = 2018 ifTrue: [^ #smiBitXor: ].
	prim = 2019 ifTrue: [^ #smiBitShiftLeft: ].
	prim = 2020 ifTrue: [^ #smiBitShiftRight: ].
	prim = 2032 ifTrue: [^ #smiGreater: ].
	prim = 2033 ifTrue: [^ #smiLess: ].
	prim = 2034 ifTrue: [^ #smiGreaterOrEqual: ].
	prim = 2035 ifTrue: [^ #smiLessOrEqual: ].
	prim = 2036 ifTrue: [^ #smiEquals: ].
	prim = 2037 ifTrue: [^ #smiNotEquals: ].
	prim = 2038 ifTrue: [^ #rawEqualsEquals: ].
	prim = 2039 ifTrue: [^ #rawNotEqualsEquals: ].
	prim = 2048 ifTrue: [^ #rawNewColon: ].
	prim = 2049 ifTrue: [^ #rawNewColonNoInit: ].
	prim = 2064 ifTrue: [^ #pointerAt: ].
	prim = 2065 ifTrue: [^ #maybeContextPointerAt: ].
	prim = 2066 ifTrue: [^ #byteAt: ].
	prim = 2067 ifTrue: [^ #shortAt: ].
	prim = 2068 ifTrue: [^ #wordAt: ].
	prim = 2069 ifTrue: [^ #doubleWordAt: ].
	prim = 3000 ifTrue: [^ #pointerAt:put: ].
	prim = 3001 ifTrue: [^ #storeCheckPointerAt:put: ].
	prim = 3002 ifTrue: [^ #maybeContextPointerAt:put: ].
	prim = 3003 ifTrue: [^ #maybeContextStoreCheckPointerAt:put: ].
	prim = 3004 ifTrue: [^ #byteAt:put: ].
	prim = 3005 ifTrue: [^ #shortAt:put: ].
	prim = 3006 ifTrue: [^ #wordAt:put: ].
	prim = 3007 ifTrue: [^ #doubleWordAt:put: ].
	prim = 6000 ifTrue: [^ #backjumpNoInterrupt ].
	prim = 7016 ifTrue: [^ #jumpWritable: ].
	prim = 7017 ifTrue: [^ #jumpReadOnly: ].
	prim = 7018 ifTrue: [^ #jumpYoung: ].
	prim = 7019 ifTrue: [^ #jumpOld: ].
	prim = 8000 ifTrue: [^ #instanceOf:jumpTrue: ].
	prim = 8001 ifTrue: [^ #instanceOf:jumpFalse: ].
	prim = 8002 ifTrue: [^ #instanceOfOneOf:jumpTrue: ].
	prim = 8003 ifTrue: [^ #instanceOfOneOf:jumpFalse: ].
	^#undefinedUnsafeOp

]

{ #category : #'*ScorchingDev' }
SymbolicBytecodeBuilder >> popIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	tempVectorIndex >= 128  ifTrue: [ 
		^ self addBytecode: 'popIntoRemoteInstVar: ', remoteTempIndex printString, ' ofTemp: ', (tempVectorIndex - 128) printString ].
	self addBytecode: 'popIntoTemp: ', remoteTempIndex printString, ' inVectorAt: ', tempVectorIndex printString 
]

{ #category : #'*ScorchingDev' }
SymbolicBytecodeBuilder >> pushRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [ 
	tempVectorIndex >= 128  ifTrue: [ 
		^ self addBytecode: 'pushRemoteInstVar: ', remoteTempIndex printString, ' ofTemp: ', (tempVectorIndex - 128) printString ].
	self addBytecode: 'pushTemp: ', remoteTempIndex printString, ' inVectorAt: ', tempVectorIndex printString
]
