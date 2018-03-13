Class {
	#name : #SoSmiNotEqualOp,
	#superclass : #SoAbsSmiCompOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiNotEqualOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiNotEqualOp: self
]

{ #category : #primitive }
SoSmiNotEqualOp >> primitiveNumber [
	<script>
	^ USmiNotEqual
]

{ #category : #primitive }
SoSmiNotEqualOp >> safePrimitiveNumber [
	<script>
	^ NotEqual
]
