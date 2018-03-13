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
		'extraSends'
	],
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #testing }
SoBlockInliner >> canInline [
	| found |
	self flag: #TODO.	"Do something about clean blocks"
	send receiver isBlockClosure
		ifFalse: [ ^ false ].
	
	"Hackish for now -  should remove the trap on FullBlockClosure"	
	send receiver uses copy do: [ :each |
		each isTrapIfNotInstanceOf ifTrue: [ each removeInstr ] ].
	
	found := send receiver uses reject: [ :use | use isSunkObject ].
	found size = 1 ifTrue: [ ^ true ].
	^ self canInlineAll: found
]

{ #category : #private }
SoBlockInliner >> canInlineAll: uses [ 
	uses remove: send.
	1 to: uses size do: [ :i | | use |
		use := uses at: i.
		use isSend ifFalse: [ ^ false ].
		use receiver = send receiver ifFalse: [ ^ false ].
		use canBeInlined ifFalse: [ ^ false ].
		send methodToInline primitive = FullBlockClosureEvaluation ifFalse: [ ^ false ].
		(use arguments includes: send receiver) ifTrue: [ ^ false ] ].
	extraSends := uses.
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

{ #category : #accessing }
SoBlockInliner >> copiedValues [
	^ send receiver values
]

{ #category : #accessing }
SoBlockInliner >> decompilerClass [
	^ SoBlockDecompiler 
]

{ #category : #accessing }
SoBlockInliner >> extraSends [
	<generated>
	^ extraSends
]

{ #category : #accessing }
SoBlockInliner >> extraSends: aValue [
	<generated>
	extraSends := aValue
]

{ #category : #initialization }
SoBlockInliner >> initialize [

	super initialize.

	extraSends := #().
]

{ #category : #private }
SoBlockInliner >> insertTrap [
	"We know it's a closure"
]

{ #category : #accessing }
SoBlockInliner >> onlyNLR [
	^ onlyNLR
]

{ #category : #private }
SoBlockInliner >> parseInlinedCode [
	super parseInlinedCode ifFalse: [ ^ false ].
	extraSends isEmpty ifTrue: [self patchReceiver].
	^ true
	
]

{ #category : #private }
SoBlockInliner >> patchReceiver [
	"All uses but send are deopt info.
	Need to patch it to use the closure to recreate instead of expecting the closure to be created at runtime"
	| toPatch |
	toPatch := send receiver uses select: [ :each | each ~~ send ].
	toPatch do: [ :sunkObj |
		sunkObj replaceSubNode: send receiver by: self sunkClosure marker.
		sunkObj node deoptInfo sunkObjects 
			detect: [ :so | so marker == self sunkClosure marker ] 
			ifNone: [ sunkObj node deoptInfo addSunkObject: self sunkClosure copy ] ].
	send receiver removeInstr.
]

{ #category : #accessing }
SoBlockInliner >> receiver [
	^ send receiver receiver
]

{ #category : #accessing }
SoBlockInliner >> sunkClosure [
	^ sunkClosure ifNil: [ sunkClosure := send receiver asSunkClosure ]
]

{ #category : #accessing }
SoBlockInliner >> sunkClosure: aValue [
	<generated>
	sunkClosure := aValue
]
