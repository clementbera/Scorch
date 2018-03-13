"
Access to a remote temp. Similar to instVar access, but with specific constraints for temp vectors.
"
Class {
	#name : #SoRemoteTemp,
	#superclass : #SoHeapAccess,
	#instVars : [
		'tempVector',
		'remoteIndex'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #accessing }
SoRemoteTemp >> accessID [
	^ { tempVector . remoteIndex } 
]

{ #category : #'graph edition' }
SoRemoteTemp >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	tempVector == node ifTrue: [ 
		tempVector := anotherNode.
		^ anotherNode addUse: self ].
	accessStrategy expression: anotherNode.
	anotherNode addUse: self
]

{ #category : #accessing }
SoRemoteTemp >> beWrite [
	accessStrategy := SoRTWrite new.
]

{ #category : #traversing }
SoRemoteTemp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseRemoteTemp: self
]

{ #category : #accessing }
SoRemoteTemp >> remoteIndex [
	<generated>
	^ remoteIndex
]

{ #category : #accessing }
SoRemoteTemp >> remoteIndex: aValue [
	<generated>
	remoteIndex := aValue
]

{ #category : #'graph edition' }
SoRemoteTemp >> subNodes [
	<generated>
	^ {tempVector} , accessStrategy subNodes
]

{ #category : #accessing }
SoRemoteTemp >> tempVector [
	<generated>
	^ tempVector
]

{ #category : #accessing }
SoRemoteTemp >> tempVector: aValue [
	<generated>
	tempVector := aValue.
	tempVector  addUse: self
]
