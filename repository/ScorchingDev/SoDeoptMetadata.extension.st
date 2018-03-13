Extension { #name : #SoDeoptMetadata }

{ #category : #'*ScorchingDev' }
SoDeoptMetadata >> printDebugInfo [
	^ String streamContents: [ :s | self printDebugInfoOn: s ]
]

{ #category : #'*ScorchingDev' }
SoDeoptMetadata >> printDebugInfoOn: stream [
	debugInfo ifNil: [ ^ self ].
	debugInfo ifEmpty: [ ^ stream << 'no opt logged' ].
	"debugInfo is a collection of ScDebugInliningLog"
	debugInfo sort.
	stream << debugInfo first stackOrNil last key selector.
	debugInfo do: [ :each |
		each crTabPrintOn: stream ]
		
	
]

{ #category : #'*ScorchingDev' }
SoDeoptMetadata >> printSDebugInfo [
	^ String streamContents: [ :s | self printSDebugInfoOn: s ]
]

{ #category : #'*ScorchingDev' }
SoDeoptMetadata >> printSDebugInfoOn: stream [
	debugInfo ifNil: [ ^ self ].
	debugInfo ifEmpty: [ ^ stream << 'no opt logged' ].
	"debugInfo is a collection of ScDebugInliningLog"
	debugInfo sort.
	stream << debugInfo first stackOrNil last key selector.
	debugInfo do: [ :each |
		(each message includesSubString: 'Inlined') ifTrue: [each crTabPrintOn: stream ] ]
]

{ #category : #'*ScorchingDev' }
SoDeoptMetadata >> storeOn: s [
	s << '#DeoptMetadata'.
]
