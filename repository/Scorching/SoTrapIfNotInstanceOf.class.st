"
Expanded at bytecode generation time to a jumpIfInstanceOf.

behaviors <Array of Behaviors> expected types.
"
Class {
	#name : #SoTrapIfNotInstanceOf,
	#superclass : #SoAbsTrapIf,
	#instVars : [
		'behaviors'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #accessing }
SoTrapIfNotInstanceOf >> behaviors [
	<generated>
	^ behaviors
]

{ #category : #accessing }
SoTrapIfNotInstanceOf >> behaviors: aValue [
	<generated>
	behaviors := aValue
]

{ #category : #testing }
SoTrapIfNotInstanceOf >> canLocallySpecifyType [
	^ true
]

{ #category : #testing }
SoTrapIfNotInstanceOf >> isTrapIfNotInstanceOf [
	^ true
]

{ #category : #traversing }
SoTrapIfNotInstanceOf >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseTrapIfNotInstanceOf: self
]

{ #category : #type }
SoTrapIfNotInstanceOf >> maybeSpecifyType: typeFound for: send [
	(self strictlyDominates: send) ifTrue: [ 
		^ typeFound intersection: (SoKnownType forArray: behaviors) ].
	^ typeFound
]

{ #category : #testing }
SoTrapIfNotInstanceOf >> maybeWorthSplitting [
	^ true
]

{ #category : #testing }
SoTrapIfNotInstanceOf >> okForBackEnsureEnoughSlots [
	^ true
]

{ #category : #comparing }
SoTrapIfNotInstanceOf >> sameExprAs: op [
	op class = self class ifFalse: [ ^ false ].
	op expression = expression ifFalse: [ ^ false ].
	(behaviors includesAll: op behaviors) ifFalse: [ ^ false ].
	^ op behaviors includesAll: behaviors
]

{ #category : #testing }
SoTrapIfNotInstanceOf >> specifyTypeOfExpressionAt: instr [
	^ self strictlyDominates: instr
]
