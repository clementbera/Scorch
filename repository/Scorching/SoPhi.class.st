"
implements the phi functions that are used SSA form.  To know more about phi functions, please consult any compiler textbook.

Instance Variables
	inputsMapping:		<Dictionary(BasicBlock->instruction)>
	
"
Class {
	#name : #SoPhi,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'inputsMapping'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #inputs }
SoPhi >> addInput: instr basicBlock: bb [
	inputsMapping add: (SoPhiInput input: instr basicBlock: bb phi: self)
]

{ #category : #inputs }
SoPhi >> basicBlockReferences [
	^ inputsMapping collect: [ :phiInput | phiInput basicBlock ]
]

{ #category : #inputs }
SoPhi >> basicBlocksForInput: input [
	| collection |
	collection := OrderedCollection new.
	self inputsAndBasicBlocksDo: [ :in :block |
		input = in ifTrue: [ collection add: block ] ].
	^ collection
]

{ #category : #types }
SoPhi >> basicTypeInformation [
	| type inputs |
	inputs := self mergeInputs.
	type := inputs first typeInformationAt: self.
	"profiling - inlined"
	2 to: inputs size do: [ :i | type := type union: ((inputs at: i) typeInformationAt: self) ].
	^ type
]

{ #category : #testing }
SoPhi >> cannotBeForwarded [
	^ self isLoopPhi 
		ifTrue: [ self hasLoopPhiRangeInformation "if range, it's a smi, so no fwder" ]
		ifFalse: [ self inputs allSatisfy: [ :in | in cannotBeForwarded ] ]
]

{ #category : #testing }
SoPhi >> hasLoopPhiRangeInformation [
	| in |
	self loopPhiForwardInput hasRangeInformation ifFalse: [ ^ false ].
	in := self loopPhiBackInput.
	[ in isIteratorMutator: self ] whileTrue: 
		[ in := in nextIterator: self.
		  in == self ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #testing }
SoPhi >> hasRangeInformation [
	^ self isLoopPhi 
		ifTrue: [ self hasLoopPhiRangeInformation ]
		ifFalse: [ self inputs allSatisfy: [ :in | in hasRangeInformation ] ]
]

{ #category : #initialization }
SoPhi >> initialize [

	super initialize.

	inputsMapping := OrderedCollection new
]

{ #category : #inputs }
SoPhi >> inputForBasicBlock: bb [
	inputsMapping do: [ :phiInput |
		phiInput basicBlock = bb ifTrue: [ ^ phiInput input ] ].
	self error: 'no input for this basicBlock'
]

{ #category : #inputs }
SoPhi >> inputs [
	"Remove duplicates."
	| inputs |
	inputs := Set new.
	inputsMapping do: [ :phiInput | inputs add: phiInput input ].
	^ inputs asArray
]

{ #category : #inputs }
SoPhi >> inputsAndBasicBlocksDo: aBlock [
	inputsMapping do: [ :phiInput |
		aBlock value: phiInput input value: phiInput basicBlock ]
]

{ #category : #testing }
SoPhi >> isLoopPhi [
	inputsMapping size = 2 ifFalse: [ ^ false ].
	^ self basicBlock predecessors anySatisfy: [ :pred | 
		pred lastInstr isBackjump ]
]

{ #category : #testing }
SoPhi >> isPhi [
	^ true
]

{ #category : #traversing }
SoPhi >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traversePhi: self
]

{ #category : #loopPhi }
SoPhi >> loopPhiBackInput [
	self inputsAndBasicBlocksDo: [ :in :bb |
		bb lastInstr isBackjump ifTrue: [ ^ in ] ]
]

{ #category : #loopPhi }
SoPhi >> loopPhiForwardInput [
	self inputsAndBasicBlocksDo: [ :in :bb |
		bb lastInstr isBackjump ifFalse: [ ^ in ] ]
]

{ #category : #loopPhi }
SoPhi >> loopPhiForwardPredecessor [
	self inputsAndBasicBlocksDo: [ :in :bb |
		bb lastInstr isBackjump ifFalse: [ ^ bb ] ]
]

{ #category : #types }
SoPhi >> loopRangeInformation [
	"Hard wired range computation to avoid infinite loop."
	| in shift initialRange |
	shift := 0.
	in := self loopPhiBackInput.
	initialRange := self loopPhiForwardInput rangeInformation.
	[ in isIteratorMutator: self ] whileTrue: 
		[ shift := shift + (in iteratorMutatorValue: self).
		  in := in nextIterator: self].
	shift = 0 ifTrue: [ ^SoRange new 
			minConstant: initialRange actualMinVal;
			maxConstant: initialRange actualMaxVal;
			yourself].
	shift > 0 ifTrue: [ ^SoRange new 
			minConstant: initialRange actualMinVal;
			maxConstant: SmallInteger maxVal;
			yourself].
	^SoRange new 
			minConstant: SmallInteger minVal;
			maxConstant: initialRange actualMaxVal;
			yourself
	
]

{ #category : #types }
SoPhi >> mergeInputs [
	| stream phisDealtWith |
	phisDealtWith := Set with: self.
	stream := (Array new: 12) writeStream.
	self mergeInputsInto: stream excluding: phisDealtWith.
	^ stream contents asSet asArray
]

{ #category : #types }
SoPhi >> mergeInputsInto: stream excluding: phisDealtWith [
	"Profiler"
	1 to: inputsMapping size do: [:i | | in |
		in := (inputsMapping at: i) input.
		in isPhi
			ifTrue: [  
				(phisDealtWith includes: in) 
					ifFalse: [ 
						phisDealtWith add: in.
						in mergeInputsInto: stream excluding: phisDealtWith ] ]
			ifFalse: [ stream nextPut: in ] ]
]

{ #category : #types }
SoPhi >> mergeRangeInformation [
	"All inputs have range information"
	| range |
	range := self inputs first rangeInformation.
	self inputs allButFirst do: [ :in |
		range := range union: in rangeInformation ].
	^ range
	
]

{ #category : #inputs }
SoPhi >> phiResources [
	^ { self } , self inputs
]

{ #category : #'graph edition' }
SoPhi >> postCopy [
	"Explicitely no super send (subNodes are handled differently in phis)"
	inputsMapping := inputsMapping collect: [:each | each copy].
	inputsMapping do: [ :phiInput | phiInput phi: self ].
	uses := OrderedCollection new.
]

{ #category : #types }
SoPhi >> rangeInformation [
	"Assumes the phi has range information."
	^ self isLoopPhi 
		ifTrue: [ self loopRangeInformation ]
		ifFalse: [ self mergeRangeInformation ]
]

{ #category : #inputs }
SoPhi >> removeInput: instr basicBlock: bb [
	self removeInputForBasicBlock: bb
]

{ #category : #inputs }
SoPhi >> removeInputForBasicBlock: bb [
	| thePhiInput |
	thePhiInput := inputsMapping detect: [ :phiInput | phiInput basicBlock = bb ].
	inputsMapping remove: thePhiInput.
	thePhiInput input removeUse: thePhiInput
]

{ #category : #inputs }
SoPhi >> replaceBasicBlock: inputBasicBlock with: anotherBasicBlock [
	inputsMapping 
		detect: [ :phiInput | phiInput basicBlock = inputBasicBlock ]
		 ifFound: [ :thePhiInput | thePhiInput basicBlock: anotherBasicBlock ]
		ifNone: [ self error: 'no input for this basicBlock' ]
]

{ #category : #'graph edition' }
SoPhi >> replaceSubNode: node by: anotherNode [
	inputsMapping do: [ :phiInput |
		phiInput input = node ifTrue: [ ^ phiInput replaceSubNode: node by: anotherNode ] ].
	self error: 'should have found input'

]

{ #category : #'graph edition' }
SoPhi >> subNodes [
	"keep duplicate here."
	^ inputsMapping collect: [ :phiInput | phiInput input ]
]

{ #category : #'graph edition' }
SoPhi >> subNodesDo: aBlock [
	inputsMapping do: [ :phiInput | aBlock value: phiInput input ]
]

{ #category : #'graph edition' }
SoPhi >> subNodesRemoveUses [
	inputsMapping do: [ :phiInput | phiInput input removeUse: phiInput ]
]

{ #category : #'graph edition' }
SoPhi >> subNodesSize [
	^ inputsMapping size
]
