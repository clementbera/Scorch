Extension { #name : #SoDeoptPointerObject }

{ #category : #'*ScorchingDev' }
SoDeoptPointerObject class >> ignoreAccessorNames [
	^ #(fixedFields variableFields)
]

{ #category : #'*ScorchingDev' }
SoDeoptPointerObject >> printOn: s [
	s << 'PObj(' << theClass name << ')'
]
