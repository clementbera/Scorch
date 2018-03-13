"
Set argument2 at byte at receiver's adress + numBytes in argument1. Answers argument2.

"
Class {
	#name : #SoByteAtPutOp,
	#superclass : #SoAbsAccessingOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #type }
SoByteAtPutOp >> basicTypeInformation [
	^ self arguments second basicTypeInformation
]

{ #category : #testing }
SoByteAtPutOp >> canBeRemovedIfNoUses [
	^ false
]

{ #category : #testing }
SoByteAtPutOp >> hasEffect [
	^ true
]

{ #category : #testing }
SoByteAtPutOp >> isAtPut [
	^ true
]

{ #category : #traversing }
SoByteAtPutOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseByteAtPutOp: self
]

{ #category : #testing }
SoByteAtPutOp >> isWrite [
	^ true
]

{ #category : #primitive }
SoByteAtPutOp >> primitiveNumber [
	<script>
	^ UByteAtPut
]

{ #category : #primitive }
SoByteAtPutOp >> safePrimitiveNumber [
	<script>
	^ AtPut
]
