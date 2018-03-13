"
I extend the IR to e-SSA and then transform it back to SSA at the end.

The e-SSA representation has Pi nodes, after each branch, which adds range information in specific branches for specific variables. This works only on smis. The pi nodes are used by other optimisation passes to do range analysis.

retraversing <Boolean> utility to retraverse loop bodies multiple time.
"
Class {
	#name : #SoExtendSSA,
	#superclass : #SoGraphPreorderLoopTraverser,
	#instVars : [
		'retraversing'
	],
	#category : #'Scorching-Pass-Data'
}

{ #category : #pi }
SoExtendSSA >> addAndPropagatePi: branch [
	| toAddPi |
	toAddPi := OrderedCollection new: 2.
	"We create pi for non constant if the other operand has range information."
	branch expression receiver hasRangeInformation ifTrue: 
		[ branch expression firstArg isConstant ifFalse: [ toAddPi add: branch expression firstArg ] ].
	branch expression firstArg hasRangeInformation ifTrue: 
		[ branch expression receiver isConstant ifFalse: [ toAddPi add: branch expression receiver ] ].
	toAddPi ifEmpty: [ ^ self ].
	toAddPi do: [ :each |
		self addPiFor: each in:  branch trueBasicBlock.
		self addPiFor: each in:  branch falseBasicBlock ]
	
]

{ #category : #pi }
SoExtendSSA >> addPiFor: node in: basicBlock [ 
	| subGraph toPatch pi |
	subGraph := self dominatedPath: basicBlock.
	toPatch := node uses select: [ :each | each isSunkObject not and: [ subGraph includes: each basicBlock ] ].
	toPatch ifEmpty: [ ^ self ].
	pi := self newPiFor: node startBasicBlock: basicBlock.
	toPatch do: [ :use |
		use replaceSubNode: node by: pi ].
]

{ #category : #private }
SoExtendSSA >> addPis: codeNode [
	codeNode basicBlocks do: [ :basicBlock |
		basicBlock lastInstr isTraversedBy: self ].
]

{ #category : #public }
SoExtendSSA >> extendSSAFor: codeNode during: aBlock [
	self addPis: codeNode.
	aBlock cull: codeNode.
	self removePis: codeNode.
]

{ #category : #initialization }
SoExtendSSA >> initialize [

	super initialize.

	retraversing := false.
]

{ #category : #pi }
SoExtendSSA >> invertedRangeFor: node in: smiComp [
	^ node == smiComp receiver 	
		ifTrue: 
			[ smiComp firstArg rangeInformation maxArraySize ifNotNil: [ ^ SoRange fullRange ].
			  SoRange new 
				minConstant: (smiComp isSmiLessOp 
						ifTrue: [ smiComp firstArg rangeInformation minConstant ]
						ifFalse: [ smiComp firstArg rangeInformation minConstant + 1 ]);
				maxConstant: SmallInteger maxVal;
				yourself]
		ifFalse: 
			[ SoRange new 
				minConstant: SmallInteger minVal;
				maxConstant: (smiComp isSmiLessOp 
						ifTrue: [ smiComp receiver rangeInformation maxConstant ]
						ifFalse: [ smiComp receiver rangeInformation maxConstant - 1 ]);
				maxArraySize: smiComp receiver rangeInformation maxArraySize;
				yourself]
]

{ #category : #traversing }
SoExtendSSA >> maybeReprocess: basicBlock [
	retraversing := true.
	super maybeReprocess: basicBlock.
	retraversing := false.
]

{ #category : #pi }
SoExtendSSA >> newPiFor: node startBasicBlock: basicBlock [
	| branch range pi |
	branch := basicBlock predecessors anyOne lastInstr.
	range := branch trueBasicBlock == basicBlock
		ifTrue: [ self rangeFor: node in: branch expression ]
		ifFalse: [ self invertedRangeFor: node in: branch expression ].
	pi := SoPi new
		basicBlock: basicBlock;
		expression: node;
		additionalRange: range;
		yourself.
	basicBlock addFirstInstruction: pi.
	^ pi
]

{ #category : #pi }
SoExtendSSA >> rangeFor: node in: smiComp [
	^ node == smiComp receiver 	
		ifTrue: 
			[SoRange new 
				minConstant: SmallInteger minVal;
				maxConstant: (smiComp isSmiLessOp 
						ifTrue: [ smiComp firstArg rangeInformation maxConstant - 1 ]
						ifFalse: [ smiComp firstArg rangeInformation maxConstant ]);
				maxArraySize: smiComp firstArg rangeInformation maxArraySize;
				yourself]
		ifFalse: 
			[ smiComp receiver rangeInformation maxArraySize ifNotNil: [ ^ SoRange fullRange ].
			SoRange new 
				minConstant: (smiComp isSmiLessOp 
						ifTrue: [ smiComp receiver rangeInformation minConstant + 1 ]
						ifFalse: [ smiComp receiver rangeInformation minConstant ]);
				maxConstant: SmallInteger maxVal;
				yourself]
]

{ #category : #private }
SoExtendSSA >> removePis: codeNode [
	codeNode basicBlocks do: [ :basicBlock |
		self removePisInBasicBlock: basicBlock ].
]

{ #category : #private }
SoExtendSSA >> removePisInBasicBlock: basicBlock [ 
	basicBlock pisDo: [ :pi | 
		pi removeAndReplaceUsesBy: pi expression ]
]

{ #category : #accessing }
SoExtendSSA >> retraversing [
	<generated>
	^ retraversing
]

{ #category : #accessing }
SoExtendSSA >> retraversing: aValue [
	<generated>
	retraversing := aValue
]

{ #category : #traversing }
SoExtendSSA >> traversePipelinedBooleanBranch: branch [
	"if expr is unchecked and less or lessOrEqual, add the pi nodes."
	retraversing ifTrue: [ ^ self ].
	branch expression isSmiLessOrLessOrEqual ifFalse: [  ^ self ].
	(branch expression firstArg hasRangeInformation or: 
		[ branch expression receiver hasRangeInformation ]) ifFalse: [ ^ self ].
	self addAndPropagatePi: branch.
]
