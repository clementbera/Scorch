"
I represent an entire compiled code in the SSA Scorch form. I am created by the SSA decompiler, and I am either use as the compiled code top optimize or as a compiled code to be inlined.

basicBlocks <OrderedCollection of BasicBlock> basicBlocks of the compiled code, sorted in reverse post order after the basic block reordering pass.
bytecodeApproximateSize <Smi> value used to allow or forbid inlining of new methods to avoid bytecode zone blow up.
dependencies <Collection of selectors> selectors inlined in the method
debugInfo <OrderedCollection> used if debugging mode is enabled to trace optimizations.
compiledCode<CompiledCode> compiled code represented
decompSends <Collection of send> set at decompilation time, contains the sends present in the code at decompilation time.
backendMaxTempIndex <Smi> max temp index at code generation time
"
Class {
	#name : #SoAbsCode,
	#superclass : #SoAbsNode,
	#instVars : [
		'basicBlocks',
		'bytecodeApproximateSize',
		'dependencies',
		'debugInfo',
		'compiledCode',
		'decompSends',
		'backendMaxTempIndex',
		'inliningBonus'
	],
	#pools : [
		'SoMagicConstants'
	],
	#category : #'Scorching-Nodes'
}

{ #category : #accessing }
SoAbsCode >> addBasicBlock: bb [
	basicBlocks add: bb.
	bb codeNode: self.
	^ bb
]

{ #category : #accessing }
SoAbsCode >> addBasicBlock: bb after: existingBB [
	basicBlocks add: bb after: existingBB.
	bb codeNode: self.
	^ bb
]

{ #category : #accessing }
SoAbsCode >> addBasicBlock: bb before: existingBB [
	basicBlocks add: bb before: existingBB.
	bb codeNode: self.
	^ bb
]

{ #category : #accessing }
SoAbsCode >> addBasicBlocks: bbs after: bb1 [
	"profiler - rewritten for performance"
	| index newBasicBlocks |
	index := basicBlocks indexOf: bb1.
	"Anticipate array size"
	newBasicBlocks := OrderedCollection new: basicBlocks size + bbs size + 10.
	"Don't create intermediate collections please. "
	basicBlocks from: 1 to: index do: [ :elem | newBasicBlocks add: elem ].
	bbs do: [ :elem | 
		elem codeNode: self.
		newBasicBlocks add: elem ].
	basicBlocks from: index + 1 to: basicBlocks size do: [ :elem | newBasicBlocks add: elem ].
	basicBlocks := newBasicBlocks
]

{ #category : #accessing }
SoAbsCode >> addDependency: selector [
	dependencies add: selector
]

{ #category : #accessing }
SoAbsCode >> backendMaxTempIndex [
	<generated>
	^ backendMaxTempIndex
]

{ #category : #accessing }
SoAbsCode >> backendMaxTempIndex: aValue [
	<generated>
	backendMaxTempIndex := aValue
]

{ #category : #accessing }
SoAbsCode >> basicBlocks [
	<generated>
	^ basicBlocks
]

{ #category : #accessing }
SoAbsCode >> basicBlocks: aValue [
	<generated>
	basicBlocks := aValue
]

{ #category : #accessing }
SoAbsCode >> bytecodeApproximateSize [
	<generated>
	^ bytecodeApproximateSize
]

{ #category : #accessing }
SoAbsCode >> bytecodeApproximateSize: aValue [
	<generated>
	bytecodeApproximateSize := aValue
]

{ #category : #accessing }
SoAbsCode >> codeNode [
	^ self
]

{ #category : #accessing }
SoAbsCode >> compiledCode [
	<generated>
	^ compiledCode
]

{ #category : #accessing }
SoAbsCode >> compiledCode: aValue [
	<generated>
	compiledCode := aValue
]

{ #category : #accessing }
SoAbsCode >> debugInfo [
	<generated>
	^ debugInfo
]

{ #category : #accessing }
SoAbsCode >> debugInfo: aValue [
	<generated>
	debugInfo := aValue
]

{ #category : #accessing }
SoAbsCode >> decompSends [
	<generated>
	^ decompSends
]

{ #category : #accessing }
SoAbsCode >> decompSends: aValue [
	<generated>
	decompSends := aValue
]

{ #category : #accessing }
SoAbsCode >> dependencies [
	<generated>
	^ dependencies
]

{ #category : #accessing }
SoAbsCode >> dependencies: aValue [
	<generated>
	dependencies := aValue
]

{ #category : #accessing }
SoAbsCode >> entry [
	^ basicBlocks first
]

{ #category : #backend }
SoAbsCode >> generate [
	| optimizedCode |
	self prepareCodeGeneration.
	optimizedCode := self generateBytecodes.
	self mapDependencies: optimizedCode.
	optimizedCode metadata debugInfo: debugInfo.
	^ optimizedCode
]

{ #category : #backend }
SoAbsCode >> generateAndInstall [
	self install: self generate
]

{ #category : #backend }
SoAbsCode >> generateBytecodes [
	^ SoBytecodeTranslator new translate: self codeClass: self codeClass
]

{ #category : #initialization }
SoAbsCode >> initialize [

	super initialize.

	basicBlocks := OrderedCollection new.
	dependencies := OrderedCollection new.
	debugInfo := OrderedCollection new.
	decompSends := OrderedCollection new.
	inliningBonus := InitialInliningBonus. 
]

{ #category : #accessing }
SoAbsCode >> inliningBonus [
	^ inliningBonus
]

{ #category : #accessing }
SoAbsCode >> inliningBonus: anObject [
	inliningBonus := anObject
]

{ #category : #accessing }
SoAbsCode >> inliningBonusDecay [
	inliningBonus := inliningBonus - DecayInliningMalus
]

{ #category : #graph }
SoAbsCode >> maintainPostOrder [
	"profiler"
	1 to: basicBlocks size do: [ :i |
		(basicBlocks at: i) postOrder: i ].
]

{ #category : #backend }
SoAbsCode >> mapDependencies: optimizedMethod [
	| dependency |
	dependency := SoDependencyMap default.
	dependencies do: [ :selector |
		dependency addDependency: selector optimizedCode: optimizedMethod ].
]

{ #category : #accessing }
SoAbsCode >> numArgs [
	^ compiledCode numArgs
]

{ #category : #backend }
SoAbsCode >> prepareCodeGeneration [
	"| origin |
	origin := DateAndTime now."
	self validateGraphSanity.
	{SoReorderBasicBlocks . SoExpandAndReduce . SoSpillAnalysis . SoLivenessAnalysis . SoTempIndexAllocator} do: [ :each |
		each new runOn: self.
		"Transcript show: '[' , each name , ';', (DateAndTime now - origin) asMilliSeconds printString , 'ms]'."].
]

{ #category : #accessing }
SoAbsCode >> returnToSenderLevel [
	"level of the return node so the return goes to the active context's sender"
	self subclassResponsibility 
]
