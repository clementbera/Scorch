"
loads a literal from the method to the method. The literal is stored in value.

Constants are considered as Immutable for the sista optimiser. Mutable literals are optimised through the MutableLiteral node.

On the contrary to regular method literals, literals of sista method are 'identityLiterals'. This means that in regular method, if two literals are equals, then they are merged into one literal. However, in a sista method, two literals are merged only if they are identityEquals. Else you end up with bugs such as 's' == 's' answering different result before or after inlining.


"
Class {
	#name : #SoConstant,
	#superclass : #SoAbsImmediate,
	#instVars : [
		'constant'
	],
	#pools : [
		'SoPrimitiveConstants'
	],
	#category : #'Scorching-Nodes'
}

{ #category : #'instance creation' }
SoConstant class >> constant: cst [
	^ self new
		constant: cst;
		yourself
]

{ #category : #comparing }
SoConstant >> = another [
	another class == self class ifFalse: [ ^ false ].
	^ another constant == constant
]

{ #category : #converting }
SoConstant >> asDeopt [
	^ SoDeoptConstant new
		constant: constant;
		yourself
]

{ #category : #types }
SoConstant >> basicTypeInformation [
	^ SoKnownType for: constant class
]

{ #category : #accessing }
SoConstant >> constant [
	<generated>
	^ constant
]

{ #category : #accessing }
SoConstant >> constant: aValue [
	<generated>
	constant := aValue
]

{ #category : #converting }
SoConstant >> fixPCConstantIn: sunkObj for: node at: position [
	"Already fixed up."
]

{ #category : #traversing }
SoConstant >> hasRangeInformation [
	^ constant class == SmallInteger
]

{ #category : #testing }
SoConstant >> hasSizeInformation [
	| instSpec |
	instSpec := constant class instSpec.
	instSpec = 2 ifTrue: [ ^ true ].
	^ instSpec between: 16 and: 23
]

{ #category : #comparing }
SoConstant >> hash [
	^ constant hash
]

{ #category : #testing }
SoConstant >> is0Constant [
	self isSmiConstant ifFalse: [ ^ false ].
	^ constant = 0
]

{ #category : #testing }
SoConstant >> isConstant [
	^ true
]

{ #category : #testing }
SoConstant >> isSmiConstant [
	^ constant class == SmallInteger
]

{ #category : #traversing }
SoConstant >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseConstant: self
]

{ #category : #types }
SoConstant >> rangeInformation [
	^ SoRange new
		minConstant: constant;
		maxConstant: constant;
		yourself
]

{ #category : #types }
SoConstant >> sizeInformation [
	^ constant tryPrimitive: Size withArgs: #()
]
