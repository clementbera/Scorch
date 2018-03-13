"
Access to the inst var of a context, could require specific code in the VM if the context is married.
"
Class {
	#name : #SoContextInstVar,
	#superclass : #SoInstVar,
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #type }
SoContextInstVar >> basicTypeInformation [
	type == SoUnknownType default ifFalse: [ :it | ^ it ].
	index = 0 ifTrue: [ ^ type := SoSingleHintType for: Context ].				"sender"
	index = 1 ifTrue: [ ^ type := SoSingleHintType for: SmallInteger ].			"pc"
	index = 2 ifTrue: [ ^ type := SoSingleHintType for: SmallInteger ].			"stackp"
	index = 3 ifTrue: [ ^ type := SoHierarchyHintType for: CompiledCode ].	"method"
	index = 4 ifTrue: [ ^ type := SoSingleHintType for: FullBlockClosure ].		"closureOrNil"
	index = 5 ifTrue: [ ^ type := SoUnknownType default ].						"receiver"
	^ type
]

{ #category : #testing }
SoContextInstVar >> isContextStore [
	^ true
]

{ #category : #traversing }
SoContextInstVar >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseContextInstVar: self
]
