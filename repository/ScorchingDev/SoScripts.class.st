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
SoScripts class >> bytecodeReftranslator [
	{SoClassOp.
	SoCreateArray.
	SoSend.
	SoCreateContextFullBlock.
	SoCreateFullBlock.
	SoCreateTempVect.
	SoPointerEqualsOp}
		do: [ :each | 
			SoBytecodeReferenceTranslator
				compile:
					'traverse' , (each name allButFirst: 2) , ': node' , self pragmaString
						, String cr , String tab , 'node backend gen' , (each name allButFirst: 2)
						, 'Reference: node with: builder'
				classified: #traversing ].
			
	{ SoGlobal . SoMutableLiteral . SoInstVar . SoContextInstVar . SoRemoteTemp } do: [ :each |
		SoBytecodeReferenceTranslator
				compile:
					'traverse' , (each name allButFirst: 2) , ': node' , self pragmaString
						, String cr , String tab , 'node backend gen' , (each name allButFirst: 2)
						, 'ReadReference: node with: builder'
				classified: #traversing ]
]

{ #category : #scripts }
SoScripts class >> bytecodetranslator [
	{SoClassOp.
	SoCreateArray.
	SoCreateContextFullBlock.
	SoCreateFullBlock.
	SoCreateTempVect.
	SoPointerEqualsOp}
		do: [ :each | 
			SoBytecodeTranslator
				compile:
					'traverse' , (each name allButFirst: 2) , ': node' , self pragmaString
						, String cr , String tab , 'node backend gen' , (each name allButFirst: 2)
						, ': node with: builder'
				classified: #traversing ].
			
	{ SoGlobal . SoMutableLiteral . SoInstVar . SoContextInstVar . SoRemoteTemp } do: [ :each |
		SoBytecodeTranslator
				compile:
					'traverse' , (each name allButFirst: 2) , ': node' , self pragmaString
						, String cr , String tab , 'node isWrite ifTrue: [^ node backend gen' , (each name allButFirst: 2)
						, 'Write: node with: builder].' , String cr , String tab , 'node backend gen' , (each name allButFirst: 2)
						, 'Read: node with: builder'
				classified: #traversing ]
]

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

{ #category : #scripts }
SoScripts class >> effect [
	{ SoClassOp . SoCreateArray . SoCreateContextFullBlock . SoCreateFullBlock . SoCreateTempVect . SoPointerEqualsOp . SoPhi } do: [ :each |
	SoEffect compile: 'gen' , (each name allButFirst: 2) , ': node with: builder', self pragmaString , String cr , String tab , '"effect free"' classified: #'bytecode generation'].

	{ SoGlobal . SoMutableLiteral . SoInstVar . SoContextInstVar . SoRemoteTemp } do: [ :each |
		SoEffect
				compile:
					'gen' , (each name allButFirst: 2), 'Write: node with: builder' , self pragmaString
						, String cr , String tab , 'builder genPopInto' , (each name allButFirst: 2) , ': node'
				classified: #'bytecode generation'.
		SoEffect
				compile:
					'gen' , (each name allButFirst: 2), 'Read: node with: builder' , self pragmaString
						, String cr , String tab , '"effect-free, nothing"'
				classified: #'bytecode generation'.
		 ]
]

{ #category : #development }
SoScripts class >> openInitialWorkspace [
	GTPlayground openContents: '"Step 1: image recompilation with new bytecode set"
CompilationContext bytecodeBackend: OpalEncoderForSistaV1 .
CompilationContext usesFullBlockClosure: true .
OpalCompiler recompileAll.

"Step 2: ensure the validation works (expected 4 failures on context access)"
SoValidator new
	validateMethods: SoValidator allExamples
	passes: #(O0 O1 #O1b O2)
	options: #( graphSanity comparison reportToTranscript ) .

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
SoScripts class >> openLoadingWorkspace [
	GTPlayground openContents: '#(FT2Handle FreeTypeCache FreeTypeSettings) do: [ :each | 
	SessionManager default unregisterClassNamed: each  ].

Smalltalk specialObjectsArray at: 60 put: #trapTripped .
 Smalltalk specialObjectsArray at: 59 put: nil .
 WeakArray class compile: ''primitiveFetchMourner < primitive: 172 error: ec > ^ nil'' classified: #patch .
 
ConfigurationOfScorch loadBleedingEdge.

SoScripts openInitialWorkspace.

CompilationContext bytecodeBackend: OpalEncoderForSistaV1 .
 CompilationContext usesFullBlockClosure: true.
 OpalCompiler recompileAll.
 Transcript clear.
 Transcript open.
 SoValidator new 
	validateMethods: SoValidator allExamples 
	passes: #(O2) 
	options: #( graphSanity reportToTranscript ).' 
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
SoScripts class >> spill [
	{SoClassOp.
	SoSend.
	SoCreateArray.
	SoCreateContextFullBlock.
	SoCreateFullBlock.
	SoCreateTempVect.
	SoPointerEqualsOp}
		do: [ :each | 
			SoSpill
				compile:
					'gen' , (each name allButFirst: 2) , ': node with: builder' , self pragmaString , String cr
						, String tab , '"gen on reference"'
				classified: #'bytecode generation' ].
	{SoClassOp.
	SoSend.
	SoCreateArray.
	SoCreateContextFullBlock.
	SoCreateFullBlock.
	SoCreateTempVect.
	SoPointerEqualsOp}
		do: [ :each | 
			SoSpill
				compile:
					'gen' , (each name allButFirst: 2) , 'Reference: node with: builder' , self pragmaString
						, String cr , String tab , 'builder gen' , (each name allButFirst: 2) , ': node'
				classified: #'bytecode generation' ].
	{ SoGlobal . SoMutableLiteral . SoInstVar . SoContextInstVar . SoRemoteTemp } do: [ :each |
		SoSpill
				compile:
					'gen' , (each name allButFirst: 2), 'Read: node with: builder' , self pragmaString
						, String cr , String tab , '"gen on reference"'
				classified: #'bytecode generation'.
		SoSpill
				compile:
					'gen' , (each name allButFirst: 2), 'ReadReference: node with: builder' , self pragmaString
						, String cr , String tab , 'builder genPush' ,  (each name allButFirst: 2) , ': node'
				classified: #'bytecode generation'.
		 ]
]

{ #category : #scripts }
SoScripts class >> temp [
	{SoClassOp.
	SoCreateArray.
	SoCreateContextFullBlock.
	SoCreateFullBlock.
	SoCreateTempVect.
	SoPointerEqualsOp.
	SoPhi}
		do: [ :each | 
			SoTemp
				compile:
					'gen' , (each name allButFirst: 2) , 'Reference: node with: builder' , self pragmaString
						, String cr , String tab , 'builder genPushTemp: tempIndex'
				classified: #'bytecode generation' ].
	{SoClassOp.
	SoCreateArray.
	SoCreateContextFullBlock.
	SoCreateFullBlock.
	SoCreateTempVect.
	SoPointerEqualsOp.
	SoPhi}
		do: [ :each | 
			SoTemp
				compile:
					'gen' , (each name allButFirst: 2) , ': node with: builder' , self pragmaString , String cr
						, String tab , 'builder gen' , (each name allButFirst: 2) , ': node.' , String cr
						, String tab , 'builder genPopIntoTemp: tempIndex'
				classified: #'bytecode generation' ].
	{ SoGlobal . SoMutableLiteral . SoInstVar . SoContextInstVar . SoRemoteTemp } do: [ :each |
		SoTemp
				compile:
					'gen' , (each name allButFirst: 2), 'Read: node with: builder' , self pragmaString
						, String cr , String tab , 'builder genPush' ,  (each name allButFirst: 2) , ': node.',
						String cr , String tab , 'builder genPopIntoTemp: tempIndex'
				classified: #'bytecode generation'.
		SoTemp
				compile:
					'gen' , (each name allButFirst: 2), 'ReadReference: node with: builder' , self pragmaString
						, String cr , String tab , 'builder genPushTemp: tempIndex'
				classified: #'bytecode generation'.
		 ]
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
