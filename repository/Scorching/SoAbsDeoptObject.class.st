"
I represent an object to reconstruct. I can refer to markers OR other deopt nodes.

theClass <Behavior>
marker<SunkObjectMarker> unique id for the object
"
Class {
	#name : #SoAbsDeoptObject,
	#superclass : #SoAbsDeoptNode,
	#instVars : [
		'marker',
		'theClass'
	],
	#category : #'Scorching-Deoptimization'
}

{ #category : #enumerating }
SoAbsDeoptObject >> allFieldsDo: ablock [
	"nothing"
]

{ #category : #deoptimization }
SoAbsDeoptObject >> asObjectTemplate [
	self subclassResponsibility 
]

{ #category : #accessing }
SoAbsDeoptObject >> marker [
	<generated>
	^ marker
]

{ #category : #accessing }
SoAbsDeoptObject >> marker: aValue [
	<generated>
	marker := aValue
]

{ #category : #accessing }
SoAbsDeoptObject >> theClass [
	<generated>
	^ theClass
]

{ #category : #accessing }
SoAbsDeoptObject >> theClass: aValue [
	<generated>
	theClass := aValue
]
