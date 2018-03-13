Class {
	#name : #SoDeadFlowLog,
	#superclass : #SoDebugLog,
	#category : #'ScorchingDev-debug'
}

{ #category : #'as yet unclassified' }
SoDeadFlowLog >> basicPrintOn: stream [
	stream << 'Dead flow: ' << message
]
