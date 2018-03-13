"
Same as superclass with immutability check on write.
"
Class {
	#name : #SoReadOnlyCheckByteWrite,
	#superclass : #SoByteWrite,
	#instVars : [
		'deoptInfo'
	],
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #converting }
SoReadOnlyCheckByteWrite >> asInstrWithoutChecks [
	^ SoByteWrite new 	
		object: object;
		index: index;
		expression: expression;
		yourself
]

{ #category : #accessing }
SoReadOnlyCheckByteWrite >> deoptInfo [
	<generated>
	^ deoptInfo
]

{ #category : #accessing }
SoReadOnlyCheckByteWrite >> deoptInfo: aValue [
	<generated>
	aValue ifNotNil: [aValue instruction: self].
	deoptInfo := aValue
]

{ #category : #testing }
SoReadOnlyCheckByteWrite >> isMapped [
	^ true
]

{ #category : #traversing }
SoReadOnlyCheckByteWrite >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseReadOnlyCheckByteWrite: self
]

{ #category : #primitive }
SoReadOnlyCheckByteWrite >> primitiveNumber [
	^ 154
]
