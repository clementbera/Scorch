"
Tests the Type class and subclasses
"
Class {
	#name : #SoTypeTest,
	#superclass : #TestCase,
	#category : #'ScorchingTests-UnitTests'
}

{ #category : #types }
SoTypeTest >> booleanType [
	^ SoType boolean
]

{ #category : #types }
SoTypeTest >> smiType [
	^ SoType smi
]

{ #category : #tests }
SoTypeTest >> testHasOnetype [
	self assert: self trueType hasOneType.
	self assert: self smiType hasOneType.
	self deny: self booleanType hasOneType.
	self deny: self unknownType hasOneType.
]

{ #category : #tests }
SoTypeTest >> testIntersection [
	self assert: ((self trueType intersection: self booleanType) isOnlyType: True).
	self assert: ((self trueType intersection: self trueType) isOnlyType: True).
	self assert: ((self trueType intersection: self unknownType) isOnlyType: True).
	self assert: ((self unknownType intersection: self trueType) isOnlyType: True).
]

{ #category : #tests }
SoTypeTest >> testIsOnlyType [
	self assert: (self trueType isOnlyType: True).
	self assert: (self smiType isOnlyType: SmallInteger).
	self deny: (self booleanType isOnlyType: True).
	self deny: (self unknownType isOnlyType: Boolean).
]

{ #category : #tests }
SoTypeTest >> testIsOnlyTypes [
	self assert: (self trueType isOnlyTypes: {True}).
	self assert: (self trueType isOnlyTypes: {True.False}).
	self assert: (self smiType isOnlyTypes: {SmallInteger.Float}).
	self assert: (self booleanType isOnlyTypes: {True.False}).
	self assert: (self booleanType isOnlyTypes: {True.False.UndefinedObject}).
	self deny: (self booleanType isOnlyTypes: {True}).
	self deny: (self booleanType isOnlyTypes: {True.UndefinedObject}).
	self deny: (self unknownType isOnlyTypes: {Boolean}).
]

{ #category : #tests }
SoTypeTest >> testUnion [
	self assert: ((self trueType union: self booleanType) isOnlyTypes: {True.False}).
	self assert: ((self trueType union: self trueType) isOnlyType: True).
	self deny: (self trueType union: self unknownType) isKnownType.
	self deny: (self unknownType union: self trueType) isKnownType.
]

{ #category : #types }
SoTypeTest >> trueType [
	^ SoKnownType for: True 
	
]

{ #category : #types }
SoTypeTest >> unknownType [
	^ SoUnknownType default
]
