"
I reprensent generic writes. deoptInfo for the immutability call-back.

deoptInfo <DeoptimizationInformation> If not nil, the object mutated can be immutable. 
"
Class {
	#name : #SoWrite,
	#superclass : #SoRTWrite,
	#instVars : [
		'deoptInfo'
	],
	#category : #'Scorching-Nodes-AccessStrategy'
}

{ #category : #accessing }
SoWrite >> deoptInfo [
	<generated>
	^ deoptInfo
]

{ #category : #accessing }
SoWrite >> deoptInfo: aValue [
	<generated>
	aValue ifNotNil: [aValue sunkObjects do: [ :sunkObj | sunkObj node: self ] ].
	deoptInfo := aValue
]

{ #category : #testing }
SoWrite >> isDefaultStore [
	^ super isDefaultStore and: [ true "deoptInfo notNil" "immutability check required" ]
]
