"
We have no information about that send site from runtime type information.

annotation <Symbol> #__unused if this is an unused send site, else the selector of the send if this is a megamorphic send site. We could specialize the class but right now this information is unused, so we just keep this here for further references / uses.
"
Class {
	#name : #SoUnknownSendData,
	#superclass : #SoSendData,
	#instVars : [
		'annotation'
	],
	#category : #'Scorching-SendData'
}

{ #category : #'instance creation' }
SoUnknownSendData class >> fromArray: array [
	^ self new
		annotation: array last;
		yourself
]

{ #category : #accessing }
SoUnknownSendData >> annotation [
	<generated>
	^ annotation
]

{ #category : #accessing }
SoUnknownSendData >> annotation: aValue [
	<generated>
	annotation := aValue
]

{ #category : #converting }
SoUnknownSendData >> asType [
	^ SoUnknownType default
]

{ #category : #testing }
SoUnknownSendData >> canBeInlined [
	^ false
]

{ #category : #testing }
SoUnknownSendData >> mayBeInlinablePIC [
	^ false
]
