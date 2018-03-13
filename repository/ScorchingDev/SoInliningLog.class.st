Class {
	#name : #SoInliningLog,
	#superclass : #SoDebugLog,
	#category : #'ScorchingDev-debug'
}

{ #category : #'as yet unclassified' }
SoInliningLog >> basicPrintOn: stream [
	stream << message
]
