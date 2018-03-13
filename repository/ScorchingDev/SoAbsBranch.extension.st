Extension { #name : #SoAbsBranch }

{ #category : #'*ScorchingDev' }
SoAbsBranch class >> ignoreAccessorNames [
	^ #(falseBasicBlock trueBasicBlock)
]

{ #category : #'*ScorchingDev' }
SoAbsBranch class >> nodesWithDef [
	^ #(expression value)
]
