Extension { #name : #SoBasicBlock }

{ #category : #'*ScorchingDev' }
SoBasicBlock >> bbNumber [
	^ [ codeNode basicBlocks identityIndexOf: self ]
			on: Error 
			do: [ 0 ]
]

{ #category : #'*ScorchingDev' }
SoBasicBlock >> debugSchedulingChildren [
	^ self instructions
]

{ #category : #'*ScorchingDev' }
SoBasicBlock >> gtInspectorSchedulingIn: composite [
	<gtInspectorPresentationOrder: 9>  
	^ composite tree
		rootsExpanded;
		children: [ :each | each debugSchedulingChildren ];
		title: 'Scheduling'.		
]

{ #category : #'*ScorchingDev' }
SoBasicBlock class >> ignoreAccessorNames [
	^ #(firstInstr)
]

{ #category : #'*ScorchingDev' }
SoBasicBlock >> instructions [
	| instrs |
	instrs := OrderedCollection new.
	self instructionsDo: [ :instr |
		instrs add: instr ].
	^ instrs
]

{ #category : #'*ScorchingDev' }
SoBasicBlock >> printOn: s [
	s << 'BasicBlock ' << self printingNumber
]

{ #category : #'*ScorchingDev' }
SoBasicBlock >> printingNumber [
	^ [ (codeNode basicBlocks identityIndexOf: self) printString ]
			on: Error 
			do: [ '?' ]
]
