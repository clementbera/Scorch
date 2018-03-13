"
I remove the store checks if the value to store does not require it.

Warning: Experimental pass.
"
Class {
	#name : #SoRemoveStoreChecks,
	#superclass : #SoGraphTraverser,
	#category : #'Scorching-Pass-Heap'
}

{ #category : #private }
SoRemoveStoreChecks >> attemptRemoveNilInit: new [
	| rawStores indexes |
	rawStores := new uses select: [ :use | use isInstVar and: [ use hasImmutabilityCheck not and: [ use ignoreStoreCheck ] ] ].
	indexes := (rawStores collect: [ :each | each index ]) asSet.
	1 to: new receiver constant instSize do: [ :i |
		(indexes includes: i - 1) ifFalse: [ ^ self ] ].
	new nilInit: false.
]

{ #category : #private }
SoRemoveStoreChecks >> attemptToRemoveIVStoreChecks: ivStore [
	| instr toUncheck |
	"for now I make that cheap heuristic. Anyway with branch with deopt info, it cannot do that much."
	ivStore basicBlock = ivStore object basicBlock ifFalse: [ ^ self ].
	toUncheck := OrderedCollection with: ivStore.
	instr := ivStore prevInstr.
	"We go backward looking for the new instruction."
	[ instr == ivStore object ] whileFalse: [ 
		"There's a send in between, we can't uncheck"
		instr isSend ifTrue: [ ^ self ].
		"There's another store in between with immutability check. If
		- it's on the same object, we also may uncheck it.
		- it's on another object / another kind of store, we attempt to remove it's store checks, 
		  and on success we keep going, else we stop."
		(instr isWrite and: [ instr hasImmutabilityCheck ]) ifTrue: [ 
			(instr isInstVar and: [ instr object = ivStore object ])
				ifTrue: [ toUncheck add: instr ]
				ifFalse: [ instr isTraversedBy: self.
						  instr hasImmutabilityCheck ifTrue: [ ^ self ] ] ].
		instr := instr prevInstr ].
	"We found it. We uncheck it all."
	self removeChecks: toUncheck.
	self attemptRemoveNilInit: ivStore object 
]

{ #category : #private }
SoRemoveStoreChecks >> attemptToRemoveRTStoreChecks: rtStore [
	| instr |
	"for now I make that cheap heuristic. Anyway with branch with deopt info, it cannot do that much."
	rtStore basicBlock = rtStore tempVector basicBlock ifFalse: [ ^ self ].
	instr := rtStore prevInstr.
	"We go backward looking for the new instruction."
	[ instr == rtStore tempVector ] whileFalse: [ 
		"There's a send in between, we can't uncheck"
		instr isSend ifTrue: [ ^ self ].
		"There's another store in between with immutability check, 
		  we attempt to remove it's store checks, 
		  and on success we keep going, else we stop."
		(instr isWrite and: [ instr hasImmutabilityCheck ]) ifTrue: [ 
			instr isTraversedBy: self.
			instr hasImmutabilityCheck ifTrue: [ ^ self ] ].
		instr := instr prevInstr ].
	"We found it. We uncheck it all."
	self removeChecks: { rtStore }
]

{ #category : #private }
SoRemoveStoreChecks >> removeChecks: list [
	list do: [ :store |
		store removeDeoptInfo.
		store ignoreStoreCheck: true ]
]

{ #category : #public }
SoRemoveStoreChecks >> runOn: codeNode [
	self traversePreorderCode: codeNode.
]

{ #category : #traversing }
SoRemoveStoreChecks >> traverseGlobal: access [
	access isWrite ifFalse: [ ^ self ].
	(access ignoreStoreCheck) ifTrue: [ ^ self ].
	(access expression typeInformationAt: access) requiresStoreCheck ifFalse: [ access ignoreStoreCheck: true ]
]

{ #category : #traversing }
SoRemoveStoreChecks >> traverseInstVar: access [
	access isWrite ifFalse: [ ^ self ].
	access object isNew ifFalse: [ ^ self ].
	(access hasImmutabilityCheck not and: [ access ignoreStoreCheck ]) ifTrue: [ ^ self ].
	(access expression typeInformationAt: access) requiresStoreCheck ifFalse: [ access ignoreStoreCheck: true ].
	self attemptToRemoveIVStoreChecks: access.
]

{ #category : #traversing }
SoRemoveStoreChecks >> traverseRemoteTemp: access [
	access isWrite ifFalse: [ ^ self ].
	(access ignoreStoreCheck) ifTrue: [ ^ self ].
	(access expression typeInformationAt: access) requiresStoreCheck ifFalse: [ access ignoreStoreCheck: true ].
	self attemptToRemoveRTStoreChecks: access.
]
