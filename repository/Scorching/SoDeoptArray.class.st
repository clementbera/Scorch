"
Minimal copy of the Array class, to avoid recursive deoptimization (see superclass comment).

I implement only code that is used directly by the deoptimiser and I should most likely be only used by the deoptimiser.
"
Class {
	#name : #SoDeoptArray,
	#superclass : #SoAbsDeopt,
	#type : #variable,
	#category : #'Scorching-Deoptimization'
}

{ #category : #'instance creation' }
SoDeoptArray class >> from: collection [
	| inst |
	inst := self new: collection size.
	1 to: collection size do: [ :i |
		inst at: i put: (collection at: i) ].
	^ inst
]

{ #category : #accessing }
SoDeoptArray >> at: index [
	<primitive: 60>
	self error: 'should not fail for deoptArray'
]

{ #category : #accessing }
SoDeoptArray >> at: index put: value [
	<primitive: 61>
	self error: 'should not fail for deoptArray'
]

{ #category : #enumerating }
SoDeoptArray >> do: aBlock [
	1 to: self size do: [ :i | aBlock value: (self at: i) ]
]

{ #category : #accessing }
SoDeoptArray >> first [
	^ self at: 1
]

{ #category : #enumerating }
SoDeoptArray >> pairsDo: aBlock [
	1 to: self size by: 2 do: [:index | aBlock value: (self at: index) value: (self at: index + 1)]
]

{ #category : #enumerating }
SoDeoptArray >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 
	<primitive: 105>
	self error: 'should not fail here'
]

{ #category : #accessing }
SoDeoptArray >> size [
	<primitive: 62>
	self error: 'should not fail for deoptArray'
]

{ #category : #enumerating }
SoDeoptArray >> withIndexDo: aBlock [
	1 to: self size do: [ :i | aBlock value: (self at: i) value: i ]
]
