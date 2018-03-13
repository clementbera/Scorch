"
I model a primitive. Most primitives are just a number. Named primitives (117) are encoded in a literal.

I am used to correctly optimize primitive methods (the fallback code is optimized, and the optimized code is still marked as a primitive).

"
Class {
	#name : #SoPrimitive,
	#superclass : #Object,
	#instVars : [
		'num',
		'literal'
	],
	#category : #'Scorching-Decompiler'
}

{ #category : #'instance creation' }
SoPrimitive class >> newForMethod: method [
	^ self new
		num: method primitive;
		literal: (method primitive = 117 ifTrue: [ method literals first ]);
		yourself
]

{ #category : #accessing }
SoPrimitive >> literal [
	<generated>
	^ literal
]

{ #category : #accessing }
SoPrimitive >> literal: aValue [
	<generated>
	literal := aValue
]

{ #category : #accessing }
SoPrimitive >> num [
	<generated>
	^ num
]

{ #category : #accessing }
SoPrimitive >> num: aValue [
	<generated>
	num := aValue
]
