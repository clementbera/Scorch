"
An instruction with effect information will be generated in a way that its result will be directly popped from the stack.

If the node is side-effect free, nothing is generated at all.
"
Class {
	#name : #SoEffect,
	#superclass : #SoSpillState,
	#category : #'Scorching-Backend-Bytecode'
}

{ #category : #'bytecode generation' }
SoEffect >> genClassOp: node with: builder [
	<script>
	"effect free"
]

{ #category : #'bytecode generation' }
SoEffect >> genContextInstVarRead: node with: builder [
	<script>
	"effect-free, nothing"
]

{ #category : #'bytecode generation' }
SoEffect >> genContextInstVarWrite: node with: builder [
	<script>
	builder genPopIntoContextInstVar: node
]

{ #category : #'bytecode generation' }
SoEffect >> genCreateArray: node with: builder [
	<script>
	"effect free"
]

{ #category : #'bytecode generation' }
SoEffect >> genCreateContextFullBlock: node with: builder [
	<script>
	"effect free"
]

{ #category : #'bytecode generation' }
SoEffect >> genCreateFullBlock: node with: builder [
	<script>
	"effect free"
]

{ #category : #'bytecode generation' }
SoEffect >> genCreateTempVect: node with: builder [
	<script>
	"effect free"
]

{ #category : #'bytecode generation' }
SoEffect >> genGlobalRead: node with: builder [
	<script>
	"effect-free, nothing"
]

{ #category : #'bytecode generation' }
SoEffect >> genGlobalWrite: node with: builder [
	<script>
	builder genPopIntoGlobal: node
]

{ #category : #'bytecode generation' }
SoEffect >> genInstVarRead: node with: builder [
	<script>
	"effect-free, nothing"
]

{ #category : #'bytecode generation' }
SoEffect >> genInstVarWrite: node with: builder [
	<script>
	builder genPopIntoInstVar: node
]

{ #category : #'bytecode generation' }
SoEffect >> genMutableLiteralRead: node with: builder [
	<script>
	"effect-free, nothing"
]

{ #category : #'bytecode generation' }
SoEffect >> genMutableLiteralWrite: node with: builder [
	<script>
	builder genPopIntoMutableLiteral: node
]

{ #category : #'bytecode generation' }
SoEffect >> genPhi: phi spillInput: cst with: builder [ 
]

{ #category : #'bytecode generation' }
SoEffect >> genPhi: aScPhi tempInput: aScSend with: aScBytecodeBuilder [ 
]

{ #category : #'bytecode generation' }
SoEffect >> genPhi: node with: builder [
	<script>
	"effect free"
]

{ #category : #'bytecode generation' }
SoEffect >> genPointerEqualsOp: node with: builder [
	<script>
	"effect free"
]

{ #category : #'bytecode generation' }
SoEffect >> genRemoteTempRead: node with: builder [
	<script>
	"effect-free, nothing"
]

{ #category : #'bytecode generation' }
SoEffect >> genRemoteTempWrite: node with: builder [
	<script>
	builder genPopIntoRemoteTemp: node
]

{ #category : #'bytecode generation' }
SoEffect >> genSend: node with: builder [
	<script>
	builder genSend: node.
	builder genPop
]

{ #category : #'bytecode generation' }
SoEffect >> genUnsafeOp: node with: builder [
	node hasEffect ifFalse: [ ^ self ]. 
	builder genUnsafeOp: node.
	builder genPop.
]
