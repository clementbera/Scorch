"
I cache statically generated send and branch data to speed up tests.

Instance Variables
	examplesData:		<Ditionary> precomputed send and branch data for the ScExamples methods overused in tests
	genericData:		<ScBasicIdentityHashMap> cache for send and brach data of any method

"
Class {
	#name : #SoSendAndBranchDataCache,
	#superclass : #Object,
	#classInstVars : [
		'examplesData',
		'genericData'
	],
	#category : #'ScorchingTests-StaticTypes'
}

{ #category : #private }
SoSendAndBranchDataCache class >> exampleData: method [
	examplesData ifNil: [ self generateExamplesData ].
	^ examplesData at: method ifAbsent: [ #() ]
]

{ #category : #public }
SoSendAndBranchDataCache class >> flushCache [ 
	"
	self flushCache
	"
	examplesData := nil.
	genericData flushCache.
]

{ #category : #private }
SoSendAndBranchDataCache class >> generateCodeData: method [ 
	examplesData at: method put: (SoSendDataCustomGenerator new generateMock: method).
	method literals allButLastDo: [ :each |
		(each class == CompiledBlock) ifTrue: 
			[ self generateCodeData: each ] ]
]

{ #category : #private }
SoSendAndBranchDataCache class >> generateExamplesData [
	"self generateExamplesData"
	
	| examples  |
	examples := SoExamples methodDict values , SoExamplesDispatch methodDict values.
	examplesData := Dictionary new.
	examples do: [ :method | 
		self generateCodeData: method ]
]

{ #category : #private }
SoSendAndBranchDataCache class >> genericData: method [
	^ genericData 
		cacheAt: method
		valueToCompute: [ 
			SoSendDataAutomaticGenerator new generateMock: method ]
]

{ #category : #initialize }
SoSendAndBranchDataCache class >> initialize [

	genericData := SoIdentityHashMap new: 2048 accuracy: 2.
]

{ #category : #public }
SoSendAndBranchDataCache class >> staticSendAndBranchData: method [

	(method methodClass == SoExamples or: [ 
		method methodClass == SoExamplesDispatch ])
			ifTrue: [ ^ self exampleData: method ].

	method = (Integer>>#benchFib) ifTrue: [^ {{23 . SmallInteger . (SmallInteger>>#< )} . #(24 46179 23094) . {31 . SmallInteger . (Integer>>#benchFib )} . {35 . SmallInteger . (Integer>>#benchFib )} . {36 . SmallInteger . (SmallInteger>>#+)}} ].

	method = (Integer>>#benchmark) ifTrue: [ ^  {#(44 1 0) . {50 . Array class . (Array class>>#new: "a CompiledMethod(3447222)")} . {52 . Array . (SequenceableCollection>>#atAllPut: "a CompiledMethod(3254444)")} . #(59 8179 8178) . {63 . Array . (Object>>#at: "a CompiledMethod(3702394)")} . #(64 8178 1022) . {72 . SmallInteger . (SmallInteger>>#+ "a CompiledMethod(2013942)")} . {76 . SmallInteger . (SmallInteger>>#<= "a CompiledMethod(944586)")} . #(77 9070 8047) . {82 . Array . (Object>>#at:put: "a CompiledMethod(1765086)")} . {86 . SmallInteger . (SmallInteger>>#+ "a CompiledMethod(2013942)")}} ].
	^ "self genericData: method" #() 
]
