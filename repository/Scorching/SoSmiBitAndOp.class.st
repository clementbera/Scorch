Class {
	#name : #SoSmiBitAndOp,
	#superclass : #SoAbsSmiBitOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiBitAndOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiBitAndOp: self
]

{ #category : #primitive }
SoSmiBitAndOp >> primitiveNumber [
	<script>
	^ USmiBitAnd
]

{ #category : #primitive }
SoSmiBitAndOp >> safePrimitiveNumber [
	<script>
	^ BitAnd
]
