"
I represent a read inside an object, such as (object at: 1), inst var read, etc.
"
Class {
	#name : #SoAbsObjectRead,
	#superclass : #SoAbsObjectAccess,
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #statification }
SoAbsObjectRead >> computeStatically [
	^ SoConstant constant: (object constant 
		tryPrimitive: 173 "instVarAt:" 
		withArgs: {index constant})
]

{ #category : #testing }
SoAbsObjectRead >> hasEffect [
	^ false
]

{ #category : #testing }
SoAbsObjectRead >> isRead [
	^ true
]

{ #category : #traversing }
SoAbsObjectRead >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseObjectRead: self
]

{ #category : #testing }
SoAbsObjectRead >> okForBackEnsureEnoughSlots [
	^ true
]
