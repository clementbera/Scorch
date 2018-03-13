"
I am used to generate code given some description of instance variables.
"
Class {
	#name : #SoMacroExpander,
	#superclass : #Object,
	#pools : [
		'SoGenerationSetting'
	],
	#category : #'ScorchingDev-macros-utils'
}

{ #category : #'macro-expansions' }
SoMacroExpander >> expandReplaceSubNode: instVarName last: isLast on: stream [
	self subclassResponsibility
]

{ #category : #'macro-expansions' }
SoMacroExpander >> expandSubNodes: instVarName on: stream [
	self subclassResponsibility
]

{ #category : #generating }
SoMacroExpander >> generateDefUseSetter: varName class: aClass [
	self subclassResponsibility
]

{ #category : #generating }
SoMacroExpander >> maybeAddPragma: s [
	AddPragma ifTrue: [ 
		s cr; tab.
		s << '<' << PragmaName << '>' ].
]
