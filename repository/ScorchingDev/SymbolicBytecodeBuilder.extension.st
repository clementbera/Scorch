Extension { #name : #SymbolicBytecodeBuilder }

{ #category : #'*ScorchingDev' }
SymbolicBytecodeBuilder >> branchIfInstanceOf: lit distance: offset [
	"Print the Unconditional Jump bytecode."

	self addBytecode: 'jumpIfInstanceOf: ' , lit printString , ' to: ' , (scanner pc + (offset - 32768)) printString.
]

{ #category : #'*ScorchingDev' }
SymbolicBytecodeBuilder >> branchIfNotInstanceOf: lit distance: offset [
	"Print the Unconditional Jump bytecode."

	self addBytecode: 'jumpIfNotInstanceOf: ' , lit printString , ' to: ' , (scanner pc + offset) printString.
]

{ #category : #'*ScorchingDev' }
SymbolicBytecodeBuilder >> callPrimitive: primNumber [
	"Print the callPrimitive bytecode."

	| isInlined |
	isInlined := primNumber >= (1 << 15)
		ifTrue: [ 'Inlined' ]
		ifFalse: [ '' ].
	primNumber >= (1 << 15)
		ifTrue: [(#((2065 #UByteAt)
			(3001 UByteAtPut)
			(1011 UPointerNew)
			(1003 UByteNumBytes)
			(1030 UCharacterAsInteger)
			(1000 UClass)
			(1020 UIdentityHash)
			(2064 UPointerAt)
			(3000 UPointerAtPut)
			(1002 UPointerBasicSize)
			(1001 UPointerNumSlots)
			(2000 USmiAdd)
			(2016 USmiBitAnd)
			(2017 USmiBitOr)
			(2019 USmiBitShiftLeft)
			(2020 USmiBitShiftRight)
			(2018 USmiBitXor)
			(2003 USmiDiv)
			(2036 USmiEqual)
			(2032 USmiGreater)
			(2034 USmiGreaterOrEqual)
			(2033 USmiLess)
			(2035 USmiLessOrEqual)
			(2004 USmiMod)
			(2005 USmiMod2)
			(2002 USmiMul)
			(2037 USmiNotEqual)
			(2006 USmiQuo)
			(2001 USmiSub)) detect: [:tuple| tuple first = (primNumber bitAnd: 1 << 15 - 1)] ifFound: [ :tuple | ^ self addBytecode: tuple last ]) ].
	self addBytecode: 'call' , isInlined , 'Primitive: ' , primNumber printString
]

{ #category : #'*ScorchingDev' }
SymbolicBytecodeBuilder >> jumpOrPopIfNotInstanceOf: lit distance: offset [
	"Print the Unconditional Jump bytecode."

	offset < 0 ifTrue: 
		[ ^ self addBytecode: 'jumpIfInstanceOf: ' , lit printString , ' to: ' , (scanner pc + (offset + 32768)) printString ].
	self addBytecode: 'jumpIfNotInstanceOf: ' , lit printString , ' to: ' , (scanner pc + offset) printString.
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
