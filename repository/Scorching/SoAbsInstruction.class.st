"
My instances are scheduled inside a basicBlock.

basicBlock <BasicBlock> 
prevInstr <AbsInstruction> Instruction before this one in the linked list of instruction of a basicBlock.
"
Class {
	#name : #SoAbsInstruction,
	#superclass : #SoAbsNode,
	#instVars : [
		'prevInstr',
		'basicBlock'
	],
	#category : #'Scorching-Nodes'
}

{ #category : #accessing }
SoAbsInstruction >> basicBlock [
	<generated>
	^ basicBlock
]

{ #category : #accessing }
SoAbsInstruction >> basicBlock: aValue [
	<generated>
	basicBlock := aValue
]

{ #category : #accessing }
SoAbsInstruction >> codeNode [
	^ basicBlock codeNode
]

{ #category : #dominator }
SoAbsInstruction >> dominates: anotherInstruction [
	^ self == anotherInstruction or: [ self strictlyDominates: anotherInstruction ]
]

{ #category : #dominator }
SoAbsInstruction >> isDominatedByBasicBlock: bb [
	^ bb dominatesInstr: self
]

{ #category : #'graph edition' }
SoAbsInstruction >> postCopy [
	self subNodes do: [ :each | each addUse: self ].
	self hasDeoptInfo ifTrue: [ self deoptInfo: self deoptInfo copy ]
]

{ #category : #accessing }
SoAbsInstruction >> prevInstr [
	<generated>
	^ prevInstr
]

{ #category : #accessing }
SoAbsInstruction >> prevInstr: aValue [
	<generated>
	prevInstr := aValue
]

{ #category : #'graph edition' }
SoAbsInstruction >> prevInstrNextInstr: instr [ 
	prevInstr
		ifNil: [ basicBlock firstInstr: instr ]
		ifNotNil: [ :prev | prev nextInstr: instr ]
]

{ #category : #'graph edition' }
SoAbsInstruction >> removeInstr [
	self subNodesRemoveUses.
	self removeDeoptInfo 
]

{ #category : #dominator }
SoAbsInstruction >> strictlyDominates: anotherInstruction [
	(basicBlock strictlyDominates: anotherInstruction basicBlock) ifTrue: [ ^ true ].
	basicBlock == anotherInstruction basicBlock ifFalse: [ ^ false ].
	self == anotherInstruction ifTrue: [ ^ false ].
	"both in the same basicBlock but different instruction. We must ensure that self is before anotherInstruction in the scheduling"
	basicBlock instructionsDo: [ :instr |
		instr == self ifTrue: [ ^ true ].
		instr == anotherInstruction ifTrue: [ ^ false ] ].
	self error: 'should not reach'.
]

{ #category : #'graph edition' }
SoAbsInstruction >> subNodes [
	^ #()
]
