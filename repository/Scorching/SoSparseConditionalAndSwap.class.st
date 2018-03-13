"
-- SparseConditional --

Based on the e-SSA representation, I analyse all branches and attempts to figure out the values of some conditionals. Typical examples are:

bar: a
	a = 1
		ifTrue: [^a]
==> I can replace ^a by ^1 

foo: a
	a < 1 
		ifTrue: [a > -1 
			ifTrue: [ ^a]
==> I can replace the ^a by ^0

 -- Swap --

The other thing I do is swapping. For each smiEquality/pointerEquality operation, I swap the uses in the graph to allow futher optimisations. Typical case:

foo: a bar: b
	| sz |
	sz := a size.
	sz = b size ifFalse: [^false].
	1 to: sz do: [ :i |
		(a at: i) = (b at: i) ifFalse:[^false]].
	^ true
==> swapping the loop limit from a size to b size allows to uncheck (b at: i) while (a at: i) have already been unchecked.

swapped <OrderedCollection of Instructions> instructions already swap so when loop bodies are processed multiple times they are not swapped again.
"
Class {
	#name : #SoSparseConditionalAndSwap,
	#superclass : #SoGraphPreorderLoopTraverser,
	#instVars : [
		'swapped'
	],
	#category : #'Scorching-Pass-Data'
}

{ #category : #initialization }
SoSparseConditionalAndSwap >> initialize [

	super initialize.

	swapped := OrderedCollection new.
]

{ #category : #size }
SoSparseConditionalAndSwap >> okRangeIn: access max: maxConstant [
	| range |
	access firstArg hasRangeInformation ifFalse: [ ^ false ].
	range := access firstArg rangeInformation.
	range maxArraySize ifNotNil: [ ^ false ]. "standard case - not dealt here"
	range minConstant >= 1 ifFalse: [ ^ false ].
	^ range maxConstant <= maxConstant
	
]

{ #category : #public }
SoSparseConditionalAndSwap >> runOn: codeNode [
	self traversePreorderCode: codeNode.
]

{ #category : #swap }
SoSparseConditionalAndSwap >> swap: op dominatedBy: instr [
	(swapped includes: op) ifTrue: [ ^ self ].
	"If one operand is a constant, it has no uses, hence it will force using the constant everywhere."
	swapped add: op.
	"2 operands are equals. we need to swap them in the basicblock where they are equal to attempt other optimisations"
	self swapInstruction: op receiver with: op firstArg dominatedBy: instr.
	self swapInstruction: op firstArg with: op receiver dominatedBy: instr.
	"special size optimisation."
	(op receiver isSizeOp and: [ op firstArg isSmiConstant ]) ifTrue: [ 
		self uncheckSize: op receiver with: op firstArg constant dominatedBy: instr ].
	(op firstArg isSizeOp and: [ op receiver isSmiConstant ]) ifTrue: [ 
		self uncheckSize: op firstArg with: op receiver constant dominatedBy: instr ].
]

{ #category : #swap }
SoSparseConditionalAndSwap >> swapEqual: op [
	| comp |
	comp := op uses detect: [ :use | use isBooleanBranch ] ifNone: [ ^ self ].
	self swap: op dominatedBy: comp trueBasicBlock firstInstr
]

{ #category : #swap }
SoSparseConditionalAndSwap >> swapInstruction: instr with: alternate dominatedBy: domInstr [
	instr uses copy do: [ :use |
		use isSunkObject ifFalse: [ 
			(domInstr dominates: use) ifTrue: [ use replaceSubNode: instr by: alternate ] ] ]
]

{ #category : #swap }
SoSparseConditionalAndSwap >> swapNotEqual: op [
	| comp |
	comp := op uses detect: [ :use | use isBooleanBranch ] ifNone: [ ^ self ].
	self swap: op dominatedBy: comp falseBasicBlock firstInstr
]

{ #category : #accessing }
SoSparseConditionalAndSwap >> swapped [
	<generated>
	^ swapped
]

{ #category : #accessing }
SoSparseConditionalAndSwap >> swapped: aValue [
	<generated>
	swapped := aValue
]

{ #category : #traversing }
SoSparseConditionalAndSwap >> traversePi: pi [
	"solve multiple comp resolution here."
	| cst |
	pi rangeInformation isSolved ifFalse: [ ^ self ].
	cst := pi rangeInformation solvedConstant.
	pi removeAndReplaceUsesBy: (SoConstant constant: cst)
]

{ #category : #traversing }
SoSparseConditionalAndSwap >> traversePipelinedBooleanBranch: branch [
	branch expression ~= branch prevInstr ifFalse:  [ ^ self ].
	"Seems CSE has removed a duplicated condition. We need to fix that."
	branch expression uses copy do: [ :use |
		use isBooleanBranch ifTrue: [ 
			(use trueBasicBlock dominatesInstr: branch) ifTrue: [ branch replaceSubNode: branch expression by: (SoConstant constant: true) ].
			(use falseBasicBlock dominatesInstr: branch) ifTrue: [ branch replaceSubNode: branch expression by: (SoConstant constant: false) ] ]]
]

{ #category : #traversing }
SoSparseConditionalAndSwap >> traverseRawPointerEqualsOp: op [
	^ self swapEqual: op
	
]

{ #category : #traversing }
SoSparseConditionalAndSwap >> traverseRawPointerNotEqualsOp: op [
	^ self swapNotEqual: op
	
]

{ #category : #traversing }
SoSparseConditionalAndSwap >> traverseSmiEqualOp: op [
	op receiver hasRangeInformation ifFalse: [ ^ self swapEqual: op ].
	op firstArg hasRangeInformation ifFalse: [ ^ self swapEqual: op ].
	(op receiver rangeInformation alwaysEqualThan: op firstArg rangeInformation)
		ifTrue: [  ^ 	op removeAndReplaceUsesBy: (SoConstant constant: true) ].
	(op receiver rangeInformation alwaysNotEqualThan: op firstArg rangeInformation)
		ifTrue: [  ^ op removeAndReplaceUsesBy: (SoConstant constant: false) ].
	^ self swapEqual: op
	
]

{ #category : #traversing }
SoSparseConditionalAndSwap >> traverseSmiLessOp: op [
	op receiver hasRangeInformation ifFalse: [ ^ self ].
	op firstArg hasRangeInformation ifFalse: [ ^ self ].
	(op receiver rangeInformation alwaysLessThan: op firstArg rangeInformation)
		ifTrue: [  ^ 	op removeAndReplaceUsesBy: (SoConstant constant: true) ].
	(op receiver rangeInformation alwaysGreaterOrEqualThan: op firstArg rangeInformation)
		ifTrue: [  ^ op removeAndReplaceUsesBy: (SoConstant constant: false) ].
	
]

{ #category : #traversing }
SoSparseConditionalAndSwap >> traverseSmiLessOrEqualOp: op [
	op receiver hasRangeInformation ifFalse: [ ^ self ].
	op firstArg hasRangeInformation ifFalse: [ ^ self ].
	(op receiver rangeInformation alwaysLessOrEqualThan: op firstArg rangeInformation)
		ifTrue: [  ^ 	op removeAndReplaceUsesBy: (SoConstant constant: true) ].
	(op receiver rangeInformation alwaysGreaterThan: op firstArg rangeInformation)
		ifTrue: [  ^ op removeAndReplaceUsesBy: (SoConstant constant: false) ].
	
]

{ #category : #traversing }
SoSparseConditionalAndSwap >> traverseSmiNotEqualOp: op [
	op receiver hasRangeInformation ifFalse: [ ^ self swapNotEqual: op ].
	op firstArg hasRangeInformation ifFalse: [ ^ self swapNotEqual: op ].
	(op receiver rangeInformation alwaysNotEqualThan: op firstArg rangeInformation)
		ifTrue: [  ^ 	op removeAndReplaceUsesBy: (SoConstant constant: true) ].
	(op receiver rangeInformation alwaysEqualThan: op firstArg rangeInformation)
		ifTrue: [  ^ op removeAndReplaceUsesBy: (SoConstant constant: false) ].
	 ^ self swapNotEqual: op 
	
]

{ #category : #size }
SoSparseConditionalAndSwap >> uncheckSize: sizeOp with: maxConstant dominatedBy: dominator [
	| array accessToFold |
	array := sizeOp receiver.
	accessToFold := array uses select: [ :each | 
		each isSend 
			and: [ each canBeInlined 
			and: [ (each methodToInline primitive between: 60 and: 61)
			and: [ dominator dominates: each ] ] ] ].
	accessToFold do: [ :access |
		(self okRangeIn: access max: maxConstant)
			ifTrue: [ access inlineAccessWithNoRangeCheck ] ]


]
