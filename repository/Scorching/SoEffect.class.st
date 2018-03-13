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
SoEffect >> genInstantiation: node with: builder [
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
