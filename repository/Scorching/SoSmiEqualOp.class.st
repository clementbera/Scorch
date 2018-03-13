Class {
	#name : #SoSmiEqualOp,
	#superclass : #SoAbsSmiCompOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiEqualOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiEqualOp: self
]

{ #category : #primitive }
SoSmiEqualOp >> primitiveNumber [
	<script>
	^ USmiEqual
]

{ #category : #primitive }
SoSmiEqualOp >> safePrimitiveNumber [
	<script>
	^ Equal
]
