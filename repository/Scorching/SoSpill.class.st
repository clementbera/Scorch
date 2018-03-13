"
An instruction with spill information will be generated in a way that it's result will be pushed on stack to be reused directly by another instruction.

"
Class {
	#name : #SoSpill,
	#superclass : #SoSpillState,
	#category : #'Scorching-Backend-Bytecode'
}

{ #category : #'bytecode generation' }
SoSpill >> genClassOp: node with: builder [
	<script>
	"gen on reference"
]

{ #category : #'bytecode generation' }
SoSpill >> genClassOpReference: node with: builder [
	<script>
	builder genClassOp: node
]

{ #category : #'bytecode generation' }
SoSpill >> genContextInstVarRead: node with: builder [
	<script>
	"gen on reference"
]

{ #category : #'bytecode generation' }
SoSpill >> genContextInstVarReadReference: node with: builder [
	<script>
	builder genPushContextInstVar: node
]

{ #category : #'bytecode generation' }
SoSpill >> genCreateArray: node with: builder [
	<script>
	"gen on reference"
]

{ #category : #'bytecode generation' }
SoSpill >> genCreateArrayReference: node with: builder [
	<script>
	builder genCreateArray: node
]

{ #category : #'bytecode generation' }
SoSpill >> genCreateContextFullBlock: node with: builder [
	<script>
	"gen on reference"
]

{ #category : #'bytecode generation' }
SoSpill >> genCreateContextFullBlockReference: node with: builder [
	<script>
	builder genCreateContextFullBlock: node
]

{ #category : #'bytecode generation' }
SoSpill >> genCreateFullBlock: node with: builder [
	<script>
	"gen on reference"
]

{ #category : #'bytecode generation' }
SoSpill >> genCreateFullBlockReference: node with: builder [
	<script>
	builder genCreateFullBlock: node
]

{ #category : #'bytecode generation' }
SoSpill >> genCreateTempVect: node with: builder [
	<script>
	"gen on reference"
]

{ #category : #'bytecode generation' }
SoSpill >> genCreateTempVectReference: node with: builder [
	<script>
	builder genCreateTempVect: node
]

{ #category : #'bytecode generation' }
SoSpill >> genGlobalRead: node with: builder [
	<script>
	"gen on reference"
]

{ #category : #'bytecode generation' }
SoSpill >> genGlobalReadReference: node with: builder [
	<script>
	builder genPushGlobal: node
]

{ #category : #'bytecode generation' }
SoSpill >> genInstVarRead: node with: builder [
	<script>
	"gen on reference"
]

{ #category : #'bytecode generation' }
SoSpill >> genInstVarReadReference: node with: builder [
	<script>
	builder genPushInstVar: node
]

{ #category : #'bytecode generation' }
SoSpill >> genMutableLiteralRead: node with: builder [
	<script>
	"gen on reference"
]

{ #category : #'bytecode generation' }
SoSpill >> genMutableLiteralReadReference: node with: builder [
	<script>
	builder genPushMutableLiteral: node
]

{ #category : #'bytecode generation' }
SoSpill >> genPhi: phi spillInput: input with: builder [
	builder referenceTranslator translate: input.
]

{ #category : #'bytecode generation' }
SoSpill >> genPhi: phi tempInput: input with: builder [ 
	builder genPushTemp: input backend tempIndex
]

{ #category : #'bytecode generation' }
SoSpill >> genPhi: node with: builder [
	<script>
	"gen on reference"
]

{ #category : #'bytecode generation' }
SoSpill >> genPhiReference: node with: builder [
	"inputs should be on stack"
]

{ #category : #'bytecode generation' }
SoSpill >> genPointerEqualsOp: node with: builder [
	<script>
	"gen on reference"
]

{ #category : #'bytecode generation' }
SoSpill >> genPointerEqualsOpReference: node with: builder [
	<script>
	builder genPointerEqualsOp: node
]

{ #category : #'bytecode generation' }
SoSpill >> genRemoteTempRead: node with: builder [
	<script>
	"gen on reference"
]

{ #category : #'bytecode generation' }
SoSpill >> genRemoteTempReadReference: node with: builder [
	<script>
	builder genPushRemoteTemp: node
]

{ #category : #'bytecode generation' }
SoSpill >> genSend: node with: builder [
	<script>
	"gen on reference"
]

{ #category : #'bytecode generation' }
SoSpill >> genSendReference: node with: builder [
	<script>
	builder genSend: node
]

{ #category : #'bytecode generation' }
SoSpill >> genUnsafeOp: node with: builder [
	
]

{ #category : #'bytecode generation' }
SoSpill >> genUnsafeOpReference: node with: builder [
	builder genUnsafeOp: node
]

{ #category : #testing }
SoSpill >> isSpilled [
	^ true
]
