Extension { #name : #SoPointerSunkObjectState }

{ #category : #'*ScorchingDev' }
SoPointerSunkObjectState class >> nodesWithDef [
	^ #(fixedFields array
		variableFields array)
]

{ #category : #'*ScorchingDev' }
SoPointerSunkObjectState >> printOn: s [
	s << 'Sunk ' << theClass name << ' in '.
	node printOn: s.
]
