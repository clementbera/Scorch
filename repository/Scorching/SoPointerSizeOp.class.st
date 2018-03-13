"
Answers the number of slots including the inst var fields for pointer objects. 
"
Class {
	#name : #SoPointerSizeOp,
	#superclass : #SoAbsSizeOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #traversing }
SoPointerSizeOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traversePointerSizeOp: self
]

{ #category : #accessing }
SoPointerSizeOp >> maxSmi [
	^ MaxArraySize
]

{ #category : #primitive }
SoPointerSizeOp >> primitiveNumber [
	<script>
	^ UPointerSize
]

{ #category : #primitive }
SoPointerSizeOp >> safePrimitiveNumber [
	<script>
	^ Size
]
