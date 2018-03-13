"
I am the abstract superclass of all the Scorch nodes. A method decompiled to a CFG form with the SSA and TAC property is decompiled to a graph of Scorch nodes.
"
Class {
	#name : #SoAbsNode,
	#superclass : #Object,
	#category : #'Scorching-Nodes'
}

{ #category : #'graph edition' }
SoAbsNode >> basicReplaceSubNode: one by: other [
	self subclassResponsibility 
]

{ #category : #testing }
SoAbsNode >> canLocallySpecifyType [
	^ false
]

{ #category : #testing }
SoAbsNode >> deoptInfo [
	^ nil
]

{ #category : #testing }
SoAbsNode >> hasDeoptInfo [
	^ self deoptInfo notNil
]

{ #category : #testing }
SoAbsNode >> hasRangeInformation [
	^ false
]

{ #category : #testing }
SoAbsNode >> hasScope [
	^ false
]

{ #category : #testing }
SoAbsNode >> hasSizeInformation [
	^ false
]

{ #category : #testing }
SoAbsNode >> is0Constant [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isArg [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isAt [
	^ false
		
]

{ #category : #testing }
SoAbsNode >> isAtPut [
	^ false
		
]

{ #category : #testing }
SoAbsNode >> isBackjump [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isBlockClosure [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isBooleanBranch [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isBranch [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isBranchIfNotInstanceOf [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isCFGInstr [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isCFGInstruction [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isConstant [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isCreateArray [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isEnsureEnoughSpace [
	^ false
]

{ #category : #testing }
SoAbsNode >> isGlobal [
	^ false
]

{ #category : #testing }
SoAbsNode >> isImmediate [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isInstVar [
	^ false
		
]

{ #category : #testing }
SoAbsNode >> isIteratorMutator [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isJump [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isJumpAhead [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isMarker [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isNew [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isPhi [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isPhiInput [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isPi [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isRead [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isReceiver [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isReturn [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isSend [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isSizeOp [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isSmiAddOp [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isSmiCompOp [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isSmiConstant [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isSmiLessOp [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isSmiLessOrLessOrEqual [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isSpilled [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isSunkObject [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isTempVector [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isTrapIfNotInstanceOf [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isUncheckedAddConstant [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isUnsafeOp [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> isWrite [
	<generated>
	^ false
]

{ #category : #testing }
SoAbsNode >> maybeWorthSplitting [
	^ false
]

{ #category : #'graph edition' }
SoAbsNode >> removeDeoptInfo [
	self deoptInfo ifNotNil: 
		[ :deopt | 
			deopt removeDeopt.
			self deoptInfo: nil ].
	
]

{ #category : #'graph edition' }
SoAbsNode >> replaceDeoptInfoBy: deoptInfo2 [
	self removeDeoptInfo.
	self deoptInfo: deoptInfo2
]

{ #category : #'graph edition' }
SoAbsNode >> replaceSubNode: one by: other [
	one removeUse: self.
	self basicReplaceSubNode: one by: other
]

{ #category : #types }
SoAbsNode >> specializeTypeAt: instr fromType: type [
	| typeFound use |
	typeFound := type.
	1 to: self uses size do: [ :i |
		use := self uses at: i.
		use canLocallySpecifyType ifTrue: [
			typeFound := use maybeSpecifyType: typeFound for: instr.
			typeFound hasOneType ifTrue: [ ^ typeFound ] ] ].
	^ typeFound
]

{ #category : #'graph edition' }
SoAbsNode >> subNodes [
	self subclassResponsibility 
]

{ #category : #'graph edition' }
SoAbsNode >> subNodesRemoveUses [
	self subNodes do: [ :subNode | subNode removeUse: self ]
]

{ #category : #types }
SoAbsNode >> typeInformationAt: instr [
	"The type answered is guaranteed (A trap dominates the instruction for example)"
	| typeFound |
	
	"Attempt 1: basic type information."
	typeFound := self basicTypeInformation.
	typeFound hasOneType ifTrue: [ ^ typeFound ].
	
	"Attempt 2: type specialization based on previous type checks"
	^ self specializeTypeAt: instr fromType: typeFound
]
