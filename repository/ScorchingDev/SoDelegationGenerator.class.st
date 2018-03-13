"
Generates delegation to an inst var named 'node''
"
Class {
	#name : #SoDelegationGenerator,
	#superclass : #SoAbstractGenerator,
	#pools : [
		'SoGenerationSetting'
	],
	#category : #'ScorchingDev-macros'
}

{ #category : #generating }
SoDelegationGenerator >> genDelegationFor: aMessage in: aClass [
	| s gen |
	s := '' writeStream.
	self printMessage: aMessage on: s.
	self maybeAddPragma: s.
	s cr; tab.
	s << '^ node '. 
	self printMessage: aMessage on: s.
	gen := UIManager default confirm: 'Generate ' , aClass name , '>>', s contents , ' ?'.
	gen ifTrue: [ aClass compile: s contents classified: #delegating ]
	
	
	
]

{ #category : #generating }
SoDelegationGenerator >> printMessage: msg on: stream [

	msg arguments isEmpty ifTrue: [^ stream nextPutAll: msg selector].
	msg arguments with: msg selector keywords do: [:arg :word |
		stream nextPutAll: word.
		stream space.
		stream << arg class canonicalArgumentName.
		stream space.
	].

]
