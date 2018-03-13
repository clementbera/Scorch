"
I do three things by processing the codeNode forward:
- common sub expression elimination (CSE)
- statification 
- simplification

CSE works with a list of sub expressions, if one is duplicated and one dominates the other, it can be removed and the first result is used. Mainly useful to remove redondant traps and unforward checks, also useful in some ways with unsafeOp (though we don't have no rematerialization pass and stuff).

Statification take specific operations and resolves them statically. Good examples are:
- computing the size of a known size instruction
- computing the class of a known type instruction
- unforwarding a constant
- trapping on a constant
- computing certain operations between constants only

Simplification attempts to remove other instructions with specific conditions
- multiple ensureEnoughSlots can be merged into one
- Smalltalk boolean branches can be pipelined
- phi simplification

I also do some canonicalization & value numbering for basic Smi operations.

commonSubExpressions <Dictionary of Instructions> used for CSE
phiSimplifier <PhiSimplifier> to avoid allocating it again and again...

"
Class {
	#name : #SoSubexpressionElimination,
	#superclass : #SoGraphPreorderLoopTraverser,
	#instVars : [
		'commonSubExpressions',
		'phiSimplifier'
	],
	#category : #'Scorching-Pass-Data'
}

{ #category : #'private - statification' }
SoSubexpressionElimination >> aliasingEqual: equal [
	"Very very naive alisiasing analysis but was proven to work in multiple real cases (i.e. String>>new:)"
	equal receiver = equal firstArg ifFalse: [ ^ false ].
	equal removeAndReplaceUsesBy: (SoConstant constant: true).
	^ true
]

{ #category : #'private - statification' }
SoSubexpressionElimination >> aliasingNotEqual: equal [
	"Very very naive alisiasing analysis but was proven to work in multiple real cases (i.e. String>>new:)"
	equal receiver = equal firstArg ifFalse: [ ^ false ].
	equal removeAndReplaceUsesBy: (SoConstant constant: false).
	^ true
]

{ #category : #'private - statification' }
SoSubexpressionElimination >> allSubNodesConstants: node [
	"don't create temporary collection"
	node subNodesDo: [ :sub | sub isConstant ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #'private - statification' }
SoSubexpressionElimination >> allSubNodesSmiConstants: node [
	"don't create temporary collection"
	node subNodesDo: [ :sub | sub isSmiConstant ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #'private - slots' }
SoSubexpressionElimination >> attemptRemoveEnsureEnoughSlots: instr [
	| backwardInstr |
	backwardInstr := instr prevInstr.
	[ backwardInstr ifNil: [ ^ false ].
	 backwardInstr isEnsureEnoughSlots ifTrue: [ 
		backwardInstr numSlots isConstant ifFalse: [ ^ false ].
		backwardInstr numSlots: (SoConstant constant: backwardInstr numSlots constant + instr numSlots constant).
		instr removeInstr. ^ true ].
	 backwardInstr hasBreakingDeoptPoint ifTrue: [ ^ false ].
	 true ] whileTrue: [ backwardInstr := backwardInstr prevInstr ]
]

{ #category : #'private - algebra' }
SoSubexpressionElimination >> canonicalizeSub: sub [
	"instr - cst => instr + (-cst)"
	| negatedConstant add |
	sub firstArg constant = SmallInteger minVal ifTrue: [ ^ self "uncommon..."].
	negatedConstant := SoConstant constant: (sub firstArg constant negated).
	sub replaceBy: (add := SoSmiAddOp new
		receiver: sub receiver;
		arguments: {negatedConstant};
		yourself).
	self traverseInstruction: add
	
]

{ #category : #'private cse' }
SoSubexpressionElimination >> commonSubEx: expr againstAll: listOfExpr [
	| found |
	found := false.
	listOfExpr do: 
		[ :each |
			each ~~ expr 
				ifTrue: [ 
					(each sameExprAs: expr) ifTrue: 
						[ (each strictlyDominates: expr) ifTrue: 
							[ ^ expr removeAndReplaceUsesBy: each ] ] ]
				ifFalse: [ found := true ] ].
	found ifFalse: [ listOfExpr add: expr ].
]

{ #category : #accessing }
SoSubexpressionElimination >> commonSubExpressions [
	<generated>
	^ commonSubExpressions
]

{ #category : #accessing }
SoSubexpressionElimination >> commonSubExpressions: aValue [
	<generated>
	commonSubExpressions := aValue
]

{ #category : #'private cse' }
SoSubexpressionElimination >> cse: op [
	commonSubExpressions
			at: op receiver
			ifPresent: [ :elem | self commonSubEx: op againstAll: elem ]
			ifAbsentPut: [ OrderedCollection with: op ]
]

{ #category : #'private - algebra' }
SoSubexpressionElimination >> identityAbsorbingElement: op [
	^ self identityAbsorbingElement: op at: op safePrimitiveNumber
]

{ #category : #'private - algebra' }
SoSubexpressionElimination >> identityAbsorbingElement: op at: num [
	| descr |
	descr := SoArithmeticDescriptor arithmeticDescriptors at: num.
	op receiver isSmiConstant ifTrue: [ 
		op receiver constant = descr leftIdentity ifTrue: [ op removeAndReplaceUsesBy: op firstArg. ^ true ].
		op receiver constant = descr leftAbsorbing ifTrue: [ op removeAndReplaceUsesBy: op receiver. ^ true ] ].
	op firstArg isSmiConstant ifTrue: [ 
		op firstArg constant = descr rightIdentity ifTrue: [ op removeAndReplaceUsesBy: op receiver. ^ true ].
		op firstArg constant = descr rightAbsorbing ifTrue: [ op removeAndReplaceUsesBy: op firstArg. ^ true ] ].
	^ false
]

{ #category : #initialization }
SoSubexpressionElimination >> initialize [

	super initialize.

	commonSubExpressions := Dictionary new.
	phiSimplifier := SoSimplifyPhis new
]

{ #category : #testing }
SoSubexpressionElimination >> isPrimitiveFailToken: anObject [
	^ (Smalltalk version includesSubString: 'Squeak')
		ifTrue: [ thisContext isPrimFailToken: anObject ]
		ifFalse: [ thisContext isFailToken: anObject ]
]

{ #category : #accessing }
SoSubexpressionElimination >> phiSimplifier [
	<generated>
	^ phiSimplifier
]

{ #category : #accessing }
SoSubexpressionElimination >> phiSimplifier: aValue [
	<generated>
	phiSimplifier := aValue
]

{ #category : #'private - algebra' }
SoSubexpressionElimination >> reduceStrength: op index: index class: cls [
	| newOp |
	op replaceBy: (newOp := cls new
		receiver: op receiver;
		arguments: {SoConstant constant: index};
		yourself).
	self traverseInstruction: newOp.
]

{ #category : #public }
SoSubexpressionElimination >> runOn: codeNode [
	self traversePreorderCode: codeNode
]

{ #category : #'private - statification' }
SoSubexpressionElimination >> statifyOp: op [
	op removeAndReplaceUsesBy: op computeStatically
]

{ #category : #'private - algebra' }
SoSubexpressionElimination >> strengthReductionIndex: constant [
	" | r |
	(1 to: 16)  collect: [ :i |
		r := 1.
		i timesRepeat: [ r := r * 2 ].
		r ].
	Could add:
	(1 to: 8) collect: [ :i |
		r := 1.
		i timesRepeat: [ r := r * 256 ].
		r ]."
	^ #(2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536) indexOf: constant
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseByteSizeOp: op [
	op receiver isByteNewColon ifFalse: [ ^ super traversePointerSizeOp: op ].
	op removeAndReplaceUsesBy: op receiver sized.
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseEnsureEnoughSlots: instr [
	(self attemptRemoveEnsureEnoughSlots: instr) ifTrue: [ ^ self ].
	(instr numSlots isConstant and: [ instr numSlots constant = 0 ]) ifFalse: [ ^ self ].
	instr removeInstr
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseMutableLiteralRead: mlr [
	commonSubExpressions
		at: mlr literal
		ifPresent: [ :elem | self commonSubEx: mlr againstAll: elem ]
		ifAbsentPut: [ OrderedCollection with: mlr ]
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseObjectRead: read [
	(self allSubNodesConstants: read) ifTrue: [ ^ self statifyOp: read ].
	^ super traverseObjectRead: read
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseOp: op [
	(self allSubNodesConstants: op) ifTrue: [ ^ self statifyOp: op ].
	op canBeCSE ifTrue: [ self cse: op ]
]

{ #category : #traversing }
SoSubexpressionElimination >> traversePhi: phi [
	phiSimplifier simplifyPhis: (OrderedCollection with: phi)
]

{ #category : #traversing }
SoSubexpressionElimination >> traversePointerSizeOp: op [
	op receiver isPointerNewColon ifFalse: [ ^ super traversePointerSizeOp: op ].
	op removeAndReplaceUsesBy: op receiver sized.
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseRawClassOp: op [
	| type |
	type := op receiver typeInformationAt: op.
	type hasOneType ifTrue: 
		[ ^ op removeAndReplaceUsesBy: (SoConstant new constant: type behaviors anyOne) ].
	super traverseRawClassOp: op
	
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseRawPointerEqualsOp: op [
	(self aliasingEqual: op) ifTrue: [ ^ self ].
	^ super traverseRawPointerEqualsOp: op
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseRawPointerNotEqualsOp: op [
	(self aliasingNotEqual: op) ifTrue: [ ^ self ].
	^ super traverseRawPointerNotEqualsOp: op
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseSend: send [
	| primitive |
	send canBeInlined ifFalse: [ ^ self ].
	send methodToInline primitive = 117 ifTrue: [ 
		^ SoStringEqualStub new maybeStringEqual: send ].
	(self allSubNodesConstants: send) ifFalse: [ ^ self ].
	primitive := send methodToInline primitive.
	"Smi primitives"
	((1 to: 19) includes: primitive) ifTrue: [ 
		^ send receiver isSmiConstant ifTrue: [ self tryPrimitive: primitive for: send ] ].
	"at class == size"
	({ 60 . 111 . 110 . 62 } includes: primitive)
		ifTrue: [ self tryPrimitive: primitive for: send ].
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseSmalltalkBooleanBranch: branch [
	(branch expression isSmiCompOp or: [branch expression isPointerEquals]) ifFalse: [  ^ self ].
	branch replaceBy: branch asPipelinedBranch
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseSmiAddOp: op [
	op receiver isConstant ifTrue: [ op commute ].
	^ super traverseSmiAddOp: op
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseSmiArithmeticOp: op [
	(self identityAbsorbingElement: op) ifTrue: [ ^ true ].
	^ super traverseSmiArithmeticOp: op
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseSmiBitOp: op [
	(self identityAbsorbingElement: op) ifTrue: [ ^ true ].
	^ super traverseSmiBitOp: op
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseSmiBitShiftLeftOp: op [
	(self identityAbsorbingElement: op at: 18) ifTrue: [ ^ true ].
	^ super traverseSmiBitOp: op
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseSmiDivOp: op [
	| index |
	op firstArg isConstant ifTrue: [ 
		(index := self strengthReductionIndex: op firstArg constant) ~= 0
			ifTrue: [ ^ self reduceStrength: op index: index class: SoSmiBitShiftRightOp ] ].
	^ super traverseSmiDivOp: op
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseSmiEqualOp: op [
	(self aliasingEqual: op) ifTrue: [ ^ self ].
	^ super traverseSmiEqualOp: op
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseSmiMulOp: op [
	| index |
	op firstArg isConstant ifTrue: [ 
		(index := self strengthReductionIndex: op firstArg constant) ~= 0
			ifTrue: [ ^ self reduceStrength: op index: index class: SoSmiBitShiftLeftOp ] ].
	^ super traverseSmiMulOp: op
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseSmiNotEqualOp: op [
	(self aliasingNotEqual: op) ifTrue: [ ^ self ].
	^ super traverseSmiNotEqualOp: op
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseSmiOp: op [
	(self allSubNodesSmiConstants: op) ifTrue: [ ^ self statifyOp: op ].
	self cse: op
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseSmiSubOp: op [
	op firstArg isConstant ifTrue: [ ^ self canonicalizeSub: op ].
	^ super traverseSmiSubOp: op
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseTrapIfNotInstanceOf: trap [
	| type |
	type := trap expression typeInformationAt: trap.
	type isKnownType ifTrue: 
		[ (trap behaviors includesAll: type behaviors) ifTrue: [ 
			^ trap removeInstr ] ].
	commonSubExpressions
		at: trap expression
		ifPresent: [ :elem | self commonSubEx: trap againstAll: elem ]
		ifAbsentPut: [ OrderedCollection with: trap ]
]

{ #category : #traversing }
SoSubexpressionElimination >> traverseUnforward: unforward [
	unforward expression cannotBeForwarded ifTrue: [ 
		^ unforward removeAndReplaceUsesBy: unforward expression ].
	((unforward expression typeInformationAt: unforward) isOnlyTypes: { SmallInteger . Character . SmallFloat64 })
		ifTrue: [ ^ unforward removeAndReplaceUsesBy: unforward expression ].
	commonSubExpressions
		at: unforward expression
		ifPresent: [ :elem | self commonSubEx: unforward againstAll: elem ]
		ifAbsentPut: [ OrderedCollection with: unforward ]
]

{ #category : #'private - statification' }
SoSubexpressionElimination >> tryPrimitive: primitive for: send [
	| res |
	res := send receiver constant tryPrimitive: primitive withArgs: (send arguments collect: [ :arg | arg constant ]).
	(self isPrimitiveFailToken: res) ifTrue: [ ^ self ].
	send addDependency.
	send removeAndReplaceUsesBy: (SoConstant new constant: res; yourself).
]
