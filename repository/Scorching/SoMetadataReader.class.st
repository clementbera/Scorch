"
I get the sendAndBranchData from the jitted method through the primitive, which answers basically an array, and provide convenient APIs to read it.

It's simpler to wrap this behavior in a class in order to easily change the behavior depending on the VM behavior.

Instance Variables
	sendAndBranchData:		<Array> data from the VM


"
Class {
	#name : #SoMetadataReader,
	#superclass : #SoAbsSendAndBranchDataHandler,
	#instVars : [
		'sendAndBranchData'
	],
	#category : #'Scorching-Decompiler'
}

{ #category : #'instance creation' }
SoMetadataReader class >> on: data [ 
	^ self new
		sendAndBranchData: data;
		yourself
]

{ #category : #public }
SoMetadataReader >> addSendData: messageNode pc: currentPC [
	messageNode sendData: (self 
		sendDataForPC: currentPC 
		ifNone: [ self fakeMegamorphicRawData ])

]

{ #category : #public }
SoMetadataReader >> addSendDataAndSmiEntry: messageNode pc: currentPC [ 
	messageNode sendData: (self sendDataAndSmiEntryForPC: currentPC send: messageNode).
]

{ #category : #private }
SoMetadataReader >> addSmiEntryInRawSendData: array for: send [
	2 to: array size by: 2 do: [ :i |
		(array at: i) == SmallInteger ifTrue: [ ^ array ] ].
	^ array , { SmallInteger . SmallInteger >> send selector }
	
]

{ #category : #private }
SoMetadataReader >> castSendData: array [
	"This manual dispatch is needed because that's how the VM gives the data to the image."
	| concreteSubclass |
	concreteSubclass := array basicSize = 3 
		ifTrue: [ (array at: 2) 
			ifNil: [ SoUnknownSendData ] "megamorphic or unused - depends on array last value"
			ifNotNil: [ SoAvailableSendData ] ] "monomorphic"
		ifFalse: [ SoAvailableSendData  ]. "polymorphic"
	^ concreteSubclass fromArray: array allButFirst
]

{ #category : #accessing }
SoMetadataReader >> fakeMegamorphicRawData [ 
	^ #(0 nil #__unknown)
]

{ #category : #public }
SoMetadataReader >> getBranchData: pc [
	^ sendAndBranchData 
		detect: [ :array | array first = pc  ]
		ifNone: [ #(0 0) ]
]

{ #category : #private }
SoMetadataReader >> rawSendDataForPC: pc ifNone: aBlock [
	^ sendAndBranchData 
		detect: [ :arr | arr first = pc  ]
		ifNone: aBlock
]

{ #category : #accessing }
SoMetadataReader >> sendAndBranchData [
	<generated>
	^ sendAndBranchData
]

{ #category : #accessing }
SoMetadataReader >> sendAndBranchData: aValue [
	<generated>
	sendAndBranchData := aValue
]

{ #category : #private }
SoMetadataReader >> sendDataAndSmiEntryForPC: pc send: send [
	"Adds the Smi entry if not present. Can't be unused."
	| array |
	array :=  self rawSendDataForPC: pc ifNone: [ {0 . SmallInteger . SmallInteger >> send selector} ].
	(array at: 2) ifNil: [ ^ self castSendData: array ]. "megamorphic"
	array := self addSmiEntryInRawSendData: array for: send.
	^ self castSendData: array
]

{ #category : #private }
SoMetadataReader >> sendDataForPC: pc ifNone: aBlock [
	^ self castSendData: (self rawSendDataForPC: pc ifNone: aBlock)
]
