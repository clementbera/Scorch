"
I am the common superclass of the passes setting dominators to basicBlocks
"
Class {
	#name : #SoAbstractDominators,
	#superclass : #Object,
	#category : #'Scorching-Pass-Utils'
}

{ #category : #public }
SoAbstractDominators >> runOn: codeNode [
	self findDominators: codeNode basicBlocks
]
