"
i represent a constant.

constant <Literal> constant I represent
"
Class {
	#name : #SoDeoptConstant,
	#superclass : #SoAbsDeoptNode,
	#instVars : [
		'constant'
	],
	#category : #'Scorching-Deoptimization'
}

{ #category : #visiting }
SoDeoptConstant >> accept: visitor [
	<script>
	^ visitor visitConstant: self
]

{ #category : #accessing }
SoDeoptConstant >> constant [
	<generated>
	^ constant
]

{ #category : #accessing }
SoDeoptConstant >> constant: aValue [
	<generated>
	constant := aValue
]
