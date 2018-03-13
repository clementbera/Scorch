"
Access to a global

assoc <Association>
"
Class {
	#name : #SoGlobal,
	#superclass : #SoHeapAccess,
	#instVars : [
		'assoc'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #accessing }
SoGlobal >> accessID [
	^ assoc
]

{ #category : #accessing }
SoGlobal >> assoc [
	<generated>
	^ assoc
]

{ #category : #accessing }
SoGlobal >> assoc: aValue [
	<generated>
	assoc := aValue
]

{ #category : #type }
SoGlobal >> basicTypeInformation [
	^ type == SoUnknownType default
		ifTrue: [ type := SoSingleHintType for: assoc value class ]
		ifFalse: [ type ]
]

{ #category : #testing }
SoGlobal >> isGlobal [
	^ true
]

{ #category : #traversing }
SoGlobal >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseGlobal: self
]
