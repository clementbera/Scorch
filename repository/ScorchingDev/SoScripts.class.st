"
All class side.
"
Class {
	#name : #SoScripts,
	#superclass : #Object,
	#pools : [
		'SoGenerationSetting'
	],
	#category : #'ScorchingDev-macros'
}

{ #category : #scripts }
SoScripts class >> decodeEncoderClassComment [
"To decode from Encoder class comment inline primitive:"
	self collect: [ :each | 
		(each first: 4) -> ((each copyFrom: 15 to: (40 min: each size) ) subStrings: '.') first ]
]

{ #category : #scripts }
SoScripts class >> deoptVisitor [
	SoAbsDeoptNode allSubclasses
		do: [ :e | 
			(e name beginsWith: 'SoAbs')
				ifFalse: [ e
						compile:
							'accept: visitor' , self pragmaString , String cr , String tab , '^ visitor visit'
								, (e name allButFirst: 7) , ': self'
						classified: #visiting ] ]
]

{ #category : #scripts }
SoScripts class >> dispatchPrim [
	"
	self dispatchPrim
	"

	| s |
	s := '' writeStream.
	#(#Add #Equal #Greater #GreaterOrEqual #Less #LessOrEqual #NotEqual #Size #At #Sub #BitAnd #BitOr #BitXor #ClassPrim #PointerEquals #New)
		do: [ :f | 
			s << 'prim = ' << f << ' ifTrue: [ ^ self maybe' << f << ': send ].'.
			s cr ].
	^ s contents
]

{ #category : #scripts }
SoScripts class >> displayClasses [
	"
	self displayClasses
	"

	| stream |
	stream := '' writeStream.
	SoAbsNode
		withAllSubclassesDo: [ :sub | 
			| depth c |
			depth := 0.
			c := sub.
			[ c == SoAbsNode ]
				whileFalse: [ depth := depth + 1.
					c := c superclass ].
			depth timesRepeat: [ stream tab ].
			stream << sub name.
			stream cr ].
	^ stream contents
]

{ #category : #development }
SoScripts class >> exploreText [
^ '
"Make sure your image is prepared (Check image preparation workspace first)"	
	
"Ensure the validation works (expected failures on context access)"
SoValidator new
	validateMethods: (SoValidator allMethods)
	passes: { {#optimizeCodeNode} }
	options: #(finalGraphSanity reportToTranscript ) .

"Script to recover the systems" 
CompiledMethod allInstances do: [ :each | (each isOptimized and: [ each metadata isCustomized ifNil: [ false ] ]) ifTrue: [ SoDependencyMap default uninstallMethod: each ]  ].
SoDependencyMap default debugFlushAll. 

"Enable runtime optimizations"
Smalltalk specialObjectsArray at: 59 put: #conditionalBranchCounterTrippedOn:.
"Run bench, open transcript or command line for logs"
[ 38 benchFib ] timeToRun logCr.
[ShootoutTests binarytrees: 17 to: DummyStream basicNew ] timeToRun logCr.
"Disable runtime optimization"
Smalltalk specialObjectsArray at: 59 put: nil.

"Other scripts for tests and validation"
SoValidator exPass: true.
SoValidator exPass: false.
SoValidator timeout: 1000.' 
]

{ #category : #development }
SoScripts class >> imagePreparationText [
^ '
"Disable freetype for non freetype compatible VMs, to avoid crashes and for fast VM simulation"
#(FT2Handle FreeTypeCache FreeTypeSettings) do: [ :each | 
SessionManager default unregisterClassNamed: each  ].

"Put correct value in special object array, patch mourner bug."
Smalltalk specialObjectsArray at: 60 put: #trapTripped .
Smalltalk specialObjectsArray at: 59 put: nil .
WeakArray class compile: ''primitiveFetchMourner < primitive: 172 error: ec > ^ nil'' classified: #patch .

CompilationContext bytecodeBackend: (Smalltalk at: #OpalEncoderForSistaV1 ifAbsent: [ EncoderForSistaV1 ]) .
CompilationContext usesFullBlockClosure: true.
OpalCompiler recompileAll.' 
]

{ #category : #development }
SoScripts class >> openInitialWorkspace [
	self openWorkspace: '
"Make sure your image is prepared (Check image preparation workspace first)"	
	
"Ensure the validation works (expected failures on context access)"
SoValidator new
	validateMethods: (SoValidator allMethods)
	passes: { {#optimizeCodeNode} }
	options: #(finalGraphSanity reportToTranscript ) .

"Script to recover the systems" 
CompiledMethod allInstances do: [ :each | (each isOptimized and: [ each metadata isCustomized ifNil: [ false ] ]) ifTrue: [ SoDependencyMap default uninstallMethod: each ]  ].
SoDependencyMap default debugFlushAll. 

"Enable runtime optimizations"
Smalltalk specialObjectsArray at: 59 put: #conditionalBranchCounterTrippedOn:.
"Run bench, open transcript or command line for logs"
[ 38 benchFib ] timeToRun logCr.
[ShootoutTests binarytrees: 17 to: DummyStream basicNew ] timeToRun logCr.
"Disable runtime optimization"
Smalltalk specialObjectsArray at: 59 put: nil.

"Other scripts for tests and validation"
SoValidator exPass: true.
SoValidator exPass: false.
SoValidator timeout: 1000.' title: 'Exploring Scorch'
]

{ #category : #development }
SoScripts class >> openWorkspaces [
	GTPlayground openContents: self exploreText label: 'Explore Scorch'.
	GTPlayground openContents: self imagePreparationText label: 'Image Preparation'
]

{ #category : #utils }
SoScripts class >> pragmaString [
	AddPragma ifFalse: [ ^ '' ].
	^ String cr , String tab , '<script>'
]

{ #category : #scripts }
SoScripts class >> scannerMethods [
	InstructionClient methodDict values do:[:m |
		| code pattern s |
		code := m sourceCode.
		s := '' writeStream.
		s << (pattern := (code splitOn: String cr) first).
		s << self pragmaString.
		s << (code allButFirst: pattern size).
		SoAbstractScanner 
			compile:s contents classified: #opcodes ].
]

{ #category : #utils }
SoScripts class >> script [
	"If a method has this pragma, it's generated from a class side method here."
]

{ #category : #scripts }
SoScripts class >> unsafeOp [
	| gen |
	gen := [ :safePrim :prefix | 
	| theClass |
	theClass := Smalltalk at: ('So' , prefix , safePrim , 'Op') asSymbol.
	theClass
		compile: 'safePrimitiveNumber' , self pragmaString , String cr , String tab , '^ ' , safePrim
		classified: #primitive.
	theClass
		compile: 'primitiveNumber' , self pragmaString , String cr , String tab , '^ U' , prefix , safePrim
		classified: #primitive ].
	#(#Add #BitAnd #BitOr #BitXor #Equal #Less #LessOrEqual #NotEqual)
		do: [ :safePrim | gen value: safePrim value: #Smi ].
	#(#At #AtPut #Size)
		do: [ :safePrim | #(#Byte #Pointer) do: [ :prefix | gen value: safePrim value: prefix ] ]
]
