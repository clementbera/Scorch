"
I take a context and examine its callers until I find the best context to optimize in the caller chain and answer the method of that context. If I don't find anything to optimize I raise a SearchError.

My strategy is as follow:
- I walk up the stack from the bottom context.  For each context, if I can optimize it, I add it to the contextsFound list.
- When I reach DefaultContextDistance, I stop as soon as the current context can be optimized, when I reach MaxHomeContextDistance, I stop in any case.
- A context is suitable for optimization if it is a method context, all block activations can be inlined up to their senders and the method to optimize is not marked as cannot be optimized.
- For each sender, I try to see if it's a better candidate for optimization. If it' not the case I stop searching.

contextsToFind <Set of Context> contexts we need to have in the list of context to optimize or we can't perform the optimizations. Typically, this includes the home context of block context. It can also includes other context related to heuristic on method reoptimization.

contextsFound <OrderedCollection of Context> contexts which methods are suitable for optimizations. The last one is the context further away from the current context and is the one selected for optimizations.
"
Class {
	#name : #SoStackSearcher,
	#superclass : #Object,
	#instVars : [
		'contextsToFind',
		'contextsFound'
	],
	#pools : [
		'SoMagicConstants',
		'SoSpecialSelectorConstants'
	],
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #testing }
SoStackSearcher >> canStopSearchingAt: context [
	context method hasNoCounterBit ifTrue: [ 
		"this method was already deoptimized because of optimization problems 
		 so we should look deeper on stack" 
		^ false ].
	context method isGloballyOptimized ifTrue: [ ^ false ].
	"There is a home context missing or a method to reoptimize"
	^ contextsToFind isEmpty
	
	
]

{ #category : #accessing }
SoStackSearcher >> contextsFound [
	<generated>
	^ contextsFound
]

{ #category : #accessing }
SoStackSearcher >> contextsFound: aValue [
	<generated>
	contextsFound := aValue
]

{ #category : #accessing }
SoStackSearcher >> contextsToFind [
	<generated>
	^ contextsToFind
]

{ #category : #accessing }
SoStackSearcher >> contextsToFind: aValue [
	<generated>
	contextsToFind := aValue
]

{ #category : #private }
SoStackSearcher >> findContextStackToOptimize: currentContext depth: depth [
	| sender |
	sender := currentContext sender.
	"May the next context be better ? If not, we pick this one"
	(self hasSenderWorthOptimizing: currentContext) ifFalse: [ ^ self ].
	"Update the home."
	self manageHomeContext: sender.
	"We can't search too deep. Finish now if deep enough"
	depth >= MaxHomeContextDistance ifTrue: [ ^ self ].
	"If we can't optimize the current method, go one depth further."
	(self canStopSearchingAt: sender) ifFalse: [ ^ self findContextStackToOptimize: sender depth: depth + 1 ].
	"This context is valid for optimization."
	contextsFound add: sender.
	"If there are closure we may look further"
	(self shouldStopSearchingAt: sender) ifFalse: [ ^ self findContextStackToOptimize: sender depth: depth + 1 ].
	"We can look further. We're still very close to the tripping context."
	^ self findContextStackToOptimize: sender depth: depth + 1
	
	
	
	
]

{ #category : #testing }
SoStackSearcher >> hasSenderWorthOptimizing: currentContext [
	currentContext sender ifNil: [^ false].
	"Currently the optimizer can't really deal with VM call-back. We may reconsider for DNUs later."
	(VMCallBackSelectors includes: currentContext method selector) ifTrue: [^ false].
	"The call is through a primitive failure fall-back code. The optimizer can't deal with this case right now.
	 This can't be a quick primitive (it's a sender)"
	(currentContext method primitive > 0) ifTrue: [^false].
	^ self methodAllowOptimizations: currentContext sender method
]

{ #category : #initialization }
SoStackSearcher >> initialize [

	super initialize.

	contextsToFind := Set new.
	contextsFound := OrderedCollection new.
]

{ #category : #private }
SoStackSearcher >> manageHomeContext: currentContext [
	"If we meet a block context we need to inline it up to its home or not inline it at all"
	contextsToFind add: currentContext home.
	contextsToFind remove: currentContext ifAbsent: nil.
]

{ #category : #testing }
SoStackSearcher >> methodAllowOptimizations: method [
	"We don't optimize:
	- method already optimized
	- method with no RuntimeOptimization pragma
	- DoIt methods"
	method selector isDoIt ifTrue: [ ^ false ].
	method isGloballyOptimized ifTrue: [ ^ false ].
	method hasNoCounterBit ifTrue: [ ^ false ]. "in case of cusomisation"
	^ method allowRuntimeOptimizations
]

{ #category : #public }
SoStackSearcher >> searchCodeToOptimize: context [
	"We can't optimize anything in that case."
	(self methodAllowOptimizations: context method) ifFalse: [ self searchError: 'cant optimize first context' ].
	self manageHomeContext: context.
	"If everything fail, optimize the bottom context."
	context isBlockContext ifFalse: [ contextsFound add: context ].
	self findContextStackToOptimize: context depth: 1.
	contextsFound ifEmpty: [ self searchError: 'No method to optimize found' ].
	^ contextsFound last
]

{ #category : #private }
SoStackSearcher >> searchError: string [
	SoStackSearchError signal: string
	
]

{ #category : #testing }
SoStackSearcher >> shouldStopSearchingAt: context [
	"If there are full block it is likely that another method higher on tack is better suited for optimisations"
	(context objectClass: context receiver) = FullBlockClosure ifTrue: [ ^ false ]. 
	1 to: context method numArgs do: [ :i |
		(context objectClass: (context tempAt: i)) = FullBlockClosure ifTrue: [ ^ false ] ].
	^ true
	
]
