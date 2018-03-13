Class {
	#name : #SoByteNewColon,
	#superclass : #SoAbsNewColon,
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #accessing }
SoByteNewColon >> initConstant [
	^ SoConstant constant: 0
]

{ #category : #accessing }
SoByteNewColon >> initWriteAt: i [
	^ SoByteWrite new
					object: self;
					index: (SoConstant constant: i);
					expression: (SoConstant new);
					yourself 
]

{ #category : #testing }
SoByteNewColon >> isByteNewColon [
	^ true
]

{ #category : #testing }
SoByteNewColon >> isPointers [
	^ false
]

{ #category : #traversing }
SoByteNewColon >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseByteNewColon: self
]
