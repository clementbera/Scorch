"
examples method for the tests.

Contains examples for all the different bytecode semantics of Smalltalk.
"
Class {
	#name : #SoExamples,
	#superclass : #Object,
	#instVars : [
		'iv1',
		'iv2',
		'dispatch'
	],
	#classVars : [
		'ClassVar1'
	],
	#category : #'ScorchingTests-Examples'
}

{ #category : #'as yet unclassified' }
SoExamples class >> compiler [
	| comp |
	comp :=  super compiler.
	comp compilationContext usesFullBlockClosure: true.
	comp compilationContext encoderClass: OpalEncoderForSistaV1.
	^ comp
]

{ #category : #'tests running facilities' }
SoExamples >> = anotherObject [
	anotherObject class == self class ifFalse: [ ^ false ].
	1 to: self class instSize do: [ :i |
		(self instVarAt: i) = (anotherObject instVarAt: i) ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #'examples - sendAndBranchData' }
SoExamples >> allDifferentData [
	"Run this script to know expected sendAndBranchDatas values from the VM:
	
	| a |
	a := LiliExamples new.
	10000 timesRepeat: [a allDifferentData].
	(LiliExamples>>#allDifferentData) primitiveSendAndBranchData
	
	Current result:
	{{98. SmallInteger class. Behavior>>#'>>'}. {100. SmallInteger class. ProtoObject>>#class}. {102. Object class. Behavior>>#new}. {105. Array. Collection>>#atRandom}. #(108 nil #printString). {116. Array. Collection>>#atRandom}. {119. SmallInteger. SmallInteger>>#printString. ByteSymbol. Object>>#printString. Array. Object>>#printString. Float. Number>>#printString}. {141. BlockClosure. BlockClosure>>#on:do:}. #(145 9999 0). {150. Array. Collection>>#atRandom}. #(152 9999 5040). {156. SmallInteger. SmallInteger>>#printString. Float. Number>>#printString}. {159. LiliExamples. Object>>#printString}. {127. Float. #doesNotUnderstand:. SmallInteger. #doesNotUnderstand:. ByteSymbol. #doesNotUnderstand:. Array. #doesNotUnderstand:}. {130. LiliExamples. #doesNotUnderstand:}. {139. MessageNotUnderstood. Exception>>#resume:}}
	"
	
	| randomReceiver |
	randomReceiver := { 1 . 1.1 . #foo . #() . 'as' . $c . SmallInteger . SmallInteger>>#+ . SmallInteger class. Object new } atRandom.
	randomReceiver printString. "megamorphic"
	randomReceiver := { 1 . 1.1 . #foo . #() } atRandom.
	randomReceiver printString. "polymorphic"
	[ randomReceiver zork. self zork ] on: MessageNotUnderstood do: [ :ex | ex resume: #zork ].
	true ifFalse: [ self printString. "unused" ] ifTrue: [ 1 ]. "branch unused"
	(#(true false) atRandom ifFalse: [ 2 ] ifTrue: [ 1.0 ]) printString. "both branches used" "polymorphic"
	^ self printString "monomorphic"
]

{ #category : #'examples - sendAndBranchData' }
SoExamples >> arithmeticData [
	"Run this script to know expected sendAndBranchDatas values from the VM:
	
	| a |
	a := LiliExamples new.
	10000 timesRepeat: [a arithmeticData].
	(LiliExamples>>#arithmeticData) primitiveSendAndBranchData
	
	CurrentResult:
	{{67. SmallInteger. SmallInteger>>#*}. {71. SmallInteger. SmallInteger>>#/}. {75. SmallInteger. SmallInteger>>#'\\'}. {79. SmallInteger. Number>>#@}. {83. SmallInteger. SmallInteger>>#bitShift:}. {87. SmallInteger. SmallInteger>>#'//'}}
	"
	1 + 2.
	1 - 2.
	1 < 2.
	1 < 2 ifTrue: [ 42 ].
	1 > 2.
	1 > 2 ifTrue: [ 42 ].
	1 <= 2.
	1 <= 2 ifTrue: [ 42 ].
	1 >= 2.
	1 >= 2 ifTrue: [ 42 ].
	1 = 2.
	1 ~= 2.
	1 * 2.
	1 / 2.
	1 \\ 2.
	1 @ 2.
	1 bitShift: 2.
	1 // 2.
	1 bitAnd: 2.
	1 bitOr: 2.
	
]

{ #category : #'tests running facilities' }
SoExamples >> bar [
	| t |
	t := 1.
	[  t < 5 ] whileTrue: [ 
		t := [ t ] value  + 1. 
		t > 4 ifTrue: [ ^ #noBar ] ].
	^ #bar
]

{ #category : #'tests running facilities' }
SoExamples >> bar: a foo: b baz: c [
	iv2 := 'r'.
	[ :val |
	iv2 := iv2 , val , a printString , c printString ] value: 'ADD'.
	^ $c
]

{ #category : #'tests running facilities' }
SoExamples >> baz [ 
	^ self
]

{ #category : #'tests running facilities' }
SoExamples >> blockCannotReturn [
	^ [  ^ 1 ]
]

{ #category : #'tests running facilities' }
SoExamples >> blockWithDeadOuter [
	^ [ 1 + 2. self ]
]

{ #category : #'tests running facilities' }
SoExamples >> blockWithNLR [
	11 + 12.
	[ ^ 1 ] value.
	22 + 23.
]

{ #category : #'tests running facilities' }
SoExamples >> blockWithNLR2 [
	self evalFar: [ ^ 10 ]
]

{ #category : #'tests running facilities' }
SoExamples >> bool: a [
	iv1 := a.
	iv2 := [ :b | | t |
	t := 1.
	t + b ] value: 5.
	^ true
]

{ #category : #'tests running facilities' }
SoExamples >> callContext [
	^ thisContext
]

{ #category : #'tests running facilities' }
SoExamples >> contextCancel [
	#(true false) atRandom ifTrue: [ ^ self ].
	^ thisContext receiver
]

{ #category : #accessing }
SoExamples >> dispatch [
	^ dispatch
]

{ #category : #accessing }
SoExamples >> dispatch: anObject [
	dispatch := anObject
]

{ #category : #'tests running facilities' }
SoExamples >> eval: aBlock [
	^ aBlock value
]

{ #category : #'tests running facilities' }
SoExamples >> evalFar: aBlock [
	^ self eval: aBlock
]

{ #category : #'tests running facilities' }
SoExamples >> evalMulti: aBlock [
	iv1 := aBlock value.
	iv2 := aBlock value printString.
	^ aBlock value
]

{ #category : #'examples - blocks' }
SoExamples >> example2TempVectors [
	| full1 |
	full1 := 1.
	[ full1 := 2 ] value.
	[ | full2 |
	full2 := 3.
	[ full2 := 4 ] value ] value
]

{ #category : #'examples - blocks' }
SoExamples >> example2TempVectorsInterruptPoint [
	| full1 |
	full1 := 1.
	[ full1 := 2 ] value.
	[ | full2 |
	full2 := 3.
	[ full2 := 4.
	full2 printString ] value ] value
]

{ #category : #'examples - blocks' }
SoExamples >> example2TempVectorsOptimizedScope [
	|  var1 |
	var1 := 0.
	true ifTrue: [ 
		| var2 |
		var2 := 1.
		[  
		var1 := 2.
		var2 := 3 ] value
		 ]
]

{ #category : #examples }
SoExamples >> exampleAdd [
	^ 1 + 2
]

{ #category : #'examples - ranges' }
SoExamples >> exampleAdd0 [
	| value temp |
	value := #(4 5) atRandom.
	temp := value + 0 - 0.
	1 to: 10 do: [ :each |
		 temp := each + 1 - 1 + temp ].
	^ temp
	
]

{ #category : #examples }
SoExamples >> exampleAddChained [
	
	^ 1 + 2 + 3
]

{ #category : #'examples - jumps' }
SoExamples >> exampleAndOr1 [
	^ (true and: [ true and: [ false or: [ true ] ] ]) ifTrue: [ 40 ] 
]

{ #category : #'examples - jumps' }
SoExamples >> exampleAndOr2 [
	^ nil
		ifNil: [ true and: [ true and: [ false or: [ true ] ] ] ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleAndOr3 [
	| a b |
	a := 'string'.
	iv1 := 6.
	b := 'gnirts'.
	^ (a size = iv1) and: [| errors |
				errors := 0.
				a with: b do: [:c1 :c2 |
					c1 ~= c2 ifTrue: [errors := errors + 1] ] ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleAndOr4 [
	| bool | 
	bool := #(true false) atRandom.
	((bool
		ifTrue: [ true ]
		ifFalse: [ bool ]) 
			ifTrue: [ false ]
			ifFalse: [ bool ])
				ifTrue: [ self foo ]
				ifFalse: [ self foo ].
]

{ #category : #'examples - jumps' }
SoExamples >> exampleAndOr5 [
	| bool | 
	bool := #(true false) atRandom.
	(bool
		ifTrue: [ true ]
		ifFalse: [ bool ])
				ifTrue: [ self foo ]
				ifFalse: [ self foo ].
]

{ #category : #'examples - jumps' }
SoExamples >> exampleAndOr6 [
	"From addBlockReturnTopIfRequired"
	| collection1 collection2 |
	collection1 := self getMaybeEmptyCollection.
	collection2 := self getMaybeEmptyCollection.
	^ (collection1 isEmpty and: [(collection2 isEmpty) or: [(self getNastyCollection
								anySatisfy: [:each | (each last isInteger not) and: [(each last isFloat)
												or: [(each size > 1) and: [(each at: each size -1) isInteger]]]])]])
							ifTrue: [self foo]
							ifFalse: [self foo]
]

{ #category : #examples }
SoExamples >> exampleArg: arg [
	
	^ arg + 1
]

{ #category : #examples }
SoExamples >> exampleArg: arg arg: arg2 arg: arg3 [
	
	^ arg + arg2 + arg3
]

{ #category : #examples }
SoExamples >> exampleArray [
	| temp |
	temp := #( 1 2 3 ).
	^ {  1 . self bar . 3 }
]

{ #category : #examples }
SoExamples >> exampleArray2 [
	| temp |
	temp := {  1 . self bar . 3 }.
	iv1 := (temp at: 1).
	temp at: 2 put: temp class.
	^ temp size
]

{ #category : #examples }
SoExamples >> exampleArray3 [
	| temp |
	temp := #( 42 . self bar . 3 ).
	iv1 := (temp at: 1).
	iv2 := temp class.
	^ temp size
]

{ #category : #examples }
SoExamples >> exampleArrayAsArg [
	
	self bar: 1 foo: { 1 . 2 . 4 . 5 } baz: true.
	true ifFalse: [ self foo ]
]

{ #category : #examples }
SoExamples >> exampleArrayDo [
	 Smalltalk specialSelectors  do: [ :i | self kick: i ]
]

{ #category : #examples }
SoExamples >> exampleAssign [
	| t1 t2 |
	ClassVar1 := t1 := t2 := t1 := ClassVar1 := 1.
	[ t2 := ClassVar1 := t2 := ClassVar1 := 2 ] value.
	^ t1 + t2
]

{ #category : #examples }
SoExamples >> exampleAssign2 [
	| t1 |
	iv1 := 42.
	t1 := iv1.
	iv1 := 27.
	^ t1
]

{ #category : #examples }
SoExamples >> exampleAssignInstVarInlined [
	iv2 := self foo.
	^ iv2
]

{ #category : #examples }
SoExamples >> exampleAssignment [
	| temp1 |
	temp1 := #value.
	^ temp1
]

{ #category : #examples }
SoExamples >> exampleBasicNew [
	^ SoExamples basicNew
		iv1: 1;
		iv2: 2;
		yourself
]

{ #category : #'examples - ranges' }
SoExamples >> exampleBasicRange1 [
	| array |
	array := #(1 2 3 4 5).
	1 to: array size do: [ :i |
		self nonInlinedEval: (array at: i) ]
]

{ #category : #'examples - ranges' }
SoExamples >> exampleBasicRange2 [
	| array |
	array := #(1 2 3 4 5).
	0 to: array size - 1 do: [ :i |
		self nonInlinedEval: (array at: i + 1) ]
]

{ #category : #'examples - ranges' }
SoExamples >> exampleBasicRange3 [
	| array |
	array := #(1 2 3 4 5).
	1 to: array size - 1 do: [ :i |
		self nonInlinedEval: (array at: i + 1).
		self nonInlinedEval: (array at: i) ]
]

{ #category : #'examples - ranges' }
SoExamples >> exampleBasicRange4 [
	iv1 := #(1 2 3 4 5).
	1 to: iv1 size do: [ :i |
		self nonInlinedEval: (iv1 at: i) ]
]

{ #category : #'examples - ranges' }
SoExamples >> exampleBasicRange5 [
	| array |
	array := {Object new . 2 . Object new . 3 . 4 . 5 . 6 . 7 . 8 . 9 . 10}.
	1 to: array size do: [ :i |
		array at: i put: true ].
	^ array
]

{ #category : #examples }
SoExamples >> exampleBigArray [
	"This array should have a size more than 127 elements"
	^ { 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 .  255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 . 255 }
]

{ #category : #examples }
SoExamples >> exampleBit [
	| t1 t2 t3 |
	t1 := 2r11001100.
	t2 := 2r11110000.
	t3 := 2r10101010.
	^ { t1 bitAnd: t2 . t1 bitAnd: t3 . t1 bitOr: t2. t2 bitOr: t3. t1 bitXor: t2 . t2 bitXor: t3 . 
		t1 bitAnd: 12. 12 bitAnd: t1 . t2 bitOr: 23. 23 bitOr: t2 . t3 bitXor: 17. 17 bitXor: t3 }
	
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlock [
	| copied1 copied2 full1 full2 |
	copied1 := copied2 := full1 := full2 := 1.
	[ :arg1 :arg2 | | temp1 temp2 | temp1 := temp2 := full1 := full2 := copied1 + copied2 + arg1 + arg2 ] value: 2 value: 3.
	^ full1 - copied1 
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlock2 [
	| t |
	t := 1.
	2 + 3.
	t := self bool: [ t + 5 ].
	4 + 5.
	^ t
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlock3 [
	| t |
	t := [ 1 + 2. self ].
	4 + 5 - 3.
	self eval: t.
	^ 3 + 2
	
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlock4 [
	| t |
	t := self blockWithDeadOuter.
	4 + 5 - 3.
	self eval: t.
	^ 3 + 2
	
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlock5 [
	| t |
	t := [ 1 + 2. self ].
	4 + 5 - 3.
	self evalFar: t.
	^ 3 + 2
	
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlock6 [
	| three |
	three := self nonInlinedEval: [ 1 + 2 ].
	true ifTrue: [^ self].
	(self bool: 12) ifFalse: [ self yourself ].
	^ self foo
	
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockArgCopied [
	^ [ :arg | [ arg ] value ] value: 5
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockArgCopied2 [
	| temp |
	temp := 1.
	^ [ :arg | arg = temp ifTrue: [ arg ] ifFalse: [ temp ] ] value: 5
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockArgCopied3 [
	| temp |
	temp := 1.
	^ [ :arg | arg = temp ifTrue: [ arg ] ifFalse: [ temp ] ] value: 1
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockArgWritten [
	"| t |	
	t := [ :arg | arg := 1. arg ].
	^ t value: 5"
	
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockBackJump [
	^ [ | t |
		t := true.
		[ t ] whileTrue: [ t := false ] ] value
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockCannotReturn [
	| temp |
	temp := 1.
	^ [ ^ temp := 2 ]      
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockCannotReturn2 [
	[ self blockCannotReturn value ] on: BlockCannotReturn do: [ :ex | ex ]
]

{ #category : #'examples - block deopt' }
SoExamples >> exampleBlockDeoptFromDeadInlined [
	| block |
	block := [ [ self nonInlinedBool ] ] value.
	self nonInlinedBool
]

{ #category : #'examples - block deopt' }
SoExamples >> exampleBlockDeoptFromDeadNotInlined [
	| block |
	block := self nonInlinedEval: [ [ self nonInlinedBool ] ].
	self nonInlinedBool
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockDoubleNestedBackJump [
	^ [ [ :bool | | t |
		t := bool.
		[ t ] whileTrue: [ t := false ] ] value: true ] value
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockEvalMulti [
	[ 1 + 2 ] value.
	self evalMulti: [ 3 + 5. self printString ].
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockIfFalseNLR [
	^ [ true ifFalse: [ self ] ] value
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockIndexes [
	| t1 t2 t3 |
	t1 := t2 := self nonInlinedEval: [ 1 + 2 ].
	t3 := self nonInlinedBool.
	t2 yourself.
	[ 4 + 5. t3 ] value.
	t1 yourself.
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockIndirectEval [
	self eval: [ 1 + 2. self ]
]

{ #category : #'examples - block deopt' }
SoExamples >> exampleBlockInlined [
	"nonInlinedBool scopes need the closure."
	| t |
	t := [ self nonInlinedBool ].
	t value.
	self nonInlinedBool
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockInliningNLR [
	1 + 2.
	self blockWithNLR.
	3 + 4.
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockInliningNLR2 [
	self blockWithNLR2
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockIssue1 [
	#( 1 ) do: [ :one | 
		one isInteger ifFalse: [ ^one asInteger ] ].
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockMultipleInlining [
	| tmp |
	tmp := [ self foo ].
	tmp value.
	self bar.
	tmp value.
	^ self baz
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockNested [
	| copied1 copied2 full1 full2 |
	copied1 := copied2 := full1 := full2 := 1.
	[ :arg1 :arg2 | 
		| temp1 temp2 | 
		temp1 := temp2 := full1 := full2 := ([ :arg11 | | t3 | t3 :=copied1 + copied2 + arg11 ] value: arg1) + arg2 
	] value: 2 value: 3.
	^ full1 - copied1
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockNestedClosureWithOuterReference [
	| t count  |
	count := 0.
	t := [ 
		count := count + 1.
		count > 10 ifTrue: [ ^ 42 ].
		[ t value ] value ].
	t value.
	
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockNestedOuter [
	^ [ [ [ [ [ 1 + 2 ] ] ] ] ] value value value value value
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockNestedOuter2 [
	^ [ [ [ [ [ 1 + 2 ] value ] value ] value ] value ] value
]

{ #category : #'examples - block deopt' }
SoExamples >> exampleBlockNotInlined [
	"nonInlinedBool scopes need the closure."
	| t |
	t := [ self nonInlinedBool ].
	self nonInlinedEval: t.
	self nonInlinedBool
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockPropagation [
	| t f g block |
	t := 1.
	f := self nonInlinedBool.
	3 + 2.
	g := 5.
	block :=  [ t + f asBit + g ].
	7 + 8.
	self nonInlinedEval: block.
	4 + 5.
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockPropagation2 [
	| t f g block |
	t := 1.
	f := self nonInlinedBool.
	3 + 2.
	g := 5.
	block :=  [ t + f asBit + g ].
	7 + 8.
	self nonInlinedEval: block.
	42 yourself.
	self nonInlinedEval: block.
	4 + 5.
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockSameMethod [
	| newBlock |
	newBlock := self runAndReturnBlock: [ 3 + 4 ].
	^ self runAndReturnBlock: newBlock
]

{ #category : #'examples - block deopt' }
SoExamples >> exampleBlockUsedInNonInlinedBlock [
	| block |
	block := [ self nonInlinedBool ].
	^ self nonInlinedEval: [ 
		block value.
		self nonInlinedBool. ].
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockValueWithArguments [

	iv1 := [ :a :b :c | a - b - c ] valueWithArguments: { 3 . 5 . 9 }.
	^ [ :a :b :c | a + b + c ] valueWithArguments: #(3 5 9)
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockWithArg [
	[ :a | a ] value: 1.
	[ :b :c | b + c ] value: 2 value: 3.
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockWithArgAnd [
	| a b c |
	a := self class new.
	b := $z.
	c := 5.
	(c <= 1 
		ifTrue: [ [ :f | f ] ]
		ifFalse: [  [ :arg | 
			(arg = 128 and: [ a foo = b ]) ifTrue: [ c := c + 1 ].
			c > 1 ] ]) value: 128
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockWithDeadOuter [
	| temp |
	temp := self blockWithDeadOuter.
	1 + 2 - 3.
	^ temp value
]

{ #category : #'examples - blocks' }
SoExamples >> exampleBlockWithTemp [
	[ | t1 | t1 := 1. t1 ] value.
	[ | t2 t3 | t2 := t3 := 1. t2 + t3 ] value.
]

{ #category : #examples }
SoExamples >> exampleCSE [
	| t |
	t := self nonInlinedEval: [ 1 ].
	t < 0 ifTrue: [ 
		iv1 := t + 1.
		iv2 := t + 1.
		iv1 := t + 1 ].
]

{ #category : #examples }
SoExamples >> exampleCascade [
	self
		foo;
		bar;
		baz
]

{ #category : #'examples - jumps' }
SoExamples >> exampleCaseOf [
	| t |
	t := $m.
	t caseOf: {
		[$b] -> [self foo].
		[$o] -> [self bar].
		[$m] -> [self baz] }
		otherwise: []
]

{ #category : #'examples - jumps' }
SoExamples >> exampleChainedJumps [
	^ (true
		ifTrue: [ 1 = 0 ]
		ifFalse: [ 0 = 0 ])
			ifFalse: [ 1 ]
			ifTrue: [ 0 ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleChainedJumps2 [
	^ (true
		ifTrue: [ false ]
		ifFalse: [ true ])
			ifFalse: [ 1 ]
			ifTrue: [ 0 ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleChainedJumps3 [
	| t |
	t := 1.
	[ [ t < 5 ] whileTrue: [ t := t + 1 ]. t < 10 ] whileTrue: [ self kick: 42. t := t + 2 ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleChainedJumps4 [
	^ (self bool: 5)
		ifNotNil: [ self foo ]
		ifNil: [ self bar 
			ifNotNil: [ self foo ] 
			ifNil: [ ^ true ] ]
]

{ #category : #examples }
SoExamples >> exampleClassVar [
	
	ClassVar1 := true.
	self foo.
	^ ClassVar1
]

{ #category : #'examples - blocks' }
SoExamples >> exampleCleanBlock [
	[ 1 + 2 ].
	iv1 := [ 7 + 8 ].
	[  3 + 4 ] value.
	^ [  5 + 6 ]
]

{ #category : #examples }
SoExamples >> exampleComp [
	'' onlyLetters = ''
]

{ #category : #examples }
SoExamples >> exampleConstantPropagation [
	| t |
	t := 1.
	self foo: t bar: t.
	^ self bar: t foo: t baz: t
]

{ #category : #examples }
SoExamples >> exampleContextCancel [
	self contextCancel.
]

{ #category : #'examples - blocks' }
SoExamples >> exampleCopyingBlock [
	| temp |
	temp := 1.
	^ [ temp ] value
]

{ #category : #'examples - blocks' }
SoExamples >> exampleCopyingBlock2 [
	| temp |
	^ [ temp ] value
]

{ #category : #'examples - blocks' }
SoExamples >> exampleCopyingBlockArg: arg [
	| temp |
	temp := 1.
	^ [ temp + arg ] value
]

{ #category : #examples }
SoExamples >> exampleEmptyTemp [
	
	| temp |
]

{ #category : #examples }
SoExamples >> exampleEqual [
	^ self string == self string2
]

{ #category : #examples }
SoExamples >> exampleFillArray [
	iv1 := Array new: 10.
	iv1 atAllPut: #value.
	
	
]

{ #category : #'examples - blocks' }
SoExamples >> exampleFullBlock [
	| temp |
	temp := 1.
	^ [ temp := 2 ] 
]

{ #category : #examples }
SoExamples >> exampleGlobal [
	
	| temp |
	temp := true.
	temp := self foo: Class bar: temp.
	^ temp
]

{ #category : #examples }
SoExamples >> exampleHash [
	"unused"
	self basicIdentityHash. 
	"used + range"
	self basicIdentityHash + 10.
	
	^ self basicIdentityHash = 0
	
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfFalseNLR [
	^ true ifFalse: [ ^ 4 ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfNil [
	^ iv1 ifNil: [ #notNilLit ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfNilIfNotNil [
	^ nil ifNil: [ 0 ] ifNotNil: [ true class ] 
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfNilIfNotNil2 [
	^ nil == nil ifTrue: [ 0 ] ifFalse: [ true class ] 
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfNilIfNotNilArg [
	^ nil ifNil: [ 0 ] ifNotNil: [ :f | f class ] 
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfNilIfNotNilNested [
	^ self foo
		ifNil: [ self bar ifNil: [ '' ] ifNotNil: [ :package | '' ] ]
		ifNotNil: [ :class | class yourself ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfNotNilArg [
	^ true ifNotNil: [ :f | f yourself ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfNotNilArgWithStatement [

	self assert: (5 ifNotNil: [ :a | a ]) = 5.
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrue [
	| a b |
	a := 3.
	a = 3 ifTrue: [ b := 2 ].
	^ b
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueIfFalse [
	| a b |
	a := 3.
	a = 3 ifTrue: [ b := 2 ] ifFalse: [ b := 1 ].
	^ b
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueIfFalse2 [
	| a b |
	a := self bool: 2.
	a 
		ifTrue: [ 
			false ifTrue: [ a yourself. b := 1 ] ifFalse: [ a not. b := 2 ] ] 
		ifFalse: [ 
			true ifTrue: [ a asBit. b := 4 ] ifFalse: [ a value. b := 5 ] ].
	^ b
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueIfFalse3 [
	| a b c |
	a := true.
	a 
		ifTrue: [ 
			false ifTrue: [ b := 1 ] ifFalse: [ b := 2 ] ] 
		ifFalse: [ 
			true ifTrue: [ b := 4 ] ifFalse: [ b := 5 ] ].
	a 
		ifTrue: [ 
			false ifTrue: [ c := 10 ] ifFalse: [ c := 20  ] ] 
		ifFalse: [ 
			true ifTrue: [ c := 40 ] ifFalse: [ c := 50 ] ].
	^ b + c
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueIfFalse4 [
	| a b c |
	a := true.
	a 
		ifTrue: [ 
			c := 0.
			false ifTrue: [ b := 1 ] ifFalse: [ b := 2 ] ] 
		ifFalse: [ 
			c := 1.
			true ifTrue: [ b := 4 ] ifFalse: [ b := 5 ] ].
	^ b + c
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueIfFalse5 [
	| a t |
	a := 1.
	true 
		ifTrue: [ 
			t := a.
			a := 2. ]
		ifFalse: [ 
			t := a.
			a := 3 ].
	^ a + t
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueIfFalse6 [
	| temp |
	temp := self nonInlinedBool.
	temp ifTrue: [ 1 + 2 ] ifFalse: [ 2 + 3 ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueIfFalse7 [
	| t |
	t := true ifTrue: [ 1 ] ifFalse: [ 2 ].
	t = 2 ifTrue: [ t := self bar. ^ 5 ] ifFalse: [ self foo ].
	^ t
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueIfFalse8 [
	self foo: 1 bar: (true ifTrue: [^ 1] ifFalse: [^ 0])
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueIfFalseAnd [
	| a b |
	a := 3.
	(a = 3 and: [ a ~= 2 ]) ifTrue: [ b := 3 ] ifFalse: [ b := 1 ].
	^ b
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueIfFalseBlock [
	| a |
	a := 2.
	^ (a = 3 ifTrue: [ [ 5 ] ] ifFalse: [ [ 6 ] ]) value
	
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueIfFalseBlock2 [
	^ self foo isSymbol
		ifTrue: [(self bool: 1)
				ifTrue: [[self bar ]]
				ifFalse: [[self baz ]]]
		ifFalse: [(self bool: 2)
				ifTrue: [self bar]
				ifFalse: [[self baz]]] 
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueIfFalseSameResult [
	^ true 
		ifTrue: [ false ifTrue: [ $d ] ifFalse: [ $d ] ]
		ifFalse: [ false ifTrue: [ $d ] ifFalse: [ $d ] ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueIfFalseSpilled [
	^ true
		ifTrue: [ 1 ]
		ifFalse: [ 2 ].
]

{ #category : #'examples - jumps' }
SoExamples >> exampleIfTrueReturn [
	| a |
	a := 3.
	a = 3 ifTrue: [ ^ a + 1 ].
	^ a
]

{ #category : #examples }
SoExamples >> exampleInlineContext [
	^ self callContext
]

{ #category : #examples }
SoExamples >> exampleInlinedNLR [
	self nlr1
]

{ #category : #examples }
SoExamples >> exampleInlinedNLR2 [
	self nlr2
]

{ #category : #examples }
SoExamples >> exampleInstVarStore [
	iv1 := 5.
	iv2 := 10.
]

{ #category : #examples }
SoExamples >> exampleInstVarX [
	iv1 := 1.
	iv2 := 3.
	iv2 := 10.
	iv1 := iv1 - 2.
	iv2 := 5.
	iv1 := iv2.
	iv1 + iv1.
]

{ #category : #examples }
SoExamples >> exampleIsSomething [
	^ #( 1 . #foo ) atRandom isInteger ifTrue: [ 1 ] ifFalse: [ 0 ]
]

{ #category : #examples }
SoExamples >> exampleIsSomething2 [
	#( 1 . #foo . 3 . #bar . 5 . #baz ) do: [ :each |
		iv1 := each isInteger ifTrue: [ 1 ] ifFalse: [ 0 ] ].
]

{ #category : #'examples - jumps' }
SoExamples >> exampleJumpDelete [
	| t |
	t := true 
		ifTrue: [ 1 ]
		ifFalse: [ 2 ].
	
]

{ #category : #'examples - jumps' }
SoExamples >> exampleJumpOnArgCondition [
	| a b |
	a := 3.
	(self bool: a) ifTrue: [ b := 3 ].
	^ b
]

{ #category : #examples }
SoExamples >> exampleLiteralIVAccess [
	
	^ 1.0s1 scale
]

{ #category : #examples }
SoExamples >> exampleLoad1 [
	| t |
	t := ClassVar1 := 1.
	ClassVar1 := 5.
	^ t
]

{ #category : #examples }
SoExamples >> exampleLoad2 [
	| t |
	t := iv1  := 1.
	iv1 := 5.
	^ t
]

{ #category : #examples }
SoExamples >> exampleLoad3 [
	| indirectTemp |
	indirectTemp := 1.
	[ | v |
	v := indirectTemp  := 1.
	indirectTemp := 5. 
	^ v ] value
	
]

{ #category : #'examples - jumps' }
SoExamples >> exampleLoopConditionExits [ 
	1 to: 10 do: [ :i |
		i > 3
			ifTrue: [ ^ 5 ]
			ifFalse: [ ^ #foo ] ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleLoopManyExits [ 
	1 to: 10 do: [ :i |
		i > 15 ifTrue: [ ^ self ].
		i >= 10 ifTrue: [ ^ 1 ].
		i < 1 ifFalse: [ ^ 12 ]. ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleLoopManyPhis [
	| tmp1 tmp2 tmp3 |
	1 to: 25 do: [ :i | 
		tmp1 := SoExamplesDispatch new.
		tmp2 := SoExamplesDispatch new.
		tmp3 := SoExamplesDispatch new.
		tmp1 remoteIV1: 1.
		tmp2 remoteIV1: 2.
		tmp3 remoteIV1: 3 ].
	^ { tmp1 remoteIV1 . tmp2 remoteIV1 . tmp3 remoteIV1 }
]

{ #category : #'examples - jumps' }
SoExamples >> exampleLoopMultiplePreds [
	| t |
	true 
		ifTrue: [ t := 1 ]
		ifFalse: [ t := 3 ].
	[ [ t < 5 ] whileTrue: [ t := t + 1 ]. t > 10 ] whileFalse: [ t := t + 10 ].
]

{ #category : #'examples - jumps' }
SoExamples >> exampleLoopNLR [
	1 to: 5 do: [ :i | ^ i + 1 ]
]

{ #category : #examples }
SoExamples >> exampleMultipleAssignment [
	| temp1 temp2 temp3 |
	temp1 := #value.
	temp2 := temp1.
	temp3 := temp1.
	temp1 := temp2.
	^ temp1
]

{ #category : #'examples - jumps' }
SoExamples >> exampleMultipleIfTrue [
	| a b |
	a := false.
	a ifTrue: [ self bool: 7 ].
	a ifTrue: [ ^ self kick: a ].
	a ifFalse: [ b := 3 ].
	a ifFalse: [ ^ a ].
	^ b
]

{ #category : #'examples - jumps' }
SoExamples >> exampleMultipleJumpNoFallThrough [
	| iterator |
	(self bool: $s) ifTrue: 
		[ iterator := 1.
		  [ iterator < 5 ] whileTrue: 
			[ iv2 := #(11 22 33 44 55) at: iterator.
			  iterator := iterator + 1 ] ].
	^ self foo
]

{ #category : #examples }
SoExamples >> exampleMultiplePICs [
	#( 1 . #foo . 3 . #bar . 5 . #baz ) do: [ :each |
		| t1 t2 |
		t1 := each isInteger.
		t2 := each isSymbol.
		iv1 := t1 or: [ t2 ] ].
]

{ #category : #examples }
SoExamples >> exampleMultiplePICs2 [
	#( 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz ) do: [ :each |
		each isInteger;isSymbol. ].
]

{ #category : #examples }
SoExamples >> exampleMultiplePICs3 [
	#( 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz . 1 . #foo . 3 . #bar . 5 . #baz ) do: [ :each |
		| t |
		t := each isInteger
			ifTrue: [ 1 ]
			ifFalse: [ 0 ].
		each printString.
		iv1 := t + 1. ].
]

{ #category : #examples }
SoExamples >> exampleMultiplePICs4 [
	#(1 1.0 2 2.0 3 3.0) do: [ :each |
		iv1 := each + each - each ].
]

{ #category : #'examples - jumps' }
SoExamples >> exampleNastyJumps [
	| r1 r2 |
	iv1 := 0.
	(r1 := 1) > iv1
		ifTrue: [ (r2 := 2) = iv1
				ifTrue: [ ^r2 ] ].
	[ (r2 := r2 + 1) = 5 or: [ self bool: $c ] ] whileFalse: [ r1 := r1 + 1 ].
	^ r2
	
]

{ #category : #examples }
SoExamples >> exampleNestedArray [
	^ {  1 . self yourself . { 10 . self bar . 20 . { $c . self yourself . { self foo } . $d } . 30 } . 3 }
]

{ #category : #examples }
SoExamples >> exampleNestedLoops [
	1 to: 17 do: [ :i |
		1 to: 20 do: [ :j |
			1 to: 23 do: [ :k |
				self nonInlinedEval: i + j + k ] ] ].
	1 to: 17 do: [ :z |
		1 to: 20 do: [ :x |
			1 to: 23 do: [ :c |
				self nonInlinedEval: z + x + c ] ].
		1 to: 20 do: [ :v |
			1 to: 23 do: [ :b |
				self nonInlinedEval: z + v + b ].
			1 to: 23 do: [ :n |
				self nonInlinedEval: z + v + n ] ] ]
]

{ #category : #examples }
SoExamples >> exampleNestedSend [
	self kick: (self bool: (self foo: (self foo) bar: #XXX))
]

{ #category : #examples }
SoExamples >> exampleNestedSend2 [
	^ self bar: self foo foo: self bar baz: self baz
]

{ #category : #examples }
SoExamples >> exampleNew [
	^ SoExamples new
		iv1: 1;
		iv2: 2;
		yourself
]

{ #category : #'examples - blocks' }
SoExamples >> exampleNonLocalReturn [
	| temp |
	temp := 1.
	[ ^ 2 ] value
]

{ #category : #'examples - blocks' }
SoExamples >> exampleNonLocalReturn2 [
	| temp |
	temp := 1.
	[ ^ temp := 2 ] value
]

{ #category : #'examples - blocks' }
SoExamples >> exampleNonLocalReturnNested [
	iv1 := 1.
	[
		iv2 := 2.
		[ ^ 3 ] value.
		iv1 := 3.
	 ] value.
	iv2 := 4.
]

{ #category : #'examples - blocks' }
SoExamples >> exampleNonLocalReturnNested2 [
	iv1 := 1.
	[ iv2 := 2. [ ^ 3 ] ] value value.
	iv1 := 3.
	iv2 := 4.
]

{ #category : #'examples - blocks' }
SoExamples >> exampleOptimizedBlockInBlock [
	^ [ true ifFalse: [ ^ self ] ] value 
]

{ #category : #'examples - blocks' }
SoExamples >> exampleOptimizedBlockInOptimizedBlock [
	| t1 |
	true ifTrue: [ [ t1 isNil ] whileTrue: [ t1 := 10 ] ]

]

{ #category : #'example - loop opt' }
SoExamples >> examplePeelUsedAfter [
	| array comp val iterator |
	array := { 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 . 1 . 2 . 3 . 4 . 5 } .
	val := 5.
	iterator := 1.
	[ comp := (iterator <= 5) ] whileTrue: [ 
		val := val + (array at: iterator).
		iterator := iterator + 1 ].
	^ { val . iterator . comp }
]

{ #category : #examples }
SoExamples >> examplePerform [
	Object new perform: #bindingOf: with: nil
]

{ #category : #examples }
SoExamples >> examplePrimitive [
	<primitive: 65>
]

{ #category : #examples }
SoExamples >> examplePrimitiveJump [
	<primitive: 65>
	true ifFalse: [  ^ false ].
	^ 42
]

{ #category : #examples }
SoExamples >> examplePrimitiveModule [
	<primitive: 'primitiveSubFloatArray' module: 'FloatArrayPlugin'>
]

{ #category : #'examples - quick methods' }
SoExamples >> exampleQuickReturn1 [
	^ 1
]

{ #category : #'examples - quick methods' }
SoExamples >> exampleQuickReturnFalse [
	^ false
]

{ #category : #'examples - quick methods' }
SoExamples >> exampleQuickReturnNil [
	^ nil
]

{ #category : #'examples - quick methods' }
SoExamples >> exampleQuickReturnReceiverVar [
	^ iv1
]

{ #category : #'examples - quick methods' }
SoExamples >> exampleQuickReturnSelf [
	"nothing, returns self by default :)"
]

{ #category : #'examples - ranges' }
SoExamples >> exampleRange [
	| start stop array res |
	start := 1.
	stop := 10.
	array := { 1 . 2 . 3 . 4 . 5. 6. 7. 8. 9. 10 }.
	start to: stop do: [ :i |
		res := array at: i.
		res := (i > 5) ifTrue: [ array at: i - 5 ] ifFalse: [ array at: i + 5 ] ].
	
]

{ #category : #'examples - ranges' }
SoExamples >> exampleRange10 [
	| array |
	array := self getArray.
	1 to: array size do: [ :i | 
		i decimalDigitLength printString.
		(array at: i) ]
]

{ #category : #'examples - ranges' }
SoExamples >> exampleRange2 [
	| array |
	array := #(1 2 3 4 5).
	1 to: array size do: [ :i | (array at: i) printString ]
]

{ #category : #'examples - ranges' }
SoExamples >> exampleRange3 [
	| limit expr array |
	expr := 1.
	limit := 20.
	array := (1 to: 20) asArray.
	[ expr < array size ] whileTrue: [
		array at: limit.
		array at: expr.
		limit := limit - 1.
		expr := expr + 1 ]
]

{ #category : #'examples - ranges' }
SoExamples >> exampleRange4 [
	| array |
	array := #(1 2 3 4 5 6 7).
	1 to: array size by: 2 do: [ :i |
		(array at: i) printString ].
	array size to: 1 by: -2 do: [ :i |
		(array at: i) printString ].
]

{ #category : #'examples - ranges' }
SoExamples >> exampleRange5 [
	| i array |
	array := #(1 2 4 17 3 6).  
	i := 1.
	"first array at: i overflows on i := array size + 1. Not reached for tests, but cannot be optimized."
	[ (array at: i) < array size ifTrue: [ ^ 54 ].
	i < array size ] whileTrue: [ (array at: i) yourself ]
]

{ #category : #'examples - ranges' }
SoExamples >> exampleRange6 [
	| array |
	array := #( 1 2 3 4 5).
	1 to: array size do: [ :each |
		each >= 5 ifTrue: [ ^ nil ].
		each printString ].
	
]

{ #category : #'examples - ranges' }
SoExamples >> exampleRange7 [
	| array temp |
	array := #( 1 2 3 4 5).
	temp := 1.
	false ifTrue: [ 
		1 to: array size do: [ :each |
			temp := each + 1.
			(array at: temp - 1) printString.
		 ] ].
	^ temp + 1.
]

{ #category : #'examples - ranges' }
SoExamples >> exampleRange8 [
	| array |
	array := #( 1 2 3 4 5 6).
	0 to: array size -1 do: [ :i |
		(array at: i + 1) printString ].
	array size to: 1 by: -1 do: [ :j |
		(array at: j) printString ]
]

{ #category : #'examples - ranges' }
SoExamples >> exampleRange9 [
	| array |
	array := self getArray.
	1 to: 3 do: [ :i | (array at: i) printString ]
]

{ #category : #'examples - ranges' }
SoExamples >> exampleRangeFolding [
	| value |
	value := #(8 9) atRandom.
	^ value < 10
		ifTrue: [ value < 20
				ifTrue: [ value > 50 ifTrue: [ 1 ] ifFalse: [ 3 ] ]
				ifFalse: [ 0 ] ]
		ifFalse: [ value >= 10
			ifTrue: [ 5 ]
			ifFalse: [ 2 ] ]
]

{ #category : #'examples - ranges' }
SoExamples >> exampleRealRange1 [
	iv1 := #(1 2 3 4).
	iv1 do: [ :elem | self nonInlinedEval: elem ].
	iv1 := #(a b c d e).
	iv1 do: #species.
]

{ #category : #'examples - remote' }
SoExamples >> exampleRemoteDeadBlock [
	| deadBlock |
	deadBlock := dispatch remoteDeadBlock.
	4 + 5.
	^ deadBlock value.
]

{ #category : #'examples - remote' }
SoExamples >> exampleRemoteDeadBlock2 [
	^ dispatch remoteDeadBlock value
]

{ #category : #'examples - remote' }
SoExamples >> exampleRemoteEval [
	^ dispatch remoteEval: [ 4 + 5. self ]
]

{ #category : #'examples - remote' }
SoExamples >> exampleRemoteEval2 [
	dispatch remoteEval: [ self eval: [ iv1 := 5 ] ].
	^ iv1
]

{ #category : #'examples - remote' }
SoExamples >> exampleRemoteMethod [
	self bool: 1.
	dispatch remoteMethod.
	self foo.
]

{ #category : #'examples - remote' }
SoExamples >> exampleRemoteMethod2 [
	self bar.
	self bool: dispatch remoteMethod.
	self foo.
]

{ #category : #'examples - remote' }
SoExamples >> exampleRemoteMethod3 [
	self eval: [ dispatch remoteMethod ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleRepeat [
	| t |
	t := [ ^ nil ].
	[ t value ] repeat.
	self foo
]

{ #category : #'examples - jumps' }
SoExamples >> exampleRepeat2 [
	| t |
	t := [^ nil].
	[ self foo.
	true ifTrue: [ self foo: 1 bar: 2 ].
	t value.
	self foo ] repeat.
	self foo
]

{ #category : #'examples - jumps' }
SoExamples >> exampleRepeatBranch [
	false
		ifFalse: [ self yourself ]
		ifTrue: [ [ self foo ] repeat ].
	self foo: 1 bar: 2.
]

{ #category : #'examples - jumps' }
SoExamples >> exampleReturnJump [
	| bool |
	bool := true ifTrue: [ ^ 1 ] ifFalse: [ 0 ].
	^ bool
]

{ #category : #'example - loop opt' }
SoExamples >> exampleSafePeelUsedAfter [
	| array comp val iterator size |
	array := Smalltalk specialSelectors.
	val := 5.
	iterator := 1.
	size := array size.
	[ comp := (iterator <= size) ] whileTrue: [ 
		val := array at: iterator.
		iterator := iterator + 1 ].
	^ { val . iterator . comp }
]

{ #category : #examples }
SoExamples >> exampleShifts [
	| a b c d tmp |
	iv1 := #[1 4 6].
	tmp := iv1.
	1 to: tmp size do: [ :i |
		a := (tmp at: i) bitShift: 8.
		b := (tmp at: i) bitShift: 16.
		c := (tmp at: i) bitShift: -8.
		d := (tmp at: i) bitShift: -16. ].
	iv2 := { a . b . c . d }
]

{ #category : #'example - loop opt' }
SoExamples >> exampleSmallLoop [
	"May get unrolled or peeled"
	^ { 1 . 2 . 3 . 4 . 5. 6. 7. 8. 9. 10 } includes: 7
	
]

{ #category : #'examples - jumps' }
SoExamples >> exampleSparseConditional [
	| t |
	t := #(2 2) atRandom.
	t = 2
		ifTrue: [ ^ t ]
		ifFalse: [ ^ 3 ]
]

{ #category : #examples }
SoExamples >> exampleSpillPhi [ 
	| t1 t2 t3 |
	true 
		ifTrue: [ 
			t1 := 1.
			t2 := 2.
			t3 := 3. ]
		ifFalse: [ 
			t3 := 30.
			t2 := 20.
			t1 := 10. ].
	self bar: t2 foo: t3 baz: t1
]

{ #category : #examples }
SoExamples >> exampleSpillPhi2 [
	| t1 t2 t3 |
	true 
		ifTrue: [ 
			t1 := SoExamples new.
			t2 := 2.
			t3 := 3. ]
		ifFalse: [ 
			t3 := 30.
			t2 := 20.
			t1 := SoExamplesDispatch new. ].
	^ t1 foo: t3 bar: t2
]

{ #category : #examples }
SoExamples >> exampleSpillPhi3 [
	| t3 |
	iv1 := true 
		ifTrue: [ 
			t3 := 3. ]
		ifFalse: [ 
			t3 := 30. ].
]

{ #category : #examples }
SoExamples >> exampleSpillPhi4 [
	| t1 t2 t3 t4 t5 |
	true 
		ifTrue: [ 
			t1 := SoExamples new.
			t2 := SoExamplesDispatch new.
			t4 := 4.
			t5 := 5.
			t3 := 3. ]
		ifFalse: [ 
			t5 := 50.
			t4 := 40.
			t3 := 30.
			t1 := SoExamplesDispatch new.
			t2 := SoExamples new. ].
	^ t1 bar: t3 foo: (t2 foo: t4 bar: t5) baz: t5.
]

{ #category : #examples }
SoExamples >> exampleSpillPhi5 [
	| t1 |
	t1 := true ifTrue: [ 2 ] ifFalse: [ $c ].
	self bool: t1 yourself
]

{ #category : #examples }
SoExamples >> exampleSpillPhi6 [
	| t1 t2 |
	true 
		ifTrue: [ 
			t1 := 1.
			t2 := 2 ] 
		ifFalse: [ 
			t2 := 20.
			t1 := 10 ].
	^ { t1 . t2 }
]

{ #category : #examples }
SoExamples >> exampleSplit [
	^ (true 
		ifTrue: [ 5 ]
		ifFalse: [ 5.0 ]) printString
]

{ #category : #examples }
SoExamples >> exampleSplitSend [
	| temp |
	#(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) do: [ :i |
		temp := (i // 2 = 0 
			ifTrue: [ 1 ]
			ifFalse: [ 1.0 ]) sqrt ].
	^ temp
]

{ #category : #'examples - jumps' }
SoExamples >> exampleStackSpill [
	| temp |
	temp := 1.
	^ true ifFalse: [ temp := 3. ^ temp ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleStackSpill2 [ 
	| tmp |
	tmp := 5.
	^ true ifTrue: [ tmp := 2. ^ tmp ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleStackpJump [
	^ {  1 . 2 . 3 . true ifTrue: [ 5 ] ifFalse: [ 7 ] }
	
]

{ #category : #examples }
SoExamples >> exampleStackpMessage [
	^ {  1 . 2 . 3 . self bar }
	
]

{ #category : #examples }
SoExamples >> exampleStressPhis [
	ClassVar1 := 1.
	^ self getIndex @ self getIndex
]

{ #category : #examples }
SoExamples >> exampleStringEqual [
	ClassVar1 := 'd'.
	self foo.
	iv1 := ClassVar1 = 'd'.
	ClassVar1 := 'ff'.
	self foo.
	iv2 := ClassVar1 = 'ffffffd'
]

{ #category : #examples }
SoExamples >> exampleSuper [
	super yourself.
	^ super
]

{ #category : #examples }
SoExamples >> exampleSuper2 [
	^ (super = self) == (self = super)
]

{ #category : #'examples - blocks' }
SoExamples >> exampleTempVectorNoBlock [	
	| index |
	index := 0.
	[ index < 5 ] whileTrue: [
		| temp |
		[ temp ].
		temp := index := index + 1].
	^index

]

{ #category : #examples }
SoExamples >> exampleThisContext [
	
	^ thisContext
]

{ #category : #'examples - jumps' }
SoExamples >> exampleToDo [
	
	1 to: 3 do: [ :i |
		self kick: i ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleToDo2 [
	
	1 to: 10 do: [ :i |
		| t |
		t := 0.
		true ifTrue: [ t := 1 ] ifFalse: [ t := 2 ] ]
]

{ #category : #'examples - ranges' }
SoExamples >> exampleToDo3 [
	
	20 to: 100 by: 1073741823 "SmallInteger maxVal" do: [ :i |
		self kick: i ]
]

{ #category : #'examples - ranges' }
SoExamples >> exampleToDo4 [
	
	| x |
	x := #(true false) atRandom ifTrue: [ 1 ] ifFalse: [ 3 ].
	[ x < 10 ] whileTrue: [ 
		#( 1 2 3 4 5 6 7 8 9 10 11 12) at: x. 
		x := x + 5. ]
	
]

{ #category : #'examples - ranges' }
SoExamples >> exampleToDoArray [
	
	| array |
	array := #( 1 2 3 4 5 ).
	0 to: array size - 1 do: [ :i |
		(array at: i + 1) yourself ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleToDoValue [
	
	^ 1 to: 2 do: [:each | each]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleToDoValueLimitExpression [

	^ 2 to: 3 + 4 do: [ :each | each ]
	
]

{ #category : #examples }
SoExamples >> exampleTrapMessage [
	^ self yourself baz
]

{ #category : #'example - loop opt' }
SoExamples >> exampleUnrollUsedAfter [
	| array comp val iterator |
	array := { 1 . 2 . 3 . 4 . 5 } .
	val := 50000.
	iterator := 1.
	[ comp := (iterator <= 5) ] whileTrue: [ 
		val := val + (array at: iterator).
		iterator := iterator + 1 ].
	^ { val . iterator . comp }
]

{ #category : #'examples - jumps' }
SoExamples >> exampleWhileTrue [
	| t |
	t := 1.
	[ t < 10 ] whileTrue: [ t := t + 1. self kick: t ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleWhileTrue2 [
	[ iv1 isNil ] whileTrue: [ self foo. iv2 := 1. self bar. ]
]

{ #category : #'examples - jumps' }
SoExamples >> exampleWhileTrue3 [
	| t1 |
	[ t1 isNil ] whileTrue: [ t1 := 1. [ t1 ] ].
]

{ #category : #'examples - jumps' }
SoExamples >> exampleWhileTrue4 [
	| iterator |
	iterator := 1.
	[5 > iterator ] whileFalse: [ 
		(#(1 2 3 4 5 6) at: iterator) value. 
		iterator := iterator + 1 ].
	^ iterator
]

{ #category : #'examples - jumps' }
SoExamples >> exampleWhileTrue5 [
	| iterator |
	iterator := 1.
	
	[(#(true false) atRandom ifTrue: [  5 ] ifFalse: [ 6 ]) > iterator ] whileFalse: [ 
		(#(1 2 3 4 5 6) at: iterator) value.
		iterator := iterator + 1 ].
	^ 5
]

{ #category : #'tests running facilities' }
SoExamples >> foo [
	| t p |
	p := 0.
	t := 0.
	iv1 := "iv1 printString"''.
	[ t < 5 ] whileTrue: [ 
		iv1 := iv1 , t printString. 
		t := t + 1 + p ].
	^ #foo
	
]

{ #category : #'tests running facilities' }
SoExamples >> foo: a bar: a2 [
	| temp |
	temp := $z.
	iv1 := temp.
	1 to: 10 do: [ :i | self kick: i ].
	^ $d
]

{ #category : #'tests running facilities' }
SoExamples >> getArray [
	^ #(1 2 3 4 5)
]

{ #category : #examples }
SoExamples >> getIndex [ 
	^ (iv1 ifNil: [ iv1 := Array braceWith: 0 with: 0 with: 0 with: 0 ]) at: ClassVar1
]

{ #category : #accessing }
SoExamples >> getMaybeEmptyCollection [
	^ Array new: (3 atRandom - 1)
]

{ #category : #accessing }
SoExamples >> getNastyCollection [
	| col |
	col := OrderedCollection new.
	1 to: 100 atRandom do: [ :i |
		i \\ 7 = 0 ifTrue: [ col add: {  i . i asString } ].
		i \\ 9 = 0 ifTrue: [ col add: {  i asFloat . i asString } ].
		i \\ 11 = 0 ifTrue: [ col add: { i . i } ].
		i \\ 7 = 0 ifTrue: [ col add: { i asFloat . i } ].
		i \\ 9 = 0 ifTrue: [ col add: { i . i asFloat } ].
		i \\ 11 = 0 ifTrue: [ col add: { i asFloat . i asFloat } ] ].
	^ col
]

{ #category : #initialize }
SoExamples >> initialize [

	super initialize.

	dispatch := SoExamplesDispatch new.
]

{ #category : #accessing }
SoExamples >> iv1: anObject [
	^ iv1 := anObject
]

{ #category : #accessing }
SoExamples >> iv2 [
	^ iv2
]

{ #category : #accessing }
SoExamples >> iv2: anObject [
	^ iv2 := anObject
]

{ #category : #'tests running facilities' }
SoExamples >> kick: i [
	| t1 t2 |
	t1 := 7.
	t2 := 10.
	iv2 := t1 + t2.
	iv2 = t2
		ifTrue: [ iv1 := iv1 printString , 'P' ] 
		ifFalse: [ iv1 := iv1 -> nil ].
	^ i yourself
]

{ #category : #'tests running facilities' }
SoExamples >> nlr1 [
	iv1 := true.
	self eval: [ iv1 ifTrue: [ ^ nil ] ].
	
]

{ #category : #'tests running facilities' }
SoExamples >> nlr2 [
	iv1 := true.
	self nonInlinedEval: [ iv1 ifTrue: [ ^ nil ] ].
	
]

{ #category : #'tests running facilities' }
SoExamples >> nonInlinedBool [
	^ false
]

{ #category : #'tests running facilities' }
SoExamples >> nonInlinedEval: aBlock [
	^ aBlock value
]

{ #category : #'tests running facilities' }
SoExamples >> runAndReturnBlock: aBlock [
	aBlock value.
	^ [ 1 + 2 ]
]

{ #category : #'examples - sendAndBranchData' }
SoExamples >> specialData [
	"Run this script to know expected sendAndBranchDatas values from the VM:
	
	| a |
	a := LiliExamples new.
	10000 timesRepeat: [a specialData].
	(LiliExamples>>#specialData) primitiveSendAndBranchData
	
	Current result:
	{{59. Array. Object>>#at:}. {63. Array. Object>>#at:}. {68. Array. Object>>#at:put:}. {73. Array. Object>>#at:put:}. {76. Array. ArrayedCollection>>#size}. {79. ByteString. ArrayedCollection>>#size}. {87. BlockClosure. BlockClosure>>#value}. {96. BlockClosure. BlockClosure>>#value:}. #(99 9999 9999). {102. Object class. ProtoObject>>#'=='}. {106. SmallInteger. Number>>#@}. {109. Point. Point>>#x}. {111. Point. Point>>#y}. {112. SmallInteger. SmallInteger>>#+}}
	"

	| array point |
	array := {#value}.
	array at: 1.
	array at: 1.
	array at: 1 put: 5.
	array at: 1 put: 6.
	array size.
	'abcde' size.
	[ 42 ] value.
	[ :a | a ] value: 12.
	true ifTrue: [ Object == Object ].
	point := 33@66.
	^ point x + point y

]

{ #category : #'tests running facilities' }
SoExamples >> string [
	^ 'string'
]

{ #category : #'tests running facilities' }
SoExamples >> string2 [
	^ 'string'
]
