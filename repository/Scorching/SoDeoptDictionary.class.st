"
Minimal copy of the Dictionary class, to avoid recursive deoptimization (see superclass comment).

I implement only code that is used directly by the deoptimiser and I should most likely be only used by the deoptimiser.

The implementation is linear and not hashed (similar to SmallDictionary). It's more efficient for small number of values, and as I am used only in the deoptimiser I know that in most case there are a small number of values.

Warning: I use in many places == instead of = because = is potentially dangerous (Could be optimised).
"
Class {
	#name : #SoDeoptDictionary,
	#superclass : #SoAbsDeopt,
	#instVars : [
		'array'
	],
	#category : #'Scorching-Deoptimization'
}

{ #category : #accessing }
SoDeoptDictionary >> array [
	<generated>
	^ array
]

{ #category : #accessing }
SoDeoptDictionary >> array: aValue [
	<generated>
	array := aValue
]

{ #category : #accessing }
SoDeoptDictionary >> at: k [
	array pairsDo: [ :key :value | key == k ifTrue: [ ^ value ] ].
	self error: 'should not happen'
]

{ #category : #accessing }
SoDeoptDictionary >> at: k ifAbsent: aBlock [
	array pairsDo: [ :key :value | key == k ifTrue: [ ^ value ] ].
	^ aBlock value
]

{ #category : #accessing }
SoDeoptDictionary >> at: k put: val [
	| newArray |
	1 to: array size - 1 by: 2 do: [ :i | 
		((array at: i) == k or: [ (array at: i) == nil ]) 
			ifTrue: [ 
				array at: i put: k.
				^ array at: i + 1 put: val ] ].
	"full. grow array."
	newArray := SoDeoptArray basicNew: array size * 2.
	newArray replaceFrom: 1 to: array size with: array startingAt: 1.
	newArray at: array size + 1 put: k.
	newArray at: array size + 2 put: val.
	array := newArray.
]

{ #category : #initialization }
SoDeoptDictionary >> initialize [

	super initialize.

	array := SoDeoptArray new: 10.
]

{ #category : #enumerating }
SoDeoptDictionary >> keysAndValuesDo: aBlock [
	array pairsDo: [ :key :value | aBlock value: key value: value ]
]

{ #category : #accessing }
SoDeoptDictionary >> removeKey: k [
	1 to: array size - 1 by: 2 do: [ :i | 
		(array at: i) == k 
			ifTrue: [ 
				array at: i put: nil.
				^ array at: i + 1 put: nil ] ].
	self error: 'should not happen'.
]
