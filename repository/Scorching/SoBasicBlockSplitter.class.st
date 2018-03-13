"
I split a basic block at a given instruction. The instruction is removed. Answers the previous basicblock.

I am mainly used when an instruction needs to be replaced by control flow operations.
"
Class {
	#name : #SoBasicBlockSplitter,
	#superclass : #Object,
	#category : #'Scorching-Pass-Flow'
}

{ #category : #public }
SoBasicBlockSplitter >> splitBasicBlockAt: instr [
	| prevBB |
	instr removeInstr.
	instr codeNode addBasicBlock: (prevBB := SoBasicBlock new) before: instr basicBlock.
	instr basicBlock predecessors copy do: 
		[ :each | each lastInstr replaceSuccessor: instr basicBlock by: prevBB ].
	self splitInstructionsAt: instr prevBB: prevBB.
	prevBB dominator: instr basicBlock dominator.
	instr basicBlock dominator: prevBB.
	^ prevBB
	
]

{ #category : #private }
SoBasicBlockSplitter >> splitInstructionsAt: instr prevBB: prevBB [
	| jumpAhead |
	jumpAhead := SoJumpAhead from: prevBB to: instr basicBlock.
	prevBB firstInstr: (instr prevInstr 
		ifNotNil: [ instr basicBlock firstInstr ]
		ifNil: [ jumpAhead ]).
	instr prevInstrNextInstr: jumpAhead.
	prevBB instructionsDo: [ :in | in basicBlock: prevBB ].
	instr basicBlock firstInstr: instr nextInstr.
	prevBB lastInstr: jumpAhead.
]
