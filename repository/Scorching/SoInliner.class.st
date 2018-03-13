"
Same as superclass, but I first iterate of the graph and collect the sends to process
"
Class {
	#name : #SoInliner,
	#superclass : #SoInitialInliner,
	#instVars : [
		'collectedSends'
	],
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #accessing }
SoInliner >> collectedSends [
	<generated>
	^ collectedSends
]

{ #category : #accessing }
SoInliner >> collectedSends: aValue [
	<generated>
	collectedSends := aValue
]

{ #category : #initialization }
SoInliner >> initialize [

	super initialize.

	collectedSends := OrderedCollection new.
]

{ #category : #public }
SoInliner >> runOn: codeNode [
	self traversePreorderCode: codeNode.
	self inlineSends: collectedSends
]

{ #category : #traversing }
SoInliner >> traverseSend: send [
	collectedSends add: send
]
