Class {
	#name : #SoValueExpander,
	#superclass : #SoMacroExpander,
	#category : #'ScorchingDev-macros-utils'
}

{ #category : #'macro-expansions' }
SoValueExpander >> expandReplaceSubNode: instVarName last: isLast on: stream [
	isLast ifTrue: [ 
		stream << instVarName << ' := anotherNode.'.
		stream cr;tab.
		^ stream << 'anotherNode addUse: self' ].
	
	stream << instVarName << ' == node ifTrue: [ '.
	stream cr;tab;tab.
	stream << instVarName << ' := anotherNode.'.
	stream cr;tab;tab.
	stream << '^ anotherNode addUse: self ].'.
	stream cr;tab
]

{ #category : #'macro-expansions' }
SoValueExpander >> expandSubNodes: instVarName on: stream [
	stream << '{' << instVarName << '}'
]

{ #category : #'macro-expansions' }
SoValueExpander >> generateDefUseSetter: varName class: aClass [
	| s |
	s := '' writeStream.
	s << varName << ': aValue' .
	self maybeAddPragma: s.
	s << String cr << String tab << varName << ' := aValue.'.
	s << String cr << String tab << varName << '  addUse: self'.
	aClass compile: s contents classified: #accessing
]
