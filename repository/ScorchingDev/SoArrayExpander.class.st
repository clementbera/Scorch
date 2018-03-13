Class {
	#name : #SoArrayExpander,
	#superclass : #SoMacroExpander,
	#category : #'ScorchingDev-macros-utils'
}

{ #category : #'macro-expansions' }
SoArrayExpander >> expandReplaceSubNode: instVarName last: isLast on: stream [
	self assert: isLast.
	stream 
		<< instVarName << ' at: (' << instVarName 
		<< ' identityIndexOf: node) put: anotherNode.'.
	stream cr;tab.
	stream << 'anotherNode addUse: self.'.
]

{ #category : #'macro-expansions' }
SoArrayExpander >> expandSubNodes: instVarName on: stream [
	stream << instVarName
]

{ #category : #'macro-expansions' }
SoArrayExpander >> generateDefUseSetter: varName class: aClass [
	| s |
	s := '' writeStream.
	s << varName << ': aValue' .
	self maybeAddPragma: s.
	s << String cr << String tab << varName << ' := aValue.'.
	s << String cr << String tab << varName << ' do: [  :each | each addUse: self ]'.
	aClass compile: s contents classified: #accessing
]
