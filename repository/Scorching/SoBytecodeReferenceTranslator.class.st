"
I am used to generate bytecode on instructions referenced by another instructions i.e., instructions' subnodes.

Instance Variables
	builder:		<BytecodeBuilder> called to generate bytecode on the basicblock bytecodes stream
"
Class {
	#name : #SoBytecodeReferenceTranslator,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'builder'
	],
	#category : #'Scorching-Backend-Bytecode'
}

{ #category : #accessing }
SoBytecodeReferenceTranslator >> builder [
	<generated>
	^ builder
]

{ #category : #accessing }
SoBytecodeReferenceTranslator >> builder: aValue [
	<generated>
	builder := aValue
]

{ #category : #public }
SoBytecodeReferenceTranslator >> translate: instr [
	^ instr isTraversedBy: self
]

{ #category : #public }
SoBytecodeReferenceTranslator >> translateAll: instrCol [
	instrCol do: [ :each | each isTraversedBy: self ]
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseArg: node [
	builder genPushArg: node
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseBodyInstruction: node [
	<script>
	node backend genUnsafeOpReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseConstant: node [
	builder genPushConstant: node
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseCreateContextFullBlock: node [
	<script>
	node backend genCreateContextFullBlockReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseCreateFullBlock: node [
	<script>
	node backend genCreateFullBlockReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseInstantiation: node [
	node backend genInstantiationReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseMutableLiteralRead: node [
	node backend genMutableLiteralReadReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traversePhi: node [
	<script>
	node backend genPhiReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseReceiver: node [
	^ builder genPushReceiver
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseSend: node [
	node backend genSendReference: node with: builder
]
