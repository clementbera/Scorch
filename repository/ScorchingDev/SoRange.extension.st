Extension { #name : #SoRange }

{ #category : #'*ScorchingDev' }
SoRange >> printOn: s [
	s nextPut: $[.
	s << minConstant asString.
	s nextPut: $;.
	maxArraySize ifNotNil: [ :m | maxArraySize shortPrintOn: s. s << ' + ' ].
	s << maxConstant asString.
	s nextPut: $]
]
