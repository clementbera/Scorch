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
		'SoMagicConstants',
		'SoOptimizationSettingConstants'
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
SoOptimizer >> passes [
	^ ActiveO
]

{ #category : #private }
SoOptimizer >> postponeOptimization [
	self flag: #TODO.
	'TimeOut' logCr.
]

{ #category : #private }
SoOptimizer >> uncheckedOptimize: contextTripping [
	codeNode := self getFirstCodeNode: contextTripping.
	self passes do: [ :pass | 
		pass new runOn: codeNode.
		"Transcript show: '[' , pass name , ';', (DateAndTime now - origin) asMilliSeconds printString , 'ms]'; cr." ].
	codeNode generateAndInstall.
	"Transcript show: 'Opt done in: ' , (DateAndTime now - origin) asMilliSeconds printString , 'ms - '."
	"contextTripping method markOptimizedBit."
	codeNode compiledCode markOptimizedBit.
	
]
