Extension { #name : #SoDeoptMetadata }

{ #category : #'*ScorchingDev' }
SoDeoptMetadata >> gtInspectorMetadata2In: composite [
	<gtInspectorPresentationOrder: 15> 
	composite text 
		title: 'AllDebugS'; 
		display: self printSDebugInfo
]

{ #category : #'*ScorchingDev' }
SoDeoptMetadata >> gtInspectorMetadataIn: composite [
	<gtInspectorPresentationOrder: 16> 
	composite text 
		title: 'AllDebug'; 
		display: self printDebugInfo
]

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
	debugInfo do: [ :each |each crTabPrintOn: stream ]
		
	
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
		(each isInliningLog not or: [ each message includesSubString: 'Inlined' ]) ifTrue: [ each crTabPrintOn: stream ] ].
]

{ #category : #'*ScorchingDev' }
SoDeoptMetadata >> storeOn: s [
	s << '#DeoptMetadata'.
]
