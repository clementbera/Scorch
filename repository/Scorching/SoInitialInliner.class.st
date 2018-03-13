"
I attempt to inline all the call graph at the beginning of the optimisation process so the optimiser has something to deal with. My main difference with my subclasses is that I can start from the sends found at decompilation time.

sends <OrderedCollection of Send> sends to inline (not processed yet) 

"
Class {
	#name : #SoInitialInliner,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'sends'
	],
	#pools : [
		'SoMagicConstants'
	],
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #'inlining sends' }
SoInitialInliner >> addNewSends: newSends [
	newSends ifEmpty: [ ^ self ].
	sends addAllFirst: newSends.
	"sends sort: [ :a :b | a loopDepth >= b loopDepth ]
	 Too much time wasted sorting - for nothing"
]

{ #category : #'inlining sends' }
SoInitialInliner >> basicInline: send [
	"Answers the inlined sends to be reprocessed for additional inlining."
	| prim |
	prim := send methodToInline primitive.
	^ (prim = 0 or: [ send methodToInline isQuick ])
		ifTrue: [ self inlineMethod: send ]
		ifFalse: [ 
			prim = 207
				ifTrue: [ self inlineFullBlock: send ]
				ifFalse: [ self inlinePrimitiveMethod: send ] ]
]

{ #category : #accessing }
SoInitialInliner >> extraBonus [
	^ InitialInliningBonus
]

{ #category : #initialization }
SoInitialInliner >> initialize [

	super initialize.

	sends := OrderedCollection new.
]

{ #category : #'inlining sends' }
SoInitialInliner >> inline: send [
	"Answers the inlined sends to be reprocessed for additional inlining."
	send canBeInlined ifFalse: [ SoPICInliner new maybePICInlining: send. ^ #() ].
	^ self basicInline: send
]

{ #category : #'inlining sends' }
SoInitialInliner >> inline: send withInliner: inliner [
	| futureSends |
	futureSends := inliner inline: send.
	inliner lastInliningWasSuccessful 
		ifTrue: [ 
			send codeNode inliningBonusDecay.
			inliner nonLocalFlow ifTrue: [ self removeDeadSendsException: send basicBlock ] ].
	^ futureSends
]

{ #category : #'inlining sends' }
SoInitialInliner >> inlineFullBlock: send [
	| futureSends inliner blockSends |
	inliner := SoBlockInliner new.
	blockSends := send receiver uses select: [ :each | each isSend ].
	futureSends := inliner inline: send.
	"It may inline all sends."
	inliner lastInliningWasSuccessful 
		ifTrue: [
			blockSends do: [ :each | (sends includes: each) ifTrue: [ sends remove: each ] ].
			inliner nonLocalFlow ifTrue: [ self removeDeadSendsNLR ] ].
	^ futureSends
]

{ #category : #'inlining sends' }
SoInitialInliner >> inlineMethod: send [
	^ self inline: send withInliner: SoMethodInliner new 
]

{ #category : #'inlining sends' }
SoInitialInliner >> inlinePrimitiveMethod: send [
	^ self inline: send withInliner: SoPrimitiveInliner new
]

{ #category : #public }
SoInitialInliner >> inlineSends: sendToProcess [	
	sendToProcess ifEmpty: [ ^ self ].
	self addNewSends: sendToProcess.
	self processSends.
	sendToProcess first codeNode maintainPostOrder.
]

{ #category : #'inlining sends' }
SoInitialInliner >> maybeAddNewSends: newSends [
	self addNewSends: (newSends reject: [ :send | sends includes: send ]).
]

{ #category : #'inlining sends' }
SoInitialInliner >> processSends [
	[sends isEmpty] whileFalse: [self addNewSends: (self inline: sends removeFirst)].
]

{ #category : #'inlining sends' }
SoInitialInliner >> removeDeadSendsException: basicBlock [
	"A bit hackish... Inlining exceptions can sometimes lead to dead sends..."
	| bbs |
	sends ifEmpty: [ ^ self ].
	bbs := sends first codeNode basicBlocks asSet. "Set for performance"
	sends copy do: [ :s |
		s basicBlock = basicBlock 
			ifTrue: [ sends remove: s ]
			ifFalse: [(bbs includes: s basicBlock) ifFalse: [ sends remove: s ] ] ]
]

{ #category : #'inlining sends' }
SoInitialInliner >> removeDeadSendsNLR [
	| bbs |
	"A bit hackish... Inlining NLR can sometimes lead to dead sends..."
	sends ifEmpty: [ ^ self ].
	bbs := sends first codeNode basicBlocks.
	sends copy do: [ :s |
		(bbs includes: s basicBlock) ifFalse: [ sends remove: s ] ]
]

{ #category : #public }
SoInitialInliner >> runOn: codeNode [
	"Should be run right after decompilation."
	self inlineSends: codeNode decompSends
]

{ #category : #accessing }
SoInitialInliner >> sends [
	<generated>
	^ sends
]

{ #category : #accessing }
SoInitialInliner >> sends: aValue [
	<generated>
	sends := aValue
]
