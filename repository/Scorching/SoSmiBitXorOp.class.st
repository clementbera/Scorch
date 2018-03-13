Class {
	#name : #SoSmiBitXorOp,
	#superclass : #SoAbsSmiBitOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #traversing }
SoSmiBitXorOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiBitXorOp: self
]

{ #category : #primitive }
SoSmiBitXorOp >> primitiveNumber [
	<script>
	^ USmiBitXor
]

{ #category : #primitive }
SoSmiBitXorOp >> safePrimitiveNumber [
	<script>
	^ BitXor
]
