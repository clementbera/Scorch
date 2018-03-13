"
I valide optimized compiled code by making sure that:
- deopt info is present at each deopt point.
"
Class {
	#name : #SoOptCCodeValidator,
	#superclass : #InstructionClient,
	#instVars : [
		'scanner',
		'prevPC',
		'compiledCode'
	],
	#category : #'ScorchingTests-Validation'
}

{ #category : #decoding }
SoOptCCodeValidator >> directedSuperSend: selector numArgs: numArgs [
	"sends should have deopt info"
	self ensureDeoptMetadataAt: self nextPC string: 'directedSuperSend'
]

{ #category : #asserting }
SoOptCCodeValidator >> ensureDeoptMetadataAt: pc string: string [
	compiledCode metadata deoptPoints 
		at: (compiledCode metadata indexFromPC: pc code: compiledCode) 
		ifAbsent: [ self assert: false description: 'Should be deopt metadata for ' , string ]
	" 
	|allDebugPCs|
	allDebugPCs := OrderedCollection new.
	compiledCode metadata deoptPoints array pairsDo: [ :k :v |
		k ifNotNil: [allDebugPCs add: k] ].
	allDebugPCs sort
	"
]

{ #category : #decoding }
SoOptCCodeValidator >> jump: offset [
	offset < 0 ifTrue: [ self ensureDeoptMetadataAt: self prevPC string: 'backjump' ]
]

{ #category : #accessing }
SoOptCCodeValidator >> nextPC [
	^ scanner pc
]

{ #category : #accessing }
SoOptCCodeValidator >> prevPC [
	^ prevPC
]

{ #category : #decoding }
SoOptCCodeValidator >> send: selector super: supered numArgs: numberArguments [
	"sends should have deopt info"
	(selector = #== or: [selector = #~~ or: [selector = #class]]) ifTrue: [ ^ self ].
	self ensureDeoptMetadataAt: self nextPC string: 'send'
]

{ #category : #decoding }
SoOptCCodeValidator >> trap [
	self ensureDeoptMetadataAt: self nextPC string: 'trap'
]

{ #category : #public }
SoOptCCodeValidator >> validateCompiledCode: cc [
	| end |
	compiledCode := cc.
	scanner := InstructionStream on: compiledCode.
	end := compiledCode endPC.
	[scanner pc <= end] whileTrue:
		[prevPC := scanner pc.
		scanner interpretNextInstructionFor: self.].
]
