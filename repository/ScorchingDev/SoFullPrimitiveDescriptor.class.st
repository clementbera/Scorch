"
I am compiled ahead of time using Scorch development tools. Cannot be compiled without the development tools.

Descriptors:
> All blocks are inlined.
> All temps are at method level
> branches have to match template (ifReadOnly, etc) and loops use to:dy:interruptDo: scheme
> All sends must be recognized based on unsafe op specifications.
> nullary op must be sent on #nullary.
> last return must be explicit (#fallThough means fallThrough)
"
Class {
	#name : #SoFullPrimitiveDescriptor,
	#superclass : #Object,
	#category : #'ScorchingDev-primitive'
}

{ #category : #'as yet unclassified' }
SoFullPrimitiveDescriptor class >> genAllDescriptors [
	SoPrimitiveInliner class
		compile: 'byteDescriptors 
	<generated>
	"header literals bytes"
	^ self descriptorCacheFrom: #(
' , (SoIntrinsicCompiler new compileAllAsString: self methods), '	)'
		classified: #constant.
	SoPrimitiveInliner flushCaches.
]

{ #category : #'descriptors - complex' }
SoFullPrimitiveDescriptor >> primArrayReplaceFrom: start to: stop with: replacement startingAt: repStart [ 
	"Traps on types & array operands before"
	| repOff |
	(1 smiLessOrEqual: start) 
		ifTrue: [ 
			(1 smiLessOrEqual: repStart)
				ifTrue: [ 
					(stop smiLessOrEqual: self numSlots) 
						ifTrue: [ 
							(((stop smiSub: start) smiAdd: repStart) smiLessOrEqual: replacement numSlots)
								ifTrue: [ 
									self possibleRoot.
									repOff := repStart smiSub: start.
									start to: stop by: 1 noInterruptDo: [ :i |
										self pointerAt: i put: (replacement pointerAt: (repOff smiAdd: i)) ].
									^ self  ]  ]  ]  ] .
	"false through to method body - parsed from Smalltalk"
	^ #fallThrough
	
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primByteAt: index [
	^ self byteAt: index
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primByteAt: index put: value [
	^ self byteAt: index put: value
]

{ #category : #'descriptors - complex' }
SoFullPrimitiveDescriptor >> primByteAtAllPut: value [
	"can make a pointer vectorized version."
	1 to: self numBytes by: 1 noInterruptDo: [ :i |
		self byteAt: i put: value ].
	^ self
	
]

{ #category : #'descriptors - complex' }
SoFullPrimitiveDescriptor >> primByteEquals: otherByteObject [
	"Traps on types of array operands before"
	"Assumes 2 byte objects of the same size
	 Pointer size vectorization, unused bytes are zeroed."
	1 to: self numSlots by: 1 noInterruptDo: [ :i |
		((self pointerAt: i) smiEquals: (otherByteObject pointerAt: i)) ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #'descriptors - complex' }
SoFullPrimitiveDescriptor >> primByteReplaceFrom: start to: stop with: replacement startingAt: repStart [ 
	"Traps on types & array operands before"
	| repOff |
	(1 smiLessOrEqual: start) 
		ifTrue: [ 
			(1 smiLessOrEqual: repStart)
				ifTrue: [ 
					(stop smiLessOrEqual: self numBytes) 
						ifTrue: [ 
							(((stop smiSub: start) smiAdd: repStart) smiLessOrEqual: replacement numBytes)
								ifTrue: [ 
									repOff := repStart smiSub: start.
									start to: stop by: 1 noInterruptDo: [ :i |
										self byteAt: i put: (replacement byteAt: (repOff smiAdd: i)) ].
									^ self  ]  ]  ]  ] .
	"false through to method body - parsed from Smalltalk"
	^ #fallThrough
	
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primByteSize [
	^ self numBytes
		 
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primCharacterAsInteger [
	^ self characterAsInteger
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primClass [
	"If inline this way receiver has a trap"
	^ self rawClass
]

{ #category : #'descriptors - complex' }
SoFullPrimitiveDescriptor >> primHashMultiply [
	| low |
	low := self smiBitAnd: 16383.
	^(16r260D smiMul: low)
		 smiAdd: ((((16r260D smiMul: (self smiBitShiftLeft: 14)) 
			smiAdd: (16r0065 smiMul: low)) 
				smiBitAnd: 16383) 
					smiMul: 16384)
]

{ #category : #'descriptors - almost simple' }
SoFullPrimitiveDescriptor >> primNotPointerEquals: arg [
	"If inline this way receiver has a trap"
	^ self rawNotEqualsEquals: arg unforward
		 
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primPointerAt: index [
	^ self pointerAt: index
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primPointerAt: index put: value [
	^ self storeCheckPointerAt: index put: value
]

{ #category : #'descriptors - almost simple' }
SoFullPrimitiveDescriptor >> primPointerEquals: arg [
	"If inline this way receiver has a trap"
	^ self rawEqualsEquals: arg unforward 
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primPointerSize [
	^ self numSlots
		 
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiAddNoOverflow: arg [
	^ self smiAdd: arg

]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiBitAnd: arg [
	^ self smiBitAnd: arg
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiBitOr: arg [
	^ self smiBitOr: arg
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiBitShiftLeft: arg [
	"Comes from bitShift no need to negate arg"
	^ self smiBitShiftLeft: arg
]

{ #category : #'descriptors - almost simple' }
SoFullPrimitiveDescriptor >> primSmiBitShiftRight: arg [
	"Comes from bitShift no need to negate arg"
	^ self smiBitShiftRight: (0 smiSub: arg)
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiBitXor: arg [
	^ self smiBitXor: arg
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiDivNoOverflowNoZero: arg [
	^ self smiDiv: arg

]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiEquals: arg [
	^ self smiEquals: arg
]

{ #category : #'descriptors - almost simple' }
SoFullPrimitiveDescriptor >> primSmiGreater: arg [
	^ arg smiLess: self
]

{ #category : #'descriptors - almost simple' }
SoFullPrimitiveDescriptor >> primSmiGreaterOrEqual: arg [
	^ arg smiLessOrEqual: self
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiLess: arg [
	^ self smiLess: arg
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiLessOrEqual: arg [
	^ self smiLessOrEqual: arg
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiMod: arg [
	"Arg guranteed non zero, Smis."
	^ self smiMod: arg

]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiMulNoOverflow: arg [
	^ self smiMul: arg

]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiNotEquals: arg [
	^ self smiNotEquals: arg
]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiQuoNoOverflowNoZero: arg [
	^ self smiQuo: arg

]

{ #category : #'descriptors - simple' }
SoFullPrimitiveDescriptor >> primSmiSubNoOverflow: arg [
	^ self smiSub: arg

]
