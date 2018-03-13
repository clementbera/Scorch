Class {
	#name : #SoArrayCopyOp,
	#superclass : #SoAbsUnsafeOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #types }
SoArrayCopyOp >> basicTypeInformation [
	^ receiver basicTypeInformation
]

{ #category : #testing }
SoArrayCopyOp >> hasEffect [
	^ true
]

{ #category : #traversing }
SoArrayCopyOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseArrayCopyOp: self
]

{ #category : #primitive }
SoArrayCopyOp >> primitiveNumber [
	^ 5000
]
