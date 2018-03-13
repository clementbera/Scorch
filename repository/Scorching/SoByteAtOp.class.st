"
Answers byte at receiver's adress + numBytes in argument1.

"
Class {
	#name : #SoByteAtOp,
	#superclass : #SoAbsAccessingOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #type }
SoByteAtOp >> basicTypeInformation [
	^ SoType smi
]

{ #category : #testing }
SoByteAtOp >> hasRangeInformation [
	^ true
]

{ #category : #testing }
SoByteAtOp >> isAt [
	^ true
]

{ #category : #testing }
SoByteAtOp >> isRead [
	^ true
]

{ #category : #traversing }
SoByteAtOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseByteAtOp: self
]

{ #category : #primitive }
SoByteAtOp >> primitiveNumber [
	<script>
	^ UByteAt
]

{ #category : #type }
SoByteAtOp >> rangeInformation [
	^ SoRange new
		minConstant: 0;
		maxConstant: 255;
		yourself
		
]

{ #category : #primitive }
SoByteAtOp >> safePrimitiveNumber [
	<script>
	^ At
]
