"
Pretty prints the CFG in a nice way. 

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
SoPrettyPrinter >> traverseEnsureEnoughSlots: ensure [
	stream << 'Ensure '.
	ensure numSlots shortPrintOn: stream.
	stream << ' slots'.
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
SoPrettyPrinter >> traverseImmediateTrap: trap [
	stream << 'trap'.
]

{ #category : #traversing }
SoPrettyPrinter >> traverseInstanceOfBranch: branch [
	branch expression shortPrintOn: stream.
	stream << ' ifInstanceOf: '.
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
SoPrettyPrinter >> traverseMutableLiteralRead: read [
	stream << 'ReadMutableLit: '.
	read literal printOn: stream.
]

{ #category : #traversing }
SoPrettyPrinter >> traverseNewColon: inst [
	self traversePointerNew: inst.
	stream << ': '.
	inst sized shortPrintOn: stream
]

{ #category : #traversing }
SoPrettyPrinter >> traverseNoInterruptBackjump: bj [
	stream << 'backTo: '.
	stream << bj targetBasicBlock printingNumber
]

{ #category : #traversing }
SoPrettyPrinter >> traverseObjectRead: read [
	read object shortPrintOn: stream.
	stream << ' ' << ((read class name allButFirst: 2) allButLast: 3).
	stream << ':'.
	stream space.
	read index shortPrintOn: stream.
]

{ #category : #traversing }
SoPrettyPrinter >> traverseObjectWrite: write [
	write object shortPrintOn: stream.
	write storeCheck ifTrue: [ stream << ' <sc>' ].
	stream << ' '.
	stream << ((write class name allButFirst: 2) allButLast: 4).
	stream << ': '.
	write index shortPrintOn: stream.
	stream << ' put: '.
	stream space.
	write expression shortPrintOn: stream.
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
SoPrettyPrinter >> traversePipelinedBooleanBranch: branch [
	branch expression shortPrintOn: stream.
	stream space.
	stream 
		<< '<pipe> ifTrue: '
		<< branch trueBasicBlock printingNumber
		<< ' ifFalse: '
		<< branch falseBasicBlock printingNumber.
]

{ #category : #traversing }
SoPrettyPrinter >> traversePointerNew: inst [
	inst behavior name printOn: stream.
	inst needsInit 
		ifTrue: [ stream << ' <init> ' ]
		ifFalse: [ stream << ' <noInit> ' ].
	stream << (inst class name allButFirst: 2).
]

{ #category : #traversing }
SoPrettyPrinter >> traversePossibleRoot: op [
	op expression shortPrintOn: stream.
	stream << ' possibleRoot'
]

{ #category : #traversing }
SoPrettyPrinter >> traverseReadOnlyBranch: branch [
	branch expression shortPrintOn: stream.
	stream 
		<< ' ifReadOnly: '
		<< branch trueBasicBlock printingNumber
		<< ' ifWritable: '
		<< branch falseBasicBlock printingNumber.
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
SoPrettyPrinter >> traverseSmalltalkBooleanBranch: branch [
	branch expression shortPrintOn: stream.
	stream space.
	stream 
		<< 'ifTrue: '
		<< branch trueBasicBlock printingNumber
		<< ' ifFalse: '
		<< branch falseBasicBlock printingNumber.
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
SoPrettyPrinter >> traverseTrapIfReadOnly: node [
	stream << 'Ensure '.
	node expression shortPrintOn: stream.
	stream << ' isWritable'.
]

{ #category : #traversing }
SoPrettyPrinter >> traverseUnforward: op [
	op expression shortPrintOn: stream.
	stream << ' ' << (op class name allButFirst: 2) asLowercase 
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

{ #category : #traversing }
SoPrettyPrinter >> traverseYoungBranch: branch [
	branch expression shortPrintOn: stream.
	stream space.
	stream 
		<< 'ifYoung: '
		<< branch trueBasicBlock printingNumber
		<< ' ifOld: '
		<< branch falseBasicBlock printingNumber.
]
