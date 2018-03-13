"
Pretty prints the Cfg in a nice way. 

On code you can use the Roassal visualisation too
"
Class {
	#name : #SoPrettyPrinter,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'stream'
	],
	#category : #'ScorchingDev-debug'
}

{ #category : #public }
SoPrettyPrinter >> printCodeNode: node on: s [
	stream := s.
	self traversePreorderCode: node.
]

{ #category : #public }
SoPrettyPrinter >> printDefUse: instr on: s [
	self printInstruction: instr on: s.
	instr uses do: [ :use |
		stream cr.
		stream tab.
		use isSunkObject 
			ifTrue: [ use shortPrintOn: stream ]
			ifFalse: [ self traverseInstruction: use ] ].
	
]

{ #category : #private }
SoPrettyPrinter >> printInstruction: instr [
	instr hasDeoptInfo ifTrue: [ stream << ' (S) ' ].
	stream space.
	super traverseInstruction: instr.
	stream << '.'
]

{ #category : #public }
SoPrettyPrinter >> printInstruction: instr on: s [
	stream := s.
	instr shortPrintOn: stream.
	self printInstruction: instr.
]

{ #category : #private }
SoPrettyPrinter >> printStore: store [
	stream space.
	store ignoreStoreCheck ifTrue: [ stream <<':U' ].
	stream << ':= '.
	store expression shortPrintOn: stream.
]

{ #category : #traversing }
SoPrettyPrinter >> traverseBackjump: bj [
	stream << 'backTo: '.
	stream << bj targetBasicBlock printingNumber
]

{ #category : #traversing }
SoPrettyPrinter >> traverseBooleanBranch: branch [
	branch expression shortPrintOn: stream.
	stream space.
	stream 
		<< 'ifTrue: '
		<< branch trueBasicBlock printingNumber
		<< ' ifFalse: '
		<< branch falseBasicBlock printingNumber.
]

{ #category : #traversing }
SoPrettyPrinter >> traverseBranchIfNotInstanceOf: branch [
	branch expression shortPrintOn: stream.
	stream << ' ifNotInstanceOf: '.
	branch behaviors size = 1 
		ifTrue: [ branch behaviors anyOne printOn: stream ] 
		ifFalse: [ branch behaviors printOn: stream ].
	stream 
		<< ' goTo: '
		<< branch trueBasicBlock printingNumber
		<< ' else: '
		<< branch falseBasicBlock printingNumber.
	
]

{ #category : #traversing }
SoPrettyPrinter >> traverseContextInstVar: instVar [
	stream << 'Ctxt:'.
	self traverseInstVar: instVar.
]

{ #category : #traversing }
SoPrettyPrinter >> traverseCreateArray: aCreateArray [
	stream nextPut: ${.
	aCreateArray values do: [ :e |
		e shortPrintOn: stream ]
		separatedBy: [ stream space. stream nextPut: $. . stream space ].
	stream nextPut: $}.
]

{ #category : #traversing }
SoPrettyPrinter >> traverseCreateFullBlock: fullBlock [
	stream <<'-[-'.
	fullBlock receiver shortPrintOn: stream.
	stream space.
	stream nextPut: $|.
	stream space.
	fullBlock values do: [ :e |
		e shortPrintOn: stream ]
		separatedBy: [ stream space ].
	stream << '-]-'.
]

{ #category : #traversing }
SoPrettyPrinter >> traverseCreateNLRFullBlock: fullBlock [
	stream << 'NLR->'.
	super traverseCreateNLRFullBlock: fullBlock
]

{ #category : #traversing }
SoPrettyPrinter >> traverseCreateTempVect: vect [
	stream 
		<< 'new TempVect('
		<< vect vectorSize asString
		<< ')'. 
]

{ #category : #traversing }
SoPrettyPrinter >> traverseEnsureEnoughSpace: instr [
	stream 
		<< 'Ensure '
		<< instr numWords asString
		<< ' available'. 
]

{ #category : #traversing }
SoPrettyPrinter >> traverseForwardBasicBlock: basicBlock [
	stream 
		<< 'Preds: ' 
		<< (basicBlock predecessors collect: #bbNumber) asArray printString
		<< '. Dom: '
		<< (basicBlock dominator ifNil: [ #None ] ifNotNil: [ :it | it printingNumber]).
	stream cr.
	super traverseForwardBasicBlock: basicBlock.
	stream cr.
]

{ #category : #traversing }
SoPrettyPrinter >> traverseGlobal: global [
	stream << 'Gbl:' << global assoc key. 
	global isWrite ifTrue: [ self printStore: global ].
]

{ #category : #traversing }
SoPrettyPrinter >> traverseImmediateTrap: trap [
	stream << 'trap'.
]

{ #category : #traversing }
SoPrettyPrinter >> traverseInstVar: instVar [
	instVar object shortPrintOn: stream.
	stream << '%'. 
	instVar index printOn: stream.
	instVar isWrite ifTrue: [ self printStore: instVar ].
]

{ #category : #traversing }
SoPrettyPrinter >> traverseInstruction: instr [ 
	instr shortPrintOn: stream.
	self printInstruction: instr.
	stream cr.
]

{ #category : #traversing }
SoPrettyPrinter >> traverseJumpAhead: jumpAhead [
	stream << 'goTo: '.
	stream << jumpAhead targetBasicBlock printingNumber
]

{ #category : #traversing }
SoPrettyPrinter >> traverseLoopHead: loopHead [
	stream << 'loopHead'
]

{ #category : #traversing }
SoPrettyPrinter >> traversePhi: phi [
	stream << 'phi: '.
	phi inputsAndBasicBlocksDo: [ :input :block |
	 	input shortPrintOn: stream.
		stream nextPut: $' .
		stream << block printingNumber.
		stream space ].
	
]

{ #category : #traversing }
SoPrettyPrinter >> traversePi: pi [
	stream << 'Pi'.	
	pi expression shortPrintOn: stream.
]

{ #category : #traversing }
SoPrettyPrinter >> traversePointerEqualsOp: pointerEquals [
	pointerEquals receiver shortPrintOn: stream.
	stream space; nextPutAll: #==; space.
	pointerEquals firstArg shortPrintOn: stream
]

{ #category : #traversing }
SoPrettyPrinter >> traverseRemoteTemp: remote [
	remote tempVector shortPrintOn: stream.
	stream << '$'. 
	remote remoteIndex printOn: stream.
	remote isWrite ifTrue: [ self printStore: remote ].
]

{ #category : #traversing }
SoPrettyPrinter >> traverseReturn: return [
	stream << (#( '-> ' '^^' '^' '^3^' '^4^') at: return numLevels + 1).
	stream space.
	return returnedValue shortPrintOn: stream
]

{ #category : #traversing }
SoPrettyPrinter >> traverseSend: send [
	send receiver shortPrintOn: stream. 
	send methodClass ifNotNil: [ stream nextPutAll: ' [super]' ].
	stream space.
	send arguments ifEmpty: [ ^ stream << send selector ].
	send arguments  with: send selector keywords do: [:arg :word |
		stream nextPutAll: word.
		stream space.
		arg shortPrintOn: stream.
		stream space ].
	stream skip: -1.
]

{ #category : #traversing }
SoPrettyPrinter >> traverseTrapIfNotInstanceOf: node [
	stream << 'Ensure '.	
	node expression shortPrintOn: stream.
	stream << ' class == '.
	node behaviors size = 1 
		ifTrue: [ node behaviors anyOne printOn: stream ] 
		ifFalse: [ node behaviors printOn: stream ].
]

{ #category : #traversing }
SoPrettyPrinter >> traverseUnsafeOp: op [
	op receiver shortPrintOn: stream.
	stream << ' U'.
	stream << ((op class name allButFirst: 2) allButLast: 2).
	stream space.
	op arguments 
		do: [ :arg | arg shortPrintOn: stream ] 
		separatedBy: [ stream space ].
]
