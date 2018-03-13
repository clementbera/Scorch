"
I am the interface to the optimization infrastructure.

Basically, I take a context as input, and based on it I choose a method to optimise and a class where to install it, I optimise it and install it.


"
Class {
	#name : #SoOptimizer,
	#superclass : #Object,
	#instVars : [
		'origin',
		'codeNode'
	],
	#pools : [
		'SoMagicConstants'
	],
	#category : #'Scorching-Pass-FrontEnd'
}

{ #category : #private }
SoOptimizer >> basicOptimizedContext: context [
	"('Attempt to optimize: ' , context method printString , ' with rcvrClass: ' , context receiver class name) logCr."
	origin := DateAndTime now.
	[ [ self uncheckedOptimize: context ]
		valueWithin: TimeBeforePostponing
		onTimeout: [ 
				context method markOptimizedBit.
				^ self postponeOptimization ] ]
			on: Error, Warning 
			do: [ :ex | 
					ex class = MessageNotUnderstood ifTrue: [ ex pass ].
					"ex class = SoStackSearchError ifTrue: [ (context stackOfSize: 15) logCr ]."
					Transcript show: ('Failure for ' , context method printString , '. ' , ex class name , ': ' , ex messageText , ' | in ' , ex signalerContext method printString); cr.
					FileStream stdout << ('Failure for ' , context method printString , '. ' , ex class name , ': ' , ex messageText , ' | in ' , ex signalerContext method printString).
					FileStream stdout cr.
					"Cant be optimized, usually SoStackSearchError"
					^ context method markOptimizedBit. ].
]

{ #category : #'private- opt' }
SoOptimizer >> cfgPhase [
	"cfg super phase with optimisations on loops. Needs to be improved..."
	self run: SoLICM.
	SoGoldLoopOptimiser new runOn: codeNode retryAfter: [self corePhase].
	SoDiamondOptimiser new runOn: codeNode untilFixedPointOrRetryAfter: [ self corePhase ].
	
]

{ #category : #accessing }
SoOptimizer >> codeNode [
	<generated>
	^ codeNode
]

{ #category : #accessing }
SoOptimizer >> codeNode: aValue [
	<generated>
	codeNode := aValue
]

{ #category : #'private- opt' }
SoOptimizer >> corePhase [
	"Core optimisation super phase : requires inlining and other optimisations to perform well,
	 Does simple clean-ups and canonicalizations"
	{SoSubexpressionElimination.
	 SoInliner .
	 SoDeadBranchElimination .
	 SoEscapeOptimisation .
	 SoBranchSplitter .
	 SoSubexpressionElimination . "Twice because so important"
	 SoDeadCodeElimination } do: [ :pass | self run: pass ]
]

{ #category : #'private- opt' }
SoOptimizer >> eSSADuring: aBlock [
	SoExtendSSA new extendSSAFor: codeNode during: aBlock
]

{ #category : #'private- opt' }
SoOptimizer >> eSSAPhase [
	"e-SSA optimisation super phase : specialized on range analysis.
	 Also performs sparse conditional and swapping of comparison to enable more range optimisations"
	self eSSADuring: [ 
		self corePhase.
		self run: SoSparseConditionalAndSwap ].
	self eSSADuring: [ self corePhase ].
]

{ #category : #private }
SoOptimizer >> getFirstCodeNode: ctxtTripping [
	| ctxt |
	ctxt := SoStackSearcher new searchCodeToOptimize: ctxtTripping.
	self assert: ctxt method class == CompiledMethod. "We don't support block here right now"
	codeNode := SoMethodDecompiler decompile: ctxt method context: ctxt.
	{SoReorderBasicBlocks . SoFindDominators . SoSimplifyPhis} do: [ :each |
		each new runOn: codeNode ].
	^ codeNode
]

{ #category : #'private- opt' }
SoOptimizer >> initialInliningPhase [
	"Super phase :  inlining with extra bonus so the optimizer have something to work with."
	self run: SoInitialInliner.
	"we do some clean-ups to avoid future pass to deal with dead code / too many deopt info."
	self run: SoSubexpressionElimination.
	self run: SoDeadBranchElimination 
]

{ #category : #'private- opt' }
SoOptimizer >> optimizeCodeNode [
	"Current standard planning. Need better loop phases. Need to investigate more which pass cost and which does not."
	self initialInliningPhase.
	self corePhase.
	self eSSAPhase.
	self cfgPhase.
	self eSSAPhase.
	self cfgPhase.
	self corePhase.
]

{ #category : #public }
SoOptimizer >> optimizeContext: context [ 
	"FileStream stdout cr.
	FileStream stdout << context method printString << ' tripping '."
	context method isGloballyOptimized ifTrue: [ ^ self ].
	context method hasNoCounterBit ifTrue: [ ^ self ]. 
	Transcript show: 'Counter tripped in ' , context method printString; cr.
	self basicOptimizedContext: context.
]

{ #category : #accessing }
SoOptimizer >> origin [
	<generated>
	^ origin
]

{ #category : #accessing }
SoOptimizer >> origin: aValue [
	<generated>
	origin := aValue
]

{ #category : #private }
SoOptimizer >> postponeOptimization [
	self flag: #TODO.
	'TimeOut' logCr.
]

{ #category : #'private- opt' }
SoOptimizer >> run: optClass [
	optClass new runOn: codeNode
]

{ #category : #private }
SoOptimizer >> uncheckedOptimize: contextTripping [
	codeNode := self getFirstCodeNode: contextTripping.
	self optimizeCodeNode.
	codeNode generateAndInstall.
	codeNode compiledCode markOptimizedBit.
	
]
