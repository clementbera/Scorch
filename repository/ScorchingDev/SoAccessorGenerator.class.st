"
I create accessors for all the classes in Scorching packages, except the ones defined class side in ""ignoreAccessorNames"".

I generate specific setter for IR nodes with nodesWithDef

usage:
self genAllAccessors
"
Class {
	#name : #SoAccessorGenerator,
	#superclass : #SoAbstractGenerator,
	#category : #'ScorchingDev-macros'
}

{ #category : #public }
SoAccessorGenerator class >> genAllAccessors [
	^ self new genAllAccessors
]

{ #category : #generating }
SoAccessorGenerator >> check: selector for: aClass [
	^ (aClass respondsTo: selector) and: 
		[ ((aClass >> selector) hasPragmaNamed: PragmaName) not ]
	
]

{ #category : #public }
SoAccessorGenerator >> genAllAccessors [
	"NB: it is recommended not to have a Nautilus browser opened on these packages or it will take multiple seconds."
	| packages |
	packages := #(Scorching) collect: [ :packName |
		RPackageOrganizer default packageNamed: packName ].
	packages 
		do: [ :pack | self genPackageAccessors: pack ] 
		
]

{ #category : #generating }
SoAccessorGenerator >> genClassAccessors: aClass [
	| toIgnore defUseGraph |
	toIgnore := (aClass respondsTo: #ignoreAccessorNames)
		ifTrue: [ aClass ignoreAccessorNames ]
		ifFalse: [ #() ].
	defUseGraph := (aClass respondsTo: #nodesWithDef)
		ifTrue: [ aClass nodesWithDef pairsCollect: [ :ivName :annotation | ivName ] ]
		ifFalse: [ #() ].
	(aClass instVarNames copyWithoutAll: toIgnore) do: [ :name |
		self genIVAccessor: name class: aClass defUse: (defUseGraph includes: name) ]
]

{ #category : #generating }
SoAccessorGenerator >> genIVAccessor: varName class: aClass defUse: defUse [
	(self check:  varName asSymbol for: aClass)
		ifFalse: [ self generateGetter: varName class: aClass. ].
	(self check:  (varName , ':') asSymbol for: aClass) ifFalse:
		[ defUse
			ifTrue: [ self generateDefUseSetter: varName class: aClass ]
			ifFalse: [ self generateSetter: varName class: aClass ] ].
]

{ #category : #generating }
SoAccessorGenerator >> genPackageAccessors: pack [ 
	pack definedClasses do: [ :aClass |
		self genClassAccessors: aClass ]
]

{ #category : #generating }
SoAccessorGenerator >> generateDefUseSetter: varName class: aClass [
	| exp |
	aClass nodesWithDef pairsDo: [ :name :annot |
		name = varName ifTrue: [ exp := self macroExpanderFromSymbol: annot ] ].
	exp generateDefUseSetter: varName class: aClass
	
]

{ #category : #generating }
SoAccessorGenerator >> generateGetter: varName class: aClass [ 
	| s |
	s := '' writeStream.
	s << varName.
	self maybeAddPragma: s.
	s << String cr << String tab << '^ ' << varName.
	aClass compile: s contents classified: #accessing
]

{ #category : #generating }
SoAccessorGenerator >> generateSetter: varName class: aClass [ 
	| s |
	s := '' writeStream.
	s << varName << ': aValue' .
	self maybeAddPragma: s.
	varName = #deoptInfo ifTrue: [ 
		s << String cr << String tab << 'aValue ifNotNil: [aValue sunkObjects do: [ :sunkObj | sunkObj node: self ] ].' ].
	s << String cr << String tab << varName << ' := aValue'.
	aClass compile: s contents classified: #accessing
]
