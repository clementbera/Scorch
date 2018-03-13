"
Load the argument of the method or block. Done by stack frame creation. 

index <Smi> index of the argument
"
Class {
	#name : #SoArg,
	#superclass : #SoAbsImmediateUses,
	#instVars : [
		'index'
	],
	#category : #'Scorching-Nodes'
}

{ #category : #converting }
SoArg >> asDeopt [
	^ SoDeoptTemp new
		index: index + 1;
		yourself
]

{ #category : #accessing }
SoArg >> index [
	<generated>
	^ index
]

{ #category : #accessing }
SoArg >> index: aValue [
	<generated>
	index := aValue
]

{ #category : #initialization }
SoArg >> initialize [

	super initialize.

	type := SoUnknownType default
]

{ #category : #testing }
SoArg >> isArg [
	^ true
]

{ #category : #traversing }
SoArg >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseArg: self
]

{ #category : #printing }
SoArg >> shortPrintOn: stream [
	stream << 'arg'.
	index printOn: stream
]
