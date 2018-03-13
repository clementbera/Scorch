"
I match the following pattern:
(ByteString compare: x with: y collated: z) = 2

In general in the IR it looks like: 
[a] ByteString compare: x with: y collated: z
[b] [a] trapIfNotInstanceOf: Smi
[c] [a] USmiEqual 2

Which is typically used in:
foo = 'cst'

If:
- z is globally ordered
- x and y have the same length
- x and y length is known
- x and y are byte objects

 I replace this to:
x byteEquals: y len: lengthOfBoth

Aggressive removal: 
- no check for ByteString is kind of ByteString class
- no check for identity of ordering
"
Class {
	#name : #SoStringEqualStub,
	#superclass : #Object,
	#instVars : [
		'stringCmp',
		'trapInstr',
		'equal2Instr',
		'exactSize',
		'anySize'
	],
	#category : #'Scorching-Pass-Data'
}

{ #category : #accessing }
SoStringEqualStub >> anySize [
	<generated>
	^ anySize
]

{ #category : #accessing }
SoStringEqualStub >> anySize: aValue [
	<generated>
	anySize := aValue
]

{ #category : #testing }
SoStringEqualStub >> bothOperandsSameSize [
	| op1 op2 |
	op1 := stringCmp firstArg.
	op2 := stringCmp arguments at: 2.
	op1 hasSizeInformation ifTrue: [ 
		exactSize := op1 sizeInformation.
		op2 hasSizeInformation ifTrue: [ 
			^ exactSize = op2 sizeInformation ].
		^ self sizeOf: op2 matchesConstant: exactSize ].
	op2 hasSizeInformation ifTrue: [ 
		exactSize := op2 sizeInformation.
		^ self sizeOf: op1 matchesConstant: op2 sizeInformation ].
	^ self sizeOf: op1 matchesSizeOf: op2
	
	
]

{ #category : #testing }
SoStringEqualStub >> checkOrder: instr [ 
	instr isRead ifFalse: [ ^ false].
	(instr index isConstant and: [ instr index constant = 2 ]) ifFalse: [ ^ false].
	instr object class == SoUnforwardNonImmediate ifFalse: [ ^ false ].
	instr object expression class == SoMutableLiteralRead ifFalse: [ ^ false ].
	^ instr object expression literal == (String classVariableNamed: #AsciiOrder)
]

{ #category : #accessing }
SoStringEqualStub >> equal2Instr [
	<generated>
	^ equal2Instr
]

{ #category : #accessing }
SoStringEqualStub >> equal2Instr: aValue [
	<generated>
	equal2Instr := aValue
]

{ #category : #accessing }
SoStringEqualStub >> exactSize [
	<generated>
	^ exactSize
]

{ #category : #accessing }
SoStringEqualStub >> exactSize: aValue [
	<generated>
	exactSize := aValue
]

{ #category : #testing }
SoStringEqualStub >> isBytes: arg [
	| type |
	"we could add a trap for ByteString & ByteSymbol if false and no type info..."
	type := arg typeInformationAt: stringCmp.
	type isKnownType ifFalse: [ ^ false ].
	^ type behaviors allSatisfy: [ :each | each instSpec = 16 ]
]

{ #category : #debug }
SoStringEqualStub >> logDebug: msg class: cls at: instruction [
	| theClass |
	theClass := Smalltalk globals at: cls ifAbsent: [ ^ self ].
	instruction codeNode debugInfo add: ((Smalltalk globals at: cls) new 
		message: msg;
		stackOrNil: (instruction deoptInfo ifNotNil: [ :d | d asDebugStack ]);
		yourself) 
]

{ #category : #testing }
SoStringEqualStub >> matchesStringEqualPattern [
	| prim |
	prim := stringCmp methodToInline literalAt: 1.
	(prim at: 1) = #MiscPrimitivePlugin ifFalse: [ ^ false ].
	(prim at: 2) = #primitiveCompareString ifFalse: [ ^ false ].
	stringCmp uses size = 3 ifFalse: [ ^ false ].
	trapInstr := stringCmp nextInstr.
	equal2Instr := trapInstr nextInstr.
	(stringCmp uses includes: trapInstr) ifFalse: [ ^ false ].
	(stringCmp uses includes: equal2Instr) ifFalse: [ ^ false ].
	(stringCmp uses anySatisfy: [ :use | use isSunkObject and: [trapInstr deoptInfo sunkObjects includes: use]]) ifFalse: [ ^ false ].
	(equal2Instr firstArg isConstant and: [ equal2Instr firstArg constant = 2 ]) ifFalse: [ ^ false ].
	(self checkOrder: stringCmp arguments last) ifFalse: [ ^ false ].
	(self isBytes: stringCmp firstArg) ifFalse: [ ^ false ].
	(self isBytes: stringCmp arguments second) ifFalse: [ ^ false ].
	^ true
]

{ #category : #public }
SoStringEqualStub >> maybeStringEqual: send [
	stringCmp := send.
	self matchesStringEqualPattern ifFalse: [ ^ self ].
	self bothOperandsSameSize ifFalse: [ ^self ].
	self rewriteStringEqual.
	"('String Equal inlined for size ' , exactSize printString) logCr."
]

{ #category : #rewrite }
SoStringEqualStub >> newByteStringTrapFor: node [
	(SoTrapIfNotInstanceOf new
		behaviors: {ByteString};
		expression: node;
		deoptInfo: (stringCmp deoptInfo convertToTrapWith: stringCmp)
		yourself) insertBefore: stringCmp.
]

{ #category : #rewrite }
SoStringEqualStub >> rewriteStringEqual [
	self logDebug: exactSize printString class: #SoStringEqLog at: equal2Instr.
	^ exactSize
		ifNotNil: [ self rewriteStringEqualExactSize ]
		ifNil: [ self rewriteStringEqualAnySize ]
]

{ #category : #rewrite }
SoStringEqualStub >> rewriteStringEqualAnySize [
	| byteEqual |
	byteEqual := SoByteEqualOp
		withReceiver: stringCmp firstArg
		arguments: { stringCmp arguments at: 2 . anySize}.
	
	"Here we may want to check that ByteString is kind of ByteString class"
	"We need to check here that last argument is not mutated from elsewhere..."
	
	byteEqual insertBefore: stringCmp.
	
	trapInstr removeInstr.
	equal2Instr removeAndReplaceUsesBy: byteEqual.
	stringCmp removeInstr.

]

{ #category : #rewrite }
SoStringEqualStub >> rewriteStringEqualExactSize [
	| byteEqual |
	byteEqual := SoByteEqualOp
		withReceiver: stringCmp firstArg
		arguments: { stringCmp arguments at: 2 . SoConstant constant: exactSize }.
	
	"Here we may want to check that ByteString is kind of ByteString class"
	"We need to check here that last argument is not mutated from elsewhere..."
	
	byteEqual insertBefore: stringCmp.
	
	trapInstr removeInstr.
	equal2Instr removeAndReplaceUsesBy: byteEqual.
	stringCmp removeInstr.

]

{ #category : #testing }
SoStringEqualStub >> sizeOf: op matchesConstant: int [
	
	| sizeOps equals branches |
	sizeOps := op uses select: [ :use | use isSizeOp ].
	equals := sizeOps flatCollect: [ :each | each uses select: [ :use | use class = SoSmiEqualOp ] ].
	equals := equals select: [ :each | each subNodesAnySatisfy: [ :sub | sub isConstant and: [ sub constant = int ] ] ].
	branches := equals flatCollect: [ :each | each uses select: [ :use | use isBooleanBranch ] ].
	^ branches anySatisfy: [ :each | each trueBasicBlock dominatesInstr: stringCmp]
]

{ #category : #testing }
SoStringEqualStub >> sizeOf: op1 matchesSizeOf: op2 [
	
	| sizeOps1 equals sizeOps2 branches |
	sizeOps1 := op1 uses select: [ :use | use isSizeOp ].
	sizeOps2 := op2 uses select: [ :use | use isSizeOp ].
	equals := sizeOps1 flatCollect: [ :each | each uses select: [ :use | 
			use class = SoSmiEqualOp and: [ sizeOps2 includes: use firstArg ] ] ].
	branches := equals flatCollect: [ :each | each uses select: [ :use | use isBooleanBranch ] ].
	^ branches 
		detect: [ :each | each trueBasicBlock dominatesInstr: stringCmp]
		ifFound: [ :elem | anySize := elem expression receiver. true ]
		ifNone: [ false ]
]

{ #category : #accessing }
SoStringEqualStub >> stringCmp [
	<generated>
	^ stringCmp
]

{ #category : #accessing }
SoStringEqualStub >> stringCmp: aValue [
	<generated>
	stringCmp := aValue
]

{ #category : #accessing }
SoStringEqualStub >> trapInstr [
	<generated>
	^ trapInstr
]

{ #category : #accessing }
SoStringEqualStub >> trapInstr: aValue [
	<generated>
	trapInstr := aValue
]
