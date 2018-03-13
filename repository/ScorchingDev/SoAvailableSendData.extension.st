Extension { #name : #SoAvailableSendData }

{ #category : #'*ScorchingDev' }
SoAvailableSendData >> printOn: s [
	s << 'SendData('.
	self behaviors 
		do: [:b | s << b name ]
		separatedBy: [ s << ';' ].
	s nextPut: $)
]
