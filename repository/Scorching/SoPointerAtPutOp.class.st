"
Set argument2 to receiver's adress + numWords in argument1. Answers argument2.

"
Class {
	#name : #SoPointerAtPutOp,
	#superclass : #SoAbsAccessingOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #type }
SoPointerAtPutOp >> basicTypeInformation [
	^ self arguments second basicTypeInformation
]

{ #category : #testing }
SoPointerAtPutOp >> canBeRemovedIfNoUses [
	^ false
]

{ #category : #testing }
SoPointerAtPutOp >> hasEffect [
	^ true
]

{ #category : #testing }
SoPointerAtPutOp >> isAtPut [
	^ true
]

{ #category : #traversing }
SoPointerAtPutOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traversePointerAtPutOp: self
]

{ #category : #testing }
SoPointerAtPutOp >> isWrite [
	^ true
]

{ #category : #primitive }
SoPointerAtPutOp >> primitiveNumber [
	<script>
	^ UPointerAtPut
]

{ #category : #primitive }
SoPointerAtPutOp >> safePrimitiveNumber [
	<script>
	^ AtPut
]
