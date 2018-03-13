"
I am specific decompiler for methods. Two specificities: methods have no copied values and a SoMethod instance is created.
"
Class {
	#name : #SoMethodDecompiler,
	#superclass : #SoDecompiler,
	#category : #'Scorching-Decompiler'
}

{ #category : #accessing }
SoMethodDecompiler >> codeNodeClass [
	^ SoMethod
]

{ #category : #accessing }
SoMethodDecompiler >> copiedValues [
	^ #()
]
