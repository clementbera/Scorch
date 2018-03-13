"
Create a temp vector of a given size. Access through remote temp instructions.

Can be used only in remote temp instructions AND closure creation.
"
Class {
	#name : #SoCreateTempVect,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'vectorSize'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #converting }
SoCreateTempVect >> asSunkVector [
	^ SoPointerSunkObjectState new
		theClass: Array;
		marker: SoSunkObjectMarker new;
		fixedFields: #();
		variableFields: (Array new: vectorSize withAll: SoConstant new);
		subNodesRemoveUses; "only copies are used"
		yourself.
]

{ #category : #testing }
SoCreateTempVect >> isTempVector [
	^ true
]

{ #category : #traversing }
SoCreateTempVect >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseCreateTempVect: self
]

{ #category : #accessing }
SoCreateTempVect >> vectorSize [
	<generated>
	^ vectorSize
]

{ #category : #accessing }
SoCreateTempVect >> vectorSize: aValue [
	<generated>
	vectorSize := aValue
]
