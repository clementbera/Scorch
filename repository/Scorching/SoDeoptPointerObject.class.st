"
I represent a specific subclass for poitner objects. I can refer to markers OR other deopt nodes.

fixedFields <Array of Marker|DeoptNode>
variableFields <Array of Marker|DeoptNode>
"
Class {
	#name : #SoDeoptPointerObject,
	#superclass : #SoAbsDeoptObject,
	#instVars : [
		'fixedFields',
		'variableFields'
	],
	#pools : [
		'SoMemoryManagerConstants'
	],
	#category : #'Scorching-Deoptimization'
}

{ #category : #visiting }
SoDeoptPointerObject >> accept: visitor [
	<script>
	^ visitor visitPointerObject: self
]

{ #category : #enumerating }
SoDeoptPointerObject >> allFieldsDo: aBlock [
	fixedFields , variableFields do: aBlock
]

{ #category : #deoptimization }
SoDeoptPointerObject >> asObjectTemplate [
	theClass == ContextClass ifTrue: [ 
		^ theClass newForMethod: (fixedFields at: 4) constant ].
	variableFields size = 0 ifTrue: [ ^ theClass basicNew ].
	^ theClass basicNew: variableFields size
	
]

{ #category : #accessing }
SoDeoptPointerObject >> fixedFields [
	<generated>
	^ fixedFields
]

{ #category : #accessing }
SoDeoptPointerObject >> fixedFields: aValue [
	<generated>
	fixedFields := SoDeoptArray from: aValue
]

{ #category : #accessing }
SoDeoptPointerObject >> variableFields [
	<generated>
	^ variableFields
]

{ #category : #accessing }
SoDeoptPointerObject >> variableFields: aValue [
	<generated>
	variableFields := SoDeoptArray from: aValue
]
