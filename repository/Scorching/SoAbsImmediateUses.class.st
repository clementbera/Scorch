"
Subclass of immediate where uses are tracked down. Uses are required for type inference.
"
Class {
	#name : #SoAbsImmediateUses,
	#superclass : #SoAbsImmediate,
	#instVars : [
		'uses',
		'type'
	],
	#category : #'Scorching-Nodes'
}

{ #category : #accessing }
SoAbsImmediateUses >> addUse: use [
	uses add: use
]

{ #category : #types }
SoAbsImmediateUses >> basicTypeInformation [
	^ type
]

{ #category : #initialization }
SoAbsImmediateUses >> initialize [

	super initialize.

	uses := OrderedCollection new.
	type := SoUnknownType default
]

{ #category : #accessing }
SoAbsImmediateUses >> removeUse: use [
	uses remove: use
]

{ #category : #accessing }
SoAbsImmediateUses >> type [
	<generated>
	^ type
]

{ #category : #accessing }
SoAbsImmediateUses >> type: aValue [
	<generated>
	type := aValue
]

{ #category : #accessing }
SoAbsImmediateUses >> uses [
	<generated>
	^ uses
]

{ #category : #accessing }
SoAbsImmediateUses >> uses: aValue [
	<generated>
	uses := aValue
]
