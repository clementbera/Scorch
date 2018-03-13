Class {
	#name : #SoSmiBitOrOp,
	#superclass : #SoAbsSmiBitOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiBitOrOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiBitOrOp: self
]

{ #category : #primitive }
SoSmiBitOrOp >> primitiveNumber [
	<script>
	^ USmiBitOr
]

{ #category : #primitive }
SoSmiBitOrOp >> safePrimitiveNumber [
	<script>
	^ BitOr
]
