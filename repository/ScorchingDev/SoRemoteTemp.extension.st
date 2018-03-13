Extension { #name : #SoRemoteTemp }

{ #category : #'*ScorchingDev' }
SoRemoteTemp class >> nodesWithDef [
	^ #(tempVector value
		expression accessStrategy)
]
