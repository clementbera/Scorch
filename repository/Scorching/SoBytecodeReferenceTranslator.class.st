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
SoBytecodeReferenceTranslator >> traverseClassOp: node [
	<script>
	node backend genClassOpReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseConstant: node [
	builder genPushConstant: node
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseContextInstVar: node [
	<script>
	node backend genContextInstVarReadReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseCreateArray: node [
	<script>
	node backend genCreateArrayReference: node with: builder
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
SoBytecodeReferenceTranslator >> traverseCreateTempVect: node [
	<script>
	node backend genCreateTempVectReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseGlobal: node [
	<script>
	node backend genGlobalReadReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseInstVar: node [
	<script>
	node backend genInstVarReadReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseMutableLiteral: node [
	<script>
	node backend genMutableLiteralReadReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traversePhi: node [
	<script>
	node backend genPhiReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traversePointerEqualsOp: node [
	<script>
	node backend genPointerEqualsOpReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseReceiver: node [
	^ builder genPushReceiver
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseRemoteTemp: node [
	<script>
	node backend genRemoteTempReadReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseSend: node [
	node backend genSendReference: node with: builder
]

{ #category : #traversing }
SoBytecodeReferenceTranslator >> traverseUnsafeOp: node [
	<script>
	node backend genUnsafeOpReference: node with: builder
]
