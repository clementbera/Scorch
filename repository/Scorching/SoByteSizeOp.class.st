"
Answers the number of bytes including the inst var fields for byte objects (and compiledMethods ?). 
"
Class {
	#name : #SoByteSizeOp,
	#superclass : #SoAbsSizeOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #traversing }
SoByteSizeOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseByteSizeOp: self
]

{ #category : #accessing }
SoByteSizeOp >> maxSmi [
	^ MaxByteArraySize
]

{ #category : #primitive }
SoByteSizeOp >> primitiveNumber [
	<script>
	^ UByteSize
]

{ #category : #primitive }
SoByteSizeOp >> safePrimitiveNumber [
	<script>
	^ Size
]
