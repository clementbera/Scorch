Class {
	#name : #SoAllocFoldedLog,
	#superclass : #SoDebugLog,
	#category : #'ScorchingDev-debug'
}

{ #category : #'as yet unclassified' }
SoAllocFoldedLog >> basicPrintOn: stream [
	stream << 'Alloc folded: ' << message
]
