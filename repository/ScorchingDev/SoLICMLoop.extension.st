Extension { #name : #SoLICMLoop }

{ #category : #'*ScorchingDev' }
SoLICMLoop >> printOn: s [
	s << 'Loop[' << range first << ';' << range last << ']{' << headBasicBlock postOrder << '}'
]
