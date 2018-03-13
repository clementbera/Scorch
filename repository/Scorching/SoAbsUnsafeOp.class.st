"
I represent an unsafe operation aka an inlined primitive.

These operations never check for receiver or arguments types. Their types have to be ensured by the optimizer.
"
Class {
	#name : #SoAbsUnsafeOp,
	#superclass : #SoAbsOp,
	#pools : [
		'SoPrimitiveConstants',
		'SoUnsafeOpConstants'
	],
	#category : #'Scorching-Nodes-Op'
}

{ #category : #'instance creation' }
SoAbsUnsafeOp class >> fromSend: send [
	^ self new 	
		receiver: send receiver;
		arguments: send arguments;
		yourself
]

{ #category : #'instance creation' }
SoAbsUnsafeOp class >> withReceiver: receiver [
	^ self withReceiver: receiver arguments: #()
]

{ #category : #'instance creation' }
SoAbsUnsafeOp class >> withReceiver: receiver arguments: args [
	^ self new 	
		receiver: receiver;
		arguments: args;
		yourself
]

{ #category : #testing }
SoAbsUnsafeOp >> canBeRemovedIfNoUses [
	^ true
]

{ #category : #static }
SoAbsUnsafeOp >> computeStatically [ 
	^ SoConstant constant: (receiver constant 
		tryPrimitive: self safePrimitiveNumber 
		withArgs: (self arguments collect: [ :e | e constant ] ) )
]

{ #category : #testing }
SoAbsUnsafeOp >> hasEffect [
	^ false
]

{ #category : #testing }
SoAbsUnsafeOp >> isUnsafeOp [
	^ true
]

{ #category : #comparing }
SoAbsUnsafeOp >> sameExprAs: op [
	self class = op class ifFalse: [ ^ false ].
	receiver  = op receiver ifFalse: [ ^ false ].
	arguments size = op arguments size ifFalse: [ ^ false ].
	1 to: arguments size do: [ :i |
		(arguments at: i) = (op arguments at: i) ifFalse: [ ^ false ] ].
	^ true
]
