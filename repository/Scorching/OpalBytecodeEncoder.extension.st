Extension { #name : #OpalBytecodeEncoder }

{ #category : #'*Scorching' }
OpalBytecodeEncoder >> bytecodes [
	^ stream contents
]

{ #category : #'*Scorching' }
OpalBytecodeEncoder >> sizeBranchIfInstanceOf: behaviors distance: distance [
	^self sizeOpcodeSelector: #genBranchIfInstanceOf:distance: withArguments: {behaviors.distance}
	
]

{ #category : #'*Scorching' }
OpalBytecodeEncoder >> sizeBranchIfNotInstanceOf: behaviors distance: distance [
	^self sizeOpcodeSelector: #genBranchIfNotInstanceOf:distance: withArguments: {behaviors.distance}
]
