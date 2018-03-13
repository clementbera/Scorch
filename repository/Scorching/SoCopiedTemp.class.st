"
Load the copied temp, done at stack frame creation. Used if the code to optimize is a block.

index <Smi> index of the copied temp
"
Class {
	#name : #SoCopiedTemp,
	#superclass : #SoAbsImmediateUses,
	#instVars : [
		'index'
	],
	#category : #'Scorching-Nodes'
}

{ #category : #accessing }
SoCopiedTemp >> index [
	<generated>
	^ index
]

{ #category : #accessing }
SoCopiedTemp >> index: aValue [
	<generated>
	index := aValue
]

{ #category : #traversing }
SoCopiedTemp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseCopiedTemp: self
]
