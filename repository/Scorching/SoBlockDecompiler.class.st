"
I am a specific decompiler for blocks. Various things are different in blocks (Context state, a SoBlock is created instead of a SoMethod, returns are different, etc.).

The biggest differences are:
- handling of block inlining
- handling of copied values
- handling of non local returns
"
Class {
	#name : #SoBlockDecompiler,
	#superclass : #SoDecompiler,
	#instVars : [
		'copiedValues',
		'nonLocalPhi',
		'sunkClosure'
	],
	#category : #'Scorching-Decompiler'
}

{ #category : #'opcodes - control flow' }
SoBlockDecompiler >> blockReturnTop [
	builder localReturn: self stackTop.
	self ensureFixupAt: self shiftedPC.
]

{ #category : #'opcodes-datamovement' }
SoBlockDecompiler >> closureClass: compiledBlock ignoreOuterContext: ignoreOuterContext [
	ignoreOuterContext ifTrue: [ ^ SoCreateFullBlock ].
	nonLocalPhi ifNil: [ "Block nested in outer most method" ^ SoCreateContextFullBlock ].
	callerDeoptInfo ifNil: [ ^SoCreateContextFullBlock ].
	^ (SoBlockNLRScanner scan: compiledBlock)
		ifTrue: [ SoCreateNLRFullBlock ]
		ifFalse: [ SoCreateContextFullBlock ] 
]

{ #category : #'sunk objects' }
SoBlockDecompiler >> closureRef [
	^ sunkClosure marker
]

{ #category : #accessing }
SoBlockDecompiler >> codeNodeClass [
	^ SoBlock
]

{ #category : #accessing }
SoBlockDecompiler >> copiedValues [
	<generated>
	^ copiedValues
]

{ #category : #accessing }
SoBlockDecompiler >> copiedValues: aValue [
	<generated>
	copiedValues := aValue
]

{ #category : #initialization }
SoBlockDecompiler >> initialize [

	super initialize.

	self flag: 'should be copied temp'.
	copiedValues := #().
	sunkClosure := SoThisClosure new
]

{ #category : #'opcodes - control flow' }
SoBlockDecompiler >> methodReturnTop [
	nonLocalPhi 
		ifNil: [ builder nonLocalReturn: self stackTop ]
		ifNotNil: [ :targetPhi | 
			targetPhi addInput: self stackTop basicBlock: builder currentBasicBlock.
			builder jump: targetPhi basicBlock ].
	self ensureFixupAt: self shiftedPC.
]

{ #category : #accessing }
SoBlockDecompiler >> nonLocalPhi [
	<generated>
	^ nonLocalPhi
]

{ #category : #accessing }
SoBlockDecompiler >> nonLocalPhi: aValue [
	<generated>
	nonLocalPhi := aValue
]

{ #category : #'sunk objects' }
SoBlockDecompiler >> recordSunkContext: node [
	super recordSunkContext: node.
	node deoptInfo addSunkObject: sunkClosure copy.
]

{ #category : #initialization }
SoBlockDecompiler >> setUpWithInliner: inliner [
	super setUpWithInliner: inliner.
	copiedValues := inliner copiedValues.
	nonLocalPhi := inliner closure nlrPhi.
	nonLocalPhi ifNotNil: [ nonLocalPhi removeInput: inliner closure fakeConstant basicBlock: inliner closure fakeBasicBlock ].
	sunkClosure := inliner sunkClosure
]

{ #category : #accessing }
SoBlockDecompiler >> sunkClosure [
	<generated>
	^ sunkClosure
]

{ #category : #accessing }
SoBlockDecompiler >> sunkClosure: aValue [
	<generated>
	sunkClosure := aValue
]
