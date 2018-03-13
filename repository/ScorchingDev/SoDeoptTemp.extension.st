Extension { #name : #SoDeoptTemp }

{ #category : #'*ScorchingDev' }
SoDeoptTemp >> printOn: s [
	s << 'temp(' << index printString << ')'
]
