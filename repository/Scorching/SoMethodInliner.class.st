"
I am a specific inliner version for methods. The main difference compared to my superclass is that I implement multiple heuristic to guess if I should inline or not.
"
Class {
	#name : #SoMethodInliner,
	#superclass : #SoAbsMessageInliner,
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
	(self shouldInline: methodToInline) ifFalse: [ ^ false ].
	(self isPossibletoInline: methodToInline) ifFalse: [ ^ false ].
	^ self depthAllowinlining: methodToInline
	
]

{ #category : #heuristic }
SoMethodInliner >> checkForRecursion: method [
	^ (send deoptInfo sunkObjects count: [ :each |
		"method field"
		(each theClass == ContextClass) and: [ (each fixedFields at: 4) constant == method] ]) <= MaxRecursion
]

{ #category : #accessing }
SoMethodInliner >> codeToInline [
	^ send methodToInline
]

{ #category : #'private - parsing' }
SoMethodInliner >> contextAccessInlining [
	(self codeToInline hasPragmaNamed: #scorchSignal) ifTrue: [ self inlineExceptionSignal ].
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
SoMethodInliner >> inlineSizeWithBonus [
	| bonus |
	bonus := 0.
	"Constant folding / Allocation folding / Closure inlining bonus"
	send subNodesDo: [ :sub |
		sub isNew ifTrue: [ bonus := bonus + EscapeInliningBonus ].
		sub isConstant ifTrue: [ bonus := bonus + ConstantInliningBonus ].
		sub isBlockClosure ifTrue: [ bonus := bonus + ClosureInliningBonus ] ].
	"Loop depth bonus"
	bonus := bonus +  (LoopDepthInliningBonus * (send loopDepth - 1)).
	"initial/decay bonus/malus"
	bonus := bonus + (send codeNode inliningBonus // 10 max: AlwaysInlineSize).
	"Used in big arrays - kills compilation performance - temporary hack - need to see what we do later."
	send selector = #nextPut: ifTrue: [ bonus := bonus - 999 ].
	^ bonus
]

{ #category : #heuristic }
SoMethodInliner >> isPossibletoInline: methodToInline [
	"Is the method marked as cant be inlined"
	methodToInline allowRuntimeOptimizations ifFalse: [ 
		debugString := 'noRuntimeOpt'.
		^ false ].
	^ true
]

{ #category : #accessing }
SoMethodInliner >> receiver [
	^ send receiver
]

{ #category : #heuristic }
SoMethodInliner >> shouldInline: method [
	| allowInliningUpToSize methodToInline toInline |
	methodToInline := send methodToInline.
	allowInliningUpToSize := self inlineSizeWithBonus.
	toInline := methodToInline isOptimized 
		ifTrue: [methodToInline metadata unoptimizedMethod]
		ifFalse: [methodToInline].
	debugString := 'should inline if ' , toInline bytecodeSize printString , ' <= ' , allowInliningUpToSize printString .
	^ toInline bytecodeSize <= allowInliningUpToSize	 
]
