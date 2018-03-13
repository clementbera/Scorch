"
Ensure a specific number of words is available in Eden or triggers a scavenge.

numWords <Smi>
"
Class {
	#name : #SoEnsureEnoughSpace,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'numWords'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #testing }
SoEnsureEnoughSpace >> isEnsureEnoughSpace [
	^ true
]

{ #category : #traversing }
SoEnsureEnoughSpace >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseEnsureEnoughSpace: self
]

{ #category : #accessing }
SoEnsureEnoughSpace >> numWords [
	<generated>
	^ numWords
]

{ #category : #accessing }
SoEnsureEnoughSpace >> numWords: aValue [
	<generated>
	numWords := aValue
]
