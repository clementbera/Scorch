"
Same as superclass but called later in the optimisation process. Less aggressive optimisations.
"
Class {
	#name : #SoLateCallGraphInliner,
	#superclass : #SoCallGraphInliner,
	#instVars : [
		'collectedSends'
	],
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #accessing }
SoLateCallGraphInliner >> collectedSends [
	<generated>
	^ collectedSends
]

{ #category : #accessing }
SoLateCallGraphInliner >> collectedSends: aValue [
	<generated>
	collectedSends := aValue
]

{ #category : #initialization }
SoLateCallGraphInliner >> initialize [

	super initialize.

	collectedSends := OrderedCollection new.
]

{ #category : #public }
SoLateCallGraphInliner >> runOn: codeNode [
	self traversePreorderCode: codeNode.
	self inlineQuietlySends: collectedSends
]

{ #category : #traversing }
SoLateCallGraphInliner >> traverseSend: send [
	collectedSends add: send
]
