"
I am an implementation of the V8's engine liveness analysis of environment slots, adapted and ported to Smalltalk.

I assume the spillAnalysis has been run before, because I need to know which instructions are going to be compiled to a temporary.

I compute liveness of temporaries at the beginning of each basic block and store it for each basic block (using the tempData field for performance) until it doesn't change any more. For efficiency, I visit basic blocks in reverse pre order traversal and walk backwards through each block. I need several iterations to propagate liveness through nested loops (complexity is number of basicBlocks * number of nested loops). While computing the liveness of temporaries, I also build the interference graph between then, used later for graph coloring.

live <Set of instructions> Set of live instructions at the current state of the analysis (all temporaries).
"
Class {
	#name : #SoLivenessAnalysis,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'live'
	],
	#category : #'Scorching-Backend-Analysis'
}

{ #category : #private }
SoLivenessAnalysis >> addInterferenceBetween: instr1 and: instr2 [
	instr1 backend addInterferenceWith: instr2.
	instr2 backend addInterferenceWith: instr1.
]

{ #category : #private }
SoLivenessAnalysis >> ensureDeoptRefAlive: deoptInfo [
	deoptInfo sunkObjects do: [ :sunkObj |
		sunkObj subNodes do: [ :each | self markAsAliveIfTemp: each ] ]
]

{ #category : #private }
SoLivenessAnalysis >> ensureSubnodesAlive: node [
	node subNodes do: [ :n | self markAsAliveIfTemp: n ] .
]

{ #category : #initialization }
SoLivenessAnalysis >> initialize [

	super initialize.

	live := Set new.
]

{ #category : #accessing }
SoLivenessAnalysis >> live [
	<generated>
	^ live
]

{ #category : #accessing }
SoLivenessAnalysis >> live: aValue [
	<generated>
	live := aValue
]

{ #category : #private }
SoLivenessAnalysis >> markAsAliveIfTemp: instruction [ 
	instruction isImmediate ifTrue: [ ^ self ].
	instruction backend isTemp ifTrue: [ live add: instruction ]
]

{ #category : #private }
SoLivenessAnalysis >> markAsDeadIfTemp: instr [
	instr backend isTemp ifFalse: [ ^ self ]. 
	live remove: instr ifAbsent: nil.
	live do: [ :each | self addInterferenceBetween: each and: instr ]
]

{ #category : #private }
SoLivenessAnalysis >> processBlock: bbProcessed worklist: workList [
	| newLiveIn |
	self updateLivenessAtBlockEnd: bbProcessed.
	self reverseWalk: bbProcessed.
	newLiveIn := bbProcessed tempData union: live.
	bbProcessed tempData size = newLiveIn size ifTrue: [ ^ self ]. 
	bbProcessed tempData: newLiveIn.
	workList addAllFirst: bbProcessed predecessors
]

{ #category : #private }
SoLivenessAnalysis >> reverseWalk: bbProcessed [
	"phi inputs are considered are being the last instruction of the basicblock 
	they come from instead of in the basic block they are."
	
	"If there are phis there is only 1 successor"
	bbProcessed successors do: [ :pred | 
		pred phis reverseDo: [ :phi | 
			self markAsDeadIfTemp: phi.
			self markAsAliveIfTemp: (phi inputForBasicBlock: bbProcessed). ] ].
	
	self traverseBackwardBasicBlock: bbProcessed
]

{ #category : #public }
SoLivenessAnalysis >> runOn: codeNode [
	| workList bbProcessed |
	codeNode basicBlocks do: [ :bb | bb tempData: Set new ].
	workList := codeNode basicBlocks reversed.
	[ workList isEmpty ] whileFalse: [ 
		bbProcessed := workList removeFirst.
		(workList includes: bbProcessed) ifFalse: [ 
			self processBlock: bbProcessed worklist: workList ] ].
	
]

{ #category : #private }
SoLivenessAnalysis >> traverseInstruction: instr [
	instr isPhi ifTrue: [ ^ self ]. "traversed in prev basicBlock"
	instr isCFGInstr ifFalse: [ self markAsDeadIfTemp: instr ].
	self ensureSubnodesAlive: instr.
	instr hasDeoptInfo ifTrue: [ self ensureDeoptRefAlive: instr deoptInfo ].
]

{ #category : #private }
SoLivenessAnalysis >> updateLivenessAtBlockEnd: bbProcessed [
	live removeAll.
	bbProcessed successors do: [ :succ | 
		live := live union: succ tempData].
	"uncomment the following line to compute liveOut."
	"bbProcessed liveOut addAll: live."
]
