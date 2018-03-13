"
I am a specific inliner version for methods. The main difference compared to my superclass is that I implement multiple heuristic to guess if I should inline or not.
"
Class {
	#name : #SoMethodInliner,
	#superclass : #SoAbsMessageInliner,
	#instVars : [
		'debugString'
	],
	#pools : [
		'SoMagicConstants',
		'SoMemoryManagerConstants'
	],
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #heuristic }
SoMethodInliner >> canInline [
	| methodToInline |
	methodToInline := self codeToInline.
	(self isPossibletoInline: methodToInline) ifFalse: [ ^ false ].
	^ self depthAllowinlining: methodToInline
	
]

{ #category : #heuristic }
SoMethodInliner >> checkForRecursion: method [
	^ (send deoptInfo sunkObjects count: [ :each |
		(each theClass == ContextClass) and: [ (each fixedFields at: 4) constant == method] ]) <= MaxRecursion
]

{ #category : #accessing }
SoMethodInliner >> codeToInline [
	^ send methodToInline
]

{ #category : #accessing }
SoMethodInliner >> debugString [
	<generated>
	^ debugString
]

{ #category : #accessing }
SoMethodInliner >> debugString: aValue [
	<generated>
	debugString := aValue
]

{ #category : #accessing }
SoMethodInliner >> decompilerClass [
	^ SoMethodDecompiler 
]

{ #category : #heuristic }
SoMethodInliner >> depthAllowinlining: methodToInline [
	
	"Can't inline if too far: else dynamic deoptimization may end freaking slow"
	send deoptInfo depth < MaxInliningDepth ifFalse: [ 
		debugString := 'deep stack'.
		^ false ].
	"Don't inline too much a method in itself"
	(self checkForRecursion: methodToInline) ifFalse: [ 
		debugString := 'deep recursion'.
		^ false].
	^ true
	
]

{ #category : #heuristic }
SoMethodInliner >> isPossibletoInline: methodToInline [
	"Is the method marked as cant be inlined"
	methodToInline allowRuntimeOptimizations ifFalse: [ 
		debugString := 'noRuntimeOpt'.
		^ false ].
	"Can't inline primitives in the default inliner. Should use other passes."
	methodToInline primitive > 0 ifTrue: [ 
		methodToInline isQuick ifFalse: [ 
			debugString := 'primitive'.
			^ false ] ].
	^ true
]

{ #category : #'private - parsing' }
SoMethodInliner >> parseInlinedCode [
	| r |
	r := super parseInlinedCode.
	debugString := r 
		ifTrue: ['Inlined (' , self codeToInline printString , ')']
		ifFalse: ['Parsing error'].
	^ r
]

{ #category : #'private - parsing' }
SoMethodInliner >> parseNLRInlinedCode [
	| r |
	r := super parseNLRInlinedCode.
	debugString := r 
		ifTrue: ['Inlined With NLR (' , self codeToInline printString , ')'.
				send codeNode debugInfo addAll: inlinedCodeNode debugInfo ]
		ifFalse: ['Parsing error'].
	^ r
]

{ #category : #accessing }
SoMethodInliner >> receiver [
	^ send receiver
]
