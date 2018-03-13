"
I validate two path compilation, a technique to speed-up setter-like methods.
"
Class {
	#name : #TwoPathCogitTests,
	#superclass : #TestCase,
	#instVars : [
		'guineaPig'
	],
	#category : #ScorchingVMTests
}

{ #category : #'guinea pigs' }
TwoPathCogitTests >> assertGuineaPigIVsAre: array [
	| firstIndex |
	firstIndex := (self guineaPigClass allInstVarNames indexOf: #iv1) - 1.
	array withIndexDo: [ :expectedIVValue :index | 
		self assert: (guineaPig instVarAt: index + firstIndex) equals: expectedIVValue ]
]

{ #category : #'guinea pigs' }
TwoPathCogitTests >> guineaPigClass [
	^ TwoPathGuineaPig
]

{ #category : #tests }
TwoPathCogitTests >> testOnePath [
	self useNewGuineaPig.
	guineaPig onePathRegAr: 1 g: 2.
	self assertGuineaPigIVsAre: #(1 2).
	
	self useNewGuineaPig.
	guineaPig onePathReg2Ar: 1 g: 2.
	self assertGuineaPigIVsAre: #(1 2).
	
	
]

{ #category : #tests }
TwoPathCogitTests >> testOnePathRegArgMultiAssign [
	self useNewGuineaPig.
	guineaPig onePathRegArgMultiAssign: 1.
	self assertGuineaPigIVsAre: #(1 1 1).
	
	
]

{ #category : #tests }
TwoPathCogitTests >> testTwoPathOldRegArg [
	self useNewOldGuineaPig.
	guineaPig twoPathRegAr: 1 g: 2.
	self assertGuineaPigIVsAre: #(1 2).
	
	self useNewOldGuineaPig.
	guineaPig twoPathRegArg: 1.
	self assertGuineaPigIVsAre: #(1 2).
	
	
]

{ #category : #tests }
TwoPathCogitTests >> testTwoPathOldRegArgMultiAssign [
	self useNewOldGuineaPig.
	guineaPig twoPathRegArgMultiAssign: 1.
	self assertGuineaPigIVsAre: #(1 1 1).
	
	
]

{ #category : #tests }
TwoPathCogitTests >> testTwoPathOldStackArg [
	self useNewOldGuineaPig.
	guineaPig twoPathStackA: 1 r: 2 g: 3.
	self assertGuineaPigIVsAre: #(1 2 3).
	
	self useNewOldGuineaPig.
	guineaPig twoPathStack2A: 1 r: 2 g: 3.
	self assertGuineaPigIVsAre: #(1 2 3).
	
	
	
]

{ #category : #tests }
TwoPathCogitTests >> testTwoPathYoungRegArg [
	self useNewYoungGuineaPig.
	guineaPig twoPathRegAr: 1 g: 2.
	self assertGuineaPigIVsAre: #(1 2).
	
	self useNewYoungGuineaPig.
	guineaPig twoPathRegArg: 1.
	self assertGuineaPigIVsAre: #(1 2).
	
	
]

{ #category : #tests }
TwoPathCogitTests >> testTwoPathYoungRegArgMultiAssign [
	self useNewYoungGuineaPig.
	guineaPig twoPathRegArgMultiAssign: 1.
	self assertGuineaPigIVsAre: #(1 1 1).
	
]

{ #category : #tests }
TwoPathCogitTests >> testTwoPathYoungStackArg [
	self useNewYoungGuineaPig.
	guineaPig twoPathStackA: 1 r: 2 g: 3.
	self assertGuineaPigIVsAre: #(1 2 3).
	
	self useNewYoungGuineaPig.
	guineaPig twoPathStack2A: 1 r: 2 g: 3.
	self assertGuineaPigIVsAre: #(1 2 3).
	
	
]

{ #category : #'guinea pigs' }
TwoPathCogitTests >> useNewGuineaPig [
	guineaPig := self guineaPigClass new
]

{ #category : #'guinea pigs' }
TwoPathCogitTests >> useNewOldGuineaPig [
	self useNewGuineaPig.
	"Pinning forces the object to be old"
	guineaPig pin; unpin.

]

{ #category : #'guinea pigs' }
TwoPathCogitTests >> useNewYoungGuineaPig [
	"Hopefully the guinea pig will be young"
	Smalltalk garbageCollectMost.
	self useNewGuineaPig.
]
