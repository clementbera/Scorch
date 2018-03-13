Extension { #name : #SoAbsInstruction }

{ #category : #'*ScorchingDev' }
SoAbsInstruction >> debugSchedulingChildren [
	^ self subNodes
]

{ #category : #'*ScorchingDev' }
SoAbsInstruction >> printOn: s [
	SoPrettyPrinter new printInstruction: self on: s
]
