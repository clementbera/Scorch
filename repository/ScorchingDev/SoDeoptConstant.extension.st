Extension { #name : #SoDeoptConstant }

{ #category : #'*ScorchingDev' }
SoDeoptConstant >> printOn: s [
	s << 'cst:' << constant printString
]
