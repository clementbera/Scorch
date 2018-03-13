"
I use graph coloring and phi coalescing to associate a temporary index to each instruction that will be a temporary variable once compiled.

I require the liveness analysis to be run before (I need the interference graph for graph coloring).

Algorithm (See #runOn:):
1) I visit the superBasicBlock to collect all future temps and phi nodes that require a temp (no phi node with spill values wuch as branch merge assignment). 
2) I iterate other the phi nodes and coalesce the phiResources with an union-find algorithm when possible, else copies will be needed.
3) I use graph coloring to reduce the number of temporaries, graph coloring nodes are either a temporary or a set of temporaries in case of temporaries already coalesced by step 2. For each temp mark 'index' to identify what temporary the instr will be stored to.

temps <OrderedCollection of Instruction> Instruction with ScTemp as bytecodeGenInfo 
phis <OrderedCollection of Phi> all the phi of the graph 
allSets <Dictionary (instruction -> set of Instruction not interfering with each other)>
"
Class {
	#name : #SoTempIndexAllocator,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'temps',
		'phis',
		'allSets'
	],
	#pools : [
		'SoSistaV1BytecodeSetConstants'
	],
	#category : #'Scorching-Backend-Analysis'
}

{ #category : #'graph coloring' }
SoTempIndexAllocator >> addDependencies: allNodes nodeMap: nodeMap [
	allNodes do: [ :node |
		node id do: [ :instr |
			 instr backend interferences do: [ :otherInstr |
				| otherNode |
				otherNode := nodeMap at: (allSets at: otherInstr).
				(node relations includes: otherNode)
					ifFalse: [ node addRelation: otherNode ] ] ] ]
]

{ #category : #accessing }
SoTempIndexAllocator >> allSets [
	<generated>
	^ allSets
]

{ #category : #accessing }
SoTempIndexAllocator >> allSets: aValue [
	<generated>
	allSets := aValue
]

{ #category : #'phi coalescing' }
SoTempIndexAllocator >> computeSets [
	temps do: [ :tmp |
		allSets at: tmp put: (Set with: tmp) ]
]

{ #category : #'graph coloring' }
SoTempIndexAllocator >> graphColoring: codeNode [
	| allNodes nodeMap numColors |
	nodeMap := Dictionary new.
	allNodes := allSets values collect: [ :set | nodeMap at: set put: (SoGraphNode id: set) ].
	self addDependencies: allNodes nodeMap: nodeMap.
	numColors := SoGraphColorer new 
		color: allNodes asOrderedCollection 
		minColor: 0
		maxColor: MaxNumTempsPerMethod - codeNode numArgs - codeNode numCopied.
	codeNode backendMaxTempIndex: numColors.
	self setNewIndexFromColor: allNodes.
]

{ #category : #initialization }
SoTempIndexAllocator >> initialize [

	super initialize.

	allSets := Dictionary new.
	phis := OrderedCollection new.
	temps := OrderedCollection new.
]

{ #category : #'phi coalescing' }
SoTempIndexAllocator >> mergeSets [
	phis do: [ :phi |
		| resources |
		resources := phi phiResources select: [ :e | e backend isTemp ].
		resources do: [ :var1 |
			| set1 |
			set1 := allSets at: var1.
			resources do: [ :var2 |
				| set2 |
				set2 := allSets at: var2.
				(var1 == var2 or: [set1 == set2]) ifFalse: [ 
					self mergeSetsIfNoInterferences: set1 with: set2 ] ] ] ].
]

{ #category : #'phi coalescing' }
SoTempIndexAllocator >> mergeSetsIfNoInterferences: set1 with: set2 [
	set1 do: [ :elem1 |
		set2 do: [ :elem2 |
			(elem1 interfersWith: elem2) ifTrue: [ ^ self ] ] ].
	"no interferences. put set2 in set1."
	set1 addAll: set2.
	set2 do: [ :val |
		allSets at: val put: set1 ].
]

{ #category : #accessing }
SoTempIndexAllocator >> phis [
	<generated>
	^ phis
]

{ #category : #accessing }
SoTempIndexAllocator >> phis: aValue [
	<generated>
	phis := aValue
]

{ #category : #public }
SoTempIndexAllocator >> runOn: codeNode [
	"Step 1"
	self traversePreorderCode: codeNode.
	self computeSets.
	"Step 2"
	self mergeSets.
	"Step 3"
	self graphColoring: codeNode
]

{ #category : #'graph coloring' }
SoTempIndexAllocator >> setNewIndexFromColor: allNodes [
	allNodes do: [ :node | 
		node id do: [ :instr | 
			instr backend tempIndex: node color ] ].
]

{ #category : #accessing }
SoTempIndexAllocator >> temps [
	<generated>
	^ temps
]

{ #category : #accessing }
SoTempIndexAllocator >> temps: aValue [
	<generated>
	temps := aValue
]

{ #category : #traversing }
SoTempIndexAllocator >> traverseInstruction: instr [
	instr isCFGInstr ifTrue: [ ^ self ].
	instr backend isTemp ifTrue: [ temps add: instr ].
	instr isPhi ifTrue: [ phis add: instr ]
]
