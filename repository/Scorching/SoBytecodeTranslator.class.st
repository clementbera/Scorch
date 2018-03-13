"
I translate instructions to bytecode. 

I assume TempIndexAllocation has been run before.

Instance Variables
	builder:		<BytecodeBuilder> called to generate bytecode on the basicblock bytecodes stream
	referenceTranslator:		<BytecodeReferenceTranslator> called to generate bytecodes for references of an instruction in the traversed instruction.

"
Class {
	#name : #SoBytecodeTranslator,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'builder',
		'referenceTranslator'
	],
	#pools : [
		'SoSistaV1BytecodeSetConstants'
	],
	#category : #'Scorching-Backend-Bytecode'
}

{ #category : #accessing }
SoBytecodeTranslator >> builder [
	<generated>
	^ builder
]

{ #category : #accessing }
SoBytecodeTranslator >> builder: aValue [
	<generated>
	builder := aValue
]

{ #category : #initialization }
SoBytecodeTranslator >> initialize [

	super initialize.

	builder := SoBytecodeBuilder new.
	referenceTranslator := SoBytecodeReferenceTranslator new.
	builder referenceTranslator: referenceTranslator.
	referenceTranslator builder: builder.
]

{ #category : #accessing }
SoBytecodeTranslator >> referenceTranslator [
	<generated>
	^ referenceTranslator
]

{ #category : #accessing }
SoBytecodeTranslator >> referenceTranslator: aValue [
	<generated>
	referenceTranslator := aValue
]

{ #category : #public }
SoBytecodeTranslator >> translate: codeNode codeClass: codeClass [
	builder initializeWith: codeNode.
	self traversePreorderCode: codeNode.
	^ builder compiledCode: codeNode codeClass: codeClass
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseBranch: branch [
	referenceTranslator translate: branch expression.
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseClassOp: node [
	<script>
	node backend genClassOp: node with: builder
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseContextInstVar: node [
	<script>
	node isWrite ifTrue: [^ node backend genContextInstVarWrite: node with: builder].
	node backend genContextInstVarRead: node with: builder
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseCreateArray: node [
	<script>
	node backend genCreateArray: node with: builder
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseCreateContextFullBlock: node [
	<script>
	node backend genCreateContextFullBlock: node with: builder
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseCreateFullBlock: node [
	<script>
	node backend genCreateFullBlock: node with: builder
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseCreateTempVect: node [
	<script>
	node backend genCreateTempVect: node with: builder
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseEnsureEnoughSpace: instr [
	builder genEnsureEnoughSpace: instr
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseForwardBasicBlock: basicBlock [
	super traverseForwardBasicBlock: basicBlock.
	self traverseSuccessorPhis: basicBlock.
	builder endBasicBlock: basicBlock.
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseGlobal: node [
	<script>
	node isWrite ifTrue: [^ node backend genGlobalWrite: node with: builder].
	node backend genGlobalRead: node with: builder
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseImmediateTrap: trap [
	builder genImmediateTrap: trap
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseInstVar: node [
	<script>
	node isWrite ifTrue: [^ node backend genInstVarWrite: node with: builder].
	node backend genInstVarRead: node with: builder
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseMutableLiteral: node [
	<script>
	node isWrite ifTrue: [^ node backend genMutableLiteralWrite: node with: builder].
	node backend genMutableLiteralRead: node with: builder
]

{ #category : #traversing }
SoBytecodeTranslator >> traversePhi: phi forBasicBlock: basicBlock [
	"phi can be effect, spill, temp.
	inputs can be spill or temp."
	| input |
	input := phi inputForBasicBlock: basicBlock.
	input backend isTemp 
		ifTrue: [ phi backend genPhi: phi tempInput: input with: builder ]
		ifFalse: [ phi backend genPhi: phi spillInput: input with: builder ]
]

{ #category : #traversing }
SoBytecodeTranslator >> traversePointerEqualsOp: node [
	<script>
	node backend genPointerEqualsOp: node with: builder
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseRemoteTemp: node [
	<script>
	node isWrite ifTrue: [^ node backend genRemoteTempWrite: node with: builder].
	node backend genRemoteTempRead: node with: builder
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseReturn: ret [
	"we could do quick return check here for quick return self and co".
	ret numLevels = 0 ifTrue: 
		[ referenceTranslator translate: ret returnedValue.
		  ^ builder genBlockReturn ].
	ret numLevels = 2 ifTrue: 
		[ | val |
		  val := ret returnedValue.
		  val isReceiver ifTrue: [ ^ builder genReturnReceiver ].
		  (val isConstant and: [SpecialReturnConstants includes: val constant]) 
		 	 ifTrue: [ ^ builder genReturnSpecialConstant: val ].
		  referenceTranslator translate: ret returnedValue.
		  ^ builder genReturn ].
	self error: 'unsupported'
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseSend: node [
	node backend genSend: node with: builder
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseSuccessorPhis: basicBlock [
	basicBlock successors size = 1 ifFalse: [ ^ self ].
	basicBlock successors anyOne phisDo: [ :phi |
		self traversePhi: phi forBasicBlock: basicBlock ].
]

{ #category : #traversing }
SoBytecodeTranslator >> traverseUnsafeOp: node [
	node backend genUnsafeOp: node with: builder
]
