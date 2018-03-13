Class {
	#name : #SoValueIfNotNilExpander,
	#superclass : #SoValueExpander,
	#category : #'ScorchingDev-macros-utils'
}

{ #category : #'macro-expansions' }
SoValueIfNotNilExpander >> expandSubNodes: instVarName on: stream [
	stream 
		<< '(' << instVarName 
		<< ' ifNil: [#()] ifNotNil: [ :it | { it } ])'
]
