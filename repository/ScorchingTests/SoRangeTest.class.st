"
Unit tests on SoRange instances
"
Class {
	#name : #SoRangeTest,
	#superclass : #TestCase,
	#instVars : [
		'maxArraySize',
		'array'
	],
	#category : #'ScorchingTests-UnitTests'
}

{ #category : #'range-array' }
SoRangeTest >> koArrayRange [
	^ SoRange new
		minConstant: 0;
		maxConstant: 0;
		maxArraySize: maxArraySize;
		yourself
]

{ #category : #'range-array' }
SoRangeTest >> koArrayRange2 [
	^ SoRange new
		minConstant: 1;
		maxConstant: 1;
		maxArraySize: maxArraySize;
		yourself
]

{ #category : #'range-array' }
SoRangeTest >> okArrayRange [
	^ SoRange new
		minConstant: 1;
		maxConstant: 0;
		maxArraySize: maxArraySize;
		yourself
]

{ #category : #'range-array' }
SoRangeTest >> okArrayRange2 [
	^ SoRange new
		minConstant: 2;
		maxConstant: -1;
		maxArraySize: maxArraySize;
		yourself
]

{ #category : #'range-array' }
SoRangeTest >> otherArrayRange [
	^ SoRange new
		minConstant: 0;
		maxConstant: 0;
		maxArraySize: (SoPointerSizeOp withReceiver: (SoArg new index: 1; yourself));
		yourself
]

{ #category : #'range-overflow' }
SoRangeTest >> overflowingArrayRange [
	^ SoRange new
		minConstant: 2;
		maxConstant: SmallInteger maxVal - 50;
		maxArraySize: maxArraySize;
		yourself
]

{ #category : #'range-overflow' }
SoRangeTest >> overflowingRange [
	^SoRange new
		minConstant: SmallInteger minVal - 1;
		maxConstant: 1;
		yourself
]

{ #category : #'range-overflow' }
SoRangeTest >> overflowingRange2 [
	^SoRange new
		minConstant: 5;
		maxConstant: SmallInteger maxVal + 1;
		yourself
]

{ #category : #range }
SoRangeTest >> range0to1 [
	^SoRange new
		minConstant: 0;
		maxConstant: 1;
		yourself
]

{ #category : #range }
SoRangeTest >> range0toMax [
	^SoRange new
		minConstant: 0;
		maxConstant: SmallInteger maxVal;
		yourself
]

{ #category : #range }
SoRangeTest >> rangeMinto0 [
	^SoRange new
		minConstant: SmallInteger minVal;
		maxConstant: 0;
		yourself
]

{ #category : #'set up' }
SoRangeTest >> setUp [
	array := SoReceiver new
				type: SoUnknownType default;
				yourself.
	maxArraySize := SoPointerSizeOp new 
			receiver: array;
			yourself
]

{ #category : #tests }
SoRangeTest >> testAcceptArray [
	self assert: (self okArrayRange acceptArray: array).
	self assert: (self okArrayRange2 acceptArray: array).
	self deny: (self koArrayRange acceptArray: array).
	self deny: (self koArrayRange2 acceptArray: array).
]

{ #category : #tests }
SoRangeTest >> testIntersection [
	| inter |
	inter := self range0to1 intersection: self range0toMax.
	self assert: inter minConstant equals: 0.
	self assert: inter maxConstant equals: 1.
	inter := self range0to1 intersection: self rangeMinto0.
	self assert: inter minConstant equals: 0.
	self assert: inter maxConstant equals: 0.
	inter := self okArrayRange intersection: self range0to1.
	self assert: inter minConstant equals: 1.
	self assert: inter maxConstant equals: 0.
	inter := self okArrayRange intersection: self koArrayRange.
	self assert: inter minConstant equals: 1.
	self assert: inter maxConstant equals: 0.
	inter := self okArrayRange intersection: self otherArrayRange.
	self assert: inter minConstant equals: 1.
	self assert: inter maxConstant equals: 0.
	
	
]

{ #category : #tests }
SoRangeTest >> testOverflow [
	| flag |
	flag := false.
	self overflowingArrayRange onOverflow: [flag := true].
	self assert: flag.
	flag := false.
	self okArrayRange onOverflow: [flag := true].
	self deny: flag.
	flag := false.
	self koArrayRange onOverflow: [flag := true].
	self deny: flag.
	flag := false.
	self overflowingRange onOverflow: [flag := true].
	self assert: flag.
	flag := false.
	self overflowingRange2 onOverflow: [flag := true].
	self assert: flag.
]

{ #category : #tests }
SoRangeTest >> testUnion [
	| inter |
	inter := self range0to1 union: self range0toMax.
	self assert: inter minConstant equals: 0.
	self assert: inter maxConstant equals: SmallInteger maxVal.
	inter := self range0to1 union: self rangeMinto0.
	self assert: inter minConstant equals: SmallInteger minVal.
	self assert: inter maxConstant equals: 1.
	inter := self okArrayRange union: self range0to1.
	self assert: inter minConstant equals: 0.
	self assert: inter maxConstant equals: 1.
	inter := self okArrayRange union: self koArrayRange.
	self assert: inter minConstant equals: 0.
	self assert: inter maxConstant equals: 0.
	inter := self okArrayRange union: self otherArrayRange.
	self assert: inter minConstant equals: SmallInteger minVal.
	self assert: inter maxConstant equals: SmallInteger maxVal.
	
	
]
