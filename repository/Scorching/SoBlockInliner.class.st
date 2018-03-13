"
I am a specific inliner version for closures. I have 3 main differences:
- the code to parse is taken from the block (receiver of value message) and not from the method inlined.
- copied Values and receiver needs to be taken from the block and not from the stack
- I need to correctly update the closure deoptimisation information so the closure can be recreated at deoptimisation time.
"
Class {
	#name : #SoBlockInliner,
	#superclass : #SoAbsMessageInliner,
	#instVars : [
		'sunkClosure',
		'extraSend'
	],
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #testing }
SoBlockInliner >> canInline [
	| found |
	self flag: #TODO.	"Do something about clean blocks"
	send receiver isBlockClosure
		ifFalse: [ debugString := 'receiver not a closure'. ^ false ].
	
	found := send receiver uses reject: [ :use | use isSunkObject ].
	found size = 1 ifTrue: [ debugString := 'inline block'.^ true ].
	^ self canInlineAll: found
]

{ #category : #testing }
SoBlockInliner >> canInlineAll: uses [ 
	uses remove: send.
	debugString := 'multi-inline failure'.
	1 to: uses size do: [ :i | | use |
		use := uses at: i.
		use isSend ifFalse: [ ^ false ].
		use receiver = send receiver ifFalse: [ ^ false ].
		use canBeInlined ifFalse: [ ^ false ].
		send methodToInline primitive = 207 ifFalse: [ ^ false ].
		(use arguments includes: send receiver) ifTrue: [ ^ false ] ].
	debugString := 'multi-inline success'.
	extraSend := uses anyOne.
	^ true
]

{ #category : #accessing }
SoBlockInliner >> closure [
	^ send receiver
]

{ #category : #private }
SoBlockInliner >> codeToInline [
	^ send receiver compiledCode
]

{ #category : #private }
SoBlockInliner >> contextAccessInlining [
	self sunkClosure subNodesRemoveUses
]

{ #category : #accessing }
SoBlockInliner >> copiedValues [
	^ send receiver values
]

{ #category : #accessing }
SoBlockInliner >> decompilerClass [
	^ SoBlockDecompiler 
]

{ #category : #accessing }
SoBlockInliner >> extraSend [
	<generated>
	^ extraSend
]

{ #category : #accessing }
SoBlockInliner >> extraSend: aValue [
	<generated>
	extraSend := aValue
]

{ #category : #private }
SoBlockInliner >> insertTrap [
	"We know it's a closure"
]

{ #category : #private }
SoBlockInliner >> parseInlinedCode [
	super parseInlinedCode ifFalse: [ ^ false ].
	extraSend
		ifNil: [self patchReceiver]
		ifNotNil: [self patchExtraSend].
	^ true
	
]

{ #category : #private }
SoBlockInliner >> patchExtraSend [
	"We need to inline the extra sends right now. The next inliner will recursively call another inliner 
	 until no send is left, reusing the same sunkClosure to preserve closure identity at deoptimisation time.
	 nonLocal flow will be set by the current block inlininer,  but we need to add all the other sends to inline. "
	send receiver removeUse: send.
	futureSendsToInline addAll: (SoBlockInliner new
		sunkClosure: self sunkClosure;
	 	inline: extraSend).
	send receiver addUse: send.
]

{ #category : #private }
SoBlockInliner >> patchReceiver [
	"All uses but send are deopt info.
	Need to patch it to use the closure to recreate instead of expecting the closure to be created at runtime"
	| toPatch |
	toPatch := send receiver uses select: [ :each | each ~~ send ].
	toPatch do: [ :sunkObj |
		sunkObj replaceSubNode: send receiver by: self sunkClosure marker.
		sunkObj uses do: [ :deoptInfo |
			deoptInfo sunkObjects 
				detect: [ :so | so marker == self sunkClosure marker ] 
				ifNone: [ deoptInfo addSunkObject: self sunkClosure ] ] ].
	send receiver removeInstr.
	self sunkClosure uses ifEmpty: [ self sunkClosure subNodesRemoveUses ].
]

{ #category : #accessing }
SoBlockInliner >> receiver [
	^ send receiver receiver
]

{ #category : #accessing }
SoBlockInliner >> sunkClosure [
	"Creating the sunk closure has def-use side-effects"
	^ sunkClosure ifNil: [ sunkClosure := send receiver asSunkClosure ]
]

{ #category : #accessing }
SoBlockInliner >> sunkClosure: aValue [
	<generated>
	sunkClosure := aValue
]
