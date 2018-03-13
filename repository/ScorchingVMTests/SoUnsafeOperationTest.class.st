"
I test inlined primitives aka unsafe operations. On failure, I may crash the image.

The process to test an inlined primitive is to instrument a method by editing its bytecode so the inlined primitive to test is called, with constants and variables used in the non instrumented versions of the instrumented method.

I have a setting, jitCode. If true, I attempt to compile using Cogit in-image compilation feature the method to native code. If false, I run the method and evaluates both the JIT and the interpreter results against the expected value.

For binary unsafe operations, Cogit generates significantly different code if one of the two operand is a constant instead of a register / spilled value, therefore we need to test all the possible cases. 

For binary comparison and equalities,  Cogit generates significantly different code if the operation is directly followed by a branch. This is explicitely tested in addition.

For size operands, different paths are taken depending on if the base header numSlots slot overflows (size > 255), so we need to test object with size below and over 255.


"
Class {
	#name : #SoUnsafeOperationTest,
	#superclass : #TestCase,
	#instVars : [
		'jitCode'
	],
	#pools : [
		'SoPrimitiveConstants',
		'SoSistaV1BytecodeSetConstants',
		'SoUnsafeOpConstants'
	],
	#category : #ScorchingVMTests
}

{ #category : #accessing }
SoUnsafeOperationTest class >> encoderClass [
	^ OpalEncoderForSistaV1 
]

{ #category : #'code generation' }
SoUnsafeOperationTest class >> genBlockGen [
	"	
	self genBlockGen.
	"
	| genMethods |
	genMethods := self methods select: [ :m | m selector beginsWith: 'gen' ].
	genMethods do: [ :meth |
		| stream |
		stream := '' writeStream.
		stream 
			nextPutAll: 'block';
			nextPutAll: (meth selector allButLast) capitalized;
			cr;
			tab;
			nextPutAll: '<generatedFrom: #genBlockGen>';
			cr;
			tab;
			nextPutAll: '^ [ :encoder | self ';
			nextPutAll: meth selector;
			nextPutAll: ' encoder ]'.
		 SoUnsafeOperationTest 
				compile: stream contents
				classified: 'helper - gen' ]
]

{ #category : #asserting }
SoUnsafeOperationTest >> assertOperation: primNumber operands: operands equals: expectedResult [
	self 
		assertOperation: primNumber 
		varBlock: (self blockGenSuccessively: operands) 
		branchBlock: self emptyBlock 
		equals: expectedResult

]

{ #category : #asserting }
SoUnsafeOperationTest >> assertOperation: primNumber varBlock: varBlock branchBlock: branchBlock equals: expectedResult [
	| res |
	res := self 
		instrumentMethodAndRunPrimitive: primNumber 
		varBlock: varBlock
		branchBlock: branchBlock.
	jitCode ifFalse:
		[self assertResults: res equals: expectedResult]
]

{ #category : #asserting }
SoUnsafeOperationTest >> assertResults: results equals: expectedResult [
	self assert: results first = expectedResult description: 'Failure for interpreted method'.
	self assert: results second = expectedResult description: 'Failure for jitted method'.
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenCst0 [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genCst0: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenCst10 [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genCst10: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenCst3 [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genCst3: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenCst5 [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genCst5: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenCstA [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genCstA: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenCstArray [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genCstArray: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenCstB [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genCstB: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenCstByteArray [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genCstByteArray: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenCstC [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genCstC: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenInstrumentedBytes [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genInstrumentedBytes: encoder ]
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> blockGenSuccessively: listOfElements [ 
	^ [ :encoder | 
		listOfElements do: [ :each |
			each value: encoder ] ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenVar3 [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genVar3: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenVar50 [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genVar50: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenVarArray [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genVarArray: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenVarByteArray [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genVarByteArray: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenVarLargeArray [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genVarLargeArray: encoder ]
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> blockGenVarLargeByteArray [
	<generatedFrom: #genBlockGen>
	^ [ :encoder | self genVarLargeByteArray: encoder ]
]

{ #category : #accessing }
SoUnsafeOperationTest >> emptyBlock [
	^ [ :encoder | ]
]

{ #category : #accessing }
SoUnsafeOperationTest >> encoderClass [
	^ self class encoderClass
]

{ #category : #'initialize-release' }
SoUnsafeOperationTest >> ensureMethodToInstrumentIsInSistaBytecodeSet [
	| myClass theMethod |
	myClass := thisContext methodClass.
	theMethod := myClass >> #methodToInstrument.
	(theMethod encoderClass name endsWith: 'EncoderForSistaV1') ifFalse:
		[myClass
			addSelectorSilently: theMethod selector
			withMethod:
				((myClass newParser
					encoderClass: EncoderForSistaV1;
					parse: (myClass sourceCodeAt: #methodToInstrument)
					class: myClass) generate: theMethod trailer)]
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genCst0: encoder [ 
	encoder genPushSpecialLiteral: 0
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genCst10: encoder [ 
	encoder genPushLiteral: (self literalIndexOf: 10) - 1
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genCst3: encoder [ 
	encoder genPushLiteral: (self literalIndexOf: 3) - 1
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genCst5: encoder [ 
	encoder genPushLiteral: (self literalIndexOf: 5) - 1
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genCstA: encoder [
	encoder genPushLiteral: (self literalIndexOf: $a) - 1
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genCstArray: encoder [ 
	encoder genPushLiteral: (self literalIndexOf: #(1 2 3 4 5 6)) - 1
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genCstB: encoder [
	encoder genPushLiteral: (self literalIndexOf: $b) - 1
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genCstByteArray: encoder [ 
	encoder genPushLiteral: (self literalIndexOf: #[1 2 3 4 5 6 7 8 9 10]) - 1
	
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genCstC: encoder [
	encoder genPushLiteral: (self literalIndexOf: $c) - 1
]

{ #category : #'helper - method instrumentation' }
SoUnsafeOperationTest >> genInstrumentedBytes: aBlock [
	| encoder |
	encoder := self encoderClass new.
	encoder stream: (ByteArray new: 30) writeStream.
	aBlock value: encoder.
	^ encoder bytecodes
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genVar3: encoder [ 
	encoder genPushTemp: 1
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genVar50: encoder [ 
	encoder genPushTemp: 0
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genVarArray: encoder [ 
	encoder genPushTemp: 2
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genVarByteArray: encoder [ 
	encoder genPushTemp: 3
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genVarLargeArray: encoder [ 
	encoder genPushTemp: 4
]

{ #category : #'helper - bytecode gen' }
SoUnsafeOperationTest >> genVarLargeByteArray: encoder [ 
	encoder genPushTemp: 5
]

{ #category : #'helper - runtime' }
SoUnsafeOperationTest >> get3 [
	^ 3
]

{ #category : #'helper - runtime' }
SoUnsafeOperationTest >> get50 [
	^ 50
]

{ #category : #'helper - runtime' }
SoUnsafeOperationTest >> getArray [
	^ #( 1 2 3 4 5 6 7 8 9 10 11) copy
]

{ #category : #'helper - runtime' }
SoUnsafeOperationTest >> getByteArray [
	^ #[ 1 2 3 4 5 6 7 8 9 10] copy
]

{ #category : #'helper - runtime' }
SoUnsafeOperationTest >> getLargeArray [
	^ #(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287 288 289 290 291 292 293 294 295 296 297 298 299 300) copy
]

{ #category : #'helper - runtime' }
SoUnsafeOperationTest >> getLargeByteArray [
	^ #[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 ] copy
]

{ #category : #'initialize-release' }
SoUnsafeOperationTest >> initialize [
	jitCode := false.
	self ensureMethodToInstrumentIsInSistaBytecodeSet
]

{ #category : #'helper - method instrumentation' }
SoUnsafeOperationTest >> instrumentMethod: aBlock [
	| bytes method initPC |
	bytes := self genInstrumentedBytes: aBlock.
	method := self class >> #methodToInstrument.
	self 
		assert: (method encoderClass name endsWith: 'EncoderForSistaV1')
		description: 'Can manipulate the bytecode of methods encoded with SistaV1 bytecode set only'.
	initPC := method initialPC + (3 * method numTemps).
	initPC to: initPC + bytes size - 1 do: [ :i |
		method at: i put: (bytes at: i - initPC + 1)]. 
"	method propertyValueAt: #symbolic put: method symbolic."
	method voidCogVMState
	 
]

{ #category : #'helper - method instrumentation' }
SoUnsafeOperationTest >> instrumentMethodAndRun: aBlock [
	self instrumentMethod: aBlock.
	^ self runInstrumentedMethod
]

{ #category : #'helper - method instrumentation' }
SoUnsafeOperationTest >> instrumentMethodAndRunPrimitive: primNumber varBlock: varBlock branchBlock: branchBlock [
	^ self instrumentMethodAndRun: [ :encoder |
		varBlock value: encoder.
		primNumber class == SmallInteger 
			ifTrue: [ encoder genCallInlinePrimitive: primNumber ]
			ifFalse: 
				[ "I added later than the prim number can be a selector instead of a number to test No must be boolean branches."
				  self assert: (SpecialSelectors includes: primNumber).
				  encoder genSendSpecial: (SpecialSelectors indexOf: primNumber) numArgs: primNumber numArgs ].
		branchBlock value: encoder.
	 	encoder genReturnTop	]
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> invertedPair: pair [ 
	^ { pair second . pair first }
]

{ #category : #accessing }
SoUnsafeOperationTest >> jitCode [

	^ jitCode
]

{ #category : #accessing }
SoUnsafeOperationTest >> jitCode: anObject [

	jitCode := anObject
]

{ #category : #'helper - method instrumentation' }
SoUnsafeOperationTest >> jitInstrumentedMethod [
	(Smalltalk at: #SistaCogit ifAbsent: [ self error: 'should load Cogit'])
		genAndDis: thisContext methodClass >> #methodToInstrument
		options: #(ObjectMemory Spur32BitCoMemoryManager 
				MULTIPLEBYTECODESETS true
				bytecodeTableInitializer initializeBytecodeTableForSqueakV3PlusClosuresSistaV1Hybrid
				SistaVM true
				ISA IA32)
]

{ #category : #accessing }
SoUnsafeOperationTest >> jumpBlockResult: boolean [
	^ boolean ifTrue: [ 5 ] ifFalse: [ 10 ]
]

{ #category : #accessing }
SoUnsafeOperationTest >> jumpFalse10Else5Block [
	^ [ :encoder | 
			encoder genBranchPopFalse: 2.
			self genCst5: encoder.
			encoder genJump: 1.
			self genCst10: encoder. ]
]

{ #category : #accessing }
SoUnsafeOperationTest >> jumpFalse10Else5BlockNoMustBeBoolean [
	^ [ :encoder | 
			encoder genNoMustBeBooleanFlag.
			encoder genBranchPopFalseLong: 2.
			self genCst5: encoder.
			encoder genJump: 1.
			self genCst10: encoder. ]
]

{ #category : #accessing }
SoUnsafeOperationTest >> jumpTrue5Else10Block [
	^ [ :encoder | 
			encoder genBranchPopTrue: 2.
			self genCst10: encoder.
			encoder genJump: 1.
			self genCst5: encoder. ]
]

{ #category : #accessing }
SoUnsafeOperationTest >> jumpTrue5Else10BlockNoMustBeBoolean [
	^ [ :encoder | 
			encoder genNoMustBeBooleanFlag.
			encoder genBranchPopTrueLong: 2.
			self genCst10: encoder.
			encoder genJump: 1.
			self genCst5: encoder. ]
]

{ #category : #accessing }
SoUnsafeOperationTest >> literalIndexOf: literal [
	^ (self class>>#methodToInstrument) literals indexOf: literal
]

{ #category : #'helper - method instrumentation' }
SoUnsafeOperationTest >> methodToInstrument [
	"This method is instrumented in the tests. Do *not* edit it.
	
	The instrumentation starts after the last temporary assignment. 
	Temporaries are result of message sends, so they're in registers 
	or spilled on stack, whereas literals are constants.
	 
	Code after the last temporary assignment is here to generate the 
	required literals and to let enough room for instrumentation."
	  
	| t50 t3 tArray tByteArray tLargeArray tLargeByteArray |
	t50 := self get50.
	t3 := self get3.     
	tArray := self getArray.  
	tByteArray := self getByteArray.
	tLargeArray := self getLargeArray.
	tLargeByteArray := self getLargeByteArray.
	5 + 10 + 3 + 50 + #(1 2 3 4 5 6) first + #[1 2 3 4 5 6 7 8 9 10] first. 
	{ $a . $b . $c } yourself.
	tArray copy.
	^ t3 + t50 + t3 + t50 + t3 + t50 + t3 + t50 + t3 + t50 
	
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> mutate1stWordByteArrayBlock [
	^ [ :encoder | 
		encoder genSend: (self literalIndexOf: #copy) - 1 numArgs: 0.
		encoder genDup.
		self genCst3: encoder.
		self genCst10: encoder.
		encoder genSendSpecial: (Smalltalk specialSelectors indexOf: #at:put:) // 2 + 1 numArgs: 2.
		encoder genPop ] 
]

{ #category : #'helper - gen' }
SoUnsafeOperationTest >> mutateLastWordByteArrayBlock [
	^ [ :encoder | 
		encoder genSend: (self literalIndexOf: #copy) - 1 numArgs: 0.
		encoder genDup.
		self genCst10: encoder.
		self genCst3: encoder.
		encoder genSendSpecial: (Smalltalk specialSelectors indexOf: #at:put:) // 2 + 1 numArgs: 2.
		encoder genPop ] 
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> newClassWithinstSize: instSize [
	| stream |
	stream := '' writeStream.
	1 to: instSize do: [ :i | stream << ' iv' << i printString ].
	^ Object 
		subclass: #GuineaPig1 
		instanceVariableNames: stream contents
		classVariableNames: ''
		package: 'ScorchingVMTests'
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> protect2LiteralsFor: aBlock [
	| method lit7 lit8 |
	method := SoUnsafeOperationTest >> #methodToInstrument.
	lit7 := method literalAt: 7.
	lit8 := method literalAt: 8.
	aBlock value.
	method literalAt: 7 put: lit7.
	method literalAt: 8 put: lit8.  
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> protectObjectAt5ToBeTemporarily10: variableObject for: block [
	| prevValue |
	prevValue := variableObject at: 5.
	[
		variableObject at: 5 put: 42.
		block value.
		jitCode ifTrue: [^self].
		self assert: (variableObject at: 5) equals: 10.
	]
	ensure: [ variableObject at: 5 put: prevValue ]
]

{ #category : #'helper - method instrumentation' }
SoUnsafeOperationTest >> runInstrumentedMethod [
	| res |
	jitCode ifTrue:
		[^self jitInstrumentedMethod].

	res := { nil . nil }.
	res at: 1 put: self runMethodToInstrument. "interpreter result"
	1 to: 5 do: [ :i | self runMethodToInstrument ]. "heat up the JIT"
	res at: 2 put: self runMethodToInstrument. "jitted result"
	^ res
]

{ #category : #'helper - method instrumentation' }
SoUnsafeOperationTest >> runMethodToInstrument [
	^ self methodToInstrument
]

{ #category : #'tests - other' }
SoUnsafeOperationTest >> testArrayCopy [
	"We need to test:
	- srcPos and destPos both integer constant and the same.
	- array of size 0 to write in."
	
	"dest destIndex destLast src srcFirst result"
	{ 
	{ self blockGenVarArray . 
		self blockGenCst3 . 
		self blockGenCst5 . 
		self blockGenVarLargeArray . 
		self blockGenCst5 . 
		(self getArray replaceFrom: 3 to: 5 with: self getLargeArray startingAt: 5) } .
	{ self blockGenVarArray . 
		self blockGenCst3 . 
		[ :e | self genVarArray: e. e genSendSpecial: (SpecialSelectors indexOf: #size) numArgs: 0 ].
		self blockGenVarLargeArray . 
		self blockGenCst5 . 
		(self getArray replaceFrom: 3 to: self getArray size with: self getLargeArray startingAt: 5) } .
	{ self blockGenVarArray . 
		self blockGenCst3 .
		self blockGenCst5 . 
		self blockGenVarLargeArray . 
		self blockGenCst3 . 
		(self getArray replaceFrom: 3 to: 5 with: self getLargeArray startingAt: 3) } 
	 } do: [ :each |
		self 	
			assertOperation: 5000 
			varBlock: (self blockGenSuccessively: each allButLast) 
			branchBlock: self emptyBlock
			equals: each last ]
]

{ #category : #'tests - branch' }
SoUnsafeOperationTest >> testBehaviorArrayBranch [
	"With 0, 1 or 2 immediates and with only, none or mixed immediates"
	
	| valuesToTest |
	valuesToTest := { 
	"Behaviors . success instances . failing instances" 
	"all immediates"
	{ {SmallInteger . Character} . {10 . $c} . #(1.0 #()) } .
	
	"mixed"
	{ {SmallInteger . Character . Object} . {10 . $c . Object new} . #(1.0 #()) } .
	{ {SmallInteger . Object} . {10 . Object new} . #($c 1.0 #()) } .
	{ {Object . Character} . {Object new . $c} . #(10 1.0 #()) } .
	{ {ByteSymbol . UndefinedObject} . {#foo . nil . #nil} . #(10 1.0 #()) } .
	{ {SmallInteger . Character . Object . UndefinedObject} . {10 . $c . Object new . nil} . #(1.0 #()) } .
	{ {SmallInteger . Object . UndefinedObject} . {10 . Object new . nil} . #($c 1.0 #()) } .
	{ {Object . Character . UndefinedObject} . {Object new . $c . nil} . #(10 1.0 #()) } .
	
	"no immediates"
	{ {Object . UndefinedObject} . {Object new . nil} . #($c 10 1.0 #()) } .
	}.
	
	valuesToTest do: [ :each |
		each second do: [ :succ | 
			self verifyBehaviorBranchOn: each first receiver: succ result: true ].
		each third do: [ :fail | 
			self verifyBehaviorBranchOn: each first receiver: fail result: false ] ]

]

{ #category : #'tests - branch' }
SoUnsafeOperationTest >> testBehaviorBranch [
	"both immediates & non immediates plz"
	
	| valuesToTest |
	valuesToTest := { 
	"Behavior . success instance . failing instances"
	{ SmallInteger . #(0 1 2 10) . #( $c 1.0 #()) } .
	{ Character . #($d $. ) . #( 5 1.0 #()) } .
	{ Object . {Object new} . #( 5 $d 1.0 #()) }
	}.
	
	valuesToTest do: [ :each |
		each second do: [ :succ | 
			self verifyBehaviorBranchOn: each first receiver: succ result: true].
		each third do: [ :fail | 
			self verifyBehaviorBranchOn: each first receiver: fail result: false ] ]
]

{ #category : #'tests - other' }
SoUnsafeOperationTest >> testByteObjectEqual [
	"We need to test:
	- 1 op is a constant or both var
	- len is constant (0, 1-4, 5-8, 12+) in 32 bits
	- len is variable (0, non 0)
	- followed by branch
	- result is true or false"
	
	"op1 mutation op2 len result"
	{ 
	{ self blockGenVarByteArray . [ :e | ] . self blockGenVarByteArray . self blockGenCst10 . true } .
	{ self blockGenCstByteArray . [ :e | ] . self blockGenVarByteArray . self blockGenCst10 . true } .
	{ self blockGenVarByteArray . [ :e | ] . self blockGenCstByteArray . self blockGenCst10 . true } .
	{ self blockGenVarByteArray . self mutate1stWordByteArrayBlock . self blockGenVarByteArray . self blockGenCst10 . false } .
	{ self blockGenCstByteArray . self mutate1stWordByteArrayBlock . self blockGenVarByteArray . self blockGenCst10 . false } .
	{ self blockGenVarByteArray . self mutate1stWordByteArrayBlock . self blockGenCstByteArray . self blockGenCst10 . false } .
	{ self blockGenVarByteArray . self mutateLastWordByteArrayBlock . self blockGenVarByteArray . self blockGenCst10 . false } .
	{ self blockGenCstByteArray . self mutateLastWordByteArrayBlock . self blockGenVarByteArray . self blockGenCst10 . false } .
	{ self blockGenVarByteArray .self mutateLastWordByteArrayBlock . self blockGenCstByteArray . self blockGenCst10 . false } .
	
	{ self blockGenVarByteArray . [ :e | ] . self blockGenVarByteArray . self blockGenCst5 . true } .
	{ self blockGenCstByteArray . [ :e | ] . self blockGenVarByteArray . self blockGenCst5 . true } .
	{ self blockGenVarByteArray . [ :e | ] . self blockGenCstByteArray . self blockGenCst5 . true } .
	{ self blockGenVarByteArray . self mutate1stWordByteArrayBlock . self blockGenVarByteArray . self blockGenCst5 . false } .
	{ self blockGenCstByteArray . self mutate1stWordByteArrayBlock . self blockGenVarByteArray . self blockGenCst5 . false } .
	{ self blockGenVarByteArray . self mutate1stWordByteArrayBlock . self blockGenCstByteArray . self blockGenCst5 . false } .
	
	{ self blockGenVarByteArray . [ :e | ] . self blockGenVarByteArray . self blockGenCst3 . true } .
	{ self blockGenCstByteArray . [ :e | ] . self blockGenVarByteArray . self blockGenCst3 . true } .
	{ self blockGenVarByteArray . [ :e | ] . self blockGenCstByteArray . self blockGenCst3 . true } .
	{ self blockGenVarByteArray . self mutate1stWordByteArrayBlock . self blockGenVarByteArray . self blockGenCst3 . false } .
	{ self blockGenCstByteArray . self mutate1stWordByteArrayBlock . self blockGenVarByteArray . self blockGenCst3 . false } .
	{ self blockGenVarByteArray . self mutate1stWordByteArrayBlock . self blockGenCstByteArray . self blockGenCst3 . false } .
	
	{ self blockGenVarByteArray . [ :e | ] . self blockGenVarByteArray . self blockGenCst0 . true } .
	
	{ self blockGenVarByteArray . [ :e | ] . self blockGenVarByteArray . [ :encoder | 
		self genCst3: encoder.
		self genCst3: encoder.
		encoder genSendSpecial: (Smalltalk specialSelectors indexOf: #-) // 2 + 1 numArgs: 1.
 ] . true } .
	
	{ self blockGenVarByteArray . [ :e | ] . self blockGenVarByteArray . self blockGenVar3 . true } .
	{ self blockGenCstByteArray . [ :e | ] . self blockGenVarByteArray . self blockGenVar3 . true } .
	{ self blockGenVarByteArray . [ :e | ] . self blockGenCstByteArray . self blockGenVar3 . true } .
	{ self blockGenVarByteArray . self mutate1stWordByteArrayBlock . self blockGenVarByteArray . self blockGenVar3 . false } .
	{ self blockGenCstByteArray . self mutate1stWordByteArrayBlock . self blockGenVarByteArray . self blockGenVar3 . false } .
	{ self blockGenVarByteArray . self mutate1stWordByteArrayBlock . self blockGenCstByteArray . self blockGenVar3 . false } .
	} do: [ :quint |
		self 
			verifyByteObjectEqual: quint allButLast
			result: quint last. ].
	
	
]

{ #category : #'tests - other' }
SoUnsafeOperationTest >> testCharacterAsInteger [
	self 
		assertOperation: UCharacterAsInteger
		operands: { self blockGenCstA }
		equals: $a asInteger.
	self 
		assertOperation: UCharacterAsInteger 
		operands: { self blockGenCstB }
		equals: $b asInteger.
	self 
		assertOperation: UCharacterAsInteger 
		operands: { self blockGenCstC }
		equals: $c asInteger
]

{ #category : #'tests - other' }
SoUnsafeOperationTest >> testFillVariablePointerObject [
	self 
		assertOperation: 4000 
		operands: { self blockGenVarArray . self blockGenCst3 . self blockGenCst10 . self blockGenCstA }
		equals: (self getArray replaceFrom: 3 to: 10 with: #($a $a $a $a $a $a $a $a $a $a $a $a) startingAt: 1) .
]

{ #category : #'tests - other' }
SoUnsafeOperationTest >> testIdentityHash [	
	self 
		assertOperation: UIdentityHash 
		operands: { self blockGenCstByteArray }
		equals: self getByteArray basicIdentityHash.
	self 
		assertOperation: UIdentityHash 
		operands: { self blockGenVarArray }
		equals: self getArray basicIdentityHash
]

{ #category : #'tests - other' }
SoUnsafeOperationTest >> testNew [	
	"8-based unrolled duff's device for the UPointerNew implementation. Test relevant sizes"
	Smalltalk garbageCollectMost.
	#(0 1 2 7 8 9 10 11 15 16 17 18 23 24 25 26) do: [ :i | self verifyNewWithInstSize: i ]
]

{ #category : #'tests - branch' }
SoUnsafeOperationTest >> testNoMustBeBooleanComparison [
	self 
		verifyMultipleComparisons: { #<= . #< }  
		invertedComparisons: { #> . #>= } 
]

{ #category : #'tests - branch' }
SoUnsafeOperationTest >> testNoMustBeBooleanComparisonEqual [
	self 
		verifyComparisonEquality: { #<= . #>= }
		inequalities: { #< . #> }
]

{ #category : #'tests - branch' }
SoUnsafeOperationTest >> testNoMustBeBooleanEquality [
	self 
		verifyMultipleEqualities: { #= . #== }
		invertedComparisons: { #~= } 
]

{ #category : #'tests - branch' }
SoUnsafeOperationTest >> testNoMustBeBooleanStaticComparison [
	| expectedRes res cases |
	cases := {self jumpFalse10Else5BlockNoMustBeBoolean . self jumpTrue5Else10BlockNoMustBeBoolean}.
	#(true false) do: 
		[ :bool |
			expectedRes := self jumpBlockResult: bool.
			cases do: [ :case |
				res := self instrumentMethodAndRun:  
					[ :encoder |
						encoder genPushSpecialLiteral: bool.
						case value: encoder.
	 					encoder genReturnTop	].
				self assertResults: res equals: expectedRes ] ].
]

{ #category : #'tests - branch' }
SoUnsafeOperationTest >> testSpecialBehaviorBranch [
	"nil, true false"
	
	| valuesToTest |
	valuesToTest := { 
	"Behavior . success instance . failing instances"
	{ True . true . #(5 $d 1.0 #()) } .
	{ False . false . #(5 $d 1.0 #()) } .
	{ UndefinedObject . nil . #(5 $d 1.0 #()) }
	}.
	
	valuesToTest do: [ :each |
		self verifyBehaviorBranchOn: each first receiver: each second result: true.
		each third do: [ :fail | 
			self verifyBehaviorBranchOn: each first receiver: fail result: false ] ]
]

{ #category : #'tests - variable object accessing' }
SoUnsafeOperationTest >> testUByteAt [
	self verifyBinaryOperation: UByteAt cases: { 
		{ self blockGenVarByteArray . self blockGenVar3 . self getByteArray at: 3 } .
		{ self blockGenVarByteArray . self blockGenCst5 . self getByteArray at: 5 } .
		{ self blockGenCstByteArray . self blockGenCst5 . #[1 2 3 4 5 6 7 8] at: 5 } .
		{ self blockGenCstByteArray . self blockGenVar3 . #[1 2 3 4 5 6 7 8] at: 3 } .
	}
]

{ #category : #'tests - variable object accessing' }
SoUnsafeOperationTest >> testUByteAtPut [
	self 
		protectObjectAt5ToBeTemporarily10: self getByteArray 
		for: [ 
			self 
				assertOperation: UByteAtPut 
				operands: { self blockGenVarByteArray . 
					self blockGenCst5 . 
					self blockGenCst10 }
				equals: 10 ]
]

{ #category : #'tests - variable object accessing' }
SoUnsafeOperationTest >> testUByteSize [
	self 
		assertOperation: UByteSize 
		operands: { self blockGenVarByteArray }
		equals: self getByteArray size.
	self 
		assertOperation: UByteSize 
		operands: { self blockGenVarLargeByteArray }
		equals: self getLargeByteArray size
]

{ #category : #'tests - variable object accessing' }
SoUnsafeOperationTest >> testUPointerAt [
	self verifyBinaryOperation: UPointerAt cases: { 
		{ self blockGenVarArray . self blockGenVar3 . self getArray at: 3 } .
		{ self blockGenVarArray . self blockGenCst5 . self getArray at: 5 } .
		{ self blockGenCstArray . self blockGenCst5 . #(1 2 3 4 5 6) at: 5 } .
		{ self blockGenCstArray . self blockGenVar3 . #(1 2 3 4 5 6) at: 3 } .
	}

]

{ #category : #'tests - variable object accessing' }
SoUnsafeOperationTest >> testUPointerAtPut [
	self 
		protectObjectAt5ToBeTemporarily10: self getArray 
		for: [ 
			self 
				assertOperation: UPointerAtPut 
				operands: { self blockGenVarArray . 
					self blockGenCst5 . 
					self blockGenCst10 }
				equals: 10 ]
]

{ #category : #'tests - variable object accessing' }
SoUnsafeOperationTest >> testUPointerSize [
	self 
		assertOperation: UPointerSize 
		operands: { self blockGenVarArray } 
		equals: self getArray size.
	self 
		assertOperation: UPointerSize 
		operands: { self blockGenVarLargeArray } 
		equals: self getLargeArray size
	
]

{ #category : #'tests - smis' }
SoUnsafeOperationTest >> testUSmiAdd [
	self verifyBinarySmiOperation: USmiAdd safePrimitive: Add
]

{ #category : #'tests - smis' }
SoUnsafeOperationTest >> testUSmiBitAnd [
	self verifyBinarySmiOperation: USmiBitAnd safePrimitive: BitAnd
]

{ #category : #'tests - smis' }
SoUnsafeOperationTest >> testUSmiBitOr [
	self verifyBinarySmiOperation: USmiBitOr safePrimitive: BitOr
]

{ #category : #'tests - smis' }
SoUnsafeOperationTest >> testUSmiBitShiftLeft [
	self verifyBinaryOperation: USmiBitShiftLeft cases: { 
		{ self blockGenVar3 . self blockGenVar3 . 3 tryPrimitive: BitShift withArgs: #(3) } .
		{ self blockGenVar3 . self blockGenCst5 . 3 tryPrimitive: BitShift withArgs: #(5) } .
		{ self blockGenCst10 . self blockGenVar3 . 10 tryPrimitive: BitShift withArgs: #(3) } .
		{ self blockGenCst10 . self blockGenCst5 . 10 tryPrimitive: BitShift withArgs: #(5) } .
	}
]

{ #category : #'tests - smis' }
SoUnsafeOperationTest >> testUSmiBitShiftRight [
	self verifyBinaryOperation: USmiBitShiftRight cases: { 
		{ self blockGenVar3 . self blockGenVar3 . 3 tryPrimitive: BitShift withArgs: #(-3) } .
		{ self blockGenVar3 . self blockGenCst5 . 3 tryPrimitive: BitShift withArgs: #(-5) } .
		{ self blockGenCst10 . self blockGenVar3 . 10 tryPrimitive: BitShift withArgs: #(-3) } .
		{ self blockGenCst10 . self blockGenCst5 . 10 tryPrimitive: BitShift withArgs: #(-5) } .
	}
]

{ #category : #'tests - smis' }
SoUnsafeOperationTest >> testUSmiBitXor [
	self verifyBinarySmiOperation: USmiBitXor safePrimitive: BitXor
]

{ #category : #'tests - smis' }
SoUnsafeOperationTest >> testUSmiComparison [
	self 
		verifyMultipleComparisons: { USmiLessOrEqual . USmiLess }  
		invertedComparisons: { USmiGreater . USmiGreaterOrEqual } 
]

{ #category : #'tests - smis' }
SoUnsafeOperationTest >> testUSmiComparisonEqual [
	self 
		verifyComparisonEquality: { USmiLessOrEqual . USmiGreaterOrEqual }
		inequalities: { USmiLess . USmiGreater }
]

{ #category : #'tests - smis' }
SoUnsafeOperationTest >> testUSmiEquality [
	self 
		verifyMultipleEqualities: { USmiEqual }
		invertedComparisons: { USmiNotEqual } 
]

{ #category : #'tests - smis' }
SoUnsafeOperationTest >> testUSmiMul [
	self verifyBinarySmiOperation: USmiMul safePrimitive: Mul
]

{ #category : #'tests - smis' }
SoUnsafeOperationTest >> testUSmiSub [
	self verifyBinarySmiOperation: USmiSub safePrimitive: Sub
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyBehaviorBranchOn: behavior receiver: receiver result: expectedResult [
	self verifyBehaviorBranchOn: behavior receiver: receiver result: expectedResult orNot: true.
	self verifyBehaviorBranchOn: behavior receiver: receiver result: expectedResult orNot: false
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyBehaviorBranchOn: behavior receiver: receiver result: expectedResult orNot: orNot [
	| results |
	self protect2LiteralsFor: [ 
		results := self instrumentMethodAndRun: [ :encoder |
			| method |
			method := SoUnsafeOperationTest >> #methodToInstrument.
			method literalAt: 7 put: behavior.
			method literalAt: 8 put: receiver.
			encoder genPushLiteral: 7.
			orNot 
				ifTrue: [ encoder genBranchIfNotInstanceOf: 6 distance: 2 ]
				ifFalse: [ encoder genBranchIfInstanceOf: 6 distance: 2 ].
			encoder
				genPushSpecialLiteral: true;
				genJump: 1;
				genPushSpecialLiteral: false;
				genReturnTop ] ].
	self assertResults: results equals: (orNot ifTrue: [expectedResult] ifFalse: [expectedResult not]).
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyBinaryOperation: primNumber cases: cases [

	cases do: [ :case |
		self assertOperation: primNumber operands: (case first: 2) equals: case third ]
	

]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyBinarySmiOperation: unsafeOpNumber safePrimitive: safePrimNumber [

	self verifyBinaryOperation: unsafeOpNumber cases: { 
		{ self blockGenVar50 . self blockGenVar3 . 50 tryPrimitive: safePrimNumber withArgs: #(3) } .
		{ self blockGenVar50 . self blockGenCst5 . 50 tryPrimitive: safePrimNumber withArgs: #(5) } .
		{ self blockGenCst10 . self blockGenVar3 . 10 tryPrimitive: safePrimNumber withArgs: #(3) } .
		{ self blockGenCst10 . self blockGenCst5 . 10 tryPrimitive: safePrimNumber withArgs: #(5) } .
	}
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyByteObjectEqual: varBlocks result: boolean [
	| int cases |
	
	int := self jumpBlockResult: boolean.
	
	cases := { 
	{ self emptyBlock . boolean } . "no branch test"
	{ self jumpFalse10Else5Block . int } . "branch false test"
	{ self jumpTrue5Else10Block . int } ". branch true test"
	"{ self jumpFalse10Else5BlockNoMustBeBoolean . int } ." "branch false NMBB test"
	"{ self jumpTrue5Else10BlockNoMustBeBoolean . int }" "branch true NMBB test"
	}.
	
	cases do: [ :case |
		self 
			assertOperation: 3021 
			varBlock: (self blockGenSuccessively: varBlocks) 
			branchBlock: case first
			equals: case second ].
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyComparison: primNumber truePair: truePair [

	| cases |

	cases := { 
	{ self blockGenSuccessively: truePair . true } .
	{ self blockGenSuccessively: (self invertedPair: truePair) . false } .
	}.
	
	cases do: [ :case |
		self 
			verifyComparisonOrEquality: primNumber 
			varBlock: case first
			comparisonResult: case second ]
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyComparisonEquality: primNumber cases: cases result: boolean [

	cases do: [ :case |
		self 
			verifyComparisonOrEquality: primNumber 
			varBlock: (self blockGenSuccessively: (case first: 2))
			comparisonResult: boolean ] 

]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyComparisonEquality: successes inequalities: failures [
	self 
		verifyComparisonEquality: successes
		inequalities: failures
		varBlock: self blockGenVar3 
		cstBlock: self blockGenCst3
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyComparisonEquality: primNumbers inequalities: invertedPrimNumbers varBlock: varBlock cstBlock: cstBlock [
	
	| cases |
	
	cases := { 
	{ varBlock . varBlock } .
	{ cstBlock . cstBlock } .
	{ varBlock . cstBlock } .
	{ cstBlock . varBlock } 
	}.
	
	primNumbers do: [ :num | 
		self verifyComparisonEquality: num cases: cases result: true ].
	
	invertedPrimNumbers do: [ :num | 
		self verifyComparisonEquality: num cases: cases result: false ].

]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyComparisonOrEquality: primNumber varBlock: varBlock comparisonResult: boolean [
	
	| int cases |
	
	int := self jumpBlockResult: boolean.
	
	cases := { 
	{ self emptyBlock . boolean } . "no branch test"
	{ self jumpFalse10Else5Block . int } . "branch false test"
	{ self jumpTrue5Else10Block . int } . "branch true test"
	{ self jumpFalse10Else5BlockNoMustBeBoolean . int } . "branch false NMBB test"
	{ self jumpTrue5Else10BlockNoMustBeBoolean . int } "branch true NMBB test"
	}.
	
	cases do: [ :case |
		self 
			assertOperation: primNumber 
			varBlock: varBlock 
			branchBlock: case first
			equals: case second ]
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyEquality: primNumber varBlock: varBlock equalCstBlock: equalCstBlock notEqualCstBlock: notEqualCstBlock boolean: boolean [
	
	| cases |
	
	cases := { 
	{ varBlock . varBlock . boolean } .
	{ equalCstBlock . equalCstBlock . boolean } .
	{ varBlock . equalCstBlock . boolean } .
	{ equalCstBlock . varBlock . boolean } .
	{ varBlock . notEqualCstBlock . boolean not } .
	{ notEqualCstBlock . varBlock . boolean not } .
	}.
	
	cases do: [ :case |
		self 
			verifyComparisonOrEquality: primNumber 
			varBlock: (self blockGenSuccessively: (case first: 2))
			comparisonResult: case third ].
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyMultipleComparisons: successes  invertedComparisons: failures [
	"test < <= > >= if both operand are different Smis"
	self 
		verifyMultipleComparisons: successes
		invertedComparisons: failures
		withTruePairs: { 
			{ self blockGenVar3 . self blockGenVar50 } .
			{ self blockGenVar3 . self blockGenCst5 } .
			{ self blockGenCst5 . self blockGenVar50 } .
			{ self blockGenCst5 . self blockGenCst10 } .
		}
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyMultipleComparisons: primNumbers invertedComparisons: invertedPrimNumber truePair: truePair [

	primNumbers do: [ :primNumber |
		self verifyComparison: primNumber truePair: truePair ].
	
	invertedPrimNumber do: [ :primNumber |
		self verifyComparison: primNumber truePair: (self invertedPair: truePair) ]
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyMultipleComparisons: primNumbers invertedComparisons: invertedPrimNumber withTruePairs: truePairs [

	truePairs do: [ :truePair | 
		self verifyMultipleComparisons: primNumbers invertedComparisons: invertedPrimNumber truePair: truePair ]
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyMultipleEqualities: successes invertedComparisons: failures [
	self 
		verifyMultipleEqualities: successes
		invertedComparisons: failures
		varBlock: self blockGenVar3  
		equalCstBlock: self blockGenCst3
		notEqualCstBlock: self blockGenCst5
]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyMultipleEqualities: primNumbers invertedComparisons: invertedPrimNumber varBlock: varBlock equalCstBlock: cstBlock notEqualCstBlock: cstBlock2 [

	primNumbers do: [ :primNumber |
		self verifyEquality: primNumber varBlock: varBlock equalCstBlock: cstBlock notEqualCstBlock: cstBlock2 boolean: true ].
	
	invertedPrimNumber do: [ :primNumber |
		self verifyEquality: primNumber varBlock: varBlock equalCstBlock: cstBlock notEqualCstBlock: cstBlock2 boolean: false ]
	

]

{ #category : #'tests support' }
SoUnsafeOperationTest >> verifyNewWithInstSize: instSize [
	| res method cls |
	method := self class >> #methodToInstrument.
	cls := self newClassWithinstSize: instSize.
	method methodClass: cls.
	res := self 
		instrumentMethodAndRunPrimitive: UPointerNew 
		varBlock: [ :encoder | encoder genPushLiteralVar: (self literalIndexOf: cls binding) - 1 ]
		branchBlock: self emptyBlock.
	method methodClass: self class.
	jitCode ifTrue: [ ^ cls removeFromSystem ].
	self assert: res first class == cls description: 'Failure for interpreted method'.
	self assert: res second class == cls description: 'Failure for jitted method'.
	1 to: instSize do: [ :i |
		self assert: (res first instVarAt: i) == nil.
		self assert: (res second instVarAt: i) == nil ].
	cls removeFromSystem.
]
