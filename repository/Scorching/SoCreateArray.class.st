"
represents an array at bytecode level (curly brace array).

ex: {  1 . 2 }

	values <Array of ScNodes> 
"
Class {
	#name : #SoCreateArray,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'values'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #converting }
SoCreateArray >> asSunkArray [
	^ SoPointerSunkObjectState new
		theClass: Array;
		marker: SoSunkObjectMarker new;
		fixedFields: #();
		variableFields: values copy;
		subNodesRemoveUses; "only copies are used"
		yourself.
]

{ #category : #'graph edition' }
SoCreateArray >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	values at: (values identityIndexOf: node) put: anotherNode.
	anotherNode addUse: self.
]

{ #category : #type }
SoCreateArray >> basicTypeInformation [
	^ SoKnownType for: Array
]

{ #category : #testing }
SoCreateArray >> hasSizeInformation [
	^ true
]

{ #category : #traversing }
SoCreateArray >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseCreateArray: self
]

{ #category : #'graph edition' }
SoCreateArray >> postCopy [
	<generated>
	values := values copy.
	super postCopy
]

{ #category : #testing }
SoCreateArray >> sizeInformation [
	^ values size
]

{ #category : #'graph edition' }
SoCreateArray >> subNodes [
	<generated>
	^ values
]

{ #category : #accessing }
SoCreateArray >> values [
	<generated>
	^ values
]

{ #category : #accessing }
SoCreateArray >> values: aValue [
	<generated>
	values := aValue.
	values do: [  :each | each addUse: self ]
]
