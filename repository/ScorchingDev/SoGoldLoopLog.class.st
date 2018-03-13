Class {
	#name : #SoGoldLoopLog,
	#superclass : #SoDebugLog,
	#category : #'ScorchingDev-debug'
}

{ #category : #'as yet unclassified' }
SoGoldLoopLog >> basicPrintOn: stream [
	stream << 'Gold loop: ' << message
]
