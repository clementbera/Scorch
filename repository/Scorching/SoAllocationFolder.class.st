"
I fold objects, i.e., postpone their allocations from runtime to deoptimisation time.

Two main steps
1) replace all reads/writes of the object by SSA values and replace all deoptimisation information by object reconstruction.
2) fill and simplify the phis created by the new ssa variables.

allocFolded <InstantiationOp> 
phis <Collection of Phi> the phis created by moved object values to SSA
currentValues <Collection of Instruction> While iterating over the graph, the current SSA values of the different object instance variables. 
sunkMarker <Marker> unique id for the object (for deoptimisation)
"
Class {
	#name : #SoAllocationFolder,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'allocFolded',
		'phis',
		'currentValues',
		'sunkMarker',
		'sunkObject'
	],
	#pools : [
		'SoMagicConstants'
	],
	#category : #'Scorching-Pass-Heap'
}

{ #category : #folding }
SoAllocationFolder >> addPhisFor: bb [
	| firstInstr |
	firstInstr := bb firstInstr.
	1 to: currentValues size do: [ :i |
		phis add: (currentValues at: i put: (SoPhi new insertBefore: firstInstr)) ].
	bb hasBackwardPredecessor ifTrue: [ ^ self ].
	self fillPhis: bb.
]

{ #category : #accessing }
SoAllocationFolder >> allocFolded [
	<generated>
	^ allocFolded
]

{ #category : #accessing }
SoAllocationFolder >> allocFolded: aValue [
	<generated>
	allocFolded := aValue
]

{ #category : #folding }
SoAllocationFolder >> basicFoldAlloc [
	| codeNode |
	allocFolded uses ifEmpty: [ ^ self ].
	sunkMarker := SoSunkObjectMarker new.
	codeNode := allocFolded codeNode.
	self traverseForwardBasicBlock: codeNode basicBlocks first.
	codeNode basicBlocks allButFirstDo: [ :bb |
		self restoreValues: bb.
		self traverseForwardBasicBlock: bb ].
]

{ #category : #folding }
SoAllocationFolder >> createSunkObject [
	sunkObject ifNotNil: [ ^ sunkObject ].
	sunkObject := SoPointerSunkObjectState new
		theClass: allocFolded behavior;
		marker: sunkMarker;
		yourself.
	"If array, currentValues has var fields, if object, currentValues has inst vars..."
	allocFolded behavior instSpec = 2
		ifTrue: [ 
			sunkObject fixedFields: #();
			variableFields: currentValues copy ]
		ifFalse: [ 
			sunkObject variableFields: #();
			fixedFields: currentValues copy ].
	^ sunkObject
]

{ #category : #accessing }
SoAllocationFolder >> currentValues [
	<generated>
	^ currentValues
]

{ #category : #accessing }
SoAllocationFolder >> currentValues: aValue [
	<generated>
	currentValues := aValue
]

{ #category : #folding }
SoAllocationFolder >> fillPhis: bb [
	| instr |
	instr := bb firstInstr.
	1 to: currentValues size do: [ :i |
		bb predecessors do: [ :pred |
			instr addInput: (pred tempData at: i) basicBlock: pred ].
		instr := instr nextInstr ]
]

{ #category : #folding }
SoAllocationFolder >> flushSunkObject [
	sunkObject := nil
]

{ #category : #public }
SoAllocationFolder >> fold: allocation [
	allocFolded := allocation.
	phis reset.
	self initializeValues.
	self basicFoldAlloc.
	SoSimplifyPhis new simplifyPhis: phis.
	allocFolded removeInstr.
	self logDebug: allocFolded behavior name class: #SoAllocFoldedLog at: allocFolded.
]

{ #category : #folding }
SoAllocationFolder >> handleDeoptInfo: deoptInfo [
	| used |
	used := false.
	deoptInfo sunkObjects do: [ :sunkObj |
		| count |
		count := 0.
		sunkObj allFieldsDo: [ :f |
			f == allocFolded ifTrue: [ used := true. count := count + 1 ].
			f == sunkMarker ifTrue: [ used := true ] ].
		count timesRepeat: [ sunkObj basicReplaceSubNode: allocFolded by: sunkMarker ] ].
	used ifFalse: [ ^ self ].
	deoptInfo addSunkObject: self createSunkObject.
]

{ #category : #initialization }
SoAllocationFolder >> initialize [

	super initialize.

	phis := OrderedCollection new.
]

{ #category : #folding }
SoAllocationFolder >> initializeValues [
	currentValues := (1 to: allocFolded instSize) collect: [ :i | allocFolded initConstant ]
]

{ #category : #accessing }
SoAllocationFolder >> phis [
	<generated>
	^ phis
]

{ #category : #accessing }
SoAllocationFolder >> phis: aValue [
	<generated>
	phis := aValue
]

{ #category : #folding }
SoAllocationFolder >> restoreFor: bb [
	currentValues := bb predecessors anyOne tempData copy.
]

{ #category : #folding }
SoAllocationFolder >> restoreValues: bb [
	bb predecessors size = 1
		ifTrue: [ self restoreFor: bb ]
		ifFalse: [ self addPhisFor: bb ].
	self flushSunkObject.
]

{ #category : #accessing }
SoAllocationFolder >> sunkMarker [
	<generated>
	^ sunkMarker
]

{ #category : #accessing }
SoAllocationFolder >> sunkMarker: aValue [
	<generated>
	sunkMarker := aValue
]

{ #category : #accessing }
SoAllocationFolder >> sunkObject [
	<generated>
	^ sunkObject
]

{ #category : #accessing }
SoAllocationFolder >> sunkObject: aValue [
	<generated>
	sunkObject := aValue
]

{ #category : #traversing }
SoAllocationFolder >> traverseForwardBasicBlock: bb [
	super traverseForwardBasicBlock: bb.
	bb lastInstr isBackjump ifFalse: [ bb tempData: currentValues copy ].
]

{ #category : #traversing }
SoAllocationFolder >> traverseInstruction: instr [
	instr hasDeoptInfo ifTrue: [ self handleDeoptInfo: instr deoptInfo ]. 
	super traverseInstruction: instr
]

{ #category : #traversing }
SoAllocationFolder >> traverseNoInterruptBackjump: bj [
	bj basicBlock tempData: currentValues copy.
	self fillPhis: bj targetBasicBlock 
]

{ #category : #traversing }
SoAllocationFolder >> traverseObjectRead: read [
	read object == allocFolded ifFalse: [ ^ self ].
	read removeAndReplaceUsesBy: (currentValues at: read index constant)
		
]

{ #category : #traversing }
SoAllocationFolder >> traverseObjectWrite: write [
	write object == allocFolded ifFalse: [ ^ self ].
	currentValues at: write index constant put: write expression.
	write removeInstr.
	self flushSunkObject.
	
		
		
]
