"
Hold methods used by optimisation pass tests
"
Class {
	#name : #SoGuineaPig,
	#superclass : #Object,
	#instVars : [
		'iv1'
	],
	#classVars : [
		'Intrinsified'
	],
	#category : #'ScorchingTests-UnitTests'
}

{ #category : #initialization }
SoGuineaPig class >> initialize [

	Intrinsified := false.
]

{ #category : #initialization }
SoGuineaPig class >> intrinsifyIfNeeded [
	Intrinsified ifTrue: [ ^ self ].
	self methods do: [ :method |
		| intrinsicMethod |
		(method hasPragmaNamed: #intrinsic) ifTrue: [ 
			intrinsicMethod := SoIntrinsicCompiler new compile: method sourceCode.
			intrinsicMethod methodClass: self.
			self methodDict at: method selector put: intrinsicMethod ] ].
	Intrinsified := true.
	
]

{ #category : #deadFlow }
SoGuineaPig >> deadDiamond [
	<intrinsic>
	| t t2 |
	t := 5.
	t2 := 3.
	^ (1 smiLess: 2)
		ifTrue: [  t ]
		ifFalse: [  t ]
]

{ #category : #'dead branch elim' }
SoGuineaPig >> deadInstanceBranch [
	<intrinsic>
	1 instanceOf: SmallInteger ifTrue: [ ^ 42 ].
	^ 0
]

{ #category : #'dead branch elim' }
SoGuineaPig >> deadInstanceBranch2 [
	<intrinsic>
	true instanceOf: SmallInteger ifTrue: [ ^ 42 ].
	^ 0
]

{ #category : #deadFlow }
SoGuineaPig >> deadLoop [
	<intrinsic>
	| t |
	t := 1.
	1 to: 5 by: 1 noInterruptDo: [ :i |
		t := t smiAdd: i ].
	^ 111
]

{ #category : #deadFlow }
SoGuineaPig >> deadLoop1 [
	<intrinsic>
	| t |
	t := 1.
	1 to: 0 by: 2 noInterruptDo: [ :i |
		t := t smiAdd: i ].
	^ 111
]

{ #category : #'gold loop' }
SoGuineaPig >> deadLoop2 [
	<intrinsic>
	1 to: 0 by: 1 noInterruptDo: [ :i |
		(1 smiLess: 2) ifFalse: [ ^ 1 ].
		self pointerAt: 1 put: (i smiAdd: 50) ].
	^ 111
]

{ #category : #'dead branch elim' }
SoGuineaPig >> deadPipeBranch [
	<intrinsic>
	^ (0 smiLess: 0) ifTrue: [ 1 ] ifFalse: [ 0 ]
]

{ #category : #'dead branch elim' }
SoGuineaPig >> deadPipeBranch2 [
	<intrinsic>
	^ (0 smiLess: 1) ifTrue: [ 1 ] ifFalse: [ 0 ]
]

{ #category : #'dead branch elim' }
SoGuineaPig >> deadSTBoolBranch [
	^ true ifTrue: [ 1 ] ifFalse: [ 0 ]
]

{ #category : #'dead branch elim' }
SoGuineaPig >> deadSTBoolBranch2 [
	^ false ifTrue: [ 1 ] ifFalse: [ 0 ]
]

{ #category : #'dead branch elim' }
SoGuineaPig >> deadSTBoolBranchLoop [
	^ false 
		ifTrue: [ 
			1 to: 5 noInterruptDo: [ :i | self pointerAt: 1 put: i ] ] 
		ifFalse: [ 0 ]
]

{ #category : #'gold loop' }
SoGuineaPig >> fullUnroll1 [
	<intrinsic>
	1 to: 5 by: 2 noInterruptDo: [ :i |
		self pointerAt: 1 put: (i smiAdd: 50) ].
	^ 111
]

{ #category : #'gold loop' }
SoGuineaPig >> fullUnroll2 [
	<intrinsic>
	1 to: 10 by: 1 noInterruptDo: [ :i |
		self pointerAt: 1 put: (i smiAdd: 50) ].
	^ 111 
]

{ #category : #'gold loop' }
SoGuineaPig >> fullUnroll3 [
	<intrinsic>
	self pointerAt: 1 put: 0.
	1 to: 5 by: 1 noInterruptDo: [ :i |
		(0 smiLess: (self pointerAt: 1)) ifTrue: [ ^ i ] . 
		self pointerAt: 1 put: (i smiAdd: 50) ].
	^ 111
]

{ #category : #'gold loop' }
SoGuineaPig >> fullUnroll4 [
	<intrinsic>
	1 to: 1 by: 1 noInterruptDo: [ :i |
		self pointerAt: 1 put: (i smiAdd: 50) ].
	^ 111
]

{ #category : #'gold loop' }
SoGuineaPig >> fullUnroll5 [
	<intrinsic>
	| t |
	t := 50.
	1 to: 5 by: 1 noInterruptDo: [ :i |
		self pointerAt: 1 put: (i smiAdd: t).
		t := 111. ].
	^ t
]

{ #category : #deadFlow }
SoGuineaPig >> loopToDiamond: array [	
	<intrinsic>
	| t |
	t := -1.
	1 to: 5 by: 1 noInterruptDo: [ :i |
		t := array numSlots ].
	^ t
]

{ #category : #'gold loop' }
SoGuineaPig >> peel1 [
	<intrinsic>
	1 to: 500 by: 2 noInterruptDo: [ :i |
		self pointerAt: 1 put: (i smiAdd: 50) ].
	^ 111
]

{ #category : #'gold loop' }
SoGuineaPig >> peel2 [
	<intrinsic>
	1 to: 500 by: 1 noInterruptDo: [ :i |
		self pointerAt: 1 put: (i smiAdd: 50) ].
	^ 111
]

{ #category : #'gold loop' }
SoGuineaPig >> peel3 [
	<intrinsic>
	self pointerAt: 1 put: 0.
	1 to: 500 by: 1 noInterruptDo: [ :i |
		(0 smiLess: 0) ifTrue: [ ^ i ] .
		self pointerAt: 1 put: (i smiAdd: 50) ].
	^ 0
]

{ #category : #'gold loop' }
SoGuineaPig >> peel4 [
	<intrinsic>
	| t |
	t := 50.
	1 to: 500 by: 1 noInterruptDo: [ :i |
		self pointerAt: 1 put: (i smiAdd: t).
		t := 111. ].
	^ t
]

{ #category : #'prim inlining' }
SoGuineaPig >> primInIining [
	"try to write all cases of byteDescriptors..."
	^{ { 4 + 5 .
		self perform: #~~ with: self .
		self class .
		self perform: #== with: self } .
		{ 1 bitShift: 5 .
		  5 bitShift: -1 .
		 #[1] at: 1 put: 3 .
		1 >= 2 .
		#(1) at: 1 put: 2.
		#[2] at: 1 }.
		{ 1 = 1 .
		  5 - 1 .
		 #[1] size .
		1 bitAnd: 5 }.
		{ 42 hashMultiply .
		  7 bitXor: 5 .
		  7 ~= 7 .
		  10 // 5 .
		  20 \\ 5 .
		  10 quo: 6 .
		  10 * 4 } .
		{ #(1) size .
		  1 bitOr: 9 .
		  1 < 4 .
		  $c asInteger .
		 7 <= 9 } .
		{ #(1) at: 1 .
		 5 > 3  } .
		{ (ByteArray basicNew: 5) replaceFrom: 1 to: 2 with: #[2 3 4] startingAt: 2 .
		   (ByteArray basicNew: 5) atAllPut: 5 . 
		   (Array basicNew: 5) replaceFrom: 1 to: 2 with: #(2 3 4) startingAt: 2 }
	}
]

{ #category : #licm }
SoGuineaPig >> sizeLICM: array [	
	<intrinsic>
	1 to: 5 by: 1 noInterruptDo: [ :i |
		self pointerAt: 1 put: array numSlots ].
	^ 111
]

{ #category : #licm }
SoGuineaPig >> unforwardLICM: array [	
	<intrinsic>
	1 to: 5 by: 1 noInterruptDo: [ :i |
		self pointerAt: 1 put: array unforward ].
	^ 111
]
