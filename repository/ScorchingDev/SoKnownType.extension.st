Extension { #name : #SoKnownType }

{ #category : #'*ScorchingDev' }
SoKnownType >> printOn: s [
	s << 'KnownType['.
	behaviors do: [ :b | s << b name ] separatedBy: [ s nextPut: $; ].
	s << ']'
]
