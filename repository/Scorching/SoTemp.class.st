"
An instruction with temp information will be generated in a way that it's result will be stored in a temp. Access to the node are generated as push temp.

tempIndex <Smi> index of the temp that will be used
interferences <set> instructions with liveness interfering with this instruction liveness 

The spill state is assigned to the instruction in SpillAnalysis phasis.
 Interferences are assigned during liveness analysis.
The temp index is finally assigned in TempIndexAllocator phasis.
"
Class {
	#name : #SoTemp,
	#superclass : #SoSpillState,
	#instVars : [
		'tempIndex',
		'interferences'
	],
	#category : #'Scorching-Backend-Bytecode'
}

{ #category : #interferences }
SoTemp >> addInterferenceWith: instr [
	interferences add: instr
]

{ #category : #'bytecode generation' }
SoTemp >> genCreateContextFullBlock: node with: builder [
	<script>
	builder genCreateContextFullBlock: node.
	builder genPopIntoTemp: tempIndex
]

{ #category : #'bytecode generation' }
SoTemp >> genCreateContextFullBlockReference: node with: builder [
	<script>
	builder genPushTemp: tempIndex
]

{ #category : #'bytecode generation' }
SoTemp >> genCreateFullBlock: node with: builder [
	<script>
	builder genCreateFullBlock: node.
	builder genPopIntoTemp: tempIndex
]

{ #category : #'bytecode generation' }
SoTemp >> genCreateFullBlockReference: node with: builder [
	<script>
	builder genPushTemp: tempIndex
]

{ #category : #'bytecode generation' }
SoTemp >> genInstantiation: op with: builder [
	builder genInstantiation: op.
	builder genPopIntoTemp: tempIndex
]

{ #category : #'bytecode generation' }
SoTemp >> genInstantiationReference: node with: builder [
	builder genPushTemp: tempIndex
]

{ #category : #'bytecode generation' }
SoTemp >> genMutableLiteralRead: node with: builder [
	<script>
	builder genPushMutableLiteral: node.
	builder genPopIntoTemp: tempIndex
]

{ #category : #'bytecode generation' }
SoTemp >> genMutableLiteralReadReference: node with: builder [
	<script>
	builder genPushTemp: tempIndex
]

{ #category : #'bytecode generation' }
SoTemp >> genPhi: phi spillInput: input with: builder [
	"Try to handle here the nil assignment mess..."
	(input isConstant 
		and: [ input constant isNil 
			and: [ (builder hasBeenAssigned: tempIndex) not ] ])
				ifTrue: [ ^ self ].
		
	builder referenceTranslator translate: input.
	builder genPopIntoTemp: tempIndex.
]

{ #category : #'bytecode generation' }
SoTemp >> genPhi: phi tempInput: input with: builder [
	tempIndex = input backend tempIndex ifTrue: [ ^ self ].
	builder genPushTemp: input backend tempIndex.
	builder genPopIntoTemp: tempIndex.
]

{ #category : #'bytecode generation' }
SoTemp >> genPhiReference: node with: builder [
	<script>
	builder genPushTemp: tempIndex
]

{ #category : #'bytecode generation' }
SoTemp >> genSend: node with: builder [
	builder genSend: node.
	builder genPopIntoTemp: tempIndex
]

{ #category : #'bytecode generation' }
SoTemp >> genSendReference: node with: builder [
	builder genPushTemp: tempIndex
]

{ #category : #'bytecode generation' }
SoTemp >> genUnsafeOp: op with: builder [
	builder genUnsafeOp: op.
	builder genPopIntoTemp: tempIndex
]

{ #category : #'bytecode generation' }
SoTemp >> genUnsafeOpReference: node with: builder [
	builder genPushTemp: tempIndex
]

{ #category : #initialization }
SoTemp >> initialize [

	super initialize.

	interferences := Set new
]

{ #category : #accessing }
SoTemp >> interferences [
	<generated>
	^ interferences
]

{ #category : #accessing }
SoTemp >> interferences: aValue [
	<generated>
	interferences := aValue
]

{ #category : #testing }
SoTemp >> isTemp [
	^ true
]

{ #category : #accessing }
SoTemp >> tempIndex [
	<generated>
	^ tempIndex
]

{ #category : #accessing }
SoTemp >> tempIndex: aValue [
	<generated>
	tempIndex := aValue
]
