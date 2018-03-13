Class {
	#name : #SoPointerNewColon,
	#superclass : #SoAbsNewColon,
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #testing }
SoPointerNewColon >> isPointerNewColon [
	^ true
]

{ #category : #traversing }
SoPointerNewColon >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traversePointerNewColon: self
]
