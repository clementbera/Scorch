Extension { #name : #SoAbsImmediate }

{ #category : #'*ScorchingDev' }
SoAbsImmediate >> gtInspectorInstructionsIn: composite [
	<gtInspectorPresentationOrder: 6> 
	composite table 
		title: 'Instr'; "Instructions"
		display: (self printString)
]

{ #category : #'*ScorchingDev' }
SoAbsImmediate >> printOn: s [
	^ self shortPrintOn: s 
]
