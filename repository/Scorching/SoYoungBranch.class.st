"
If the expression is a young object, jumps to trueBasicBlock, else to the other
"
Class {
	#name : #SoYoungBranch,
	#superclass : #SoAbsBranch,
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #primitive }
SoYoungBranch >> invertedPrimitiveNumber [
	^ 7018
]

{ #category : #traversing }
SoYoungBranch >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseYoungBranch: self
]

{ #category : #testing }
SoYoungBranch >> isYoungBranch [
	^ true
]

{ #category : #primitive }
SoYoungBranch >> primitiveNumber [
	^ 7019
]
