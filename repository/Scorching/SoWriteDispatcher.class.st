"
I am used by the escape optimisation to dispatch messages depending on different types.
"
Class {
	#name : #SoWriteDispatcher,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'write',
		'escapeOptimiser'
	],
	#category : #'Scorching-Pass-Heap'
}

{ #category : #accessing }
SoWriteDispatcher >> escapeOptimiser [
	<generated>
	^ escapeOptimiser
]

{ #category : #accessing }
SoWriteDispatcher >> escapeOptimiser: aValue [
	<generated>
	escapeOptimiser := aValue
]

{ #category : #traversing }
SoWriteDispatcher >> traverseInstantiation: inst [
	^ escapeOptimiser liveSetSimplifyWrite: write thanksToInstantiation: inst 
]

{ #category : #traversing }
SoWriteDispatcher >> traverseObjectRead: read [
	^ escapeOptimiser liveSetSimplifyWrite: write thanksToRead: read 
]

{ #category : #traversing }
SoWriteDispatcher >> traverseObjectWrite: read [
	^ escapeOptimiser liveSetSimplifyWrite: write thanksToWrite: read 
]

{ #category : #traversing }
SoWriteDispatcher >> traversePossibleRoot: pr [
	^ escapeOptimiser liveSetSimplifyWrite: write thanksToPossibleRoot: pr 
]

{ #category : #traversing }
SoWriteDispatcher >> traverseReadOnlyBranch: rob [
	^ escapeOptimiser liveSetSimplifyWrite: write thanksToReadOnlyBranch: rob 
]

{ #category : #traversing }
SoWriteDispatcher >> traverseTrapIfReadOnly: rot [
	^ escapeOptimiser liveSetSimplifyWrite: write thanksToTrapIfReadOnly: rot 
]

{ #category : #traversing }
SoWriteDispatcher >> traverseYoungBranch: rob [
	^ escapeOptimiser liveSetSimplifyWrite: write thanksToYoungBranch: rob 
]

{ #category : #accessing }
SoWriteDispatcher >> write [
	<generated>
	^ write
]

{ #category : #accessing }
SoWriteDispatcher >> write: aValue [
	<generated>
	write := aValue
]
