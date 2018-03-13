"
Setting related to code generation
	AddPragma <Boolean> Do we add a pragma to all generated methods ?
	PragmaName <String> name of the pragma for generated methods.
"
Class {
	#name : #SoGenerationSetting,
	#superclass : #SharedPool,
	#classVars : [
		'AddPragma',
		'PragmaName'
	],
	#category : #'ScorchingDev-macros'
}

{ #category : #'class initialization' }
SoGenerationSetting class >> initialize [
	AddPragma := true.
	PragmaName := #generated
]
