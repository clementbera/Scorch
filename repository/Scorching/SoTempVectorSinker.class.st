"
I am a specific object sinker for temp vector. I am different because I can use specificities of temp vectors (I know they never escape the code they're created in, they're accessed only through remote temp instruction) to make the algorithm easier and faster.

I sink temp vector in 3 main steps:
1) look for tempVector creation in basicblocks and select the ones that are not used in closures.
2) sink selected temp vectors by replacing indirect temp by ssa values. 
3) fill and simplify the phis created by the new ssa variables.

tempVectorsToSink <Colleciton of CreateTempVector> temp vectors detected as to sink (worklist)
phis <Collection of Phi> the phis created by moved temp vector values to SSA
tempVectorBeingSunk <CreateTempVector> the temp vector I'm currently sinking.
currentVectorValues <Collection of Instruction> While iterating over the graph, the current SSA values of the different vector remote temps. 
sunkMarker <Marker> unique id for the temp vector (for deoptimisation)
"
Class {
	#name : #SoTempVectorSinker,
	#superclass : #SoObjectSinker,
	#instVars : [
		'tempVectorsToSink',
		'phis',
		'tempVectorBeingSunk',
		'currentVectorValues',
		'sunkMarker'
	],
	#category : #'Scorching-Pass-Heap'
}

{ #category : #sinking }
SoTempVectorSinker >> addPhisFor: bb [
	| firstInstr |
	firstInstr := bb firstInstr.
	1 to: currentVectorValues size do: [ :i |
		phis add: (currentVectorValues at: i put: (SoPhi new insertBefore: firstInstr)) ].
	bb hasBackwardPredecessor ifTrue: [ ^ self ].
	self fillPhis: bb.
]

{ #category : #sinking }
SoTempVectorSinker >> basicSinkTempVector [
	| codeNode |
	tempVectorBeingSunk uses ifEmpty: [ ^ self ].
	sunkMarker := SoSunkObjectMarker new.
	codeNode := tempVectorBeingSunk codeNode.
	self traverseForwardBasicBlock: codeNode basicBlocks first.
	codeNode basicBlocks allButFirstDo: [ :bb |
		self restoreTempVect: bb.
		self traverseForwardBasicBlock: bb ].
]

{ #category : #sinking }
SoTempVectorSinker >> createSunkVector [
	^ SoPointerSunkObjectState new
		theClass: Array;
		marker: sunkMarker;
		fixedFields: #();
		variableFields: currentVectorValues copy;
		yourself.
]

{ #category : #accessing }
SoTempVectorSinker >> currentVectorValues [
	<generated>
	^ currentVectorValues
]

{ #category : #accessing }
SoTempVectorSinker >> currentVectorValues: aValue [
	<generated>
	currentVectorValues := aValue
]

{ #category : #detection }
SoTempVectorSinker >> detectTempVectorToSink: tempVect [
	"I added isPhi because of strange loop-local temp vector
	that I decided not to optimize for now. 
	See #exampleTempVectorNoBlock"
	(tempVect uses anySatisfy: 
		[ :use | use isBlockClosure or: [ use isPhiInput ] ]) ifTrue: [ ^ self ].
	tempVectorsToSink add: tempVect.
]

{ #category : #detection }
SoTempVectorSinker >> detectTempVectorsToSink: codeNode [
	codeNode basicBlocks do: 
		[ :bb | bb instructionsButLastDo: 
			[ :instr | instr isTempVector ifTrue: 
				[ self detectTempVectorToSink: instr ]  ]  ]
	
]

{ #category : #sinking }
SoTempVectorSinker >> fillPhis: bb [
	| instr |
	instr := bb firstInstr.
	1 to: currentVectorValues size do: [ :i |
		bb predecessors do: [ :pred |
			instr addInput: (pred tempData at: i) basicBlock: pred ].
		instr := instr nextInstr ]
]

{ #category : #sinking }
SoTempVectorSinker >> handleDeoptInfo: deoptInfo [
	| used |
	used := false.
	deoptInfo sunkObjects do: [ :sunkObj |
		| count |
		count := 0.
		sunkObj allFieldsDo: [ :f |
			f == tempVectorBeingSunk ifTrue: [ used := true. count := count + 1 ].
			f == sunkMarker ifTrue: [ used := true ] ].
		count timesRepeat: [ sunkObj basicReplaceSubNode: tempVectorBeingSunk by: sunkMarker ] ].
	used ifFalse: [ ^ self ].
	deoptInfo addSunkObject: self createSunkVector.
]

{ #category : #initialization }
SoTempVectorSinker >> initialize [

	super initialize.

	phis := OrderedCollection new.
	tempVectorsToSink := OrderedCollection new.
]

{ #category : #sinking }
SoTempVectorSinker >> initializeTempVectorValues [
	currentVectorValues := (1 to: tempVectorBeingSunk vectorSize) collect: [ :i | SoConstant new ]
]

{ #category : #accessing }
SoTempVectorSinker >> phis [
	<generated>
	^ phis
]

{ #category : #accessing }
SoTempVectorSinker >> phis: aValue [
	<generated>
	phis := aValue
]

{ #category : #sinking }
SoTempVectorSinker >> restoreStackFor: bb [
	currentVectorValues := bb predecessors anyOne tempData copy.
]

{ #category : #sinking }
SoTempVectorSinker >> restoreTempVect: bb [
	bb predecessors size = 1
		ifTrue: [ self restoreStackFor: bb ]
		ifFalse: [ self addPhisFor: bb ].
]

{ #category : #public }
SoTempVectorSinker >> runOn: codeNode [
	self detectTempVectorsToSink: codeNode.
	tempVectorsToSink do: [ :tempVect |
		self sinkTempVector: tempVect ].
]

{ #category : #sinking }
SoTempVectorSinker >> sinkTempVector: tempVect [
	tempVectorBeingSunk := tempVect.
	phis reset.
	self initializeTempVectorValues.
	self basicSinkTempVector.
	SoSimplifyPhis new simplifyPhis: phis.
	tempVectorBeingSunk removeInstr.
]

{ #category : #accessing }
SoTempVectorSinker >> sunkMarker [
	<generated>
	^ sunkMarker
]

{ #category : #accessing }
SoTempVectorSinker >> sunkMarker: aValue [
	<generated>
	sunkMarker := aValue
]

{ #category : #accessing }
SoTempVectorSinker >> tempVectorBeingSunk [
	<generated>
	^ tempVectorBeingSunk
]

{ #category : #accessing }
SoTempVectorSinker >> tempVectorBeingSunk: aValue [
	<generated>
	tempVectorBeingSunk := aValue
]

{ #category : #accessing }
SoTempVectorSinker >> tempVectorsToSink [
	<generated>
	^ tempVectorsToSink
]

{ #category : #accessing }
SoTempVectorSinker >> tempVectorsToSink: aValue [
	<generated>
	tempVectorsToSink := aValue
]

{ #category : #traversing }
SoTempVectorSinker >> traverseBackjump: bj [
	bj basicBlock tempData: currentVectorValues copy.
	self fillPhis: bj targetBasicBlock 
]

{ #category : #traversing }
SoTempVectorSinker >> traverseForwardBasicBlock: bb [
	super traverseForwardBasicBlock: bb.
	bb lastInstr isBackjump ifFalse: [ bb tempData: currentVectorValues copy ].
]

{ #category : #traversing }
SoTempVectorSinker >> traverseInstruction: instr [
	instr hasDeoptInfo ifTrue: [ self handleDeoptInfo: instr deoptInfo ]. 
	super traverseInstruction: instr
]

{ #category : #traversing }
SoTempVectorSinker >> traverseRemoteTemp: remote [
	remote tempVector == tempVectorBeingSunk ifFalse: [ ^ self ].
	remote isWrite 
		ifFalse: [ remote removeAndReplaceUsesBy: (currentVectorValues at: remote remoteIndex + 1) ]
		ifTrue: [ currentVectorValues at: remote remoteIndex + 1 put: remote expression.
				 remote removeInstr ]
		
]
