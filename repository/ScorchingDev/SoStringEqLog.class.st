Class {
	#name : #SoStringEqLog,
	#superclass : #SoDebugLog,
	#category : #'ScorchingDev-debug'
}

{ #category : #'as yet unclassified' }
SoStringEqLog >> basicPrintOn: stream [
	stream << 'String Eq exact: ' << message
]
