Extension { #name : #SoConstant }

{ #category : #'*ScorchingDev' }
SoConstant >> printOn: s [
	s << 'Cst:'.
	constant printOn: s
]

{ #category : #'*ScorchingDev' }
SoConstant >> shortPrintOn: stream [
	 | print |
	print := constant printString.
	print size > 25
		ifTrue: [ stream << (print first: 15) << ' ... ' << (print last: 5) ]
		ifFalse: [ constant printOn: stream ]
	
]
