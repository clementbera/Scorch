"
Validates the graph for a given method and a set of passes. What to validate is specified as options.

Example:
SoValidator new
	validateMethods: {SoExamples >> #exampleAdd}
	passes: #(O0 ""O1 #O1b O2"")
	options: #( reportToTranscript ) .
Then in the Transcript you can select specific lines matching a validation failure and run then as a DoIt.
In this case, we validated all the example methods, with 4 different set of passes defined by the compiler and we validated that the generated method could be correctly generated to machine code. The result is reported to Transcript,

The list of optimizations pass to perform is either one of the default compiler optimization level passed as a symbol (#O1, #O2, etc) or a list of ScAbstractIterator.

For possible options, evaluate: 
ScValidator new possibleOptions.



	
"
Class {
	#name : #SoValidator,
	#superclass : #Object,
	#instVars : [
		'codeNode',
		'currentPass',
		'report',
		'checks',
		'validationFailureClass',
		'benchReport',
		'options',
		'passSymbol',
		'jitComparison'
	],
	#classVars : [
		'ExPass',
		'Timeout'
	],
	#pools : [
		'SoOptimizationSettingConstants'
	],
	#category : #'ScorchingTests-Validation'
}

{ #category : #accessing }
SoValidator class >> allExamples [
	^ self exampleClass methodDict values select: [ :m | m selector beginsWith: 'ex' ]
]

{ #category : #accessing }
SoValidator class >> allMethods [
	| m m2 |
	m := Object withAllSubclasses collect: [ :sub | sub methodDict values ].
	m2 := OrderedCollection new.
	m do: [:each | m2 addAll: each ].
	^ m2
]

{ #category : #accessing }
SoValidator class >> exPass: x [
	ExPass := x.
]

{ #category : #accessing }
SoValidator class >> exampleClass [
	^ SoExamples
]

{ #category : #initialization }
SoValidator class >> initialize [
	Timeout := 2.
	ExPass := false.
]

{ #category : #accessing }
SoValidator class >> timeout: x [
	Timeout := x.
]

{ #category : #asserting }
SoValidator >> assert: boolean [ 
	self 
		assert: boolean 
		description: [ 'Assertion failure' ]
]

{ #category : #asserting }
SoValidator >> assert: boolean description: stringOrBlock [ 
	boolean ifTrue: [ ^ self ].
	validationFailureClass new
		messageText: stringOrBlock value;
		signal
]

{ #category : #asserting }
SoValidator >> assert: val1 equals: val2 [
	self 
		assert: val1 = val2
		description: [ 'Got ' , val1 printString , ' instead of ' , val2 printString ]
]

{ #category : #private }
SoValidator >> basicValidateMethod: method passes: o [
	| optimizedCode |
	passSymbol := o.
	currentPass := SoMethodDecompiler.
	codeNode := currentPass decompile: method.
	self validateGraphSanity.
	self defaultSuperBBState , (self class bindingOf: o) value , self prepareCodePasses do: [ :pass |
		currentPass := pass.
		"(pass = SoExpandAndReduce and: [ method selector = #exampleToDo3 ]) ifTrue: [ 1halt ]."
		"pass = SoDeadFlowElimination ifTrue: [ 1halt ]."
		pass new runOn: codeNode.
		self validateGraphSanity ]. 
	"FileStream stdout << codeNode printString."
	optimizedCode := codeNode generateBytecodes. 
	(options includes: #halt) ifTrue: [ 1halt ].
	self postGenerationValidation: method with: optimizedCode.
	checks := checks + 1.
]

{ #category : #bench }
SoValidator >> bench: method against: optimizedMethod [
	self ensureMethodIsExample: method.
	[ self bench: method with: optimizedMethod args: (self exampleArgs: method) ]
		on: Error
		do: [ SoBenchError signal ]
]

{ #category : #bench }
SoValidator >> bench: method with: anotherMethod args: args [
	benchReport add: {
		method selector , ' ' , (passSymbol printStringLimitedTo: 20) .
		[ self newGuineaPig withArgs: args executeMethod: method ] benchFor: 1 seconds .
		[ self newGuineaPig withArgs: args executeMethod: anotherMethod ] benchFor: 1 seconds
	}.
]

{ #category : #reporting }
SoValidator >> benchReport: s [
	benchReport ifNil: [ ^ self ].
	benchReport do: [ :tuple |
		s << tuple first.
		s cr. s tab.
		s 
			<< ' ref: '
			<< tuple second printString.
		s cr. s tab.
		s 
			<< ' opt: '
			<< tuple last printString.
		s cr ].
]

{ #category : #private }
SoValidator >> castException: ex [ 
	(ex class isKindOf: SoValidationFailure) ifTrue: [ ^ ex ].
	^ SoOptimizerError new
		messageText: ex messageText;
		failingPass: currentPass;
		yourself
]

{ #category : #comparing }
SoValidator >> checkBasicEqualitySpecialbetween: object1 and: object2 [
	"Specific for CompiledMethod . MethodContext . BlockClosure.
	else we end up comparing the 2 methods that are different on purpose"
		
	self assert: object1 class equals: object2 class.
	
	object1 class == FullBlockClosure
		ifTrue: [ 
			^ self assert: object1 numArgs equals: object2 numArgs ].
		
	object1 class == Context
		ifTrue: [ 
			self checkBasicEqualitySpecialbetween: object1 method and: object2 method.
			self checkBasicEqualitybetween: object1 closure and: object2 closure.
			^ self assert: object1 receiver equals: object2 receiver ].
	
	self assert: object1 methodClass equals: object2 methodClass.
	^ self assert: object1 selector equals: object2 selector.
		
]

{ #category : #comparing }
SoValidator >> checkBasicEqualitybetween: object1 and: object2 [
	"Ths method is here not to override = everywhere. We do not want to use =="
	
	(self isSpecialObject: object1) 
		ifTrue: [ ^ self checkBasicEqualitySpecialbetween: object1 and: object2 ].
	
	self assert: object1 class equals: object2 class.
	1 to: object1 class instSize do: [ :index |
		(self isSpecialObject: (object1 instVarAt: index)) 
			ifFalse: [ self assert: (object1 instVarAt: index) equals: (object2 instVarAt: index)]
			ifTrue: [ self checkBasicEqualitySpecialbetween: (object1 instVarAt: index) and: (object2 instVarAt: index) ] ].

	"Check only variable fields for array to avoid infinite check loop."
	object1 class == Array ifFalse: [ ^ self ].
	self assert: object1 size equals: object2 size.
	1 to: object1 size do: [ :i |
		self assert: (object1 at: i) isLiteral == (object2 at: i) isLiteral.
		(object1 at: i) isLiteral ifTrue: [ 
			self assert: (object1 at: i) equals: (object2 at: i) ] ]
]

{ #category : #debug }
SoValidator >> codeNode: codeNode1 [
	codeNode := codeNode1
]

{ #category : #comparing }
SoValidator >> compare: method with: optimizedMethod [
	self ensureMethodIsExample: method.
	validationFailureClass := SoComparisonError.
	self compareMethod: method with: optimizedMethod args: (self exampleArgs: method).
]

{ #category : #comparing }
SoValidator >> compareMethod: method with: anotherMethod args: args [
	
	"Compare the execution of the 2 methods. Applicable only on ScExamples"

	| guineaPig1 guineaPig2 returnValueOrException1 returnValueOrException2 |
	
	guineaPig1 := self newGuineaPig.
	guineaPig2 := self newGuineaPig.

	returnValueOrException1 := self runSafely: method on: guineaPig1 withArgs: args description: 'original'.
	returnValueOrException2 := self runSafely: anotherMethod on: guineaPig2 withArgs: args description: 'optimized'.

	"value check"
	self checkBasicEqualitybetween: returnValueOrException1 and: returnValueOrException2.
	
	"effect check"
	self checkBasicEqualitybetween: guineaPig1 and: guineaPig2.
	

]

{ #category : #public }
SoValidator >> debug: method passes: passes options: opts [
	self options: (self materializeOptions: opts).
	self timeoutProtectValidateMethod: method passes: passes.
	^ self result
]

{ #category : #debug }
SoValidator >> debug: method with: optimizedMethod [ 

	"If Squeak / Basic inspectors"
	Smalltalk at: #CompiledMethodInspector ifPresent: [ :insp |
		(insp openOn: method withEvalPane: true withLabel: 'original') model instVarNamed: #selectionIndex put: 2; changed: #selectionIndex.
		^ (insp openOn: optimizedMethod withEvalPane: true withLabel: 'optimized ' , (passSymbol printStringLimitedTo: 20)) model instVarNamed: #selectionIndex put: 2; changed: #selectionIndex ].
	
	"Else"
	"method inspect."
	optimizedMethod inspect.
	
]

{ #category : #private }
SoValidator >> defaultSuperBBState [
	^ { SoReorderBasicBlocks . SoFindDominators . SoSimplifyPhis }
]

{ #category : #asserting }
SoValidator >> deny: boolean [ 
	self assert: boolean not
]

{ #category : #'graph sanity' }
SoValidator >> ensureDeoptInfo: instr [
	instr isTrapIfNotInstanceOf ifTrue: [ self assert: instr hasDeoptInfo ].
	instr class == SoImmediateTrap ifTrue: [ self assert: instr hasDeoptInfo ].
	instr isSend ifTrue: [ self assert: instr hasDeoptInfo ].
	instr isBackjump ifTrue: [ self assert: instr hasDeoptInfo ].
]

{ #category : #comparing }
SoValidator >> ensureMethodIsExample: method [
	(method methodClass = self class exampleClass) ifFalse: [ 
		self error: 'only applicable to the examples, actually run the methods with predefined receiver and arguments' ].
]

{ #category : #comparing }
SoValidator >> errorFor: method messagePrefix: prefix [
	| stream |
	stream := '' writeStream.
	stream 
		<< prefix  
		<< ' method : '
		<< method printString" 
		<< ' lits: ' 
		<< method literals printString".
	SoRuntimeComparisonError signal: stream contents
]

{ #category : #comparing }
SoValidator >> exampleArgs: method [
	^ #( 1 2 3 4 5 6 ) copyFrom: 1 to: method selector numArgs
]

{ #category : #initialization }
SoValidator >> initialize [
	super initialize.
	jitComparison := false.
	benchReport := OrderedCollection new.
	report := Dictionary new.
	checks := 0.
]

{ #category : #'graph sanity' }
SoValidator >> isAlive: instr [
	instr isImmediate ifTrue: [ ^ true ].
	(self isInstructionAlive: instr) ifFalse: [ ^ false ].
	^ instr codeNode basicBlocks includes: instr basicBlock
]

{ #category : #'graph sanity' }
SoValidator >> isInstructionAlive: instr [
	instr isPhiInput ifTrue: [ ^ self isInstructionAlive: instr phi ].
	instr basicBlock instructionsDo: [ :i |
		i == instr ifTrue: [ ^ true ] ].
	instr isSunkObject ifTrue: [ 
		instr basicBlock instructionsDo: [ :i |
			i hasDeoptInfo ifTrue: [ 
				i deoptInfo sunkObjects detect: [ :s | s == instr ] ifFound: [ ^ true ] ] ] ].
	^ false
]

{ #category : #comparing }
SoValidator >> isSpecialObject: object [
	^ { Context . CompiledMethod . CompiledBlock . FullBlockClosure } includes: object class
]

{ #category : #private }
SoValidator >> jitCode: optimizedMethod [
	| jitClass |
	jitClass := Smalltalk at: #SistaStackToRegisterMappingCogit ifAbsent: [ self error: 'can''t jit without the jit' ].
	[ [ jitClass 
		cog: optimizedMethod
		selector: optimizedMethod selector
		options: #(	SistaVM true
				ObjectMemory Spur32BitCoMemoryManager
				bytecodeTableInitializer initializeBytecodeTableForSqueakV3PlusClosuresSistaV1Hybrid
				MULTIPLEBYTECODESETS true
				ISA IA32)
		] on: ProvideAnswerNotification
		do: []
		 	] on: Error
				do: [ :e | SoJITCompilationError signal: e messageText ].
]

{ #category : #comparing }
SoValidator >> jitCompare: method with: optimizedMethod [
	jitComparison := true.
	self compare: method with: optimizedMethod.
	jitComparison := false.
]

{ #category : #options }
SoValidator >> materializeOptions: id [
	options := OrderedCollection new.
	self possibleOptions withIndexDo: [ :sym :index |
		(id bitAnd: (1 << index)) = id ifTrue: [options add: sym ] ].
	^ options asArray
]

{ #category : #comparing }
SoValidator >> newGuineaPig [
	^ self class exampleClass new
]

{ #category : #options }
SoValidator >> options: validationOptions [
	options := validationOptions
]

{ #category : #options }
SoValidator >> possibleOptions [
	^ #(
		graphSanity "Ensure the graph is sane between each pass on the CFG"
		comparison "Run the optimized code against the non-optimized and check the results are correct"
		bench "Evaluate time spent in both optimized and regular code"
		jitCode "Verify the optimized code can be compiled to machine code"
		reportToTranscript "outputs result on Transcript"
		debug "open inspectors on optimized and non optimized code"
		jitComparison "Same as comparison but run enough time to be sure the machine code version are compared"
		halt "halt after optimized code generation"
		longWarmUp "100 instead of 5 warm-up runs"
		noWarmUp "0 instead of 5 warm-up runs"
		)
]

{ #category : #private }
SoValidator >> postGenerationValidation: method with: optimizedMethod [
	self assert: optimizedMethod metadata class = SoDeoptMetadata.
	SoOptCCodeValidator new validateCompiledCode: optimizedMethod.
	(options includes: #comparison) ifTrue: [ self compare: method with: optimizedMethod ].
	(options includes: #jitComparison) ifTrue: [ self jitCompare: method with: optimizedMethod ].
	(options includes: #bench) ifTrue: [ self bench: method against: optimizedMethod ].
	(options includes: #jitCode) ifTrue: [ self jitCode: optimizedMethod ].
	(options includes: #debug) ifTrue: [ self debug: method with: optimizedMethod ].
]

{ #category : #private }
SoValidator >> prepareCodePasses [
	^ { SoReorderBasicBlocks . SoExpandAndReduce . SoSpillAnalysis . SoLivenessAnalysis . SoTempIndexAllocator }
]

{ #category : #reporting }
SoValidator >> printChecks: s [
	| failures |
	failures := report values ifEmpty: [ 0 ] ifNotEmpty: [ :x | x sum: [ :e | e size ] ].
	(checks + failures) printOn: s.
	s << ' methods checked'.
	s cr.
	checks printOn: s.
	s << ' methods validated'.
	s cr.
	failures printOn: s.
	s << ' methods failed'.
	s cr.
]

{ #category : #reporting }
SoValidator >> printFail: fail on: s [ 
	s 	<< '>>> Failure: '.
	self printMethod: fail method on: s.
	s
		<< ' after pass: '
		<< (fail failingPass ifNil: [ '???' ] ifNotNil: [ :it | it name ])
		<< ' (' 
		<< fail listOfPasses
		<< ')'.
	s cr. s tab.
	fail messageText ifNotEmpty: [ s << 'Error msg:: ' << fail messageText. s cr. s tab ].
	s << 'SoValidator new debug: '.
	self printMethod: fail method on: s.
	s
		<< ' passes: ' 
		<< fail listOfPasses
		<< ' options: '
		<< self serializeOptions printString.
	s cr.
	
	
]

{ #category : #reporting }
SoValidator >> printMethod: method on: s [
	s 	
		<< method methodClass name
		<< '>>#'
		<< method selector
]

{ #category : #reporting }
SoValidator >> report [ 
	| s |
	s := '' writeStream.
	150 timesRepeat: [ s nextPut: $| ].
	s cr.
	self validationReport: s.
	self benchReport: s.
	^ s contents
]

{ #category : #private }
SoValidator >> reportValidationFailure: validationFailure for: exceptionClass [
	report 
		at: exceptionClass 
		ifPresent: [ :c | c add: validationFailure ]
		ifAbsentPut: [ OrderedCollection with: validationFailure ]
]

{ #category : #private }
SoValidator >> result [
	(options includes: #reportToTranscript)
		ifTrue: [ Transcript show: self report ].
	^ report
]

{ #category : #comparing }
SoValidator >> run: method on: guineaPig args: args [
	| repeat result |
	repeat := jitComparison ifTrue: [ 5 ] ifFalse: [ 1 ].
	1 to: repeat do: [ :i | result := guineaPig withArgs: args executeMethod: method ].
	^ result
]

{ #category : #public }
SoValidator >> runOn: c [
	c validateGraphSanity 
]

{ #category : #comparing }
SoValidator >> runSafely: method on: guineaPig withArgs: args description: string [
	"Answers the return value of the method or the exception raised. We do not want to have this exception failing the test, but we want to do checks on the exception"
	^ [ [ self run: method on: guineaPig args: args ] 
			on: Error 
			do: [ :ex | 
				ExPass ifTrue: [ ex pass ].
				self errorFor: method messagePrefix: 'runtime error for ', string ] ]  
		valueWithin: 0.5 second 
		onTimeout: [ self errorFor: method messagePrefix: 'method timed out for ', string ] 
]

{ #category : #options }
SoValidator >> serializeOptions [
	| id |
	id := 0.
	self possibleOptions withIndexDo: [ :sym :index |
		(options includes: sym) ifTrue: [ id := id + (1 << index) ] ].
	^ id
]

{ #category : #private }
SoValidator >> timeoutProtectValidateMethod: method passes: passes [
	self warmupRuns: method.
	[ self basicValidateMethod: method passes: passes ]
		valueWithin: Timeout seconds
		onTimeout: [ SoTimeOut signal ] 
]

{ #category : #'graph sanity' }
SoValidator >> validateAnyInstruction: instr [
	self assert: (self isInstructionAlive: instr).
	self validateDeoptInfo: instr.
	instr subNodes do: [ :sub | 
		sub isImmediate ifFalse: [ 
			self assert: (self isAlive: sub).
			instr isPhi
				ifTrue: [sub uses anySatisfy: [ :u | u isPhiInput and: [ u phi = instr ] ] ]
				ifFalse: [
					self assert: (sub uses includes: instr).
					self 
						assert: (instr subNodes count: [ :s | s == sub]) 
						equals: (sub uses count: [ :use | use == instr]) ] ] ].
]

{ #category : #'graph sanity' }
SoValidator >> validateCFG: bb [
	self assert: (bb lastInstr isBackjump or: [(bb successors includes: bb) not]).
	self assert: (codeNode basicBlocks includes: bb).
	self assert: (bb postOrder isNil or: [ bb postOrder = (codeNode basicBlocks indexOf: bb)]).
	bb successors do: [ :succ |
		self assert: (codeNode basicBlocks includes: succ).
		self assert: (succ predecessors includes: bb) ].
	bb predecessors do: [ :pred |
		self assert: (codeNode basicBlocks includes: pred).
		self assert: (pred successors includes: bb) ].
	self validateCFGCanonicalization: bb.
	"(bb lastInstr isBranch and: [ SoMethodDecompiler ~= currentPass ]) ifTrue: [ 
		next := codeNode basicBlocks at: (codeNode basicBlocks indexOf: bb) + 1.
		self assert: (bb lastInstr trueBasicBlock = next or: [bb lastInstr falseBasicBlock = next]) ]"
]

{ #category : #'graph sanity' }
SoValidator >> validateCFGCanonicalization: bb [
	"bb successors size = 1 ifTrue: [ 
		self 
			assert: bb successors anyOne predecessors size > 1
			description: 'CFG canon: should have merge ' , bb successors anyOne printingNumber , ' into ' , bb printingNumber  ].
	bb successors size = 2 ifTrue: [ 
		bb successors do: [ :succ |
			self 
				assert: succ predecessors size = 1
				description: 'CFG canon: critical edge remaining between ' , succ printingNumber , ' and ' , bb printingNumber ] ]."
	"bb lastInstr isBackjump 
		ifTrue: [ self 
					assert: bb successors anyOne bbNumber < bb bbNumber
					description: 'CFG canon: backjump jumping to a forward bb in ' , bb printingNumber ]
		ifFalse: [ bb successors do: [ :succ |
				self 
					assert: succ bbNumber > bb bbNumber
					description: 'CFG canon: jump to backward bb in ' , bb printingNumber ] ]."
]

{ #category : #'graph sanity' }
SoValidator >> validateDeoptInfo: instr [
	self ensureDeoptInfo: instr.
	instr hasDeoptInfo ifFalse: [ ^ self ].
	instr deoptInfo sunkObjects do: [ :each |
		self assert: each node == instr.
		each allFieldsDo: [ :f |
			f isMarker 
				ifTrue: [ self assert: ((instr deoptInfo sunkObjects anySatisfy: 
					[ :sunk | sunk marker == f]) or: [ each theClass == FullBlockClosure ]) ]
				ifFalse: [ f isImmediate ifFalse: [ 
					self assert: (f uses includes: each).
					self 
						assert: (each subNodes count: [ :s | s == f]) 
						equals: (f uses count: [ :use | use == each]) ] ] ] ]
]

{ #category : #'graph sanity' }
SoValidator >> validateGraphSanity [
	(options includes: #graphSanity) ifFalse: [ ^ self ].
	validationFailureClass := SoGraphInsane.
	self assert: codeNode basicBlocks size equals: codeNode basicBlocks asSet size.
	codeNode basicBlocks do: [ :basicBlock |
		self validateInstructions: basicBlock.
		self validateCFG: basicBlock ].
]

{ #category : #'graph sanity' }
SoValidator >> validateInstructions: basicBlock [
	basicBlock instructionsButLastDo: [ :instr |
		self validateAnyInstruction: instr.
		instr uses do: [ :use |
			self assert: (self isAlive: use).
			self assert: (use subNodes includes: instr).
			self 
				assert: (use subNodes count: [ :s | s == instr]) 
				equals: (instr uses count: [ :u | u == use]) ].
		self deny: instr isCFGInstruction.
		self assert: instr nextInstr prevInstr == instr.
		instr = basicBlock firstInstr ifFalse:
			[self assert: instr prevInstr nextInstr == instr].
		instr isSend ifTrue: [ self assert: instr sendData notNil ].
		instr isPhi ifTrue: [ self validatePhi: instr predecessors: basicBlock predecessors ] ].
	self validateLastInstruction: basicBlock lastInstr.
]

{ #category : #'graph sanity' }
SoValidator >> validateLastInstruction: instr [
	self validateAnyInstruction: instr.
	instr prevInstr ifNotNil: [ :prev |
		self assert: prev nextInstr == instr ].
	self assert: instr isCFGInstr.
	instr basicBlock postOrder ifNil: [ ^self ].
	instr isBackjump 
		ifTrue: [ self assert: instr targetBasicBlock postOrder <= instr basicBlock postOrder ]
		ifFalse: [ instr successors do: [ :succ |
				self assert: succ postOrder > instr basicBlock postOrder ] ]
]

{ #category : #private }
SoValidator >> validateMethod: method passes: passes [
	[ self timeoutProtectValidateMethod: method passes: passes ]
		on: Exception 
		do: [ :ex | 
			(ExPass and: [ ex class ~= SoContextAccessed ]) ifTrue: [ ex pass ].
			((options includes: #halt) and: [ ex class = Halt ]) ifTrue: [ ex pass ].
			self 
				reportValidationFailure: ((self castException: ex)
					listOfPasses: passes printString;
					method: method )
				for: ex class ]
]

{ #category : #private }
SoValidator >> validateMethods: methods passes: passes [
	methods do: [ :m |
		passes do: [ :o |
			self validateMethod: m passes: o ] ].
]

{ #category : #public }
SoValidator >> validateMethods: methods passes: passes options: opts [
	self options: opts.
	self validateMethods: methods passes: passes.
	^ self result
]

{ #category : #'graph sanity' }
SoValidator >> validatePhi: phi predecessors: preds [
	| refs |
	refs := phi basicBlockReferences.
	self assert: refs size equals: preds size.
	self assert: (refs asSet includesAll: preds)
]

{ #category : #reporting }
SoValidator >> validationReport: s [
	s << 'Validation report: '.
	s cr.
	self printChecks: s.
	report keysAndValuesDo: [ :key :value |
		s << '=====  ' << key name << '  ====='.
		s cr.
		value do: [ :fail | self printFail: fail on: s ] ].
]

{ #category : #private }
SoValidator >> warmupRuns: method [
	| gp num |
	method methodClass = self class exampleClass ifFalse: [ ^ self "can't warm up" ].
	gp := self newGuineaPig.
	num := (options includes: #longWarmUp) ifTrue: [ 100 ] ifFalse: [ 
		(options includes: #noWarmUp) ifTrue: [ 0 ] ifFalse: [ 5 ] ].
	1 to: num do: [ :i | gp perform: method selector withArguments: (self exampleArgs: method) ]
]
