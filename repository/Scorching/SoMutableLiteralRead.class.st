"
Mutable Literals may be real mutable literal (anootated with pragmas and stuff) or LiteralVariable. Mutable literal may be forwarders, hence the returned value of this instruction needs to be unforwarded before object access.
"
Class {
	#name : #SoMutableLiteralRead,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'literal',
		'type'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #accessing }
SoMutableLiteralRead >> basicTypeInformation [
	^ type == SoUnknownType default 
		ifFalse: [ type ]
		ifTrue: [ type := SoSingleHintType for: literal class ]
]

{ #category : #testing }
SoMutableLiteralRead >> hasEffect [
	^ false
]

{ #category : #traversing }
SoMutableLiteralRead >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseMutableLiteralRead: self
]

{ #category : #accessing }
SoMutableLiteralRead >> literal [
	<generated>
	^ literal
]

{ #category : #accessing }
SoMutableLiteralRead >> literal: aValue [
	<generated>
	literal := aValue
]

{ #category : #testing }
SoMutableLiteralRead >> okForBackEnsureEnoughSlots [
	^ true
]

{ #category : #comparison }
SoMutableLiteralRead >> sameExprAs: op [
	self class = op class ifFalse: [ ^ false ].
	^ literal == op literal
]

{ #category : #accessing }
SoMutableLiteralRead >> type [
	<generated>
	^ type
]

{ #category : #accessing }
SoMutableLiteralRead >> type: aValue [
	<generated>
	type := aValue
]
