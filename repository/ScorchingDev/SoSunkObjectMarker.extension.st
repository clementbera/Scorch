Extension { #name : #SoSunkObjectMarker }

{ #category : #'*ScorchingDev' }
SoSunkObjectMarker >> printOn: s [
	s << 'Marker(' << self basicIdentityHash << ')' 
]
