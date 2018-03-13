Class {
	#name : #SoAbsCall,
	#superclass : #SoAbsOp,
	#instVars : [
		'loopDepth',
		'deoptInfo'
	],
	#category : #'Scorching-Nodes-Op'
}

{ #category : #accessing }
SoAbsCall >> deoptInfo [
	<generated>
	^ deoptInfo
]

{ #category : #accessing }
SoAbsCall >> deoptInfo: aValue [
	<generated>
	aValue ifNotNil: [aValue instruction: self].
	deoptInfo := aValue
]

{ #category : #testing }
SoAbsCall >> isCall [
	^ true
]

{ #category : #testing }
SoAbsCall >> isEscapeFor: node [
	^ true
]

{ #category : #accessing }
SoAbsCall >> loopDepth [
	<generated>
	^ loopDepth
]

{ #category : #accessing }
SoAbsCall >> loopDepth: aValue [
	<generated>
	loopDepth := aValue
]
