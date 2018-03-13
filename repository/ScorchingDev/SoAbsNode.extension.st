Extension { #name : #SoAbsNode }

{ #category : #'*ScorchingDev' }
SoAbsNode >> debugSchedulingChildren [
	^ #()
]

{ #category : #'*ScorchingDev' }
SoAbsNode >> debugUses [
	^ #()
]

{ #category : #'*ScorchingDev' }
SoAbsNode >> debugUsesNoDeopt [
	^ self debugUses
]

{ #category : #'*ScorchingDev' }
SoAbsNode >> doesNotUnderstand: aMessage [
	(aMessage selector beginsWith: 'is')
		ifFalse: [ ^ super doesNotUnderstand: aMessage ].
	SoIsGenerator genIsMethodFrom: aMessage in: SoAbsNode.
	(self respondsTo: aMessage selector)
		ifFalse: [ ^ super doesNotUnderstand: aMessage ].
	^ aMessage sentTo: self
]

{ #category : #'*ScorchingDev' }
SoAbsNode >> gtInspectorInstructionsIn: composite [
	<gtInspectorPresentationOrder: 6> 
	composite table 
		title: 'Instr'; "Instructions"
		display: (self codeNode basicBlocks flatCollect: [:bb | bb instructions , ' '])
]

{ #category : #'*ScorchingDev' }
SoAbsNode >> gtInspectorSymbolicrIn: composite [
	<gtInspectorPresentationOrder: 7> 
	composite text 
		title: 'Sym'; "Symbolic"
		format: [String streamContents: [:s | SoPrettyPrinter new printCodeNode: self codeNode on: s]]
]

{ #category : #'*ScorchingDev' }
SoAbsNode >> shortPrintOn: s [
	| instr index |
	self basicBlock ifNil: [ ^ s << '?-?' ].
	s nextPut: $[.
	s << self basicBlock printingNumber.
	s nextPut: $. .
	instr := self basicBlock firstInstr.
	index := 1.
	[ instr == self or: [ instr isCFGInstr ] ] whileFalse: [ 
		index := index + 1.
		instr := instr nextInstr ].
	instr == self ifFalse: [ ^ s << '?]' ].
	index printOn: s.
	s nextPut: $].
		
]
