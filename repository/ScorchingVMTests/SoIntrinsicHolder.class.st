"
I hold primitives descriptors that can be compiled by the primitive descriptor compiler to test unsafe sista operations.
"
Class {
	#name : #SoIntrinsicHolder,
	#superclass : #Object,
	#classVars : [
		'Intrinsified'
	],
	#category : #ScorchingVMTests
}

{ #category : #initialization }
SoIntrinsicHolder class >> initialize [

	Intrinsified := false.
]

{ #category : #compiler }
SoIntrinsicHolder class >> intrinsifyIfNeeded [
	Intrinsified ifTrue: [ ^ self ].
	self methods do: [ :method |
		| intrinsicMethod |
		intrinsicMethod := SoIntrinsicCompiler new compile: method sourceCode.
		intrinsicMethod methodClass: self.
		self methodDict at: method selector put: intrinsicMethod ].
	Intrinsified := true.
	
]

{ #category : #scripts }
SoIntrinsicHolder class >> scripts [
	"Normally used in inspectors based on:
self  methods select: [ :each | each category = #'smi comp' ]
self  methods select: [ :each | each category = #'object access' ]

	-- Generation Of constants --
self do: [ :each |
	| key1 key1B key2 |
	key2 := each selector keywords first.
	key1 := key2 allButLast , '7R:'.
	key1B := key2 allButLast , '9L:'.
	each methodClass compile: key1 , 'x
	^ x ' , key2 , ' 7' classified: each category.
	each methodClass compile: key1B , 'x
	^ 9 ' , key2 , ' x' classified: each category.
	 ]

	-- Generation Of branches --
 self
		do: [ :each | 
			| s i |
			s := each sourceCode copy.
			i := s indexOf: $:.
			s := (s first: i - 1) , 'IfT:' , (s last: s size - i).
			i := s indexOf: $^.
			s := (s first: i - 1) , '^ (' , (s last: s size - i - 1) , ') ifTrue: [true] ifFalse: [false]'.
			each methodClass compile: s  classified: each category.
			
			s := each sourceCode copy.
			i := s indexOf: $:.
			s := (s first: i - 1) , 'IfF:' , (s last: s size - i).
			i := s indexOf: $^.
			s := (s first: i - 1) , '^ (' , (s last: s size - i - 1) , ') ifFalse: [false] ifTrue: [true]'.
			each methodClass compile: s  classified: each category.
			 ]
		
	-- Test gen --
	self do: [ :s | 
	SoInlinedPrimitiveTest compile: 'test' , s capitalized , String cr , String tab , 'self checkPrimitive: #' , s , ' rcvr: 1 args: #()'
		classified: #tests ]
	"
]

{ #category : #jumps }
SoIntrinsicHolder >> backjumpAlwaysInterrupt [
	| t |
	t := 0.
	1 to: 10 by: 2 alwaysInterruptDo: [ :i |
		t := t smiAdd: 1 ].
	^ t
]

{ #category : #jumps }
SoIntrinsicHolder >> backjumpAlwaysInterrupt2 [
	| t |
	t := 0.
	1 to: 5 by: 1 alwaysInterruptDo: [ :i |
		t := t smiAdd: 1 ].
	^ t
]

{ #category : #jumps }
SoIntrinsicHolder >> backjumpNoInterrupt [
	| t |
	t := 0.
	1 to: 10 by: 2 noInterruptDo: [ :i |
		t := t smiAdd: 1 ].
	^ t
]

{ #category : #jumps }
SoIntrinsicHolder >> backjumpNoInterrupt2 [
	| t |
	t := 0.
	1 to: 5 by: 1 noInterruptDo: [ :i |
		t := t smiAdd: 1 ].
	^ t
]

{ #category : #others }
SoIntrinsicHolder >> behaviorIdentityHash: obj [
	^ obj behaviorIdentityHash
]

{ #category : #'obj access' }
SoIntrinsicHolder >> byte: obj at: idx [
	^ obj byteAt: idx
]

{ #category : #'obj access' }
SoIntrinsicHolder >> byte: obj at: idx put: val [
	^ obj byteAt: idx put: val
]

{ #category : #'obj access' }
SoIntrinsicHolder >> byteAt2: obj [
	^ obj byteAt: 2
]

{ #category : #'obj access' }
SoIntrinsicHolder >> byteAt2: obj put: val [
	^ obj byteAt: 2 put: val
]

{ #category : #others }
SoIntrinsicHolder >> charIdentityHash: obj [
	^ obj charIdentityHash
]

{ #category : #others }
SoIntrinsicHolder >> characterAsInteger: char [
	^ char characterAsInteger
]

{ #category : #'obj access' }
SoIntrinsicHolder >> immCheckByte: obj at: idx put: val [
	^ obj immCheckByteAt: idx put: val
]

{ #category : #'obj access' }
SoIntrinsicHolder >> immCheckByteAt2: obj put: val [
	^ obj immCheckByteAt: 2 put: val
]

{ #category : #'obj access' }
SoIntrinsicHolder >> immCheckPointer: obj at: idx put: val [
	^ obj immCheckPointerAt: idx put: val
]

{ #category : #'obj access' }
SoIntrinsicHolder >> immCheckPointerAt2: obj put: val [
	^ obj immCheckPointerAt: 2 put: val
]

{ #category : #'obj access' }
SoIntrinsicHolder >> immCheckStoreCheckPointer: obj at: idx put: val [
	^ obj immCheckStoreCheckPointerAt: idx put: val
]

{ #category : #'obj access' }
SoIntrinsicHolder >> immCheckStoreCheckPointerAt2: obj put: val [
	^ obj immCheckStoreCheckPointerAt: 2 put: val
]

{ #category : #jumps }
SoIntrinsicHolder >> jumpOld: obj [
	obj ifOld: [ ^true ].
	^ false
	
]

{ #category : #jumps }
SoIntrinsicHolder >> jumpReadOnly: obj [
	obj ifReadOnly: [ ^true ].
	^ false
	
]

{ #category : #jumps }
SoIntrinsicHolder >> jumpWritable: obj [
	obj ifWritable: [ ^true ].
	^ false
	
]

{ #category : #jumps }
SoIntrinsicHolder >> jumpYoung: obj [
	obj ifYoung: [ ^true ].
	^ false
	
]

{ #category : #'obj access' }
SoIntrinsicHolder >> maybeContextPointer: obj at: idx [
	^ obj maybeContextPointerAt: idx
]

{ #category : #'obj access' }
SoIntrinsicHolder >> maybeContextPointer: obj at: idx put: val [
	^ obj immCheckPointerAt: idx put: val
]

{ #category : #'obj access' }
SoIntrinsicHolder >> maybeContextPointerAt2: obj [ 
	^ obj maybeContextPointerAt: 2
]

{ #category : #'obj access' }
SoIntrinsicHolder >> maybeContextPointerAt2: obj put: val [
	^ obj immCheckPointerAt: 2 put: val
]

{ #category : #'obj access' }
SoIntrinsicHolder >> maybeContextStoreCheckPointer: obj at: idx put: val [
	^ obj maybeContextStoreCheckPointerAt: idx put: val
]

{ #category : #'obj access' }
SoIntrinsicHolder >> maybeContextStoreCheckPointerAt2: obj put: val [
	^ obj maybeContextStoreCheckPointerAt: 2 put: val
]

{ #category : #others }
SoIntrinsicHolder >> numBytes: arg [
	^ arg numBytes
]

{ #category : #others }
SoIntrinsicHolder >> numDoubleWords: arg [
	^ arg numDoubleWords
]

{ #category : #others }
SoIntrinsicHolder >> numShorts: arg [
	^ arg numShorts
]

{ #category : #others }
SoIntrinsicHolder >> numSlots: arg [
	^ arg numSlots
]

{ #category : #others }
SoIntrinsicHolder >> numWords: arg [
	^ arg numWords
]

{ #category : #'class index' }
SoIntrinsicHolder >> objChar: obj [ 
	obj instanceOf: Character ifTrue: [ ^ true ].
	^ false
]

{ #category : #'class index' }
SoIntrinsicHolder >> objFalse: obj [ 
	obj instanceOf: False ifTrue: [ ^ true ].
	^ false
]

{ #category : #'class index' }
SoIntrinsicHolder >> objNil: obj [ 
	obj instanceOf: UndefinedObject ifTrue: [ ^ true ].
	^ false
]

{ #category : #'class index' }
SoIntrinsicHolder >> objNotChar: obj [ 
	obj instanceOf: Character ifFalse: [ ^ false ].
	^ true
]

{ #category : #'class index' }
SoIntrinsicHolder >> objNotFalse: obj [ 
	obj instanceOf: False ifFalse: [ ^ false ].
	^ true
]

{ #category : #'class index' }
SoIntrinsicHolder >> objNotNil: obj [ 
	obj instanceOf: UndefinedObject ifFalse: [ ^ false ].
	^ true
]

{ #category : #'class index' }
SoIntrinsicHolder >> objNotObject: obj [ 
	obj instanceOf: Object ifFalse: [ ^ false ].
	^ true
]

{ #category : #'class index many' }
SoIntrinsicHolder >> objNotObjectArray: obj [ 
	obj instanceOfOneOf: {Object.Array} ifFalse: [ ^ false ].
	^ true
]

{ #category : #'class index' }
SoIntrinsicHolder >> objNotSmallFloat: obj [ 
	obj instanceOf: SmallFloat64 ifFalse: [ ^ false ].
	^ true
]

{ #category : #'class index' }
SoIntrinsicHolder >> objNotSmi: obj [ 
	obj instanceOf: SmallInteger ifFalse: [ ^ false ].
	^ true
]

{ #category : #'class index many' }
SoIntrinsicHolder >> objNotSmiChar: obj [ 
	obj instanceOfOneOf: {SmallInteger.Character} ifFalse: [ ^ false ].
	^ true
]

{ #category : #'class index many' }
SoIntrinsicHolder >> objNotSmiCharArray: obj [ 
	obj instanceOfOneOf: {SmallInteger.Character.Array} ifFalse: [ ^ false ].
	^ true
]

{ #category : #'class index many' }
SoIntrinsicHolder >> objNotSmiCharSmallFloat: obj [ 
	obj instanceOfOneOf: {SmallInteger.Character.SmallFloat64} ifFalse: [ ^ false ].
	^ true
]

{ #category : #'class index many' }
SoIntrinsicHolder >> objNotSmiCharSmallFloatArray: obj [ 
	obj instanceOfOneOf: {SmallInteger.Character.SmallFloat64.Array} ifFalse: [ ^ false ].
	^ true
]

{ #category : #'class index many' }
SoIntrinsicHolder >> objNotSmiLargeInt: obj [ 
	obj instanceOfOneOf: {SmallInteger.LargePositiveInteger.LargeNegativeInteger} ifFalse: [ ^ false ].
	^ true
]

{ #category : #'class index' }
SoIntrinsicHolder >> objNotTrue: obj [ 
	obj instanceOf: True ifFalse: [ ^ false ].
	^ true
]

{ #category : #'class index' }
SoIntrinsicHolder >> objObject: obj [ 
	obj instanceOf: Object ifTrue: [ ^ true ].
	^ false
]

{ #category : #'class index many' }
SoIntrinsicHolder >> objObjectArray: obj [ 
	obj instanceOfOneOf: {Array.Object} ifTrue: [ ^ true ].
	^ false
]

{ #category : #'class index' }
SoIntrinsicHolder >> objSmallFloat: obj [ 
	obj instanceOf: SmallFloat64 ifTrue: [ ^ true ].
	^ false
]

{ #category : #'class index' }
SoIntrinsicHolder >> objSmi: obj [ 
	obj instanceOf: SmallInteger ifTrue: [ ^ true ].
	^ false
]

{ #category : #'class index many' }
SoIntrinsicHolder >> objSmiChar: obj [ 
	obj instanceOfOneOf: {SmallInteger.Character} ifTrue: [ ^ true ].
	^ false
]

{ #category : #'class index many' }
SoIntrinsicHolder >> objSmiCharArray: obj [ 
	obj instanceOfOneOf: {SmallInteger.Character.Array} ifTrue: [ ^ true ].
	^ false
]

{ #category : #'class index many' }
SoIntrinsicHolder >> objSmiCharSmallFloat: obj [ 
	obj instanceOfOneOf: {SmallInteger.Character.SmallFloat64} ifTrue: [ ^ true ].
	^ false
]

{ #category : #'class index many' }
SoIntrinsicHolder >> objSmiCharSmallFloatArray: obj [ 
	obj instanceOfOneOf: {SmallInteger.Character.SmallFloat64.Array} ifTrue: [ ^ true ].
	^ false
]

{ #category : #'class index many' }
SoIntrinsicHolder >> objSmiLargeInt: obj [ 
	obj instanceOfOneOf: {SmallInteger.LargePositiveInteger.LargeNegativeInteger} ifTrue: [ ^ true ].
	^ false
]

{ #category : #'class index' }
SoIntrinsicHolder >> objTrue: obj [ 
	obj instanceOf: True ifTrue: [ ^ true ].
	^ false
]

{ #category : #others }
SoIntrinsicHolder >> objectIdentityHash: obj [
	^ obj objectIdentityHash
]

{ #category : #'obj access' }
SoIntrinsicHolder >> pointer: obj at: idx [
	^ obj pointerAt: idx
]

{ #category : #'obj access' }
SoIntrinsicHolder >> pointer: obj at: idx put: val [
	^ obj pointerAt: idx put: val
]

{ #category : #'obj access' }
SoIntrinsicHolder >> pointerAt2: obj [ 
	^ obj pointerAt: 2
]

{ #category : #'obj access' }
SoIntrinsicHolder >> pointerAt2: obj put: val [
	^ obj pointerAt: 2 put: val
]

{ #category : #others }
SoIntrinsicHolder >> possibleRoot: x [
	^ x possibleRoot
]

{ #category : #others }
SoIntrinsicHolder >> rawClass: arg [
	^ arg rawClass
]

{ #category : #comp }
SoIntrinsicHolder >> rawEqualsEquals: x and: y [
	^ x rawEqualsEquals: y
]

{ #category : #comp }
SoIntrinsicHolder >> rawEqualsEqualsIfF: x and: y [
	^ (x rawEqualsEquals: y) ifFalse: [false] ifTrue: [true]
]

{ #category : #comp }
SoIntrinsicHolder >> rawEqualsEqualsIfT: x and: y [
	^ (x rawEqualsEquals: y) ifTrue: [true] ifFalse: [false]
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNew11 [
	"Assumes enough space in Eden "
	^ SoGuineaPig11 rawNew
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNew3 [
	"Assumes enough space in Eden "
	^ SoGuineaPig3 rawNew
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNew300 [
	"Assumes enough space in Eden "
	^ SoGuineaPig300 rawNew
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColon11R [
	^ Array rawNewColon: 11
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColon11RB [
	^ ByteArray rawNewColon: 11
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColon300R [
	^ Array rawNewColon: 300
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColon300RB [
	^ ByteArray rawNewColon: 300
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColon5R [
	^ Array rawNewColon: 5
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColon5RB [
	^ ByteArray rawNewColon: 5
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColon: sz [
	<bug>
	^ Array rawNewColon: sz
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColonB: sz [
	<bug>
	^ ByteArray rawNewColon: sz
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColonNoInit11R [
	| a |
	a :=  Array rawNewColonNoInit: 11.
	1 to: a numSlots by: 1 noInterruptDo: [ :i |
		a pointerAt: i put: #val ].
	^ a
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColonNoInit11RB [
	| a |
	a :=  ByteArray rawNewColon: 11.
	1 to: a numBytes by: 1 noInterruptDo: [ :i |
		a byteAt: i put: 42 ].
	^ a
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColonNoInit300R [
	| a |
	a :=  Array rawNewColonNoInit: 300.
	1 to: a numSlots by: 1 noInterruptDo: [ :i |
		a pointerAt: i put: #val ].
	^ a
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColonNoInit300RB [
	| a |
	a :=  ByteArray rawNewColon: 300.
	1 to: a numBytes by: 1 noInterruptDo: [ :i |
		a byteAt: i put: 42 ].
	^ a
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColonNoInit5R [
	| a |
	a :=  Array rawNewColonNoInit: 5.
	1 to: a numSlots by: 1 noInterruptDo: [ :i |
		a pointerAt: i put: #val ].
	^ a
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColonNoInit5RB [
	| a |
	a :=  ByteArray rawNewColon: 5.
	1 to: a numBytes by: 1 noInterruptDo: [ :i |
		a byteAt: i put: 42 ].
	^ a
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColonNoInit: sz [
	| a |
	a := Array rawNewColonNoInit: sz.
	1 to: a numSlots by: 1 noInterruptDo: [ :i |
		a pointerAt: i put: #val ].
	^ a 
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewColonNoInitB: sz [
	| a |
	a := ByteArray rawNewColonNoInit: sz.
	1 to: a numBytes by: 1 noInterruptDo: [ :i |
		a byteAt: i put: 42 ].
	^ a
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewNoInit11 [
	"Assumes enough space in Eden "
	| gp |
	"Can't let the guinea pig non initialized..."
	gp := SoGuineaPig11 rawNewNoInit.
	gp pointerAt: 1 put: #val.
	gp pointerAt: 2 put: #val.
	gp pointerAt: 3 put: #val.
	gp pointerAt: 4 put: #val.
	gp pointerAt: 5 put: #val.
	gp pointerAt: 6 put: #val.
	gp pointerAt: 7 put: #val.
	gp pointerAt: 8 put: #val.
	gp pointerAt: 9 put: #val.
	gp pointerAt: 10 put: #val.
	gp pointerAt: 11 put: #val.
	^gp
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewNoInit3 [
	"Assumes enough space in Eden "
	| gp |
	"Can't let the guinea pig non initialized..."
	gp := SoGuineaPig3 rawNewNoInit.
	gp pointerAt: 1 put: #val.
	gp pointerAt: 2 put: #val.
	gp pointerAt: 3 put: #val.
	^gp
]

{ #category : #instantiation }
SoIntrinsicHolder >> rawNewNoInit300 [
	| a |
	a := SoGuineaPig300 rawNewNoInit.
	1 to: a numSlots by: 1 noInterruptDo: [ :i |
		a pointerAt: i put: #val ].
	^ a
]

{ #category : #comp }
SoIntrinsicHolder >> rawNotEqualsEquals: x and: y [
	^ x rawNotEqualsEquals: y
]

{ #category : #comp }
SoIntrinsicHolder >> rawNotEqualsEqualsIfF: x and: y [
	^ (x rawNotEqualsEquals: y) ifFalse: [false] ifTrue: [true]
]

{ #category : #comp }
SoIntrinsicHolder >> rawNotEqualsEqualsIfT: x and: y [
	^ (x rawNotEqualsEquals: y) ifTrue: [true] ifFalse: [false]
]

{ #category : #others }
SoIntrinsicHolder >> smallFloatAsInteger: f [
	^ f smallFloatAsInteger
]

{ #category : #others }
SoIntrinsicHolder >> smallfloatIdentityHash: obj [
	^ obj smallfloatIdentityHash
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiAdd7R:x [
	^ x smiAdd: 7
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiAdd9L:x [
	^ 9 smiAdd: x
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiAdd: x and: y [
	^ x smiAdd: y
]

{ #category : #others }
SoIntrinsicHolder >> smiAsFloat: smi [
	^ smi smiAsFloat
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiBitAnd7R:x [
	^ x smiBitAnd: 7
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiBitAnd9L:x [
	^ 9 smiBitAnd: x
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiBitAnd: x and: y [
	^ x smiBitAnd: y
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiBitOr7R:x [
	^ x smiBitOr: 7
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiBitOr9L:x [
	^ 9 smiBitOr: x
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiBitOr: x and: y [
	^ x smiBitOr: y
]

{ #category : #'smi shift' }
SoIntrinsicHolder >> smiBitShiftLeft2R: x [ 
	^ x smiBitShiftLeft: 2
]

{ #category : #'smi shift' }
SoIntrinsicHolder >> smiBitShiftLeft: x and: y [
	^ x smiBitShiftLeft: y
]

{ #category : #'smi shift' }
SoIntrinsicHolder >> smiBitShiftRight2R: x [ 
	^ x smiBitShiftRight: 2
]

{ #category : #'smi shift' }
SoIntrinsicHolder >> smiBitShiftRight: x and: y [
	^ x smiBitShiftRight: y
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiBitXor7R:x [
	^ x smiBitXor: 7
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiBitXor9L:x [
	^ 9 smiBitXor: x
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiBitXor: x and: y [
	^ x smiBitXor: y
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiDiv7R:x [
	^ x smiDiv: 7
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiDiv9L:x [
	^ 9 smiDiv: x
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiDiv: x and: y [
	^ x smiDiv: y
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiDivide7R:x [
	^ x smiDivide: 7
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiDivide9L:x [
	^ 9 smiDivide: x
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiDivide: x and: y [
	^ x smiDivide: y
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiEquals7R:x [
	^ x smiEquals: 7
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiEquals7RIfF:x [
	^ (x smiEquals: 7) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiEquals7RIfT:x [
	^ (x smiEquals: 7) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiEquals9L:x [
	^ 9 smiEquals: x
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiEquals9LIfF:x [
	^ (9 smiEquals: x) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiEquals9LIfT:x [
	^ (9 smiEquals: x) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiEquals: x and: y [
	^ x smiEquals: y
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiEqualsIfF: x and: y [
	^ (x smiEquals: y) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiEqualsIfT: x and: y [
	^ (x smiEquals: y) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreater7R:x [
	^ x smiGreater: 7
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreater7RIfF:x [
	^ (x smiGreater: 7) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreater7RIfT:x [
	^ (x smiGreater: 7) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreater9L:x [
	^ 9 smiGreater: x
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreater9LIfF:x [
	^ (9 smiGreater: x) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreater9LIfT:x [
	^ (9 smiGreater: x) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreater: x and: y [
	^ x smiGreater: y
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreaterIfF: x and: y [
	^ (x smiGreater: y) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreaterIfT: x and: y [
	^ (x smiGreater: y) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreaterOrEqual7R:x [
	^ x smiGreaterOrEqual: 7
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreaterOrEqual7RIfF:x [
	^ (x smiGreaterOrEqual: 7) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreaterOrEqual7RIfT:x [
	^ (x smiGreaterOrEqual: 7) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreaterOrEqual9L:x [
	^ 9 smiGreaterOrEqual: x
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreaterOrEqual9LIfF:x [
	^ (9 smiGreaterOrEqual: x) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreaterOrEqual9LIfT:x [
	^ (9 smiGreaterOrEqual: x) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreaterOrEqual: x and: y [
	^ x smiGreaterOrEqual: y
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreaterOrEqualIfF: x and: y [
	^ (x smiGreaterOrEqual: y) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiGreaterOrEqualIfT: x and: y [
	^ (x smiGreaterOrEqual: y) ifTrue: [true] ifFalse: [false]
]

{ #category : #others }
SoIntrinsicHolder >> smiIdentityHash: obj [
	^ obj smiIdentityHash
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLess7R:x [
	^ x smiLess: 7
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLess7RIfF:x [
	^ (x smiLess: 7) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLess7RIfT:x [
	^ (x smiLess: 7) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLess9L:x [
	^ 9 smiLess: x
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLess9LIfF:x [
	^ (9 smiLess: x) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLess9LIfT:x [
	^ (9 smiLess: x) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLess: x and: y [
	^ x smiLess: y
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLessIfF: x and: y [
	^ (x smiLess: y) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLessIfT: x and: y [
	^ (x smiLess: y) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLessOrEqual7R:x [
	^ x smiLessOrEqual: 7
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLessOrEqual7RIfF:x [
	^ (x smiLessOrEqual: 7) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLessOrEqual7RIfT:x [
	^ (x smiLessOrEqual: 7) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLessOrEqual9L:x [
	^ 9 smiLessOrEqual: x
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLessOrEqual9LIfF:x [
	^ (9 smiLessOrEqual: x) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLessOrEqual9LIfT:x [
	^ (9 smiLessOrEqual: x) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLessOrEqual: x and: y [
	^ x smiLessOrEqual: y
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLessOrEqualIfF: x and: y [
	^ (x smiLessOrEqual: y) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiLessOrEqualIfT: x and: y [
	^ (x smiLessOrEqual: y) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiMod7R:x [
	^ x smiMod: 7
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiMod9L:x [
	^ 9 smiMod: x
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiMod: x and: y [
	^ x smiMod: y
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiMul7R:x [
	^ x smiMul: 7
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiMul9L:x [
	^ 9 smiMul: x
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiMul: x and: y [
	^ x smiMul: y
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiNotEquals7R:x [
	^ x smiNotEquals: 7
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiNotEquals7RIfF:x [
	^ (x smiNotEquals: 7) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiNotEquals7RIfT:x [
	^ (x smiNotEquals: 7) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiNotEquals9L:x [
	^ 9 smiNotEquals: x
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiNotEquals9LIfF:x [
	^ (9 smiNotEquals: x) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiNotEquals9LIfT:x [
	^ (9 smiNotEquals: x) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiNotEquals: x and: y [
	^ x smiNotEquals: y
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiNotEqualsIfF: x and: y [
	^ (x smiNotEquals: y) ifFalse: [false] ifTrue: [true]
]

{ #category : #'smi comp' }
SoIntrinsicHolder >> smiNotEqualsIfT: x and: y [
	^ (x smiNotEquals: y) ifTrue: [true] ifFalse: [false]
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiQuo7R:x [
	^ x smiQuo: 7
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiQuo9L:x [
	^ 9 smiQuo: x
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiQuo: x and: y [
	^ x smiQuo: y
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiSub7R:x [
	^ x smiSub: 7
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiSub9L:x [
	^ 9 smiSub: x
]

{ #category : #'smi arithmetic' }
SoIntrinsicHolder >> smiSub: x and: y [
	^ x smiSub: y
]

{ #category : #'obj access' }
SoIntrinsicHolder >> storeCheckPointer: obj at: idx put: val [
	^ obj storeCheckPointerAt: idx put: val
]

{ #category : #'obj access' }
SoIntrinsicHolder >> storeCheckPointerAt2: obj put: val [
	^ obj storeCheckPointerAt: 2 put: val
]

{ #category : #others }
SoIntrinsicHolder >> unforward: x [
	^ x unforward
]

{ #category : #others }
SoIntrinsicHolder >> unforwardNonImmediate: x [
	^ x unforwardNonImmediate
]
