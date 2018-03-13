"
Answers object at receiver's adress + numWords in argument1.

"
Class {
	#name : #SoPointerAtOp,
	#superclass : #SoAbsAccessingOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #type }
SoPointerAtOp >> basicTypeInformation [
	receiver isConstant ifFalse: [ ^ SoUnknownType default ].
	receiver constant class == Array ifFalse: [ ^ SoUnknownType default ].
	^ SoKnownType forArray: (receiver constant collect: [ :val | val class ]) asSet asArray 
]

{ #category : #testing }
SoPointerAtOp >> isAt [
	^ true
]

{ #category : #testing }
SoPointerAtOp >> isRead [
	^ true
]

{ #category : #traversing }
SoPointerAtOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traversePointerAtOp: self
]

{ #category : #primitive }
SoPointerAtOp >> primitiveNumber [
	<script>
	^ UPointerAt
]

{ #category : #primitive }
SoPointerAtOp >> safePrimitiveNumber [
	<script>
	^ At
]
