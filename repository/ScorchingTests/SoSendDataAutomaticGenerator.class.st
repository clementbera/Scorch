"
Infer statically the type of the receiver for a selector.

Imprecise but never wrong.


"
Class {
	#name : #SoSendDataAutomaticGenerator,
	#superclass : #SoSendDataAbstractGenerator,
	#category : #'ScorchingTests-StaticTypes'
}

{ #category : #'static analysis' }
SoSendDataAutomaticGenerator class >> analysis [
	"
	dict keys -> selectors
	dict values -> number of implementors
	
	====
	
	41805 selectors
	30718 implemented once 73.48%
	9198 implemented from 2 to 5 times 22.00% 
	1889 implemented more than 5 times 04.52% 
	
	Instead of:
	
	90% 9% 1%
	"
	
	| dict |
	dict := IdentityDictionary new. 
Smalltalk globals allBehaviors do: [ :b | 
	b methods do: [ :method |
	dict at: method selector ifAbsentPut: [ 0 ].
	dict at: method selector put: (dict at: method selector) + 1  ] ].
	dict inspect.
]

{ #category : #instructions }
SoSendDataAutomaticGenerator >> send: selector super: supered numArgs: numberArguments [
	| methods |
	(self arithmeticSelectors includes: selector) ifTrue: [ ^ self ].
	self checkFirst.
	(self blockEvaluationSelectors includes: selector) ifTrue: [ 
		"To force all the blockClosures to be inlined as much as possible to discover bugs."
		^ self generateMonomorphic: FullBlockClosure >> selector ].
	methods := (SystemNavigation default allImplementorsOf: selector) collect: [ :each | each compiledMethod ].
	methods size = 0 ifTrue: [ ^ self generateMegamorphic: selector ].
	methods size = 1 ifTrue: [ ^ self generateMonomorphic: methods anyOne ].
	methods size < 6 ifTrue: [ ^ self generatePolymorphic: methods ].
	^ self generateMegamorphic: selector
]
