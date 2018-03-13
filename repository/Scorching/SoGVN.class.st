"
Global Value Numbering. I do all sorts of things leading to computation simplification:
- Common sub expression elimination
- Static resolution of operations if all operands are constants.
- SmiAddOp evaluation ex: ((n-1)-2) => (n-3)
- SmiCompOp evaluation ex: ((n-1) < 2) => (n < 3) 
- branch deoptInfo removal.
- removal of runtime array / temp vect creation if unused
- some dead code elimination (unused side-effect free unchecked operations)
- phi interleaves simplification
...

In fact I do much more than just simple value numbering, maybe the name is mischosen, though the Crankshaft optimiser have the same name for similar things.

commonSubExpressions <Dictionary> used to perform CSE (Common Subexpression Elimination)
phiSimplifier <SimplifyPhi> this is here to be instantiated just once.
branchesToReprocess <Colleciton of branches> to give to dead branch eliminination
"
Class {
	#name : #SoGVN,
	#superclass : #SoGraphPreorderLoopTraverser,
	#instVars : [
		'commonSubExpressions',
		'branchesToReprocess',
		'phiSimplifier'
	],
	#pools : [
		'SoPrimitiveConstants'
	],
	#category : #'Scorching-Pass-Data'
}

{ #category : #private }
SoGVN >> allSubNodesConstants: node [
	"Constants are immutable and can't be become"
	^ node subNodes allSatisfy: [ :sub | sub isConstant ]
]

{ #category : #private }
SoGVN >> allSubNodesSmiConstants: node [
	^ node subNodes allSatisfy: [ :sub | sub isSmiConstant ]
]

{ #category : #accessing }
SoGVN >> branchesToReprocess [
	<generated>
	^ branchesToReprocess
]

{ #category : #accessing }
SoGVN >> branchesToReprocess: aValue [
	<generated>
	branchesToReprocess := aValue
]

{ #category : #private }
SoGVN >> commonSubEx: expr againstAll: listOfExpr [
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
SoGVN >> commonSubExpressions [
	<generated>
	^ commonSubExpressions
]

{ #category : #accessing }
SoGVN >> commonSubExpressions: aValue [
	<generated>
	commonSubExpressions := aValue
]

{ #category : #private }
SoGVN >> cse: op [
	"Avoid issue with branch pipelining"
	op isSmiCompOp ifTrue: [ ^self ].
	commonSubExpressions
			at: op receiver
			ifPresent: [ :elem | self commonSubEx: op againstAll: elem ]
			ifAbsentPut: [ OrderedCollection with: op ]
]

{ #category : #initialization }
SoGVN >> initialize [

	super initialize.

	commonSubExpressions := Dictionary new.
	branchesToReprocess := OrderedCollection new.
	phiSimplifier := SoSimplifyPhis new.
]

{ #category : #private }
SoGVN >> isPrimitiveFailToken: anObject [
	^ (Smalltalk version includesSubString: 'Squeak')
		ifTrue: [ thisContext isPrimFailToken: anObject ]
		ifFalse: [ thisContext isFailToken: anObject ]
]

{ #category : #modules }
SoGVN >> maybeArrayCopy: send [
	^ SoArrayCopyStub new maybeArrayCopy: send
]

{ #category : #traversing }
SoGVN >> maybeRemoveNilInit: new through: indexes [
	new receiver constant instSize = indexes size
		ifTrue: [ new nilInit: false ]
]

{ #category : #modules }
SoGVN >> maybeStringEqual: send [
	^ SoStringEqualStub new maybeStringEqual: send
]

{ #category : #private }
SoGVN >> mergeComparisonWithArg1: op [ 
	"For each variable n and constant a,b ;
	(b < (n+a)) => ((b-a) < n)
	overflow check:
	b - a should not overflow.
	ex: SmallInteger minVal < n + 1 /=>/ SmallInteger minVal - 1 < n"
	| maybeOverflow |
	maybeOverflow := op receiver constant - op firstArg firstArg constant.
	self removeFromCS: op.
	maybeOverflow > SmallInteger maxVal ifTrue: [ 
		"largePositiveInt < n, n Smi, always false"
		^ self replaceCompOp: op withBool: false ].
	maybeOverflow < SmallInteger minVal ifTrue: [ 
		"largeNegativeInt < n, n Smi, always true"
		^ self replaceCompOp: op withBool: true ].
	op replaceBy: (op class new
		basicBlock: op basicBlock;
		receiver: (SoConstant constant: maybeOverflow);
		arguments: {op firstArg receiver};
		yourself)
]

{ #category : #private }
SoGVN >> mergeComparisonWithReceiver: op [ 
	"For each variable n and constant a,b ;
	((n+a) < b) => (n < (b-a))
	overflow check:
	b - a should not overflow.
	n - 1 < SmallInteger maxVal /=>/ n < SmallInteger maxVal + 1"
	| maybeOverflow |
	maybeOverflow := op firstArg constant - op receiver firstArg constant.
	self removeFromCS: op.
	maybeOverflow > SmallInteger maxVal ifTrue: [ 
		"n < largePositiveInt, n Smi, always true"
		^ self replaceCompOp: op withBool: true ].
	maybeOverflow < SmallInteger minVal ifTrue: [ 
		"n < largeNegativeInt, n Smi, always false"
		^ self replaceCompOp: op withBool: false ].
	op replaceBy: (op class new
		receiver: op receiver receiver;
		arguments: {SoConstant constant: maybeOverflow};
		yourself)
]

{ #category : #private }
SoGVN >> mergeSmiAdd: op [
	"For each variable n and constant a,b ;
	((n+a)+b) => (n+(a+b))
	Handles overflow:
	a + b should not overflow.
	ex: ((n + SmallInteger maxVal) + 1) /=>/ n + (SmallInteger maxVal + 1)"
	| newConstant |
	newConstant := op receiver firstArg constant + op firstArg constant.
	newConstant class == SmallInteger ifFalse: [ ^ self ].
	newConstant = 0
		ifTrue: [ 
			op removeAndReplaceUsesBy: op receiver receiver ]
		ifFalse: [ 
			op replaceBy: (SoSmiAddOp
				withReceiver: op receiver receiver
				arguments: {SoConstant constant: newConstant}) ].
	self removeFromCS: op.
	
]

{ #category : #accessing }
SoGVN >> phiSimplifier [
	<generated>
	^ phiSimplifier
]

{ #category : #accessing }
SoGVN >> phiSimplifier: aValue [
	<generated>
	phiSimplifier := aValue
]

{ #category : #traversing }
SoGVN >> removeChecks: store [
	store removeDeoptInfo.
	store ignoreStoreCheck: true 
]

{ #category : #private }
SoGVN >> removeFromCS: op [
	commonSubExpressions
			at: op receiver
			ifPresent: [ :elem | elem remove: op ifAbsent: nil ]
]

{ #category : #traversing }
SoGVN >> removeStoreChecks: new [
	| instr indexes |
	instr := new.
	indexes := Set new.
	[ instr := instr nextInstr.
	(instr isInstVar and: [ instr isWrite and: [ instr object = new ] ]) ifFalse: [ ^ self maybeRemoveNilInit: new through: indexes ].
	self removeChecks: instr.
	indexes add: instr index.
	true ] whileTrue
]

{ #category : #public }
SoGVN >> runOn: codeNode [
	self traversePreorderCode: codeNode.
	self reprocessBranches.
]

{ #category : #private }
SoGVN >> sparseConditionalElimination: branch [
	"| var constant dom |
	1halt.
	branch expression firstArg isSmiConstant ifTrue: [ 
		branch expression receiver isSmiConstant ifTrue: [ ^ self ].
		var := branch expression receiver.
		constant := branch expression firstArg ].
	branch expression receiver isSmiConstant ifTrue: [ 
		var := branch expression firstArg.
		constant := branch expression receiver].
	var ifNil: [ ^ self ].
	branch expression class = SoSmiEqualOp
		ifTrue: [ dom := branch trueBasicBlock ]
		ifFalse: [ dom := branch falseBasicBlock ].
	var uses do: [ :use |
		(dom dominatesInstrOrSunkObject: use)
			ifTrue: [ 1halt. ] ]"
]

{ #category : #private }
SoGVN >> statifyOp: op [
	op removeAndReplaceUsesBy: op computeStatically
]

{ #category : #traversing }
SoGVN >> traverseAccessingOp: op [
	op arguments size = 2 ifTrue: [ ^ self ].
	"At"
	op uses ifEmpty: [ ^ op removeInstr ].
	op firstArg isSmiConstant ifFalse: [ ^ self ].
	op receiver isConstant ifTrue: [ ^ self statifyOp: op ].
	op receiver isCreateArray ifFalse: [ ^ self ].
	(op receiver uses allSatisfy: [ :use | use isSunkObject or: [ use isAt ] ]) ifFalse: [ ^ self ].
	op removeAndReplaceUsesBy: (op values at: op firstArg constant)
]

{ #category : #traversing }
SoGVN >> traverseArrayCopyOp: arrayCopy [
	
]

{ #category : #traversing }
SoGVN >> traverseBackjump: bj [
	
]

{ #category : #traversing }
SoGVN >> traverseBooleanBranch: branch [
	((branch expression typeInformationAt: branch)
		isOnlyTypes: { True . False }) ifFalse: [ ^ self ].
	branch removeDeoptInfo.
"	(branch expression isSmiCompOp and: [ branch expression isSmiLessOrLessOrEqual not ]) ifTrue: [ 
		self sparseConditionalElimination: branch ]."
	"need boolean branch for branch pipelining in the JIT.
	Fix also ExpandAndReduce if this is fixed.
	| newBranch |
	((branch expression typeInformationAt: branch)
		isOnlyTypes: { True . False }) ifFalse: [ ^ self ].
	'Branch' logCr.
	newBranch := SoBranchIfNotInstanceOf new
		basicBlock: branch basicBlock;
		behaviors: { False };
		expression: branch expression;
		trueBasicBlock: branch trueBasicBlock;
		falseBasicBlock: branch falseBasicBlock;
		yourself.
	branch replaceBy: newBranch.
	(self branchesToReprocess includes: branch)
		ifTrue: [ self branchesToReprocess remove: branch.
				 self branchesToReprocess add: newBranch  ]"
	
	
]

{ #category : #traversing }
SoGVN >> traverseBranchIfNotInstanceOf: branch [
	| type |
	type := branch expression typeInformationAt: branch.
	type isKnownType
		ifFalse: [ ^ self ].
	(branch behaviors includesAll: type behaviors)
		ifTrue: [ ^ branchesToReprocess add: branch ].
	(branch behaviors includesAny: type behaviors)
		ifFalse: [ ^ branchesToReprocess add: branch ]
]

{ #category : #traversing }
SoGVN >> traverseByteEqualOp: op [
	| arg2 |
	arg2 := op arguments at: 2.
	(arg2 isConstant and: [arg2 constant = 0]) ifTrue: [ 
		^ self replaceCompOp: op withBool: true ].
	self traverseUnsafeOp: op
]

{ #category : #traversing }
SoGVN >> traverseClassOp: op [
	| type |
	type := op receiver typeInformationAt: op.
	type hasOneType ifTrue: 
		[ ^ op removeAndReplaceUsesBy: (SoConstant new constant: type behaviors anyOne)  ].
	super traverseClassOp: op
	
]

{ #category : #traversing }
SoGVN >> traverseCreateArray: array [
	(array uses allSatisfy: [ :use | use isSunkObject or: [ use isAt or: [ use isSizeOp ] ] ]) ifFalse: [ ^ self ].
	array uses copy do: [ :each |
		each isAt ifTrue: [ each firstArg isSmiConstant ifTrue: [ 
				each removeAndReplaceUsesBy: (array values at: each firstArg constant) ] ] ].
	 self traverseCreateNode: array sunkObject: array asSunkArray.
	
]

{ #category : #traversing }
SoGVN >> traverseCreateFullBlock: block [
	self traverseCreateNode: block sunkObject: block asSunkClosure 
]

{ #category : #traversing }
SoGVN >> traverseCreateNode: obj sunkObject: sunkObj [
	obj uses ifEmpty: [ ^ obj removeInstr ].
	(obj uses allSatisfy: [ :use | use isSunkObject ]) ifFalse: [ ^ self ].
	obj removeInstr.
	obj uses do: [ :sunkObject |
		(sunkObject node deoptInfo sunkObjects includes: sunkObj) ifFalse: 
			[ sunkObject node deoptInfo addSunkObject: sunkObj copy ].
		sunkObject basicReplaceSubNode: obj by: sunkObj marker ].
]

{ #category : #traversing }
SoGVN >> traverseCreateTempVect: tempVect [
	self traverseCreateNode: tempVect sunkObject: tempVect asSunkVector
]

{ #category : #traversing }
SoGVN >> traverseEnsureEnoughSpace: instr [
	| backwardInstr |
	backwardInstr := instr prevInstr.
	[ backwardInstr ifNil: [ ^ self ].
	backwardInstr hasDeoptInfo ifTrue: [ ^ self ].
	backwardInstr isEnsureEnoughSpace ifTrue: [ 
		backwardInstr numWords: backwardInstr numWords + instr numWords.
		^ instr removeInstr ].
	true ] whileTrue: [ backwardInstr := backwardInstr prevInstr ]
]

{ #category : #traversing }
SoGVN >> traverseHeapAccess: access [
	access isWrite ifTrue: [ ^ self ].
	access uses ifEmpty: [ access removeInstr ]
]

{ #category : #traversing }
SoGVN >> traverseInstantiationOp: op [
	self removeStoreChecks: op.
	op uses size = 0 ifTrue: [ op removeInstr ]
]

{ #category : #traversing }
SoGVN >> traversePhi: phi [
	phiSimplifier simplifyPhis: (OrderedCollection with: phi)
]

{ #category : #traversing }
SoGVN >> traverseSend: send [ 	
	| primitive |
	send canBeInlined ifFalse: [ ^ self ].
	send methodToInline primitive = 117 ifTrue: [ ^ self maybeStringEqual: send ].
	send methodToInline primitive = 105 ifTrue: [ ^ self maybeArrayCopy: send ].
	(self allSubNodesConstants: send) ifFalse: [ ^ self ].
	primitive := send methodToInline primitive.
	(NumberPrimitiveRange includes: primitive) ifTrue: [ 
		^ send receiver isSmiConstant ifTrue: [ self tryPrimitive: primitive for: send ] ].
	({ At . ClassPrim . PointerEquals . Size } includes: primitive)
		ifTrue: [ self tryPrimitive: primitive for: send ].
	
]

{ #category : #traversing }
SoGVN >> traverseSizeOp: op [
	op receiver hasSizeInformation ifTrue: [ 
		^op removeAndReplaceUsesBy: (SoConstant new 
			constant: op receiver sizeInformation; 
			yourself) ].
	super traverseSizeOp: op
]

{ #category : #traversing }
SoGVN >> traverseSmiAddOp: op [
	(op isUncheckedAddConstant and: [ op firstArg value = 0 ]) ifTrue: [ 
		^ op removeAndReplaceUsesBy: op receiver ].
	"Known bug: this interfers with CSE. Disabled.
	(op isUncheckedAddConstant and: [ op receiver isUncheckedAddConstant ]) ifTrue: [ ^ self mergeSmiAdd: op ]."
	super traverseSmiAddOp: op
	
]

{ #category : #traversing }
SoGVN >> traverseSmiCompOp: op [
	(self allSubNodesSmiConstants: op) ifTrue: [ ^ self replaceCompOp: op withBool: op computeStatically constant ].
	"Known bug: this interfers with CSE. Disabled.
	op receiver isUncheckedAddConstant
		ifTrue: [ ^ self mergeComparisonWithReceiver: op ].
	op firstArg isUncheckedAddConstant
		ifTrue: [ ^ self mergeComparisonWithArg1: op ]."
	super traverseSmiCompOp: op
]

{ #category : #traversing }
SoGVN >> traverseSmiOp: op [
	(self allSubNodesSmiConstants: op) ifTrue: [ ^ self statifyOp: op ].
	self unsafeOpGVN: op
]

{ #category : #traversing }
SoGVN >> traverseTrapIfNotInstanceOf: trap [
	| type |
	type := trap expression typeInformationAt: trap.
	type isKnownType ifTrue: 
		[ (trap behaviors includesAll: type behaviors) ifTrue: [ ^ trap removeInstr ] ].
	commonSubExpressions
		at: trap expression
		ifPresent: [ :elem | self commonSubEx: trap againstAll: elem ]
		ifAbsentPut: [ OrderedCollection with: trap ]
]

{ #category : #traversing }
SoGVN >> traverseUnsafeOp: op [
	(self allSubNodesConstants: op) ifTrue: [ ^ self statifyOp: op ].
	self unsafeOpGVN: op
]

{ #category : #private }
SoGVN >> tryPrimitive: primitive for: send [ 
	| res |
	res := send receiver constant tryPrimitive: primitive withArgs: (send arguments collect: [ :arg | arg constant ]).
	(self isPrimitiveFailToken: res) ifTrue: [ ^ self ].
	send addDependency.
	(res == true or: [ res == false ]) ifTrue: [ 
		self branchesToReprocess addAll: (send uses select: [ :each | each isBooleanBranch ]).].
	send removeAndReplaceUsesBy: (SoConstant new constant: res; yourself).
]

{ #category : #private }
SoGVN >> unsafeOpGVN: op [
	(op uses size = 0 and: [ op hasEffect not ]) ifTrue: [ ^ op removeInstr ].
	self cse: op
]
