"
I scan blocks to know if there is a NLR.

hasNLR <Boolean>
"
Class {
	#name : #SoBlockNLRScanner,
	#superclass : #SoAbstractScanner,
	#instVars : [
		'hasNLR'
	],
	#category : #'Scorching-Decompiler'
}

{ #category : #public }
SoBlockNLRScanner class >> scan: compiledCode [
	^ (self on: compiledCode) scan
]

{ #category : #accessing }
SoBlockNLRScanner >> hasNLR [
	<generated>
	^ hasNLR
]

{ #category : #accessing }
SoBlockNLRScanner >> hasNLR: aValue [
	<generated>
	hasNLR := aValue
]

{ #category : #initialization }
SoBlockNLRScanner >> initialize [

	super initialize.

	hasNLR := false.
]

{ #category : #'opcodes-control flow' }
SoBlockNLRScanner >> methodReturnConstant: value [ 
	hasNLR := true.
]

{ #category : #'opcodes-control flow' }
SoBlockNLRScanner >> methodReturnReceiver [
	hasNLR := true.
]

{ #category : #'opcodes-control flow' }
SoBlockNLRScanner >> methodReturnTop [
	hasNLR := true.
]

{ #category : #'opcodes-control flow' }
SoBlockNLRScanner >> pushFullClosure: compiledBlock numCopied: numCopied receiverOnStack: recOnStack ignoreOuterContext: ignoreOuterContext [
	"For NLRs nested in closures"
	hasNLR ifFalse: [ hasNLR := SoBlockNLRScanner scan: compiledBlock  ]
]

{ #category : #public }
SoBlockNLRScanner >> scan [
	self interpret.
	^ hasNLR
]
