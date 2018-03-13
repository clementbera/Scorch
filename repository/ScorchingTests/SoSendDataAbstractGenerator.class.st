"
My subclasses generates fake sendAndBranchData for a compiledmethod. This is very convenient for tests, mostly because it does not require the VM to be stable and the data generated is deterministic.

	branchInfo <Array or 2 Smi> value for each branch data. One can try #(0 500) if one wants a dead branch, or #(200 200) if one wants the 2 branches to be equally optimzed.
	currentPC <Smi> pc of the instructions (on the opposite to pc which is the pc after the instruction)
	first <Boolean> true if first data has not been generated yet.
	stream <WriteStream> stream where you write down the send and branch data
	
"
Class {
	#name : #SoSendDataAbstractGenerator,
	#superclass : #InstructionClient,
	#instVars : [
		'branchInfo',
		'currentPC',
		'first',
		'stream'
	],
	#category : #'ScorchingTests-StaticTypes'
}

{ #category : #accessing }
SoSendDataAbstractGenerator >> arithmeticSelectors [
	^ #(#+  #-  #<  #>  #<=  #>=  #=  #~=  #*  #/  #\\  #@  #bitShift:  #//  #bitAnd:  #bitOr: )
]

{ #category : #accessing }
SoSendDataAbstractGenerator >> blockEvaluationSelectors [
	^ #( value value: value:value: value:value:value: value:value:value:value: valueWithArguments: )
]

{ #category : #private }
SoSendDataAbstractGenerator >> checkFirst [
	first ifFalse: [ stream << '.' ] ifTrue: [ first := false. ].
]

{ #category : #private }
SoSendDataAbstractGenerator >> generateMegamorphic: selector [
	stream 
		<< ' { ' 
		<< currentPC printString
		<< ' . '
		<< nil printString 
		<< ' . '
		<< selector printString
		<< ' } '
]

{ #category : #public }
SoSendDataAbstractGenerator >> generateMock: method [
	| scanner |
	first := true.
	stream := '' writeStream.
	stream nextPut: ${.
	scanner := InstructionStream on: method.
	[scanner pc < method endPC] whileTrue:
		[ currentPC := scanner pc.
		scanner interpretNextInstructionFor: self].
	stream nextPut: $}.
	^ self class compilerClass evaluate: stream contents
]

{ #category : #private }
SoSendDataAbstractGenerator >> generateMonomorphic: method [
	stream 
		<< ' { ' 
		<< currentPC printString
		<< ' . '
		<< method methodClass name
		<< ' . '
		<< method printString
		<< ' } '
]

{ #category : #private }
SoSendDataAbstractGenerator >> generatePolymorphic: methods [
	stream 
		<< ' { ' 
		<< currentPC printString.
	methods do: [ :method |
		stream
			<< ' . '
			<< method methodClass name
			<< ' . '
			<< method printString ].
	stream << ' } '
]

{ #category : #initialize }
SoSendDataAbstractGenerator >> initialize [

	super initialize.

	branchInfo := #(30000 35535)
]

{ #category : #instructions }
SoSendDataAbstractGenerator >> jump: offset if: condition [ 
	"Conditional Jump bytecode."

	self checkFirst.
	stream 
		<< ' #(' 
		<< currentPC printString
		<< ' '
		<< branchInfo first printString
		<< ' '
		<< branchInfo second printString
		<< ') '
]

{ #category : #instructions }
SoSendDataAbstractGenerator >> send: selector super: supered numArgs: numberArguments [
	self subclassResponsibility 
]

{ #category : #accessing }
SoSendDataAbstractGenerator >> specialSelectorsWithSpecialBehavior [
	^ #(#at: #at:put: #size #'==' #value #value: #x #y)
]
