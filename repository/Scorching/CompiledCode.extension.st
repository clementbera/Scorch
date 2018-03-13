Extension { #name : #CompiledCode }

{ #category : #'*Scorching' }
CompiledCode >> allowRuntimeOptimizations [
	self hasNoRuntimeOptimizationsPragma ifTrue: [ ^ false ].
	^ self methodClass allowRuntimeOptimization
]

{ #category : #'*Scorching' }
CompiledCode >> bytecodeSize [
	^ self endPC - self initialPC + 1
]

{ #category : #'*Scorching' }
CompiledCode >> discard [ 
	<noRuntimeOptimizations>
	"Discard all the cog usage of this method, replacing them by lazy usage of the deoptimized method.
	Do not uninstall the method. Use SoDependencyMap default discardOptimizedMethod: m for that"

	self isOptimized ifFalse: [ ^ self ].
	
	"Flush all machine code frame to interpreted frames.
	Flush all machine code context to interpreted context.
	Important: do that first or context frame will not be able
	to be switched to interpreted frames if the method is not
	in the n code zone"
	self voidCogVMState.
	
	"self metadata debugInfo: self symbolic."
	
	"set the method to have only immediate trap bytecodes"
	self initialPC to: self endPC do: [ :pc |
		self at: pc put: 217 ].
	
]

{ #category : #'*Scorching' }
CompiledCode >> hasNoCounterBit [
	^ (self header bitAt: 16) = 1
]

{ #category : #'*Scorching' }
CompiledCode >> isGloballyOptimized [
	^ self isOptimized or: [ 
		self isDoIt or: [
		(self methodClass >> self selector) isOptimized ] ]
]

{ #category : #'*Scorching' }
CompiledCode >> isOptimized [
	self flag: 'fix when agreed on some bits in header or anything similar'.
	self literals size < 3 ifTrue: [ ^ false ].
	^ self metadata isKindOf: SoDeoptMetadata
]

{ #category : #'*Scorching' }
CompiledCode >> markOptimizedBit [
	self objectAt: 1 put: (self header bitAt: 16 put: 1)
]

{ #category : #'*Scorching' }
CompiledCode >> metadata [
	^ self objectAt: self numLiterals - 1
]

{ #category : #'*Scorching' }
CompiledCode >> primitiveAllMethodsCompiledToMachineCode [
	
	<primitive: 'primitiveAllMethodsCompiledToMachineCode' module:''>
	^#()
	
]

{ #category : #'*Scorching' }
CompiledCode >> resetCounters [
	"Reset the conditional branch counters in the receiver that the Sista VM uses to call back when in hot spots.
	Fails if the system does not support the primitive."
	<primitive: 'primitiveResetCountersInMethod' module: ''>
]

{ #category : #'*Scorching' }
CompiledCode >> resetOptimizedBit [
	self objectAt: 1 put: (self header bitAt: 16 put: 0)
]

{ #category : #'*Scorching' }
CompiledCode >> sendAndBranchData [
	"If the method is linked to a cogit method, answers the values of the inline caches and conditional counters of the method, else answers an empty array.
	The result will be an Array such as:
	{ 
	{ bytecode pc  . 20000 . 11 } . => counters values of the conditional jump at this bytecode. 
	{ bytecode pc . class . compiledMethod } . => inline cache value
	{ bytecode pc . class1 . compiledMethod1 . class2 . compiledMethod2 . class3 . compiledMethod3 } => pic value
	{ bytecode pc . nil . selector } . => megamorphic inline cache value
	}
	Note:
	unused send sites are omitted.
	doesNotUnderstand: has the entry: class . #doesNotUnderstand: instead of: class . methodFound .
	"
	
	<primitive: 'primitiveSistaMethodPICAndCounterData' module:''>
	^#()
	
	"^ (Smalltalk globals at: #SoSendAndBranchDataCache) staticSendAndBranchData: self"
]
