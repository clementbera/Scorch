"
generate a mock for a method. Creates monomorphic inline caches if the selector is in the known selector dict, else creates a megamorphic inline cache. 

Implemented for the Validator examples
"
Class {
	#name : #SoSendDataCustomGenerator,
	#superclass : #SoSendDataAbstractGenerator,
	#category : #'ScorchingTests-StaticTypes'
}

{ #category : #accessing }
SoSendDataCustomGenerator >> knownSelectorsDict [
	
	| example exampleDispatch |
	
	example := SoExamples.
	exampleDispatch := SoExamplesDispatch.

	^ Dictionary newFromPairs:
		{ 
		#value . FullBlockClosure>>#value .
		#value: . FullBlockClosure>>#value: .
		#value:value: . FullBlockClosure>>#value:value: .
		#valueWithArguments: . FullBlockClosure>>#valueWithArguments: .
		
		#bar . example>>#bar .
		#eval: . example>>#eval: .
		#evalMulti: . example>>#evalMulti: .
		#bar:foo:baz: . example>>#bar:foo:baz: .
		#baz . example>>#baz .
		#bool: . example>>#bool: .
		#foo . example>>#foo .
		#evalFar: . example>>#evalFar: .
		#blockWithDeadOuter . example>>#blockWithDeadOuter .
		#blockCannotReturn . example>>#blockCannotReturn .
		#runAndReturnBlock: . example>>#runAndReturnBlock: .
		#callContext . example>>#callContext .
		#foo:bar: . example>>#foo:bar: .
		#kick: . example>>#kick: .
		#string . example>>#string .
		#string2 . example>>#string2 .
		#contextCancel . example>>#contextCancel .
		#nlr1 . example>>#nlr1 .
		#nlr2 . example>>#nlr2 .
		
		#decimalDigitLength . SmallInteger >>#decimalDigitLength .
		
		#perform:with: . Object>>#perform:with: .
		
		#remoteDeadBlock . exampleDispatch>>#remoteDeadBlock .
		#remoteEval: . exampleDispatch>>#remoteEval: .
		#remoteMethod . exampleDispatch>>#remoteMethod .
		
		#at: . Array>>#atWrap: .
		#at:put: . Array>>#atWrap:put: .
		#size . Array>>#size 
		
		"Use instead if you want more deoptimization
		#at: . ByteArray>>#byteAt: .
		#at:put: . ByteArray>>#byteAt:put: .
		#size . ByteArray>>#byteSize"
		 }
]

{ #category : #instructions }
SoSendDataCustomGenerator >> send: selector super: supered numArgs: numberArguments [

	| method |
	(self arithmeticSelectors includes: selector) ifTrue: [ ^ self ].
	self checkFirst.
	method := self knownSelectorsDict at: selector ifAbsent: [ 
		^ self generateMegamorphic: selector ].
	self generateMonomorphic: method
]
