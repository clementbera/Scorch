"
Generates traverser methods and templates for the graph nodes.

Usage:
self genTraversers
"
Class {
	#name : #SoTraverserGenerator,
	#superclass : #SoAbstractGenerator,
	#category : #'ScorchingDev-macros'
}

{ #category : #script }
SoTraverserGenerator class >> genTraversers [
	^ self new genTraversers
]

{ #category : #generating }
SoTraverserGenerator >> genIsTraversed: sub [
	| s |
	(self isAbstract: sub) ifTrue: [ ^self ].
	s := '' writeStream.
	s << 'isTraversedBy: aTraverser'.
	self maybeAddPragma: s.
	s cr;tab.
	s 
		<< '^ aTraverser traverse' 
		<< (self prunnedName: sub)
		<< ': self'.
	sub compile: s contents classified: #traversing
]

{ #category : #generating }
SoTraverserGenerator >> genTraverse: sub [
	| s supersub |
	s := '' writeStream.
	s 	
		<< 'traverse' 
		<< (self prunnedName: sub)
		<< ': '
		<< (self instanceName: sub).
	self maybeAddPragma: s.
	s cr;tab.
	supersub := sub superclass.
	(sub = SoAbsImmediate or: [ supersub = SoAbsInstruction ]) ifFalse: [ 
			s 	
				<< '^ self traverse' 
				<< (self prunnedName: supersub)
				<< ': '
				<< (self instanceName: sub) ].
	SoGraphTraverser  
		compile: s contents 
		classified: #traversing
]

{ #category : #public }
SoTraverserGenerator >> genTraversers [
	SoAbsInstruction allSubclasses , SoAbsImmediate withAllSubclasses do: [ :sub |
		self genTraverse: sub.
		self genIsTraversed: sub ]
]

{ #category : #generating }
SoTraverserGenerator >> instanceName: sub [
	| pn |
	pn := self prunnedName: sub.
	^ pn first isVowel
		ifTrue: [ 'an' , pn ]
		ifFalse: [ 'a' , pn ]
]

{ #category : #generating }
SoTraverserGenerator >> isAbstract: theClass [
	^ theClass name beginsWith: 'SoAbs'
]

{ #category : #generating }
SoTraverserGenerator >> prunnedName: theClass [
	(self isAbstract: theClass) ifTrue: [ ^ theClass name allButFirst: 5 ].
	^ theClass name allButFirst: 2
]
