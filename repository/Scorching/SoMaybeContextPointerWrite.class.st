"
Same as superclass but the object *can* be a context. This is typically used for writes inside Contexts or Context>>tempAt:put:.
"
Class {
	#name : #SoMaybeContextPointerWrite,
	#superclass : #SoPointerWrite,
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #traversing }
SoMaybeContextPointerWrite >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseMaybeContextPointerWrite: self
]

{ #category : #primitive }
SoMaybeContextPointerWrite >> primitiveNumber [
	^ 3002 + storeCheck asBit
]
