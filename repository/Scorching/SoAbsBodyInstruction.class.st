"
My instances are scheduled in the CFG. They know their next instruction and the previous one in the sequence of instruction of the basicBlock.

My instances remember their use graph. The uses are for now an OrderedCollection of instruction as if an instruction is used twice in another instruction, it is present twice in the uses collection.
"
Class {
	#name : #SoAbsBodyInstruction,
	#superclass : #SoAbsInstruction,
	#instVars : [
		'nextInstr',
		'uses',
		'backend'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #accessing }
SoAbsBodyInstruction >> addUse: use [
	uses add: use
]

{ #category : #converting }
SoAbsBodyInstruction >> asDeopt [
	self 
		assert: backend isTemp
		description: 'invalid backend - not a temp'.
	^ SoDeoptTemp new
		index: backend tempIndex + self codeNode numArgs + self codeNode numCopied;
		yourself
]

{ #category : #accessing }
SoAbsBodyInstruction >> backend [
	<generated>
	^ backend
]

{ #category : #accessing }
SoAbsBodyInstruction >> backend: aValue [
	<generated>
	backend := aValue
]

{ #category : #types }
SoAbsBodyInstruction >> basicTypeInformation [
	^ SoUnknownType default
]

{ #category : #initialization }
SoAbsBodyInstruction >> initialize [

	super initialize.

	uses := OrderedCollection new.
]

{ #category : #'graph edition' }
SoAbsBodyInstruction >> insertBefore: instr [
	instr prevInstrNextInstr: self.
	self nextInstr: instr
]

{ #category : #backend }
SoAbsBodyInstruction >> interfersWith: instr [ 
	^ backend interferences includes: instr
]

{ #category : #testing }
SoAbsBodyInstruction >> isSpilled [
	^ backend notNil and: [ backend isSpilled ]
]

{ #category : #accessing }
SoAbsBodyInstruction >> nextInstr [
	<generated>
	^ nextInstr
]

{ #category : #accessing }
SoAbsBodyInstruction >> nextInstr: aValue [
	nextInstr := aValue.
	aValue basicBlock: basicBlock.
	aValue prevInstr: self
]

{ #category : #'graph edition' }
SoAbsBodyInstruction >> postCopy [
	super postCopy.
	uses := OrderedCollection new
]

{ #category : #'graph edition' }
SoAbsBodyInstruction >> removeAndReplaceUsesBy: node [ 	
	self replaceUsesBy: node.
	self removeInstr
]

{ #category : #'graph edition' }
SoAbsBodyInstruction >> removeInstr [
	self prevInstrNextInstr: nextInstr.
	super removeInstr
]

{ #category : #accessing }
SoAbsBodyInstruction >> removeUse: use [
	uses remove: use
]

{ #category : #'graph edition' }
SoAbsBodyInstruction >> replaceBy: node [	
	self removeAndReplaceUsesBy: node. 
	node insertBefore: nextInstr
]

{ #category : #'graph edition' }
SoAbsBodyInstruction >> replaceUsesBy: node [
	"It takes a while to remove use one by one in OrderedCollection. bulk it with removeAll."
	self uses do: [ :use | use basicReplaceSubNode: self by: node ].
	self uses removeAll.
]

{ #category : #accessing }
SoAbsBodyInstruction >> uses [
	<generated>
	^ uses
]

{ #category : #accessing }
SoAbsBodyInstruction >> uses: aValue [
	<generated>
	uses := aValue
]
