"
I implement multiple methods compiled to 1 or 2 paths in machine code, typically inst var store. These methods are used to validate two path compilation, a technique to speed-up setter-like methods.
"
Class {
	#name : #TwoPathGuineaPig,
	#superclass : #Object,
	#instVars : [
		'iv1',
		'iv2',
		'iv3'
	],
	#category : #ScorchingVMTests
}

{ #category : #'as yet unclassified' }
TwoPathGuineaPig >> iv1 [
	^ iv1
]

{ #category : #'as yet unclassified' }
TwoPathGuineaPig >> iv2 [
	^ iv2
]

{ #category : #'as yet unclassified' }
TwoPathGuineaPig >> iv3 [
	^ iv3
]

{ #category : #'as yet unclassified' }
TwoPathGuineaPig >> onePathReg2Ar: a g: b [
	iv1 := a.
	iv2 := b yourself.
	
]

{ #category : #'as yet unclassified' }
TwoPathGuineaPig >> onePathRegAr: a g: b [
	iv1 := a.
	self yourself.
	iv2 := b.
	
]

{ #category : #'as yet unclassified' }
TwoPathGuineaPig >> onePathRegArgMultiAssign: a [
	iv1 := iv2 := iv3 := a.
	
]

{ #category : #'as yet unclassified' }
TwoPathGuineaPig >> twoPathRegAr: a g: b [
	iv1 := a.
	iv2 := b.
	
]

{ #category : #'as yet unclassified' }
TwoPathGuineaPig >> twoPathRegArg: a [
	iv1 := a.
	iv2 := 2.
	
]

{ #category : #'as yet unclassified' }
TwoPathGuineaPig >> twoPathRegArgMultiAssign: a [
	iv1 := a.
	iv2 := a.
	iv3 := a.
	
]

{ #category : #'as yet unclassified' }
TwoPathGuineaPig >> twoPathStack2A: a r: b g: c [
	iv1 := a.
	iv3 := 1.
	iv2 := b.
	iv3 := c.
	
]

{ #category : #'as yet unclassified' }
TwoPathGuineaPig >> twoPathStackA: a r: b g: c [
	iv1 := a.
	iv2 := b.
	iv3 := c.
	
]
