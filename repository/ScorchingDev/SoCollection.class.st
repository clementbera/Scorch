"
see class side comments
"
Class {
	#name : #SoCollection,
	#superclass : #Object,
	#pools : [
		'SoGenerationSetting'
	],
	#category : #'ScorchingDev-macros'
}

{ #category : #'as yet unclassified' }
SoCollection class >> dependencies [
	"
	Collection
		SeqCol
			ArrayedCol
				Array
				ByteArray
			OrderedCol
		HashedCol
			Set
			Dict
	Stream
		PosStream
			WriteStream
	"
]
