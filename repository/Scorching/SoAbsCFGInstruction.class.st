"
Instruction with control flow operations. My subinstances are necessarily at the end of each basic block.

"
Class {
	#name : #SoAbsCFGInstruction,
	#superclass : #SoAbsInstruction,
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #backend }
SoAbsCFGInstruction >> backEndJumpSize [
	^ 0
]

{ #category : #testing }
SoAbsCFGInstruction >> isCFGInstr [
	^ true
]

{ #category : #'graph edition' }
SoAbsCFGInstruction >> replaceBy: cfgInstr [
	self removeInstr.
	self successors do: [ :succ | succ removePredecessor: basicBlock ].
	self prevInstrNextInstr: cfgInstr.
	basicBlock lastInstr: cfgInstr.
]

{ #category : #accessing }
SoAbsCFGInstruction >> successors [
	^ #()
]
