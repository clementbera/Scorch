"
Generate isPlague methods from a DNU message.

"
Class {
	#name : #SoIsGenerator,
	#superclass : #SoAbstractGenerator,
	#pools : [
		'SoGenerationSetting'
	],
	#category : #'ScorchingDev-macros'
}

{ #category : #public }
SoIsGenerator class >> genIsMethodFrom: aMessage in: aClass [
	^ self new genIsMethodFrom: aMessage in: aClass
]

{ #category : #public }
SoIsGenerator >> genIsMethodFrom: aMessage in: aClass [
	| s gen |
	s := '' writeStream.
	s << aMessage selector.
	self maybeAddPragma: s.
	s cr; tab.
	s << '^ false'.
	gen := UIManager default confirm: 'Generate ' , aClass name , '>>', s contents , ' ?'.
	gen ifTrue: [ aClass compile: s contents classified: #testing ]
	
	
	
]
