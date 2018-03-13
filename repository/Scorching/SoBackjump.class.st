"
unconditional jump at the end of the basic block that jumps backward.

deoptInfo is there if the backjump is interrupted.

deoptInfo <DeoptimizationInformation>
"
Class {
	#name : #SoBackjump,
	#superclass : #SoAbsUnconditionalJump,
	#instVars : [
		'deoptInfo'
	],
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #accessing }
SoBackjump >> deoptInfo [
	<generated>
	^ deoptInfo
]

{ #category : #accessing }
SoBackjump >> deoptInfo: aValue [
	<generated>
	aValue ifNotNil: [aValue sunkObjects do: [ :sunkObj | sunkObj node: self ] ].
	deoptInfo := aValue
]

{ #category : #testing }
SoBackjump >> isBackjump [
	^ true
]

{ #category : #traversing }
SoBackjump >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseBackjump: self
]
