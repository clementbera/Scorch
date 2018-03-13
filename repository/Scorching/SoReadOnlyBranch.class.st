"
If the expression is a read-only object, jumps to trueBasicBlock, else to the other
"
Class {
	#name : #SoReadOnlyBranch,
	#superclass : #SoAbsBranch,
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #primitive }
SoReadOnlyBranch >> invertedPrimitiveNumber [
	^ 7017
]

{ #category : #testing }
SoReadOnlyBranch >> isReadOnlyBranch [
	^ true
]

{ #category : #traversing }
SoReadOnlyBranch >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseReadOnlyBranch: self
]

{ #category : #primitive }
SoReadOnlyBranch >> primitiveNumber [
	^ 7016
]
