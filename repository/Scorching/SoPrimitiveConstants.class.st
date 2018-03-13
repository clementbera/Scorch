"
I hold all the constants relatives to primitive.

FullBlockClosureEvaluation: 	All the block evaluation primitive number range, assuming they are contiguous (value, value: , ...) BUT valueWithArguments.
ComparisonRange:	 			range of the primitives for smi comparison assuming they're contiguous (< , > , ...) 
ArithmeticRange:				 range of arithmetic operation, now + and -.
"
Class {
	#name : #SoPrimitiveConstants,
	#superclass : #SharedPool,
	#classVars : [
		'Add',
		'ArithmeticRange',
		'At',
		'AtPut',
		'BitAnd',
		'BitOr',
		'BitRange',
		'BitShift',
		'BitXor',
		'ClassPrim',
		'ComparisonRange',
		'Equal',
		'FullBlockClosureEvaluation',
		'Greater',
		'GreaterOrEqual',
		'IdentityHash',
		'ImmediateAsInteger',
		'Less',
		'LessOrEqual',
		'Mul',
		'New',
		'NewColon',
		'NotEqual',
		'NumberPrimitiveRange',
		'Perform',
		'PointerEquals',
		'Size',
		'Sub'
	],
	#category : #'Scorching-Constants'
}

{ #category : #initialize }
SoPrimitiveConstants class >> initialize [
	"
	self initialize
	"
	FullBlockClosureEvaluation := 207.
	ComparisonRange := 3 to: 8. 
	ArithmeticRange := 1 to: 2.
	BitRange := 14 to: 16.
	NumberPrimitiveRange := 1 to: 19. "put back to smi primitive range because LargeIntegers and floats are mutable"
	
	Perform := 83.
	New := 70.
	NewColon := 71.
	
	ImmediateAsInteger := 171.

	PointerEquals := 110.
	ClassPrim := 111.
	IdentityHash := 75.
	
	At := 60.
	AtPut := 61.
	Size := 62.
	
	Add := 1.
	Sub := 2.
	Mul := 9.
	
	Less := 3.
	Greater := 4.
	LessOrEqual := 5.
	GreaterOrEqual := 6.
	Equal := 7.
	
	NotEqual := 8.
	BitAnd := 14.
	BitOr := 15.
	BitXor := 16.
	BitShift := 17.
]
