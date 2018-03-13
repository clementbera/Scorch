"
I try to inline a message based on its runtime information and type information inferred. IFails if not enough type information.

I answer the list of sends in the code inlined or an empty list.

Instance Variables
	send <Send> message send being inlined
	passesBeforeInlining <Collection> passes to run on the inlined codeNode basicBlocks before inlining.
	nextBasicBlock	<BasicBlock> basicblock executed just after the message send
	prevBasicBlock <BasicBlock> basicblock executed just before the message send
	inlinedCodeNode <CodeNode> code decompiled being inlined.
	NLFlow <Boolean> true in case of exception/NLR inlining
"
Class {
	#name : #SoAbsMessageInliner,
	#superclass : #Object,
	#instVars : [
		'send',
		'inlinedCodeNode',
		'nextBasicBlock',
		'prevBasicBlock',
		'futureSendsToInline',
		'nonLocalFlow',
		'debugString'
	],
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #accessing }
SoAbsMessageInliner >> arguments [
	^ send arguments 
]

{ #category : #private }
SoAbsMessageInliner >> basicInline: message [
	send := message.
	self canInline ifFalse: [ self class logInlining: send message: debugString. ^ #() ].
	self parseInlinedCode ifFalse: [ self class logInlining: send message: debugString. ^ #() ].
	self class logInlining: send message: debugString.
	self insertTrap.
	^ self finishInlining
]

{ #category : #'non local flow' }
SoAbsMessageInliner >> basicInlineExceptionSignal [
	| fake instr successors |
	debugString := 'exception signal inlining'.
	self markInliningAsSuccessful.
	nonLocalFlow := true.
	successors := send basicBlock lastInstr successors.
	"fake node for convertToTrapWith: - instVarNamed: to avoid the def-use.
	 This a bit complex since this is different from normal trap, it's inserted just
	 after the send reusing its result."
	fake := SoUnforward new instVarNamed: #expression put: send; yourself.
	send basicBlock lastInstr replaceBy: (SoImmediateTrap new 
		deoptInfo: (send deoptInfo convertToTrapWith: fake);
		yourself).
	"remove all instr between send and trap"
	instr := send nextInstr.
	[ instr isImmediateTrap ] whileFalse: [ instr removeInstr. instr := instr nextInstr ].
	"patch successors"
	successors do: [ :succ | 
		succ forwardPredecessors size = 0
			ifTrue: [ SoDeadBranchElimination new removeDominatedPath: succ ]
			ifFalse: [ 
				succ predecessors add: send basicBlock. "for compatibility with dead branch elim API..."
				SoDeadBranchElimination new removePredecessor: send basicBlock from: succ ] ]
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
		] on: SoContextAccessed
		do: [ :ex | 
			debugString := 'Parsing error'.
			self contextAccessInlining.
			^ false ].
	^ true
]

{ #category : #'non local flow' }
SoAbsMessageInliner >> basicRemoveNLR: codeNode [
	| nlrs |
	"following works for some cases..."
	SoNLRDigger new inlineSends: codeNode decompSends.
	(self stillHasNLR: codeNode) ifFalse: [ ^ self ].
	"So... We cannot remove the NLR. We try to optimise the graph with 
	 some cheap optimisations, then retry inlining. Not that this path may
	 remove the NLR without inlining (if NLR in a dead branch for example)"
	{SoSubexpressionElimination .
	 SoDeadBranchElimination .
	 SoDeadCodeElimination .
	 SoNLRDigger } do: [ :p | p new runOn: codeNode ].
	nlrs := self collectNLRs: codeNode.
	nlrs ifEmpty: [ ^ self ].
	"Still not enough... If the block is stored in an object that might be
	 folded, we try escape optimisation, else it just cannot be inlined."
	(nlrs anySatisfy: [ :nlr | nlr uses anySatisfy: [ :use | use isWrite ] ]) ifFalse: [ ^ self ].
	SoEscapeOptimisation new runOn: codeNode.
	
]

{ #category : #inlining }
SoAbsMessageInliner >> canInline [
	self subclassResponsibility
]

{ #category : #'non local flow' }
SoAbsMessageInliner >> collectNLRs: codeNode [
	| nlrs |
	nlrs := OrderedCollection new.
	codeNode basicBlocks do: [ :bb |
		bb instructionsDo: [ :instr | 
			(instr isBlockClosure and: [ instr hasNLR ]) ifTrue: [ nlrs add: instr ] ] ].
	^ nlrs 
]

{ #category : #accessing }
SoAbsMessageInliner >> copiedValues [
	^ #()
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
	self singleBasicBlockInlining ifTrue: [ ^ self singleBasicBlockPatch ].
	"Note: This path breaks postOrder annotations -
	 but the Inliner calling this should restore it afterwards"
	nextBasicBlock := send basicBlock.
	prevBasicBlock := SoBasicBlockSplitter new splitBasicBlockAt: send.
	"Patching entry / exit used to be done with BasicBlockMerger, 
	 but iterating over the whole graph only was too expensive (profiler)"
	self patchEntry.
	self patchReturn.
	send addDependency.
	^ futureSendsToInline
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
	nonLocalFlow := true.
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

	debugString := 'NoDebugInfo'.
]

{ #category : #public }
SoAbsMessageInliner >> inline: message [ 
	nonLocalFlow := false.
	^ self basicInline: message
]

{ #category : #'non local flow' }
SoAbsMessageInliner >> inlineExceptionSignal [
	"Heuristic - if it looks like the exception is not resumable, do nothing, if
	 it is not, it's likely to be uncommon, so we insert a trap just after the signal send
	 which normally will never be reached. This traps helps the optimiser since the basic
	block signalling cannot fall through any more."
	| behaviors behavior resumable |
	send basicBlock lastInstr isImmediateTrap ifTrue: [ ^ self ].
	behaviors := send specializedSendData behaviors.
	behaviors size > 1 ifTrue: [ "uncommon" ^ self basicInlineExceptionSignal ].
	behavior := behaviors anyOne.
	"heuristic - don't trap resumable exception."
	resumable := behavior lookupSelector: #isResumable.
	resumable ifNil: [ "lookup failed " ^ self basicInlineExceptionSignal ] .
	"Common case - in Exception isResumable is quick prim return true"
	resumable primitive = 257 "quickPrimReturn true"
		ifFalse: [ ^ self basicInlineExceptionSignal ]
	
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

{ #category : #'non local flow' }
SoAbsMessageInliner >> markInliningAsSuccessful [
	futureSendsToInline := #(). "See #lastInliningWasSuccessful"
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

{ #category : #'non local flow' }
SoAbsMessageInliner >> nlrPreparation: codeNode [
	{ SoReorderBasicBlocks . 
		SoNLRDominators . 
		SoSimplifyPhis } do: [ :each | 
			each new runOn: codeNode ].
]

{ #category : #accessing }
SoAbsMessageInliner >> nonLocalFlow [
	<generated>
	^ nonLocalFlow
]

{ #category : #accessing }
SoAbsMessageInliner >> nonLocalFlow: aValue [
	<generated>
	nonLocalFlow := aValue
]

{ #category : #'private - parsing' }
SoAbsMessageInliner >> parseInlinedCode [
	(self hasNLR: self codeToInline) ifTrue: [ 
		^ self parseNLRInlinedCode ].
	self basicParseInlinedCode ifFalse: [ ^ false ].
	self prepareInlinedCode: inlinedCodeNode.
	futureSendsToInline := inlinedCodeNode decompSends.
	debugString := 'Inlined ' , self codeToInline methodClass name.
	^ true
]

{ #category : #'non local flow' }
SoAbsMessageInliner >> parseNLRInlinedCode [
	"parsing nlr is very expensive, we try only once,
	 on failure we flag the send as having a nlr issue."
	send nlrIssue ifTrue: [ debugString := 'NLR issue'. ^ false ].
	self basicParseInlinedCode ifFalse: [ ^ false ].
	self removeNLR: inlinedCodeNode.
	(self stillHasNLR: inlinedCodeNode) ifTrue: [
		debugString := 'NLR removal failure'.
		inlinedCodeNode basicBlocks do: [ :bb | bb instructionsDo: [ :instr | instr removeInstr ] ].
		send nlrIssue: true.
		^ false ].
	self prepareInlinedCode: inlinedCodeNode.
	futureSendsToInline := self extractSendsFrom: inlinedCodeNode.
	debugString := 'NLR Inlined ', self codeToInline methodClass name.
	^ true
]

{ #category : #private }
SoAbsMessageInliner >> patchEntry [
	| entry instr |
	entry := inlinedCodeNode basicBlocks first.
	[ entry firstInstr isCFGInstr ] whileFalse: [ 
		instr := entry firstInstr.
		entry firstInstr: instr nextInstr.
		instr insertBefore: prevBasicBlock lastInstr ].
	prevBasicBlock lastInstr replaceBy: entry lastInstr.
	entry successors do: [ :succ |
		succ phisDo: [ :phi |
			phi replaceBasicBlock: entry with: prevBasicBlock ].
		succ removePredecessor: entry.
		succ addPredecessor: prevBasicBlock ].
	inlinedCodeNode basicBlocks removeFirst.
	inlinedCodeNode basicBlocks do: [ :each |
		each dominator = entry ifTrue: [ each dominator: prevBasicBlock ] ].
]

{ #category : #private }
SoAbsMessageInliner >> patchReturn [
	| return returnBasicBlock instr |
	return := self getExit.
	nonLocalFlow ifTrue: [ 
		"removing dominated path may remove prevBasicBlock"
		send codeNode addBasicBlocks: inlinedCodeNode basicBlocks after: prevBasicBlock.
		^ SoDeadBranchElimination new removeDominatedPath: nextBasicBlock ].
	nextBasicBlock dominator: return basicBlock dominator.
	send replaceUsesBy: return returnedValue.
	returnBasicBlock := return basicBlock.
	[ returnBasicBlock firstInstr isCFGInstr ] whileFalse: [ 
		instr := returnBasicBlock firstInstr.
		returnBasicBlock firstInstr: instr nextInstr.
		instr insertBefore: send nextInstr ].
	returnBasicBlock lastInstr subNodesRemoveUses.
	returnBasicBlock predecessors copy do: [ :pred |
		pred lastInstr replaceSuccessor: returnBasicBlock by: nextBasicBlock ].
	inlinedCodeNode basicBlocks remove: returnBasicBlock.
	send codeNode addBasicBlocks: inlinedCodeNode basicBlocks after: prevBasicBlock.
]

{ #category : #private }
SoAbsMessageInliner >> prepareInlinedCode: code [
	{ SoReorderBasicBlocks . SoFindDominators . SoSimplifyPhis } do: [ :each | 
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

{ #category : #'non local flow' }
SoAbsMessageInliner >> removeNLR: codeNode [
	"We need to remove the send uses to be able to inline block parameters and fold more allocations.
	 But if we do that, we have other problems (difficult to restore the graph if removing the NLR fails)"
	self nlrPreparation: codeNode.
	self basicRemoveNLR: codeNode.
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

{ #category : #testing }
SoAbsMessageInliner >> singleBasicBlockInlining [
	^ (inlinedCodeNode basicBlocks size = 1 and: [ 
		inlinedCodeNode basicBlocks anyOne lastInstr isReturn
			and: [ inlinedCodeNode basicBlocks anyOne lastInstr numLevels = inlinedCodeNode returnToSenderLevel ] ])
]

{ #category : #inlining }
SoAbsMessageInliner >> singleBasicBlockPatch [
	 "If inline code node single block, hard patch the instruction instead of the send, add send dependency and return sends to inline. Faster to execute."
	| uniqueBB instr |
	uniqueBB := inlinedCodeNode basicBlocks anyOne.
	send removeAndReplaceUsesBy: uniqueBB lastInstr returnedValue.
	[ uniqueBB firstInstr isCFGInstr ] whileFalse: [ 
		instr := uniqueBB firstInstr.
		uniqueBB firstInstr: instr nextInstr.
		instr insertBefore: send nextInstr ].
	uniqueBB lastInstr subNodesRemoveUses.
	send addDependency.
	^ futureSendsToInline
	
]

{ #category : #'non local flow' }
SoAbsMessageInliner >> stillHasNLR: codeNode [
	codeNode basicBlocks do: [ :bb |
		bb instructionsDo: [ :instr | 
			(instr isBlockClosure and: [ instr hasNLR ]) ifTrue: [ ^ true ] ] ].
	^ false 
]
