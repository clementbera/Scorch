"
I find out for each instruction if it has to be compiled to a temporary, if it has to be spilled on stack or just evaluated for effect.

To keep things simple, if an instruction is used in deoptimization information or in a phi, I always mark it as a temporary. The main thing is want to guarantee is that where there's a comparaison of numbers followed by a branch, the comparison is spilled on stack so cogit can pipeline it to the corresponding machine code branch.
"
Class {
	#name : #SoSpillAnalysis,
	#superclass : #SoGraphTraverser,
	#category : #'Scorching-Backend-Analysis'
}

{ #category : #private }
SoSpillAnalysis >> canSpill: sub from: node [
	| instr |
	sub isImmediate ifTrue: [ ^ true ].
	instr := node prevInstr.
	[instr == sub ifTrue: [ ^ true ].
	instr notNil and: [ instr isSpilled ] ] whileTrue: [ instr := instr prevInstr ].
	^ false
		
]

{ #category : #public }
SoSpillAnalysis >> runOn: codeNode [
	self traversePostorderCode: codeNode
]

{ #category : #traversing }
SoSpillAnalysis >> traverseBodyInstruction: instr [
	instr subNodes reverseDo: [ :sub |
		sub uses size > 1 ifTrue: [ ^ self ].
		sub isPhi ifTrue: [ 
			"For phis the problem is hard to tackle unless we start reordering them.
			 We just allow the simple common case to be spill to avoid common 
			 overhead in micro-benchmarks.
			 If instr is spilled we need to recursively check that it's the first subnode."
			instr isSpilled ifTrue: [ ^ self ].
			sub ~= instr subNodes first ifTrue: [ ^ self ] ].
		(self canSpill: sub from: instr) ifFalse: [ ^ self ].
		sub backend: SoSpill new ].
]

{ #category : #traversing }
SoSpillAnalysis >> traverseCFGInstruction: instr [
	^ self traverseBodyInstruction: instr
]

{ #category : #traversing }
SoSpillAnalysis >> traverseHeapAccess: access [
	access subNodes do: [ :s | s backend: SoTemp new ].
	access isWrite ifTrue: 
		[ access expression backend: ((access expression uses size = 1 and: [ access prevInstr == access expression ]) 
		 	ifTrue: [ SoSpill new ]
			ifFalse: [ SoTemp new ])].
]

{ #category : #public }
SoSpillAnalysis >> traverseInstruction: instr [
	(instr isCFGInstr not and: [instr backend isNil]) ifTrue: [ 
		instr uses 
			ifNotEmpty: [ instr backend: SoTemp new ]
			ifEmpty: [ instr backend: SoEffect new ] ].
	super traverseInstruction: instr
	
]

{ #category : #traversing }
SoSpillAnalysis >> traversePhi: phi [
	phi inputs do: [ :s | s backend: SoTemp new ]
]
