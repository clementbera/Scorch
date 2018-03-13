"
Inlined primitive for new:

Work with ByteArray, Arrays and Mixed Pointer objects.

Note that this operation fails if the object to instantiate cannot be allocated in young space (>65k or not enough space) crashing the VM.
"
Class {
	#name : #SoAbsNewColon,
	#superclass : #SoAbsInstantiation,
	#instVars : [
		'sized'
	],
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #'graph edition' }
SoAbsNewColon >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	sized := anotherNode.
	anotherNode addUse: self
]

{ #category : #testing }
SoAbsNewColon >> hasExactSize [
	^ sized isConstant
]

{ #category : #testing }
SoAbsNewColon >> hasSizeInformation [
	^ self sized isSmiConstant 
]

{ #category : #accessing }
SoAbsNewColon >> instSize [
	^ sized constant
]

{ #category : #primitive }
SoAbsNewColon >> primitiveNumber [
	^ 2048 + needsInit not asBit
]

{ #category : #testing }
SoAbsNewColon >> sizeInformation [
	^ sized constant
]

{ #category : #accessing }
SoAbsNewColon >> sized [
	<generated>
	^ sized
]

{ #category : #accessing }
SoAbsNewColon >> sized: aValue [
	<generated>
	sized := aValue.
	sized  addUse: self
]

{ #category : #'graph edition' }
SoAbsNewColon >> subNodes [
	<generated>
	^ {sized}
]

{ #category : #'graph edition' }
SoAbsNewColon >> subNodesAnySatisfy: aBlock [
	"profiling"
	<generated>
	^aBlock value: sized.
	
]

{ #category : #'graph edition' }
SoAbsNewColon >> subNodesDo: aBlock [
	"profiling"
	<generated>
	aBlock value: sized
]

{ #category : #'graph edition' }
SoAbsNewColon >> subNodesSize [
	<generated>
	^ 1
]
