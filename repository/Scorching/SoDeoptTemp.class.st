"
I represent a value on stack at the given index (thisContext tempAt: index)

index <Smi> index in the optimised context
"
Class {
	#name : #SoDeoptTemp,
	#superclass : #SoAbsDeoptNode,
	#instVars : [
		'index'
	],
	#category : #'Scorching-Deoptimization'
}

{ #category : #visiting }
SoDeoptTemp >> accept: visitor [
	<script>
	^ visitor visitTemp: self
]

{ #category : #accessing }
SoDeoptTemp >> index [
	<generated>
	^ index
]

{ #category : #accessing }
SoDeoptTemp >> index: aValue [
	<generated>
	index := aValue
]
