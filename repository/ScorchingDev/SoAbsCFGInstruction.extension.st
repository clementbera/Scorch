Extension { #name : #SoAbsCFGInstruction }

{ #category : #'*ScorchingDev' }
SoAbsCFGInstruction >> debugSchedulingChildren [
	^ super debugSchedulingChildren , self successors
]
