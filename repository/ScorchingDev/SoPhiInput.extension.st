Extension { #name : #SoPhiInput }

{ #category : #'*ScorchingDev' }
SoPhiInput >> printOn: stream [
	input shortPrintOn: stream.
	stream nextPut: $' .
	stream << basicBlock printingNumber.
	stream << ' in '.
	phi shortPrintOn: stream
]
