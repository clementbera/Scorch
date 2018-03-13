"
I am able to deoptimize a stack of context. I recreate objects (in deoptObjects) and remap all the references. The blockClosure's outerContext relationship is however updated lazily, hence I also provide API to figure out the outerContext of a block depending on the BlockClosure's original outerContext status (deoptimized, optimised, normal)

	deoptObjects <Dictionary <marker-> recoveredObject>>
	optimizedContext <Context>
"
Class {
	#name : #SoDeoptimizer,
	#superclass : #SoAbsDeopt,
	#instVars : [
		'deoptObjects',
		'optimizedContext'
	],
	#classVars : [
		'RES'
	],
	#pools : [
		'SoMagicConstants'
	],
	#category : #'Scorching-Deoptimization'
}

{ #category : #public }
SoDeoptimizer >> actualOuterContext: closure process: process [
	| outer |
	outer := closure outerContext.
	outer method isOptimized ifFalse: [ ^ outer ].
	(self isDeoptimizedContext: outer) ifTrue: [ ^ self recoverDeoptOuterContext: closure ].
	outer isDead ifTrue: [ ^ self recoverDeadOuterContext: closure ].
	^ self recoverOptOuterContext: closure process: process
	
]

{ #category : #'stack deoptimization' }
SoDeoptimizer >> basicDeoptimizeContext: context [
	| deoptPoint baseContext |
	context pc = (context method initialPC + 1) ifTrue: [ ^ self initialDeopt: context ].
	optimizedContext := context.
	deoptPoint := self deoptPointForContext: context.
	self debugLog: deoptPoint.
	self materializeObjects: deoptPoint.
	baseContext := deoptObjects at: deoptPoint first marker.
	self patchSender: baseContext.
	self setOuterContextMap.
	"FileStream stdout << 'About to discard...'."
	self discardMethodIfNeeded: context method.
	"FileStream stdout << 'Discarded '."
	^ baseContext
	
	
]

{ #category : #accessing }
SoDeoptimizer >> deadOuterContextMarker [
	^ #deadOuter
]

{ #category : #'stack deoptimization' }
SoDeoptimizer >> debugLog: deoptPoint [
	[ | debug |
	debug := '(' , (deoptPoint first fixedFields at: 4) constant printString , ' ;' , (deoptPoint first fixedFields at: 2) constant printString , ')'.
	debug logCr.
	FileStream stdout << debug; cr ] on: Error do: [ 'err' logCr. FileStream stdout << 'err'. ].
]

{ #category : #accessing }
SoDeoptimizer >> deoptObjects [
	<generated>
	^ deoptObjects
]

{ #category : #accessing }
SoDeoptimizer >> deoptObjects: aValue [
	<generated>
	deoptObjects := aValue
]

{ #category : #metadata }
SoDeoptimizer >> deoptPointForContext: context [
	| deopt isDiscarded |
	"In discarded method, we are returning from a send and we need to step back by 1 bytecode (the immediate trap bytecode)"
	isDiscarded := self isDiscarded: context method.
	isDiscarded ifTrue: [ FileStream stdout << 'Discarded deopt'. Transcript << 'Discarded deopt' ].
	deopt := context method metadata deoptPointAt: context pc - isDiscarded asBit code: context method.
	deopt ifNotNil: [ ^ deopt ].
	self error: 'no deopt point at current location.'
]

{ #category : #public }
SoDeoptimizer >> deoptimizeContext: context [
	"FileStream stdout << ('deoptimizing ' , context method methodClass name , '-' , context method selector).
	Transcript << ('deoptimizing ' , context method methodClass name , '-' , context method selector) << ': '.
	FileStream stdout << (context stackOfSize: 15)."
	context method isOptimized ifFalse: [ ^ context ].
	^ self basicDeoptimizeContext: context
]

{ #category : #discarding }
SoDeoptimizer >> discardMethodIfNeeded: method [
	method metadata increaseTrapTripped.
	method metadata trapTripped >= MaxTrapTrips ifFalse: [ ^ self ].
	SoDependencyMap default discardAndUninstallOptimizedCode: method.
]

{ #category : #'outer context' }
SoDeoptimizer >> getPredecessorOf: ctxtToFind process: process [
	| ctxt |
	ctxt := process == Processor activeProcess
		ifTrue: [ thisContext ]
		ifFalse: [ process suspendedContext ].
	[ ctxt sender == ctxtToFind ] whileFalse: [ 
		ctxt sender ifNil: 
			[ self warning: 'closure has a live outer context on another process stack. Might trigger runtime problems'. 
			^ Context newForMethod: ctxtToFind method  ].
		ctxt := ctxt sender ].
	^ ctxt
]

{ #category : #'stack deoptimization' }
SoDeoptimizer >> initialDeopt: optContext [ 
	"This happens when calling a discarded method, every bytecode is trap, and the first bytecode leads to deoptimization.
	 We just need to change the context to use non optimized code."
	FileStream stdout << ' INIT DEOPT '.
	optContext privRefreshWith: optContext method metadata unoptimizedMethod.
	^ optContext
]

{ #category : #initialization }
SoDeoptimizer >> initialize [

	super initialize.

	deoptObjects := SoDeoptDictionary new.
]

{ #category : #public }
SoDeoptimizer >> isDeoptimizedContext: ctxt [
	^ ctxt receiver class == SoOuterContextMap
]

{ #category : #metadata }
SoDeoptimizer >> isDiscarded: method [
	"Check for trap bytecode at first pc"
	^ (method at: method initialPC) = 217
]

{ #category : #materialization }
SoDeoptimizer >> materializeObjects: listOfObjects [
	listOfObjects do: [ :each | deoptObjects at: each marker put: each asObjectTemplate ].
	listOfObjects do: [ :each | each accept: self ].
]

{ #category : #accessing }
SoDeoptimizer >> optimizedContext [
	<generated>
	^ optimizedContext
]

{ #category : #accessing }
SoDeoptimizer >> optimizedContext: aValue [
	<generated>
	optimizedContext := aValue
]

{ #category : #metadata }
SoDeoptimizer >> outerContextMarker: closure [
	^ closure outerContext method metadata
		blockOutersAt: closure compiledBlock 
		code: closure outerContext method
]

{ #category : #'stack deoptimization' }
SoDeoptimizer >> patchSender: baseContext [
	| ctxt |
	ctxt := baseContext.
	[ ctxt sender isNil ] whileFalse: [ ctxt := ctxt sender ].
	ctxt privSender: optimizedContext sender.
]

{ #category : #'outer context' }
SoDeoptimizer >> recoverDeadOuterContext: closure [
	closure outerContext: ((Context newForMethod: closure compiledBlock outerCode)
		method: closure compiledBlock outerCode;
		receiver: closure receiver;
		stackp: closure compiledBlock method numArgs;
		yourself).
	^ closure outerContext
]

{ #category : #'outer context' }
SoDeoptimizer >> recoverDeoptOuterContext: closure [
	| marker |
	marker := self outerContextMarker: closure.
	closure outerContext: (closure outerContext receiver map at: marker).
	^ closure outerContext
]

{ #category : #'outer context' }
SoDeoptimizer >> recoverOptOuterContext: closure process: process [
	| deoptPoint marker newBase |
	marker := self outerContextMarker: closure.
	deoptPoint := self deoptPointForContext: closure outerContext.
	(deoptPoint anySatisfy: [ :each | each marker == marker ]) ifFalse: [^ self recoverDeadOuterContext: closure ].
	self basicDeoptimizeContext: closure outerContext.
	newBase := deoptObjects at: deoptPoint first marker.
	(self getPredecessorOf: closure outerContext process: process) privSender: newBase.
	closure outerContext: (deoptObjects at: marker).
	^ closure outerContext
]

{ #category : #'stack deoptimization' }
SoDeoptimizer >> setOuterContextMap [
	"This way closure will be able to recover their outer context"
	optimizedContext instVarAt: 1 put: nil.
	optimizedContext instVarAt: 2 put: nil.
	optimizedContext receiver: (SoOuterContextMap from: deoptObjects).
	
	
]

{ #category : #materialization }
SoDeoptimizer >> visitActiveClosure: rec [
	^ optimizedContext closureOrNil 
]

{ #category : #materialization }
SoDeoptimizer >> visitConstant: cst [
	^ cst constant
]

{ #category : #materialization }
SoDeoptimizer >> visitMarker: marker [
	"nil should happen for dead outer context only"
	^ deoptObjects at: marker ifAbsent: [self deadOuterContextMarker]
]

{ #category : #materialization }
SoDeoptimizer >> visitPointerObject: obj [
	| template |
	template := deoptObjects at: obj marker.
	obj fixedFields withIndexDo: [ :each :i |
		template instVarAt: i put: (each accept: self ) ].
	obj variableFields withIndexDo: [ :each :i |
		template basicAt: i put: (each accept: self) ].
	obj theClass == FullBlockClosure ifTrue: 
		[ (template instVarAt: 1) == self deadOuterContextMarker
			ifTrue: [ self recoverDeadOuterContext: template ] ].
]

{ #category : #materialization }
SoDeoptimizer >> visitReceiver: rec [
	^ optimizedContext receiver
]

{ #category : #materialization }
SoDeoptimizer >> visitTemp: tmp [
	^ optimizedContext tempAt: tmp index 
]
