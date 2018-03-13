"
Same as superclass but the object *can* be a context. This is typically used for reads inside Contexts or Context>>tempAt:.
"
Class {
	#name : #SoMaybeContextPointerRead,
	#superclass : #SoPointerRead,
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #types }
SoMaybeContextPointerRead >> basicTypeInformation [
	type == SoUnknownType default ifFalse: [ ^ type ].
	index = 0 ifTrue: [ ^ type := SoSingleHintType for: Context ].				"sender"
	index = 1 ifTrue: [ ^ type := SoSingleHintType for: SmallInteger ].			"pc"
	index = 2 ifTrue: [ ^ type := SoSingleHintType for: SmallInteger ].			"stackp"
	index = 3 ifTrue: [ ^ type := SoHierarchyHintType for: CompiledCode ].	"method"
	index = 4 ifTrue: [ ^ type := SoSingleHintType for: FullBlockClosure ].		"closureOrNil"
	index = 5 ifTrue: [ ^ type := SoUnknownType default ].					"receiver"
	^ type
]

{ #category : #traversing }
SoMaybeContextPointerRead >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseMaybeContextPointerRead: self
]

{ #category : #primitive }
SoMaybeContextPointerRead >> primitiveNumber [
	^ 2065
]
