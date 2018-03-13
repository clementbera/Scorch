"
Makes sure all unsafe operations of Sista are working just fine.

The methods to tests are encoded in SoInlinedPrimitiveTestMethodsHolder and needs to be compiled with an intrinsic compiler (to unsafe bytecode operations).

"
Class {
	#name : #SoIntrinsicTest,
	#superclass : #TestCase,
	#instVars : [
		'guineaPig'
	],
	#category : #ScorchingVMTests
}

{ #category : #'tests - support' }
SoIntrinsicTest >> assertRawNewResult: res class: cls expectedValue: expectedVal description: description size: size [
	self assert: res class == cls description: description.
	1 to: size do: [ :i |
		self assert: (res instVarAt: i) == expectedVal description: description ].
	res class isFixed ifTrue: [ ^ self ].
	self assert: res size == size description: description.
]

{ #category : #'test helper' }
SoIntrinsicTest >> checkPrimitive: selector args: args against: expectedResult [
	"Unfortunately here red test = crash, so you can afford running expected failures"
	(thisContext sender method hasPragmaNamed: 'expectedFailure') ifTrue: [ ^ self ].
	^ self 
		checkPrimitive: selector 
		args: args 
		block: [ :results |
			self assert: results first = expectedResult description: 'Interpreter failure'.
			self assert: results second = expectedResult description: 'jit failure' ]
]

{ #category : #'test helper' }
SoIntrinsicTest >> checkPrimitive: selector args: args block: block [
	| results |
	FileStream stdout << '[Intrinsic test started (Red test = VM crash): ' << selector << '... '.
	[results := self exec: SoIntrinsicHolder >> selector withArgs: args.
	FileStream stdout << ' Run done; '.
	block value: results]
		ensure:
			[FileStream stdout << 'Assertion done]'.
			 FileStream stdout cr].
]

{ #category : #'test helper' }
SoIntrinsicTest >> exec: cm withArgs: args [
	| results |
	results := {0 . 0}.
	"The exec: method is installed temporarily for the JIT to kick in properly"
	SoIntrinsicHolder compile: (self genSourcesToCall: cm) classified: #generatedDuringTests.
	[results at: 1 put: (guineaPig exec: args). "interpreter result"
	1 to: 5 do: [ :i | guineaPig exec: args ]. "triggering the JIT"
	results at: 2 put: (guineaPig exec: args). "jit result"]
		ensure: [ SoIntrinsicHolder removeSelector: #exec: ].
	^ results
]

{ #category : #'test helper' }
SoIntrinsicTest >> genSourcesToCall: cm [
	"This generates a method calling the method with the primitive so that the JIT can properly kick in."
	"self new genSourcesToCall: SoIntrinsicHolder >> #byte:at:"
	| s keywords |
	s := '' writeStream.
	s << 'exec: args
	^ self '.
	cm selector isUnary 
		ifTrue: [ s << cm selector ]
		ifFalse: [ 
			keywords := cm selector keywords.
			keywords withIndexDo: [ :kw :i |
				s 
					<< kw 
					<< ' (args at: '.
				i printOn: s.
				s << ') ' ] ].
	^ s contents
]

{ #category : #initialization }
SoIntrinsicTest >> setUp [
	SoIntrinsicHolder intrinsifyIfNeeded.
	guineaPig := SoIntrinsicHolder new.
]

{ #category : #'tests - expected failures' }
SoIntrinsicTest >> testBackjumpAlwaysInterrupt [
	<expectedFailure>
	self 
		checkPrimitive: #backjumpAlwaysInterrupt
		args: #() 
		against: 5.
		self 
		checkPrimitive: #backjumpAlwaysInterrupt2
		args: #() 
		against: 5
]

{ #category : #tests }
SoIntrinsicTest >> testBackjumpNoInterrupt [
	self 
		checkPrimitive: #backjumpNoInterrupt
		args: #() 
		against: 5.
	self 
		checkPrimitive: #backjumpNoInterrupt2
		args: #() 
		against: 5
]

{ #category : #tests }
SoIntrinsicTest >> testBehaviorIdentityHash [
	{Object . Array . Array class } do: [ :each | 
		self 
			checkPrimitive: #behaviorIdentityHash:
			args: { each } 
			against: each basicIdentityHash ]
]

{ #category : #tests }
SoIntrinsicTest >> testByteAt [
	{ #[4 5 6] . 2 . #[4 5 6] . 1 . #[4 5 6] . 3 } pairsDo: [ :byteArray :index |
		self 
			checkPrimitive: #byte:at:
			args: {byteArray . index}
			against: (byteArray at: index) ].
	self 
			checkPrimitive: #byteAt2:
			args: {#[3 4 5]}
			against: (#[3 4 5] at: 2)
	
]

{ #category : #tests }
SoIntrinsicTest >> testByteAtPut [
	| cpy |
	{ #[1 2 3] . 2 . #[1 2 3] . 1 . #[1 2 3] . 3 } pairsDo: [ :origin :index |
		| byteArray |
		byteArray := origin copy.
		self 
			checkPrimitive: #byte:at:put:
			args: {byteArray . index . 5}
			against: 5.
		self assert: (byteArray at: index) equals: 5 ].
	{ #[1 2 3] . 2 . #[1 2 3] . 1 . #[1 2 3] . 3 } pairsDo: [ :origin :index |
		| byteArray |
		byteArray := origin copy.
		self 
			checkPrimitive: #immCheckByte:at:put:
			args: {byteArray . index . 5}
			against: 5.
		self assert: (byteArray at: index) equals: 5 ].
	cpy := #[4 8 6] copy.
	self 
			checkPrimitive: #byteAt2:put:
			args: {cpy . 5}
			against: 5.
	self assert: (cpy at: 2) equals: 5.
	cpy := #[7 8 9] copy.
	self 
			checkPrimitive: #immCheckByteAt2:put:
			args: {cpy . 5}
			against: 5.
	self assert: (cpy at: 2) equals: 5
	
]

{ #category : #tests }
SoIntrinsicTest >> testCharIdentityHash [
	self 
		checkPrimitive: #charIdentityHash:
		args: { $c } 
		against: $c basicIdentityHash
]

{ #category : #tests }
SoIntrinsicTest >> testCharacterAsInteger [
	{ $x . $1 . $h . $! } do: [ :each |
		self 
			checkPrimitive: #characterAsInteger:
			args: { each }
			against: each asInteger ]
]

{ #category : #'tests - expected failures' }
SoIntrinsicTest >> testDoubleWordAt [
	<expectedFailure>
	self flag: #TODO.
	self 
		checkPrimitive: #doubleWordAt
		args: #() 
		against: 1
]

{ #category : #'tests - expected failures' }
SoIntrinsicTest >> testDoubleWordAtPut [
	<expectedFailure>
	self flag: #TODO.
	self 
		checkPrimitive: #doubleWordAtPut
		args: #() 
		against: 1
]

{ #category : #'tests - support' }
SoIntrinsicTest >> testInstanceOfJump: prefix [
	| objectGuineaPig smallFloatGuineaPig guineaPigHerd toTest |
	objectGuineaPig := Object new.
	smallFloatGuineaPig := 1 asFloat.
	"Holds all possible cases to cover all possible cases in jit compil / n code"
	guineaPigHerd := { 1 . $x . smallFloatGuineaPig . true . false . nil . objectGuineaPig }.
	toTest :={#Char . $x. #False . false. #Nil . nil. #Object . objectGuineaPig. #Smi . 1 . #True . true }.
	smallFloatGuineaPig class = SmallFloat64 ifTrue: [ "Only for 64 bits"
		toTest := toTest , {#SmallFloat . smallFloatGuineaPig} ].
	toTest pairsDo: [ :test :successfulGuineaPig |
		| failingGuineaPigs selector |
		selector := (prefix , test , ':') asSymbol.
		failingGuineaPigs := guineaPigHerd copyWithout: successfulGuineaPig.
		self 
			checkPrimitive: selector
			args: {successfulGuineaPig}
			against: true.
		failingGuineaPigs do: [ :fgp |
			self 
				checkPrimitive: selector
				args: {fgp}
				against: false ] ]
	
]

{ #category : #tests }
SoIntrinsicTest >> testInstanceOfJumpFalse [
	self testInstanceOfJump: #obj
]

{ #category : #tests }
SoIntrinsicTest >> testInstanceOfJumpTrue [
	self testInstanceOfJump: #objNot
]

{ #category : #'tests - support' }
SoIntrinsicTest >> testInstanceOfOneOfJump: prefix [
	| objectGuineaPig smallFloatGuineaPig guineaPigHerd toTest largeNIntGuineaPig largePIntGuineaPig |
	objectGuineaPig := Object new.
	smallFloatGuineaPig := 1 asFloat.
	largePIntGuineaPig := SmallInteger maxVal + 1.
	largeNIntGuineaPig := SmallInteger minVal - 1.
	"Holds all possible cases to cover all possible cases in jit compil / n code"
	guineaPigHerd := { 1 . $x . smallFloatGuineaPig . objectGuineaPig . #() . largePIntGuineaPig . largeNIntGuineaPig }.
	toTest :={#ObjectArray . {objectGuineaPig.#()} . 
	#SmiChar . { 1 . $x } . 
	#SmiCharArray . { 1 . $x . #() } . 
	#SmiCharSmallFloat . { 1 . $x . smallFloatGuineaPig } .
	#SmiCharSmallFloatArray . { 1 . $x . smallFloatGuineaPig . #() } .
	#SmiLargeInt . { 1 . largePIntGuineaPig . largeNIntGuineaPig } .
	}.
	toTest pairsDo: [ :test :successfulGuineaPigs |
		| failingGuineaPigs selector successGuineaPigs |
		selector := (prefix , test , ':') asSymbol.
		failingGuineaPigs := guineaPigHerd copyWithoutAll: successfulGuineaPigs.
		successGuineaPigs := successfulGuineaPigs.
		smallFloatGuineaPig class = SmallFloat64 ifFalse: [ 
			failingGuineaPigs := failingGuineaPigs copyWithout: smallFloatGuineaPig.
			successGuineaPigs := successGuineaPigs copyWithout: smallFloatGuineaPig. ].
		successGuineaPigs do: [ :sgp |
			self 
				checkPrimitive: selector
				args: {sgp}
				against: true].
		failingGuineaPigs do: [ :fgp |
			self 
				checkPrimitive: selector
				args: {fgp}
				against: false ] ]
	
]

{ #category : #tests }
SoIntrinsicTest >> testInstanceOfOneOfJumpFalse [
	self testInstanceOfOneOfJump: #obj
]

{ #category : #tests }
SoIntrinsicTest >> testInstanceOfOneOfJumpTrue [
	self testInstanceOfOneOfJump: #objNot
]

{ #category : #tests }
SoIntrinsicTest >> testJumpOld [
	| oldGuineaPig |
	oldGuineaPig := Object new. 
	oldGuineaPig pin; unpin.
	self 
		checkPrimitive: #jumpOld:
		args: {oldGuineaPig}
		against: true.
	self 
		checkPrimitive: #jumpOld:
		args: {Object basicNew}
		against: false
]

{ #category : #tests }
SoIntrinsicTest >> testJumpReadOnly [
	| readOnlyGuineaPig writableGuineaPig |
	Smalltalk vm supportsWriteBarrier ifFalse: [ ^self ].
	readOnlyGuineaPig := {1.2.3}. 
	readOnlyGuineaPig beReadOnlyObject.
	writableGuineaPig := {1.2.3}. 
	writableGuineaPig beWritableObject.
	self 
		checkPrimitive: #jumpReadOnly:
		args: {readOnlyGuineaPig}
		against: true.
	self 
		checkPrimitive: #jumpReadOnly:
		args: {writableGuineaPig}
		against: false
]

{ #category : #tests }
SoIntrinsicTest >> testJumpWritable [
	| readOnlyGuineaPig writableGuineaPig |
	Smalltalk vm supportsWriteBarrier ifFalse: [ ^self ].
	readOnlyGuineaPig := {1.2.3}. 
	readOnlyGuineaPig beReadOnlyObject.
	writableGuineaPig := {1.2.3}. 
	writableGuineaPig beWritableObject.
	self 
		checkPrimitive: #jumpWritable:
		args: {readOnlyGuineaPig}
		against: false.
	self 
		checkPrimitive: #jumpWritable:
		args: {writableGuineaPig}
		against: true
]

{ #category : #tests }
SoIntrinsicTest >> testJumpYoung [
	| oldGuineaPig |
	oldGuineaPig := Object new. 
	oldGuineaPig pin; unpin.
	self 
		checkPrimitive: #jumpYoung:
		args: {oldGuineaPig}
		against: false.
	self 
		checkPrimitive: #jumpYoung:
		args: {Object basicNew}
		against: true
]

{ #category : #tests }
SoIntrinsicTest >> testMaybeContextPointerAt [
	| contextGuineaPig |
	contextGuineaPig := thisContext copy.
	"method"
	self 
		checkPrimitive: #maybeContextPointer:at:
		args: {thisContext . 4} 
		against: (thisContext instVarAt: 4).
	"PC"
	self 
		checkPrimitive: #maybeContextPointer:at:
		args: {contextGuineaPig . 2} 
		against: (contextGuineaPig instVarAt: 2).
	"PC"
	self 
		checkPrimitive: #maybeContextPointerAt2:
		args: {contextGuineaPig} 
		against: (contextGuineaPig instVarAt: 2).
]

{ #category : #tests }
SoIntrinsicTest >> testMaybeContextPointerAtPut [
	| contextGuineaPig |
	contextGuineaPig := thisContext copy.
	"method - care with store check"
	self 
		checkPrimitive: #maybeContextPointer:at:put:
		args: {thisContext . 4 . thisContext instVarAt: 4} 
		against: (thisContext instVarAt: 4).
	"PC"
	self 
		checkPrimitive: #maybeContextPointer:at:put:
		args: {contextGuineaPig . 2 . (contextGuineaPig instVarAt: 2) + 5} 
		against: (contextGuineaPig instVarAt: 2) + 5.
	"PC"
	self 
		checkPrimitive: #maybeContextPointerAt2:put:
		args: {contextGuineaPig . (contextGuineaPig instVarAt: 2) + 5} 
		against: (contextGuineaPig instVarAt: 2) + 5.
]

{ #category : #tests }
SoIntrinsicTest >> testMaybeContextStoreCheckPointerAtPut [
	| contextGuineaPig |
	contextGuineaPig := thisContext copy.
	"method"
	self 
		checkPrimitive: #maybeContextStoreCheckPointer:at:put:
		args: {thisContext . 4 . thisContext instVarAt: 4} 
		against: (thisContext instVarAt: 4).
	"PC"
	self 
		checkPrimitive: #maybeContextStoreCheckPointer:at:put:
		args: {contextGuineaPig . 2 . (contextGuineaPig instVarAt: 2) + 5} 
		against: (contextGuineaPig instVarAt: 2) + 5.
	"PC"
	self 
		checkPrimitive: #maybeContextStoreCheckPointerAt2:put:
		args: {contextGuineaPig . (contextGuineaPig instVarAt: 2) + 5} 
		against: (contextGuineaPig instVarAt: 2) + 5.
]

{ #category : #tests }
SoIntrinsicTest >> testNumBytes [
	| large |
	large := #[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 255 255 255 255 255].
	self 
		checkPrimitive: #numBytes:
		args: { #[1 2 3] } 
		against: #[1 2 3] size.
	self 
		checkPrimitive: #numBytes:
		args: { large } 
		against: large size
]

{ #category : #'tests - expected failures' }
SoIntrinsicTest >> testNumDoubleWords [
	<expectedFailure>
	self flag: #TODO.
	self 
		checkPrimitive: #numDoubleWords
		args: #() 
		against: 1
]

{ #category : #'tests - expected failures' }
SoIntrinsicTest >> testNumShorts [
	<expectedFailure>
	self flag: #TODO.
	self 
		checkPrimitive: #numShorts
		args: #() 
		against: 1
]

{ #category : #tests }
SoIntrinsicTest >> testNumSlots [
	| large |
	large := #(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 255 255 255 255 255).
	self 
		checkPrimitive: #numSlots:
		args: { #(1 2 3) } 
		against: #(1 2 3) size.
	self 
		checkPrimitive: #numSlots:
		args: { large } 
		against: large size
]

{ #category : #'tests - expected failures' }
SoIntrinsicTest >> testNumWords [
	<expectedFailure>
	self flag: #TODO.
	self 
		checkPrimitive: #numWords
		args: #() 
		against: 1
]

{ #category : #tests }
SoIntrinsicTest >> testObjectIdentityHash [
	self 
		checkPrimitive: #objectIdentityHash:
		args: { #foo } 
		against: #foo basicIdentityHash
]

{ #category : #tests }
SoIntrinsicTest >> testPointerAt [
	{ #(1 2 3) . 2 . #(1 2 3) . 1 . #(1 2 3) . 3 } pairsDo: [ :array :index |
	self 
		checkPrimitive: #pointer:at:
		args: {array . index}
		against: (array at: index) ].
	self 
		checkPrimitive: #pointerAt2:
		args: {#(2 3 4) }
		against: (#(2 3 4) at: 2)
]

{ #category : #tests }
SoIntrinsicTest >> testPointerAtPut [
	| cpy |
	{ #(1 2 3) . 2 . #(1 2 3) . 1 . #(1 2 3) . 3 } pairsDo: [ :array :index |
	cpy := array copy.
	self 
		checkPrimitive: #pointer:at:put:
		args: {cpy . index . 5}
		against: 5.
	self assert: (cpy at: index) equals: 5 ].
	{ #(1 2 3) . 2 . #(1 2 3) . 1 . #(1 2 3) . 3 } pairsDo: [ :array :index |
	cpy := array copy.
	self 
		checkPrimitive: #immCheckPointer:at:put:
		args: {cpy . index . 5}
		against: 5.
	self assert: (cpy at: index) equals: 5 ].
	cpy := #(4 9 6) copy.	
	self 
		checkPrimitive: #pointerAt2:put:
		args: {cpy . 5}
		against: 5.
	self assert: (cpy at: 2) equals: 5.
	cpy := #(4 9 6) copy.	
	self 
		checkPrimitive: #immCheckPointerAt2:put:
		args: {cpy . 5}
		against: 5.
	self assert: (cpy at: 2) equals: 5.


]

{ #category : #tests }
SoIntrinsicTest >> testPossibleRoot [
	| t |
	self 
		checkPrimitive: #possibleRoot:
		args: { t := Object new } 
		against: t
]

{ #category : #tests }
SoIntrinsicTest >> testRawClass [
	self 
		checkPrimitive: #rawClass:
		args: { #() }
		against: #() class
]

{ #category : #tests }
SoIntrinsicTest >> testRawEqualsEquals [
	| guineaPig1 guineaPig2 |
	guineaPig1 := Object basicNew.
	guineaPig2 := Object basicNew.
	#(#rawEqualsEquals:and: #rawEqualsEqualsIfF:and: #rawEqualsEqualsIfT:and:) do: [ :sel |
		self 
			checkPrimitive: sel
			args: { guineaPig1 . guineaPig2 } 
			against: false.
		self 
			checkPrimitive: sel
			args: { guineaPig1 . guineaPig1 } 
			against: true ].
]

{ #category : #tests }
SoIntrinsicTest >> testRawNew [
	| ternaryValues |
	ternaryValues := #(3 11 300) collect: [ :i | 
		{ (#rawNew , i printString) asSymbol .
		   Smalltalk globals at: (#SoGuineaPig , i printString) asSymbol .
		   i } ].
	self 
		testRawNew: ternaryValues
		expectedFieldValue: nil
]

{ #category : #'tests - support' }
SoIntrinsicTest >> testRawNew: ternaryValues expectedFieldValue: expectedVal [
	ternaryValues do: [ :ternary |
		| selector cls size |
		selector := ternary first.
		cls := ternary second.
		size := ternary third.
		self 
			checkPrimitive: selector
			args: #() 
			block: [ :results |
				self 
					assertRawNewResult: results first 
					class: cls 
					expectedValue: expectedVal 
					description: 'Interpreter failure' 
					size: size.
				self 
					assertRawNewResult: results second 
					class: cls 
					expectedValue: expectedVal 
					description: 'jit failure' 
					size: size ] ]
]

{ #category : #tests }
SoIntrinsicTest >> testRawNewColon [
	| ternaryValues |
	ternaryValues := #(5 11 300) collect: [ :i | 
		{ (#rawNewColon , i printString , 'R') asSymbol .
		   Array .
		   i } ].
	self 
		testRawNew: ternaryValues
		expectedFieldValue: nil
]

{ #category : #tests }
SoIntrinsicTest >> testRawNewColonB [
	| ternaryValues |
	ternaryValues := #(5 11 300) collect: [ :i | 
		{ (#rawNewColon , i printString , 'RB') asSymbol .
		   ByteArray .
		   i } ].
	self 
		testRawNew: ternaryValues
		expectedFieldValue: 0
]

{ #category : #tests }
SoIntrinsicTest >> testRawNewColonNoInit [
	| ternaryValues |
	ternaryValues := #(5 11 300) collect: [ :i | 
		{ (#rawNewColonNoInit , i printString , 'R') asSymbol .
		   Array .
		   i } ].
	self 
		testRawNew: ternaryValues
		expectedFieldValue: #val
]

{ #category : #tests }
SoIntrinsicTest >> testRawNewColonNoInitB [
	| ternaryValues |
	ternaryValues := #(5 11 300) collect: [ :i | 
		{ (#rawNewColonNoInit , i printString , 'RB') asSymbol .
		  ByteArray .
		   i } ].
	self 
		testRawNew: ternaryValues
		expectedFieldValue: 42
]

{ #category : #tests }
SoIntrinsicTest >> testRawNewNoInit [
	| ternaryValues |
	ternaryValues := #(3 11 300) collect: [ :i | 
		{ (#rawNewNoInit , i printString) asSymbol .
		   Smalltalk globals at: (#SoGuineaPig , i printString) asSymbol .
		   i } ].
	self 
		testRawNew: ternaryValues
		expectedFieldValue: #val
]

{ #category : #tests }
SoIntrinsicTest >> testRawNotEqualsEquals [
	| guineaPig1 guineaPig2 |
	guineaPig1 := Object basicNew.
	guineaPig2 := Object basicNew.
	#(#rawNotEqualsEquals:and: #rawNotEqualsEqualsIfF:and: #rawNotEqualsEqualsIfT:and:) do: [ :sel |
		self 
			checkPrimitive: sel
			args: { guineaPig1 . guineaPig2 } 
			against: true.
		self 
			checkPrimitive: sel
			args: { guineaPig1 . guineaPig1 } 
			against: false ].
]

{ #category : #'tests - expected failures' }
SoIntrinsicTest >> testShortAt [
	<expectedFailure>
	self flag: #TODO.
	self 
		checkPrimitive: #shortAt
		args: #() 
		against: 1
]

{ #category : #'tests - expected failures' }
SoIntrinsicTest >> testShortAtPut [
	<expectedFailure>
	self flag: #TODO.
	self 
		checkPrimitive: #shortAtPut
		args: #() 
		against: 1
]

{ #category : #tests }
SoIntrinsicTest >> testSmallFloatAsInteger [
	Smalltalk wordSize >= 8 ifTrue: [  
		self 
			checkPrimitive: #smallFloatAsInteger:
			args: #(1.0) 
			against: 1.0 asInteger ]
]

{ #category : #tests }
SoIntrinsicTest >> testSmallfloatIdentityHash [
	Smalltalk wordSize >= 8 ifTrue: [  
		self 
			checkPrimitive: #smallfloatIdentityHash:
			args: #(1.0) 
			against: 1.0 basicIdentityHash ]
]

{ #category : #tests }
SoIntrinsicTest >> testSmiAdd [
	self testSmiArithmetic: #smiAdd against: #+
]

{ #category : #'tests - support' }
SoIntrinsicTest >> testSmiArithmetic: prefix against: selector [
	#('7R:' (9) '9L:' (7) ':and:' (9 7)) pairsDo: [ :suffix :args |
		self 
			checkPrimitive: (prefix, suffix) asSymbol
			args: args
			against: (9 perform: selector with: 7) ]
]

{ #category : #'tests - expected failures' }
SoIntrinsicTest >> testSmiAsFloat [
	<expectedFailure>
	self 
		checkPrimitive: #smiAsFloat:
		args: #(1) 
		against: 1.0
]

{ #category : #tests }
SoIntrinsicTest >> testSmiBitAnd [
	self testSmiArithmetic: #smiBitAnd against: #bitAnd:
]

{ #category : #tests }
SoIntrinsicTest >> testSmiBitOr [
	self testSmiArithmetic: #smiBitOr against: #bitOr:
]

{ #category : #tests }
SoIntrinsicTest >> testSmiBitShiftLeft [
	self 
		checkPrimitive: #smiBitShiftLeft:and:
		args: #(11 5) 
		against: 11 << 5.
	
	self 
		checkPrimitive: #smiBitShiftLeft2R:
		args: #(5) 
		against: 5 << 2.
]

{ #category : #tests }
SoIntrinsicTest >> testSmiBitShiftRight [
	self 
		checkPrimitive: #smiBitShiftRight:and:
		args: #(11 2) 
		against: 11 >> 2.
	
	self 
		checkPrimitive: #smiBitShiftRight2R:
		args: #(50) 
		against: 50 >> 2.
]

{ #category : #tests }
SoIntrinsicTest >> testSmiBitXor [
	self testSmiArithmetic: #smiBitXor against: #bitXor:
]

{ #category : #'tests - support' }
SoIntrinsicTest >> testSmiComp: prefix against: selector [
	self testSmiCompEqualCases: prefix against: selector.
	self testSmiCompGreaterCases: prefix against: selector.
	self testSmiCompLessCases: prefix against: selector.
]

{ #category : #'tests - support' }
SoIntrinsicTest >> testSmiCompEqualCases: prefix against: selector [
	| csts |
	self assert: (7 perform: selector with: 7) = (9 perform: selector with: 9).
	csts := #('7R' ':' (7) '9L' ':' (9) '' ':and:' (7 7) ).
	1 to: csts size by: 3 do: [ :i |
		| midFix suffix args |
		midFix := csts at: i.
		suffix := csts at: i + 1.
		args := csts at: i + 2.
		#('' 'IfT' 'IfF') do: [ :midFix2 |
			self 
				checkPrimitive: (prefix, midFix, midFix2, suffix) asSymbol
				args: args
				against: (7 perform: selector with: 7) ] ].
]

{ #category : #'tests - support' }
SoIntrinsicTest >> testSmiCompGreaterCases: prefix against: selector [
	| csts |
	csts := #('7R' ':' (9) '9L' ':' (7) '' ':and:' (9 7)).
	1 to: csts size by: 3 do: [ :i |
		| midFix suffix args |
		midFix := csts at: i.
		suffix := csts at: i + 1.
		args := csts at: i + 2.
		#('' 'IfT' 'IfF') do: [ :midFix2 |
			self 
				checkPrimitive: (prefix, midFix, midFix2, suffix) asSymbol
				args: args
				against: (9 perform: selector with: 7) ] ].
]

{ #category : #'tests - support' }
SoIntrinsicTest >> testSmiCompLessCases: prefix against: selector [
	| csts |
	self assert: (5 perform: selector with: 7) = (9 perform: selector with: 11).
	csts := #('7R' ':' (5) '9L' ':' (11) '' ':and:' (5 7)).
	1 to: csts size by: 3 do: [ :i |
		| midFix suffix args |
		midFix := csts at: i.
		suffix := csts at: i + 1.
		args := csts at: i + 2.
		#('' 'IfT' 'IfF') do: [ :midFix2 |
			self 
				checkPrimitive: (prefix, midFix, midFix2, suffix) asSymbol
				args: args
				against: (5 perform: selector with: 7) ] ].
]

{ #category : #tests }
SoIntrinsicTest >> testSmiDiv [
	self testSmiArithmetic: #smiDiv against: #//
]

{ #category : #tests }
SoIntrinsicTest >> testSmiDivide [
	#('7R:' (21) '9L:' (3) ':and:' (9 3)) pairsDo: [ :suffix :args |
		self 
			checkPrimitive: (#smiDivide, suffix) asSymbol
			args: args
			against: (9 perform: #/ with: 3) ]
]

{ #category : #tests }
SoIntrinsicTest >> testSmiEquals [
	self testSmiComp: #smiEquals against: #=
]

{ #category : #tests }
SoIntrinsicTest >> testSmiGreater [
	self testSmiComp: #smiGreater against: #>
]

{ #category : #tests }
SoIntrinsicTest >> testSmiGreaterOrEqual [
	self testSmiComp: #smiGreaterOrEqual against: #>=
]

{ #category : #tests }
SoIntrinsicTest >> testSmiIdentityHash [
	self 
		checkPrimitive: #smiIdentityHash:
		args: #(55) 
		against: 55
]

{ #category : #tests }
SoIntrinsicTest >> testSmiLess [
	self testSmiComp: #smiLess against: #<
]

{ #category : #tests }
SoIntrinsicTest >> testSmiLessOrEqual [
	self testSmiComp: #smiLessOrEqual against: #<=
]

{ #category : #tests }
SoIntrinsicTest >> testSmiMod [
	self testSmiArithmetic: #smiMod against: #\\
]

{ #category : #tests }
SoIntrinsicTest >> testSmiMul [
	self testSmiArithmetic: #smiMul against: #*
]

{ #category : #tests }
SoIntrinsicTest >> testSmiNotEquals [
	self testSmiComp: #smiNotEquals against: #~=
]

{ #category : #tests }
SoIntrinsicTest >> testSmiQuo [
	self testSmiArithmetic: #smiQuo against: #quo:
]

{ #category : #tests }
SoIntrinsicTest >> testSmiSub [
	self testSmiArithmetic: #smiSub against: #-
]

{ #category : #tests }
SoIntrinsicTest >> testStoreCheckPointerAtPut [
	| cpy |
	{ #(1 2 3) . 2 . #(1 2 3) . 1 . #(1 2 3) . 3 } pairsDo: [ :array :index |
	cpy := array copy.
	self 
		checkPrimitive: #storeCheckPointer:at:put:
		args: {cpy . index . 5}
		against: 5.
	self assert: (cpy at: index) equals: 5 ].
	{ #(1 2 3) . 2 . #(1 2 3) . 1 . #(1 2 3) . 3 } pairsDo: [ :array :index |
	cpy := array copy.
	self 
		checkPrimitive: #immCheckStoreCheckPointer:at:put:
		args: {cpy . index . 5}
		against: 5.
	self assert: (cpy at: index) equals: 5 ].
	cpy := #(4 9 6) copy.	
	self 
		checkPrimitive: #storeCheckPointerAt2:put:
		args: {cpy . 5}
		against: 5.
	self assert: (cpy at: 2) equals: 5.
	cpy := #(4 9 6) copy.	
	self 
		checkPrimitive: #immCheckStoreCheckPointerAt2:put:
		args: {cpy . 5}
		against: 5.
	self assert: (cpy at: 2) equals: 5.
]

{ #category : #tests }
SoIntrinsicTest >> testUnforward [
	| guineaPig1 guineaPig2 |
	
	guineaPig1 := Object new.
	guineaPig2 := Object new.
	guineaPig1 becomeForward: guineaPig2.
	self 
		checkPrimitive: #unforward:
		args: {guineaPig1}
		against: guineaPig2.
		
	guineaPig1 := Object new.
	guineaPig2 := Object new.
	guineaPig1 becomeForward: guineaPig2.
	self 
		checkPrimitive: #unforwardNonImmediate:
		args: {guineaPig1}
		against: guineaPig2
]

{ #category : #'tests - expected failures' }
SoIntrinsicTest >> testWordAt [
	<expectedFailure>
	self flag: #TODO.
	self 
		checkPrimitive: #wordAt
		args: #() 
		against: 1
]

{ #category : #'tests - expected failures' }
SoIntrinsicTest >> testWordAtPut [
	<expectedFailure>
	self flag: #TODO.
	self 
		checkPrimitive: #wordAtPut
		args: #() 
		against: 1
]
