"
Access to a mutable literal, we have no assumption on such literals so we need to schedule the reads.
"
Class {
	#name : #SoMutableLiteral,
	#superclass : #SoHeapAccess,
	#instVars : [
		'literal'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #accessing }
SoMutableLiteral >> accessID [
	^ literal
]

{ #category : #accessing }
SoMutableLiteral >> basicTypeInformation [
	^ type == SoUnknownType default 
		ifFalse: [ type ]
		ifTrue: [ type := SoSingleHintType for: literal class ]
]

{ #category : #traversing }
SoMutableLiteral >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseMutableLiteral: self
]

{ #category : #accessing }
SoMutableLiteral >> literal [
	<generated>
	^ literal
]

{ #category : #accessing }
SoMutableLiteral >> literal: aValue [
	<generated>
	literal := aValue
]
