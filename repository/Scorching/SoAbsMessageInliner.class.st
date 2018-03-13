"
I try to inline a message based on its runtime information and type information inferred. IFails if not enough type information.

I answer the list of sends in the code inlined or an empty list.

Instance Variables
	send <Send> message send being inlined
	passesBeforeInlining <Collection> passes to run on the inlined codeNode basicBlocks before inlining.
	nextBasicBlock	<BasicBlock> basicblock executed just after the message send
	prevBasicBlock <BasicBlock> basicblock executed just before the message send
	inlinedCodeNode <CodeNode> code decompiled being inlined.
"
Class {
	#name : #SoAbsMessageInliner,
	#superclass : #Object,
	#instVars : [
		'send',
		'passesBeforeInlining',
		'inlinedCodeNode',
		'nextBasicBlock',
		'prevBasicBlock',
		'futureSendsToInline',
		'onlyNLR'
	],
	#pools : [
		'SoPrimitiveConstants'
	],
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #private }
SoAbsMessageInliner >> addBasicBlocks [
	send codeNode addBasicBlocks: inlinedCodeNode basicBlocks after: prevBasicBlock.
]

{ #category : #accessing }
SoAbsMessageInliner >> arguments [
	^ send arguments 
]

{ #category : #'private - parsing' }
SoAbsMessageInliner >> basicParseInlinedCode [
	[ | toInline |
	  toInline := self codeToInline isOptimized 
		ifTrue: [self codeToInline metadata unoptimizedMethod]
		ifFalse: [self codeToInline].
	  inlinedCodeNode := self decompilerClass 
		decompile: toInline
		inliningWith: self.
		] on: SoContextAccessed, Error
		do: [ ^ false ].
	^ true
]

{ #category : #accessing }
SoAbsMessageInliner >> copiedValues [
	^ #()
]

{ #category : #private }
SoAbsMessageInliner >> createAndSetBasicBlocks [
	nextBasicBlock := send basicBlock.
	prevBasicBlock := send codeNode addBasicBlock: SoBasicBlock new before: nextBasicBlock.
	prevBasicBlock firstInstr: (SoJumpAhead from: nextBasicBlock to: inlinedCodeNode entry).
	prevBasicBlock lastInstr: prevBasicBlock firstInstr
]

{ #category : #'private - parsing' }
SoAbsMessageInliner >> extractSendsFrom: codeNode [
	| sends |
	sends := OrderedCollection new.
	codeNode basicBlocks do: [ :bb |
		bb instructionsDo: [ :instr |
			instr isSend ifTrue: [ sends add: instr ] ] ].
	^ sends
]

{ #category : #private }
SoAbsMessageInliner >> finishInlining [
	self addBasicBlocks.
	self fixEntryExitsDominatorTree.
	self mergeFlow.
	send codeNode bytecodeApproximateSize: send codeNode bytecodeApproximateSize + inlinedCodeNode compiledCode bytecodeSize.
	send addDependency.
	^ futureSendsToInline
]

{ #category : #private }
SoAbsMessageInliner >> fixEntryExitsDominatorTree [
	
	| exits |
	prevBasicBlock successors anyOne dominator: prevBasicBlock.
	exits := nextBasicBlock predecessors.
	exits ifEmpty: [ ^ self "block with only nlr, nextBasicBlock not reached" ].
	nextBasicBlock dominator: exits anyOne.
]

{ #category : #accessing }
SoAbsMessageInliner >> futureSendsToInline [
	<generated>
	^ futureSendsToInline
]

{ #category : #accessing }
SoAbsMessageInliner >> futureSendsToInline: aValue [
	<generated>
	futureSendsToInline := aValue
]

{ #category : #private }
SoAbsMessageInliner >> getExit [
	inlinedCodeNode basicBlocks reverseDo: [ :bb |
		(bb lastInstr isReturn and: [ bb lastInstr numLevels == inlinedCodeNode returnToSenderLevel ])
			ifTrue: [ ^ bb lastInstr ] ].
	"Reach here for blocks with only nlr"
	onlyNLR := true.
	^ nil
]

{ #category : #private }
SoAbsMessageInliner >> hasNLR: code [
	code literals do: [ :each |
		(each class == CompiledBlock)
			ifTrue: [ (SoBlockNLRScanner scan: each) ifTrue: [ ^ true ] ] ].
	^ false
]

{ #category : #initialization }
SoAbsMessageInliner >> initialize [

	super initialize.

	onlyNLR := false
]

{ #category : #private }
SoAbsMessageInliner >> inline: message [
	send := message.
	self canInline ifFalse: [ ^ #() ].
	self parseInlinedCode ifFalse: [ ^ #() ].
	self insertTrap.
	self splitBasicBlock.
	self patchReturn.
	^ self finishInlining
]

{ #category : #public }
SoAbsMessageInliner >> inline: message passesBeforeInlining: passes [
	passesBeforeInlining := passes.
	^ self inline: message
]

{ #category : #accessing }
SoAbsMessageInliner >> inlinedCodeNode [
	<generated>
	^ inlinedCodeNode
]

{ #category : #accessing }
SoAbsMessageInliner >> inlinedCodeNode: aValue [
	<generated>
	inlinedCodeNode := aValue
]

{ #category : #private }
SoAbsMessageInliner >> insertTrap [
	send insertTrap
]

{ #category : #testing }
SoAbsMessageInliner >> lastInliningWasSuccessful [
	^ futureSendsToInline notNil
]

{ #category : #private }
SoAbsMessageInliner >> mergeFlow [
	SoBasicBlockMerger new 
		mergeIntoPredecessorIfPossible: nextBasicBlock;
		mergeIntoPredecessorIfPossible: inlinedCodeNode entry.
	send codeNode maintainPostOrder.
]

{ #category : #accessing }
SoAbsMessageInliner >> nextBasicBlock [
	<generated>
	^ nextBasicBlock
]

{ #category : #accessing }
SoAbsMessageInliner >> nextBasicBlock: aValue [
	<generated>
	nextBasicBlock := aValue
]

{ #category : #accessing }
SoAbsMessageInliner >> onlyNLR [
	<generated>
	^ onlyNLR
]

{ #category : #accessing }
SoAbsMessageInliner >> onlyNLR: aValue [
	<generated>
	onlyNLR := aValue
]

{ #category : #'private - parsing' }
SoAbsMessageInliner >> parseInlinedCode [
	(self hasNLR: self codeToInline) ifTrue: [ 
		^ self parseNLRInlinedCode ].
	self basicParseInlinedCode ifFalse: [ ^ false ].
	self prepareInlinedCode: inlinedCodeNode.
	futureSendsToInline := inlinedCodeNode decompSends.
	^ true
]

{ #category : #'private - parsing' }
SoAbsMessageInliner >> parseNLRInlinedCode [
	self basicParseInlinedCode ifFalse: [ ^ false ].
	self removeNLR: inlinedCodeNode.
	(self stillHasNLR: inlinedCodeNode) ifTrue: [
		inlinedCodeNode basicBlocks do: [ :bb | bb instructionsDo: [ :instr | instr removeInstr ] ].
		^ false ].
	self prepareInlinedCode: inlinedCodeNode.
	futureSendsToInline := self extractSendsFrom: inlinedCodeNode.
	^ true
]

{ #category : #accessing }
SoAbsMessageInliner >> passesBeforeInlining [
	<generated>
	^ passesBeforeInlining
]

{ #category : #accessing }
SoAbsMessageInliner >> passesBeforeInlining: aValue [
	<generated>
	passesBeforeInlining := aValue
]

{ #category : #private }
SoAbsMessageInliner >> patchReturn [
	| return |
	return := self getExit.
	
	onlyNLR ifTrue: [ ^ SoDeadBranchElimination new removeDominatedPath: nextBasicBlock ].
	
	send replaceUsesBy: return returnedValue.
	return replaceBy: (SoJumpAhead from: return basicBlock to: nextBasicBlock).
]

{ #category : #private }
SoAbsMessageInliner >> prepareInlinedCode: code [
	passesBeforeInlining do: [ :each | 
		each new runOn: code ]
]

{ #category : #accessing }
SoAbsMessageInliner >> prevBasicBlock [
	<generated>
	^ prevBasicBlock
]

{ #category : #accessing }
SoAbsMessageInliner >> prevBasicBlock: aValue [
	<generated>
	prevBasicBlock := aValue
]

{ #category : #'private - parsing' }
SoAbsMessageInliner >> removeNLR: codeNode [
	{ SoReorderBasicBlocks . 
		SoNLRDominators . 
		SoSimplifyPhis } do: [ :each | 
			each new runOn: codeNode ].
	SoCallGraphInliner new inlineQuietlySends: codeNode decompSends.
]

{ #category : #accessing }
SoAbsMessageInliner >> send [
	<generated>
	^ send
]

{ #category : #accessing }
SoAbsMessageInliner >> send: aValue [
	<generated>
	send := aValue
]

{ #category : #private }
SoAbsMessageInliner >> splitBasicBlock [
	nextBasicBlock := send basicBlock.
	prevBasicBlock := SoBasicBlockSplitter new splitBasicBlockAt: send.
	prevBasicBlock lastInstr replaceSuccessor: nextBasicBlock by: inlinedCodeNode entry. 
	nextBasicBlock predecessors: OrderedCollection new.
]

{ #category : #'private - parsing' }
SoAbsMessageInliner >> stillHasNLR: codeNode [
	codeNode basicBlocks do: [ :bb |
		bb instructionsDo: [ :instr | 
			(instr isBlockClosure and: [ instr hasNLR ]) ifTrue: [ ^ true ] ] ].
	^ false 
]
