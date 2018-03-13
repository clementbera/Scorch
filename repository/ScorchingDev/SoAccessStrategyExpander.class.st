Class {
	#name : #SoAccessStrategyExpander,
	#superclass : #SoMacroExpander,
	#category : #'ScorchingDev-macros-utils'
}

{ #category : #'as yet unclassified' }
SoAccessStrategyExpander >> expandReplaceSubNode: instVarName last: isLast on: stream [
	self assert: isLast.
	stream << 'accessStrategy ' << instVarName << ': anotherNode.'.
	stream cr;tab.
	^ stream << 'anotherNode addUse: self' 
	
]

{ #category : #'as yet unclassified' }
SoAccessStrategyExpander >> expandSubNodes: instVarName on: stream [
	stream << 'accessStrategy subNodes'
]
