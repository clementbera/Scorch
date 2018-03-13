"
My instances are non optimized message sends.

Instance Variables
	selector	<Symbol>	the selector of the message
	methodClass:		<nil | Behavior> 	the class from which the send is done in case of super send
	loopDepth <Smi> current depth in the loops, used to direct inlining.
	sendData: <SendData> infos taken from the inline caches about the method and receiver types previously used. 
	deoptInfo <Deoptimization> metadata kept for deoptimization
	specializedSendData <SendData> version of sendData specialized with type inference. Used for inlining. May differ from sendData (typically more precise)
"
Class {
	#name : #SoSend,
	#superclass : #SoAbsOp,
	#instVars : [
		'selector',
		'loopDepth',
		'methodClass',
		'sendData',
		'deoptInfo',
		'specializedSendData'
	],
	#pools : [
		'SoMemoryManagerConstants'
	],
	#category : #'Scorching-Nodes-Op'
}

{ #category : #'dependency management' }
SoSend >> addDependency [ 
	self codeNode addDependency: selector.
]

{ #category : #conversion }
SoSend >> asUnsafeOp: opClass [
	^ opClass fromSend: self
]

{ #category : #testing }
SoSend >> canBeInlined [
	self specializeSendDataWithTypeInference.
	^ specializedSendData ifNil: [ false ] ifNotNil: [ :it | it canBeInlined ]
]

{ #category : #accessing }
SoSend >> deoptInfo [
	<generated>
	^ deoptInfo
]

{ #category : #accessing }
SoSend >> deoptInfo: aValue [
	<generated>
	aValue ifNotNil: [aValue sunkObjects do: [ :sunkObj | sunkObj node: self ] ].
	deoptInfo := aValue
]

{ #category : #traps }
SoSend >> forwarderTrap [
	^ SoTrapIfNotInstanceOf new
			behaviors: {Forwarder};
			expression: receiver;
			yourself
]

{ #category : #testing }
SoSend >> hasReliableInlinedRuntimeInformation [
	"If this send is not used, then the method inlined has irrelevant sendAndBranchData"
	sendData isAvailable ifFalse: [ ^ false ].
	^ sendData behaviors includesAll: specializedSendData behaviors
]

{ #category : #testing }
SoSend >> hasSizeInformation [
	^ self canBeInlined 
		and: [ self methodToInline primitive = 71
		and: [ self firstArg isSmiConstant ] ]
]

{ #category : #testing }
SoSend >> inferredReceiverType [
	| inferredType |
	"This is different from #typeInformationAt: because the type 
	 answered is guessed and not necessarily guaranteed."
	
	"We first try from basicTypeInfo. It may be a hint, a known or unknown type."
	inferredType := receiver basicTypeInformation.
	inferredType hasOneType ifTrue: [ ^ inferredType ].
	inferredType hasReliableHint ifTrue: [ ^ inferredType hint ].
	"If not obvious, attempt to infer the type"
	inferredType := receiver 
		specializeTypeAt: self 
		fromType: inferredType.
	"If inferred, return the type."
	inferredType isKnownType ifTrue: [ 
		inferredType hasConflict ifTrue: [ ^ SoUnknownType default ].
		^ inferredType ].
	"If nothing worked out, use runtime information and unreliable hints."
	inferredType hasHint ifFalse: [ ^ sendData asType ].
	^ inferredType hintTypeWith: sendData asType
]

{ #category : #traps }
SoSend >> insertTrap [
	| trap |
	trap := "self isSuperSend 
		ifFalse: [ "(specializedSendData trapFor: receiver)"]
		ifTrue: [ self forwarderTrap ]".
	trap deoptInfo: (deoptInfo convertToTrapWith: self).
	trap insertBefore: self.
]

{ #category : #testing }
SoSend >> isSend [
	^ true
]

{ #category : #testing }
SoSend >> isSuperSend [
	^ methodClass notNil
]

{ #category : #traversing }
SoSend >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseSend: self
]

{ #category : #accessing }
SoSend >> loopDepth [
	<generated>
	^ loopDepth
]

{ #category : #accessing }
SoSend >> loopDepth: aValue [
	<generated>
	loopDepth := aValue
]

{ #category : #testing }
SoSend >> maybeWorthSplitting [
	^ true
]

{ #category : #accessing }
SoSend >> methodClass [
	<generated>
	^ methodClass
]

{ #category : #accessing }
SoSend >> methodClass: aValue [
	<generated>
	methodClass := aValue
]

{ #category : #accessing }
SoSend >> methodToInline [
	^ specializedSendData methodToInline
]

{ #category : #copying }
SoSend >> postCopy [
	super postCopy.
	sendData := sendData copy.
	specializedSendData := specializedSendData copy
]

{ #category : #accessing }
SoSend >> selector [
	<generated>
	^ selector
]

{ #category : #accessing }
SoSend >> selector: aValue [
	<generated>
	selector := aValue
]

{ #category : #accessing }
SoSend >> sendData [
	<generated>
	^ sendData
]

{ #category : #accessing }
SoSend >> sendData: aValue [
	<generated>
	sendData := aValue
]

{ #category : #testing }
SoSend >> sizeInformation [
	^ self firstArg constant
]

{ #category : #testing }
SoSend >> specializeSendDataWithTypeInference [
	| inferredType |
	"If the analysis succeeds, no need to do it again"
	specializedSendData ifNotNil: [ ^ self ].
	inferredType := self inferredReceiverType.   
	inferredType hasOneType ifFalse: [ ^ self ]. 
	specializedSendData := inferredType specializeSendData: self 
]

{ #category : #accessing }
SoSend >> specializedSendData [
	^ specializedSendData
]

{ #category : #accessing }
SoSend >> specializedSendData: anObject [
	specializedSendData := anObject
]

{ #category : #accessing }
SoSend >> splitSubNode [
	^ receiver
]
