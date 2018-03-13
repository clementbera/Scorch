"
My instances are non optimized message sends.

Instance Variables
	selector	<Symbol>	the selector of the message
	methodClass:		<nil | Behavior> 	the class from which the send is done in case of super send
	loopDepth <Smi> current depth in the loops, used to direct inlining.
	sendData: <SendData> infos taken from the inline caches about the method and receiver types previously used. 
	deoptInfo <Deoptimization> metadata kept for deoptimization
	specializedSendData <SendData> version of sendData specialized with type inference. Used for inlining. May differ from sendData (typically more precise)
	
	nlrIssue <Boolean> used by the inlininer to avoid retrying nlr inlining too many times (expensive)
"
Class {
	#name : #SoSend,
	#superclass : #SoAbsCall,
	#instVars : [
		'selector',
		'methodClass',
		'sendData',
		'specializedSendData',
		'nlrIssue'
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

{ #category : #inlining }
SoSend >> basicInline [
	| prim inlinerClass |
	prim := self methodToInline primitive.
	inlinerClass := ((prim = 0 or: [ self methodToInline isQuick ])
		ifTrue: [ SoMethodInliner ]
		ifFalse: [ 
			prim = 207
				ifTrue: [ SoBlockInliner ]
				ifFalse: [ SoPrimitiveInliner ] ]).
	^ inlinerClass new inline: self
]

{ #category : #testing }
SoSend >> basicRespecializeSendDataWithTypeInference [
	| inferredType |
	"Sometimes other optimisations breaks the first type inference (incorrect guess).
	 For cases like that we quickly re-inference types, but we don't pay the full inference cost"
	receiver isPhi ifTrue: [ ^ self ]. "too expensive on phis - profiling"
	inferredType := receiver basicTypeInformation.
	inferredType hasOneType ifFalse: [ ^ self ]. 
	"specialized data has a single data - always"
	inferredType behaviors anyOne = specializedSendData behaviors anyOne ifTrue: [ ^self ].
	specializedSendData := inferredType specializeSendData: self 
]

{ #category : #testing }
SoSend >> canBeInlined [
	self specializeSendDataWithTypeInference.
	^ specializedSendData ifNil: [ false ] ifNotNil: [ :it | it canBeInlined ]
]

{ #category : #testing }
SoSend >> hasReliableInlinedRuntimeInformation [
	"If this send is not used, then the method inlined has irrelevant sendAndBranchData"
	sendData isAvailable ifFalse: [ ^ false ].
	^ sendData behaviors includesAll: specializedSendData behaviors
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

{ #category : #initialization }
SoSend >> initialize [

	super initialize.

	nlrIssue := false.
]

{ #category : #inlining }
SoSend >> inlineAccessWithNoRangeCheck [
	^ SoPrimitiveInliner new inlineAccessWithNoRangeCheck: self
]

{ #category : #traps }
SoSend >> insertTrap [
	"Added the guard for performance
	 (deopt info def-use management can be expensive)
	 Redondant with CSE"
	| trap type  |
	"guard"
	type := receiver typeInformationAt: self.
	type isKnownType ifTrue: 
		[ (specializedSendData behaviors includesAll: type behaviors) ifTrue: [ ^ self ] ].
	"actual trap"
	self isSuperSend 
		ifFalse: [ trap := (specializedSendData trapFor: receiver).
				 trap deoptInfo: (deoptInfo convertToTrapWith: self) ]
		ifTrue: [ trap := SoUnforward new expression: receiver; yourself ].
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

{ #category : #accessing }
SoSend >> nlrIssue [
	<generated>
	^ nlrIssue
]

{ #category : #accessing }
SoSend >> nlrIssue: aValue [
	<generated>
	nlrIssue := aValue
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
SoSend >> specializeSendDataWithTypeInference [
	| inferredType |
	"If the analysis succeeds, no need to do it again"
	specializedSendData ifNotNil: [ ^ self basicRespecializeSendDataWithTypeInference ].
	inferredType := self inferredReceiverType.   
	inferredType isKnownType ifFalse: [ ^ self ]. 
	specializedSendData := inferredType specializeSendData: self 
]

{ #category : #accessing }
SoSend >> specializedSendData [
	<generated>
	^ specializedSendData
]

{ #category : #accessing }
SoSend >> specializedSendData: aValue [
	<generated>
	specializedSendData := aValue
]

{ #category : #accessing }
SoSend >> splitSubNode [
	^ receiver
]
