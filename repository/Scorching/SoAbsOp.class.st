"
I represent an abstract operation. I can be either a message send or a typed operation.

Instance Variables
	receiver < Instruction>
	arguments <Array of Instruction>

"
Class {
	#name : #SoAbsOp,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'receiver',
		'arguments'
	],
	#category : #'Scorching-Nodes-Op'
}

{ #category : #accessing }
SoAbsOp >> arguments [
	<generated>
	^ arguments
]

{ #category : #accessing }
SoAbsOp >> arguments: aValue [
	<generated>
	arguments := aValue.
	arguments do: [  :each | each addUse: self ]
]

{ #category : #'graph edition' }
SoAbsOp >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	receiver == node ifTrue: [ 
		receiver := anotherNode.
		^ anotherNode addUse: self ].
	arguments at: (arguments identityIndexOf: node) put: anotherNode.
	anotherNode addUse: self.
]

{ #category : #accessing }
SoAbsOp >> firstArg [
	^ arguments first
]

{ #category : #'graph edition' }
SoAbsOp >> postCopy [
	<generated>
	arguments := arguments copy.
	super postCopy
]

{ #category : #accessing }
SoAbsOp >> receiver [
	<generated>
	^ receiver
]

{ #category : #accessing }
SoAbsOp >> receiver: aValue [
	<generated>
	receiver := aValue.
	receiver  addUse: self
]

{ #category : #'graph edition' }
SoAbsOp >> subNodes [
	<generated>
	^ {receiver} , arguments
]
