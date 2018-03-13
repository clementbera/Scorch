"
Same as superclass but I require the outerContext context creation.

outerScopeMarker <Object> marks the identity of the outer scope
"
Class {
	#name : #SoCreateContextFullBlock,
	#superclass : #SoCreateFullBlock,
	#instVars : [
		'outerContextMarker'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #converting }
SoCreateContextFullBlock >> asSunkClosure [
	| sunk |
	sunk := super asSunkClosure.
	sunk fixedFields at: 1 put: outerContextMarker.
	^ sunk
]

{ #category : #traversing }
SoCreateContextFullBlock >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseCreateContextFullBlock: self
]

{ #category : #accessing }
SoCreateContextFullBlock >> outerContextMarker [
	<generated>
	^ outerContextMarker
]

{ #category : #accessing }
SoCreateContextFullBlock >> outerContextMarker: aValue [
	<generated>
	outerContextMarker := aValue
]
