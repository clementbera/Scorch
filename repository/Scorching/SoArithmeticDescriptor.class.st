"
I include arithmetic descriptors for smi operations. This is used in value numbering and in inlining. 

Each descriptor includes different properties of each smi operation (primitive numbers, commutative, associative, identity and absorbing elements, ...). 

-- Half-internal composition laws --

Each operation described is a half-internal composition law for smis. The problem is that each operation has undefined behavior in case of overflows. 
If we take the magma (E,*), in standard algebra:
for each a,b in E, a*b is in E.
In our case the behavior is undefined if an overflow happens, hence we have:
for each a,b Smis, a*b is a Smi if there is no overflow, else it's undefined.

The main difference to standard Magmas can be seen for the associative property: we need to check for overflows.

In standard algebra, if we take the magna (E,*), * is associative if:
For each a,b,c in E, a*(b*c) <=> (a*b)*c

In our case, we have:
For a,b,c Smis, a*(b*c) <=> (a*b)*c only if a*b does not overflow.

"
Class {
	#name : #SoArithmeticDescriptor,
	#superclass : #Object,
	#instVars : [
		'safePrimitiveNumber',
		'primitiveNumber',
		'associative',
		'commutative',
		'leftIdentity',
		'rightIdentity',
		'leftAbsorbing',
		'rightAbsorbing',
		'rangeOperation'
	],
	#classVars : [
		'ArithmeticDescriptors'
	],
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #utils }
SoArithmeticDescriptor class >> arithmeticCacheFrom: arrayOfArrays [
	"remaps everything efficiently to an array"
	| max |
	ArithmeticDescriptors ifNotNil: [ ^ ArithmeticDescriptors ]. 
	max := 0.
	arrayOfArrays do: [ :each | 
		max := max max: each first ].
	ArithmeticDescriptors := Array new: max.
	arrayOfArrays do: [ :each |
		ArithmeticDescriptors 
			at: each first 
			put: (self new
				safePrimitiveNumber: each first;
				primitiveNumber: each second;
				associative: each third;
				commutative: each fourth;
				leftIdentity: each fifth;
				rightIdentity: each sixth;
				leftAbsorbing: each seventh;
				rightAbsorbing: each eighth;
				rangeOperation: each ninth;
				yourself) ].
	^ ArithmeticDescriptors
]

{ #category : #constant }
SoArithmeticDescriptor class >> arithmeticDescriptors [
	"primitive, inline primitive, associative, commutative, leftIdentity, rightIdentity, leftAbsorbing, rightAbsorbing, rangeOperation"
	^ self arithmeticCacheFrom: #("Smi"
		"+"
		(1 	2000 true true 		0 0 nil nil 	addRange:) 
		"-"
		(2 	2001 false false 	nil 0 nil nil 	subRange:) 			
		"*"
		(9 	2002 true true 		1 1 0 0 	mulRange:) 
		"/"
		(10 2003 false false 	nil 1 0 nil 	nil) 
		"\\"
		(11 2005 false false 	nil nil 0 nil 	nil) 
		"//"
		(12 2004 false false 	nil 1 0 nil 	nil) 
		"quo:"
		(13 2006 false false 	nil 1 0 nil 	nil) 
		"bitAnd:"
		(14 2016 true true 		-1 -1 0 0 	nil) 
		"bitOr:"
		(15 2017 true true 		0 0 -1 -1 	nil) 
		"bitXor:"	
		(16 2018 true true 		0 0 nil nil 	nil) 
		"bitShiftLeft: fake - not 18"
		(18 2019 true false 	nil 0 0 nil 	shiftLeftOverflow:) 
		"bitShiftRight:"
		(17 2020 true false 	nil 0 0 nil"ST wordSize" nil) 
	)
]

{ #category : #accessing }
SoArithmeticDescriptor >> associative [
	<generated>
	^ associative
]

{ #category : #accessing }
SoArithmeticDescriptor >> associative: aValue [
	<generated>
	associative := aValue
]

{ #category : #accessing }
SoArithmeticDescriptor >> commutative [
	<generated>
	^ commutative
]

{ #category : #accessing }
SoArithmeticDescriptor >> commutative: aValue [
	<generated>
	commutative := aValue
]

{ #category : #accessing }
SoArithmeticDescriptor >> leftAbsorbing [
	<generated>
	^ leftAbsorbing
]

{ #category : #accessing }
SoArithmeticDescriptor >> leftAbsorbing: aValue [
	<generated>
	leftAbsorbing := aValue
]

{ #category : #accessing }
SoArithmeticDescriptor >> leftIdentity [
	<generated>
	^ leftIdentity
]

{ #category : #accessing }
SoArithmeticDescriptor >> leftIdentity: aValue [
	<generated>
	leftIdentity := aValue
]

{ #category : #accessing }
SoArithmeticDescriptor >> primitiveNumber [
	<generated>
	^ primitiveNumber
]

{ #category : #accessing }
SoArithmeticDescriptor >> primitiveNumber: aValue [
	<generated>
	primitiveNumber := aValue
]

{ #category : #accessing }
SoArithmeticDescriptor >> rangeOperation [
	<generated>
	^ rangeOperation
]

{ #category : #accessing }
SoArithmeticDescriptor >> rangeOperation: aValue [
	<generated>
	rangeOperation := aValue
]

{ #category : #accessing }
SoArithmeticDescriptor >> rightAbsorbing [
	<generated>
	^ rightAbsorbing
]

{ #category : #accessing }
SoArithmeticDescriptor >> rightAbsorbing: aValue [
	<generated>
	rightAbsorbing := aValue
]

{ #category : #accessing }
SoArithmeticDescriptor >> rightIdentity [
	<generated>
	^ rightIdentity
]

{ #category : #accessing }
SoArithmeticDescriptor >> rightIdentity: aValue [
	<generated>
	rightIdentity := aValue
]

{ #category : #accessing }
SoArithmeticDescriptor >> safePrimitiveNumber [
	<generated>
	^ safePrimitiveNumber
]

{ #category : #accessing }
SoArithmeticDescriptor >> safePrimitiveNumber: aValue [
	<generated>
	safePrimitiveNumber := aValue
]
