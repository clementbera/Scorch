"
I hold all the constants relatives to the bytecode set.

"
Class {
	#name : #SoSistaV1BytecodeSetConstants,
	#superclass : #SharedPool,
	#classVars : [
		'MaxNumTempsPerMethod',
		'SpecialReturnConstants',
		'SpecialSelectors'
	],
	#category : #'Scorching-Constants'
}

{ #category : #initialize }
SoSistaV1BytecodeSetConstants class >> initialize [
	"
	self initialize.
	"
	"maximum number of temporaries a method can have (compiled method header specification)"
	MaxNumTempsPerMethod := 64.
	"Constants that have bytecodes for single bytecode return"
	SpecialReturnConstants := #( true false nil ).
	"selector that can be encoded in a single bytecode send in the order they can be encoded."
	SpecialSelectors := #(#+ #- #< #> #'<=' #'>=' #= #'~=' #* #/ #'\\' #@ #bitShift: #'//' #bitAnd: #bitOr: #at: #at:put: #size #next #nextPut: #atEnd #'==' #class #blockCopy: #value #value: #do: #new #new: #x #y) 
]
