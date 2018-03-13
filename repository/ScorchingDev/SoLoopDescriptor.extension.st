Extension { #name : #SoLoopDescriptor }

{ #category : #'*ScorchingDev' }
SoLoopDescriptor >> printOn: s [
	s << 'Loop[' << range first << ';' << range last << ']{' << headBasicBlock postOrder << '}'
]
