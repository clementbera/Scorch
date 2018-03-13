"
I represent an integer range in which the result of an instruction is included. I am used for the ABCD algorithm. 

The range is represented as follow: 
[ minConstant ; maxArraySize + maxConstant ] 

minConstant <Smi>
maxConstant <Smi>
maxArraySize <SizeOp> If the range is up to the siza of a variable-object, we remember it to uncheck easily variable-object access

"
Class {
	#name : #SoRange,
	#superclass : #Object,
	#instVars : [
		'minConstant',
		'maxConstant',
		'maxArraySize'
	],
	#category : #'Scorching-Type'
}

{ #category : #'instance creation' }
SoRange class >> fullRange [
	^ SoRange new
		minConstant: SmallInteger minVal;
		maxConstant: SmallInteger maxVal;
		yourself
]

{ #category : #testing }
SoRange >> acceptArray: array [
	minConstant >= 1 ifFalse: [ ^ false ].
	maxArraySize ifNotNil: 
		[ maxArraySize receiver ~= array ifTrue: [ ^ false ].
		  ^ maxConstant <= 0 ].
	array hasSizeInformation ifFalse: [ ^ false ].
	^ maxConstant <= array sizeInformation
	 
]

{ #category : #accessing }
SoRange >> actualMaxVal [
	^ maxConstant + (maxArraySize ifNil: [ 0 ] ifNotNil: [ maxArraySize maxSmi ])
]

{ #category : #operation }
SoRange >> addRange: range onOverflow: aBlock [
	(maxArraySize notNil and: [ range maxArraySize notNil ]) ifTrue: [ 
		^ SoRange new
			minConstant: minConstant + range minConstant;
			maxConstant: maxConstant + range maxConstant + maxArraySize maxSmi + range maxArraySize maxSmi;
			onOverflow: aBlock;
			yourself ].
	"This second case is for loop with iterator + cst"
	^ SoRange new
		minConstant: minConstant + range minConstant;
		maxConstant: maxConstant + range maxConstant;
		maxArraySize: (maxArraySize ifNil: [ range maxArraySize ]);
		onOverflow: aBlock;
		yourself
]

{ #category : #testing }
SoRange >> alwaysEqualThan: range [
	range maxArraySize ifNotNil: [ ^ false ].
	maxArraySize ifNotNil: [ ^ false ].
	^ minConstant = maxConstant = range minConstant = range maxConstant
]

{ #category : #testing }
SoRange >> alwaysGreaterOrEqualThan: range [
	^ range alwaysLessOrEqualThan: self
]

{ #category : #testing }
SoRange >> alwaysGreaterThan: range [
	^ range alwaysLessThan: self
]

{ #category : #testing }
SoRange >> alwaysLessOrEqualThan: range [
	^ self actualMaxVal  <= range minConstant
]

{ #category : #testing }
SoRange >> alwaysLessThan: range [
	^ self actualMaxVal < range minConstant
]

{ #category : #testing }
SoRange >> alwaysNotEqualThan: range [
	self flag: #TODO.
	"We could do something with maxSmi here..."
	range maxArraySize ifNotNil: [ ^ false ].
	maxArraySize ifNotNil: [ ^ false ].
	^ minConstant > range maxConstant or: [ maxConstant < range minConstant ]
]

{ #category : #operation }
SoRange >> intersection: range [
	(range maxArraySize == maxArraySize or: [ 
		range maxArraySize isNil or: [ maxArraySize isNil ] ]) ifTrue: [ ^SoRange new
		minConstant: (range minConstant max: minConstant);
		maxConstant: (range maxConstant min: maxConstant);
		maxArraySize: (range maxArraySize ifNil: [ maxArraySize ]);
		yourself].
	"different size unfortunately. can't solve"
	^ self
]

{ #category : #testing }
SoRange >> isNegative [
	^ maxConstant <= 0 and: [ maxArraySize isNil ]
]

{ #category : #testing }
SoRange >> isPositive [
	^ minConstant >= 0 
]

{ #category : #testing }
SoRange >> isPositiveOrNegative [
	^ self isPositive or: [ self isNegative ]
]

{ #category : #accessing }
SoRange >> maxArraySize [
	<generated>
	^ maxArraySize
]

{ #category : #accessing }
SoRange >> maxArraySize: aValue [
	<generated>
	maxArraySize := aValue
]

{ #category : #accessing }
SoRange >> maxConstant [
	<generated>
	^ maxConstant
]

{ #category : #accessing }
SoRange >> maxConstant: aValue [
	<generated>
	maxConstant := aValue
]

{ #category : #accessing }
SoRange >> minConstant [
	<generated>
	^ minConstant
]

{ #category : #accessing }
SoRange >> minConstant: aValue [
	<generated>
	minConstant := aValue
]

{ #category : #testing }
SoRange >> onOverflow: aBlock [
	self actualMaxVal class == SmallInteger ifFalse: [ aBlock value ].
	minConstant class == SmallInteger ifFalse: [ aBlock value ]
]

{ #category : #testing }
SoRange >> shiftLeft: range [
	"arg is range of argument, receiver is value to shift, range is positive."
	^ SoRange new
		minConstant: minConstant;
		maxConstant: self actualMaxVal << range actualMaxVal;
		onOverflow: [ ^ SoRange fullRange ];
		yourself
]

{ #category : #testing }
SoRange >> shiftLeftOverflow: range [
	"arg is range of argument, receiver is value to shift, range is positive."

	^ (self actualMaxVal << range actualMaxVal) class ~~ SmallInteger
]

{ #category : #testing }
SoRange >> shiftRight: range [
	"arg is range of argument, receiver is value to shift, range is positive."
	^ SoRange new
		minConstant: minConstant;
		maxConstant: self actualMaxVal >> range actualMaxVal;
		yourself
]

{ #category : #operation }
SoRange >> subRange: range onOverflow: aBlock [
	range maxArraySize ifNotNil: [ 
		^ SoRange new
			minConstant: minConstant - range maxConstant - range maxArraySize maxSmi;
			maxConstant: self actualMaxVal - range minConstant;
			onOverflow: aBlock;
			yourself ].
	"This second case is for loops with iterator - constant"
	^ SoRange new
		minConstant: minConstant - range maxConstant;
		maxConstant: maxConstant - range minConstant;
		maxArraySize: maxArraySize;
		onOverflow: aBlock;
		yourself
]

{ #category : #operation }
SoRange >> union: range [
	(range maxArraySize == maxArraySize or: [ 
		range maxArraySize isNil or: [ maxArraySize isNil ] ]) ifTrue: [ ^SoRange new
		minConstant: (range minConstant min: minConstant);
		maxConstant: (range maxConstant max: maxConstant);
		maxArraySize: (range maxArraySize ifNil: [ maxArraySize ]);
		yourself].
	"different size unfortunately. can't solve"
	^ SoRange fullRange
]
