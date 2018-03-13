Class {
	#name : #SoSmiLessOrEqualOp,
	#superclass : #SoAbsSmiCompOp,
	#category : #'Scorching-Nodes-SmiOp'
}

{ #category : #testing }
SoSmiLessOrEqualOp >> isSmiLessOrLessOrEqual [
	^ true
]

{ #category : #traversing }
SoSmiLessOrEqualOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSmiLessOrEqualOp: self
]

{ #category : #primitive }
SoSmiLessOrEqualOp >> primitiveNumber [
	<script>
	^ USmiLessOrEqual
]

{ #category : #primitive }
SoSmiLessOrEqualOp >> safePrimitiveNumber [
	<script>
	^ LessOrEqual
]
