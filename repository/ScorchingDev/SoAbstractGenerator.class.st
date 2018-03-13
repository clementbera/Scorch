"
Common superclass of various classes generating code.

Basically a shit load of scripts to generate methods, but saved in classes here not to be lost.
"
Class {
	#name : #SoAbstractGenerator,
	#superclass : #Object,
	#pools : [
		'SoGenerationSetting'
	],
	#category : #'ScorchingDev-macros'
}

{ #category : #utils }
SoAbstractGenerator >> macroExpanderFromSymbol: type [
	^ (Smalltalk at: ('So' , type capitalized , 'Expander') asSymbol) new
]

{ #category : #generating }
SoAbstractGenerator >> maybeAddPragma: s [
	AddPragma ifTrue: [ 
		s cr; tab.
		s << '<' << PragmaName << '>' ].
]
