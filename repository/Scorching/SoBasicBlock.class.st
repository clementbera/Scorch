"
I represent a sequence of instructions executed successfully without control flow operations (the only exception is macro instruction such as trapIfNotInstanceOf, which is an instruction wrapping control flow operations).

The sequence of instruction is held as a linkedList. The linked list can be iterated forward or backward through the instance variable firstInstr and lastInstr. LinkedList is better than OrderedCollection as the sequence of instruction is very often edited by inserting instructions in the middle.

Control flow between basic block is heavily canonicalized and that needs to be maintained (critical edges are split, etc).

The sequence of instructions has several constraints:
- phis are always the first instructions of a basicBlock.
- the last instruction is always a CFG instruction while body instruction cannot be CFG instructions.

Instance Variables
	firstInstr:		<AbsInstruction> first instruction in the sequence of instruction
	lastInstr:		<AbsInstruction> last instruction in the sequence of instr, i.e., cfg instruction.
	predecessors:		<Collection of basic blocks> basic block with control flow instruction going to this basic block
	dominator <BasicBlock> immediate dominator of myself 
	postOrder <Smi> index of this basicBlock in superBB basicBlocks once ReorderBasicBlocks has been run to sort the basicBlocks in reverse postOrder and until the CFG is edited again. 
	tempData <Object> temp data is an extra field on basicblock that can be used by optimization passes to store data relative to the basic block. This instance variable avoids optimizations passes to create dictionaries, speeding up massively the optimizer, and also avoids too many instance variables to be present on basicblock to avoid it to be considered by the memory manager as a large object slowing down garbage collection ...
	codeNode <AbsCode> Method or Block I am in.
"
Class {
	#name : #SoBasicBlock,
	#superclass : #SoAbsNode,
	#instVars : [
		'predecessors',
		'firstInstr',
		'lastInstr',
		'dominator',
		'postOrder',
		'tempData',
		'codeNode'
	],
	#category : #'Scorching-Nodes'
}

{ #category : #accessing }
SoBasicBlock >> addFirstInstruction: instr [
	| prevFirstInstr |
	prevFirstInstr := firstInstr.
	self firstInstr: instr.
	prevFirstInstr ifNotNil: [ :i | instr nextInstr: i ].
	^ instr 
]

{ #category : #accessing }
SoBasicBlock >> addPredecessor: pred [
	^ predecessors add: pred
]

{ #category : #accessing }
SoBasicBlock >> backwardPredecessor [
	"Answers my previours basic block that is related to me through backjump relationship.
	 There is at most one due to loop canonicalization."

	^ self predecessors detect: [ :each | each lastInstr isBackjump ]
]

{ #category : #accessing }
SoBasicBlock >> backwardPredecessors [
	"Answers my previours basic blocks that are related to me through backjump relationship."

	^ self predecessors select: [ :each | each lastInstr isBackjump ]
]

{ #category : #accessing }
SoBasicBlock >> codeNode [
	<generated>
	^ codeNode
]

{ #category : #accessing }
SoBasicBlock >> codeNode: aValue [
	<generated>
	codeNode := aValue
]

{ #category : #dominator }
SoBasicBlock >> commonDominatorWith: basicBlock [
	| currentDominator |
	currentDominator := self.
	[ currentDominator dominates: basicBlock ] whileFalse: [ 
		currentDominator := currentDominator dominator ].
	^ currentDominator

	 
]

{ #category : #dominator }
SoBasicBlock >> dominates: basicBlock [ 
	^ self = basicBlock or: [ self strictlyDominates: basicBlock ]
]

{ #category : #dominator }
SoBasicBlock >> dominatesInstr: instr [
	^ firstInstr dominates: instr 
]

{ #category : #accessing }
SoBasicBlock >> dominator [
	<generated>
	^ dominator
]

{ #category : #accessing }
SoBasicBlock >> dominator: aValue [
	<generated>
	dominator := aValue
]

{ #category : #accessing }
SoBasicBlock >> firstInstr [
	<generated>
	^ firstInstr
]

{ #category : #accessing }
SoBasicBlock >> firstInstr: anObject [
	firstInstr := anObject 
		basicBlock: self;
		prevInstr: nil;
		yourself
]

{ #category : #accessing }
SoBasicBlock >> forwardPredecessors [
	"Answers my previours basic blocks except the ones that are related to me through backBlock relationship."

	^ self predecessors reject: [ :each | each lastInstr isBackjump ]
]

{ #category : #testing }
SoBasicBlock >> hasBackwardPredecessor [
	^ predecessors anySatisfy: [ :pred | pred lastInstr isBackjump ] 
]

{ #category : #initialization }
SoBasicBlock >> initialize [

	super initialize.

	predecessors := OrderedCollection new: 3.
]

{ #category : #enumerating }
SoBasicBlock >> instructionsButLastDo: aBlock [
	"Iterates over the basicBlock instructions from the first instruction to the last but one instruction"
	| instr |
	instr := firstInstr.
	[ instr isCFGInstr ] whileFalse: [ 
		aBlock value: instr.
		instr := instr nextInstr ]
]

{ #category : #enumerating }
SoBasicBlock >> instructionsButLastReverseDo: aBlock [
	"Iterates over the basicBlock instructions from the last but one instruction to the first one"
	| instr |
	instr := lastInstr.
	[ instr := instr prevInstr. 
		instr isNil ] whileFalse: [ 
		aBlock value: instr. ]
]

{ #category : #enumerating }
SoBasicBlock >> instructionsDo: aBlock [
	"Iterates over the basicBlock instructions from the first instruction to the last one"
	| instr |
	instr := firstInstr.
	[ aBlock value: instr.
	instr isCFGInstr ]
		whileFalse: [ instr := instr nextInstr ]
]

{ #category : #enumerating }
SoBasicBlock >> instructionsReverseDo: aBlock [
	"Iterates over the basicBlock instructions from the last instruction to the first one"
	| instr |
	instr := lastInstr.
	[ aBlock value: instr.
	instr prevInstr isNil ] whileFalse: [ 
		instr := instr prevInstr ]
]

{ #category : #accessing }
SoBasicBlock >> lastInstr [
	<generated>
	^ lastInstr
]

{ #category : #accessing }
SoBasicBlock >> lastInstr: aValue [
	<generated>
	lastInstr := aValue
]

{ #category : #accessing }
SoBasicBlock >> phis [
	"Assumes the phis are the first instructions of the basicBlock"
	| instr phis |
	instr := firstInstr.
	phis := OrderedCollection new.
	[ instr notNil and: [ instr isPhi ] ] whileTrue: [ 
		phis add: instr.
		instr := instr nextInstr ].
	^ phis
]

{ #category : #enumerating }
SoBasicBlock >> phisDo: aBlock [ 
	"Iterates over the phis of the basicBlocks from the first phi to the last phi in scheduling order.. 
	Assumes the phis are the first instructions of the basicBlock"
	| instr |
	instr := firstInstr.
	[ instr notNil and: [ instr isPhi ] ] whileTrue: [ 
		aBlock value: instr.
		instr := instr nextInstr ]
]

{ #category : #accessing }
SoBasicBlock >> postOrder [
	<generated>
	^ postOrder
]

{ #category : #accessing }
SoBasicBlock >> postOrder: aValue [
	<generated>
	postOrder := aValue
]

{ #category : #accessing }
SoBasicBlock >> predecessors [
	<generated>
	^ predecessors
]

{ #category : #accessing }
SoBasicBlock >> predecessors: aValue [
	<generated>
	predecessors := aValue
]

{ #category : #accessing }
SoBasicBlock >> removePredecessor: pred [
	predecessors remove: pred
]

{ #category : #dominator }
SoBasicBlock >> strictlyDominates: basicBlock [ 
	| dom |
	dom := basicBlock dominator.
	[ dom = self ifTrue: [ ^ true ].
	dom isNil ] whileFalse: [ dom := dom dominator ].
	^ false
]

{ #category : #accessing }
SoBasicBlock >> successors [
	^ lastInstr successors
]

{ #category : #accessing }
SoBasicBlock >> tempData [
	<generated>
	^ tempData
]

{ #category : #accessing }
SoBasicBlock >> tempData: aValue [
	<generated>
	tempData := aValue
]
