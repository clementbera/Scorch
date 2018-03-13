Extension { #name : #SoTemp }

{ #category : #'*ScorchingDev' }
SoTemp >> printOn: s [
	s << '(temp ' << (tempIndex ifNil: [ '?' ]) << ')'
]
