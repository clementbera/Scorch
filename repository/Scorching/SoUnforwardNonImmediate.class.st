"
Specific subclass used historically for Literal Variable.
"
Class {
	#name : #SoUnforwardNonImmediate,
	#superclass : #SoUnforward,
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #traversing }
SoUnforwardNonImmediate >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseUnforwardNonImmediate: self
]

{ #category : #primitive }
SoUnforwardNonImmediate >> primitiveNumber [
	^ 1039
]
