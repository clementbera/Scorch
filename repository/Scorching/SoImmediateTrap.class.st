"
If the execution flow reaches this instruction, the trap call back is sent into the image. This instruction can't fall through (deoptimization is required)

deoptInfo <DeoptimizationInformation>
"
Class {
	#name : #SoImmediateTrap,
	#superclass : #SoAbsCFGInstruction,
	#instVars : [
		'deoptInfo'
	],
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #accessing }
SoImmediateTrap >> deoptInfo [
	<generated>
	^ deoptInfo
]

{ #category : #accessing }
SoImmediateTrap >> deoptInfo: aValue [
	<generated>
	aValue ifNotNil: [aValue sunkObjects do: [ :sunkObj | sunkObj node: self ] ].
	deoptInfo := aValue
]

{ #category : #traversing }
SoImmediateTrap >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseImmediateTrap: self
]
