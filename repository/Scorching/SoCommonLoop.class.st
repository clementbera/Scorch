"
I represent a common loop, which is a subset of all loops with specifities allowing to easily optimise them. All #to:do:, #to:dy:do: loops are common loops, #while loops are sometimes common loop. LICM allows some strange pattern present with while to be canonicalized so they can match the pattern.

Apart from pattern matching, I am used for to access the different instructions of the common loops with explicit names (accessor names) instead of cryptic code (basicBlockX firstInstr nextInstr).

--- Pattern matching ---
This comment has a short description followed by the instance variable description to understand what pattern matches a common loop or not, alternatively one can read the method matchesCommonLoop.

The head basic block (backjump target) of a common loop has the following pattern, with N >= 1 (at least 1 phi):
[X.1] phi
[X.2] phi
...
[X.N] phi
[X.N+1] comp
[X.N+2] branch ifFalse: loopExit ifTrue: loopBody

The last basicBlock of a common loop ends with:
[Y.K] addCst
[Y.K+1] backTo: X

backjump <Backjump> backjump of the loop
loopPhi <Phi> phi representing the integer iterator of the loop. the forward input is necessarily a cst smi (in a common loop). The backward input is necessarily the addCst.
comp <SmiLessOp or SmiLessOrEqualOp> comparison of the loop iterator (loopPhi) against a value to exit the loop.
addCst <SmiAddOp> addition of a constant at the end of each loop iteration.
branch <BooleanBranch> branch exiting the loop body at the end of the head basicBlock.
loopBody <Collection of basicBlocks> all basicBlocks in the loop (excluding the head basicBlock)
phis <Collection of Phi> phis of the headBasicBlock.


"
Class {
	#name : #SoCommonLoop,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'backjump',
		'loopPhi',
		'comp',
		'addCst',
		'branch',
		'loopBody',
		'phis'
	],
	#pools : [
		'SoMagicConstants'
	],
	#category : #'Scorching-Pass-Loop'
}

{ #category : #accessing }
SoCommonLoop >> addCst [
	<generated>
	^ addCst
]

{ #category : #accessing }
SoCommonLoop >> addCst: aValue [
	<generated>
	addCst := aValue
]

{ #category : #accessing }
SoCommonLoop >> backjump [
	<generated>
	^ backjump
]

{ #category : #accessing }
SoCommonLoop >> backjump: aValue [
	<generated>
	backjump := aValue
]

{ #category : #accessing }
SoCommonLoop >> branch [
	<generated>
	^ branch
]

{ #category : #accessing }
SoCommonLoop >> branch: aValue [
	<generated>
	branch := aValue
]

{ #category : #'accessing - other' }
SoCommonLoop >> codeNode [
	^ loopPhi codeNode
]

{ #category : #accessing }
SoCommonLoop >> comp [
	<generated>
	^ comp
]

{ #category : #accessing }
SoCommonLoop >> comp: aValue [
	<generated>
	comp := aValue
]

{ #category : #'accessing - other' }
SoCommonLoop >> compLimit [
	^ comp firstArg
]

{ #category : #'accessing - other' }
SoCommonLoop >> firstLoopBody [
	^ loopBody first
]

{ #category : #testing }
SoCommonLoop >> hasExactCount [
	^ comp firstArg isSmiConstant
]

{ #category : #'accessing - other' }
SoCommonLoop >> headBBMapping [
	| mapping |
	mapping := Dictionary new.
	phis do: [ :phi |
		mapping at: phi put: phi loopPhiForwardInput ].
	^ mapping
]

{ #category : #'accessing - other' }
SoCommonLoop >> headBasicBlock [
	^ backjump targetBasicBlock
]

{ #category : #'accessing - other' }
SoCommonLoop >> increment [
	^ addCst firstArg constant
]

{ #category : #initialization }
SoCommonLoop >> initFromBackjump: bj [

	backjump := bj.
	loopBody := bj codeNode basicBlocks 
		copyFrom: bj targetBasicBlock postOrder + 1
		to: bj basicBlock postOrder
]

{ #category : #'accessing - other' }
SoCommonLoop >> initialCount [
  	^ loopPhi loopPhiForwardInput constant 
		
]

{ #category : #'accessing - other' }
SoCommonLoop >> initialCountConstant [
  	^ loopPhi loopPhiForwardInput 
		
]

{ #category : #'accessing - other' }
SoCommonLoop >> iteratorRange [ 
  	^ self initialCount
		to: self maxCount
		by: self increment
]

{ #category : #'accessing - other' }
SoCommonLoop >> lastLoopBody [
	^ loopBody last
]

{ #category : #'accessing - other' }
SoCommonLoop >> lastLoopPostOrder [
	^ loopBody last postOrder
]

{ #category : #accessing }
SoCommonLoop >> loopBody [
	<generated>
	^ loopBody
]

{ #category : #accessing }
SoCommonLoop >> loopBody: aValue [
	<generated>
	loopBody := aValue
]

{ #category : #'accessing - other' }
SoCommonLoop >> loopExitBasicBlock [
	^ branch falseBasicBlock
]

{ #category : #accessing }
SoCommonLoop >> loopPhi [
	<generated>
	^ loopPhi
]

{ #category : #accessing }
SoCommonLoop >> loopPhi: aValue [
	<generated>
	loopPhi := aValue
]

{ #category : #'pattern matching' }
SoCommonLoop >> matchesAddCst [
	addCst := backjump prevInstr.
	addCst ifNil: [ ^ false ].
	^ addCst isUncheckedAddConstant
]

{ #category : #'pattern matching' }
SoCommonLoop >> matchesBranch [
	branch := comp nextInstr.
	^ branch isBooleanBranch
]

{ #category : #'pattern matching' }
SoCommonLoop >> matchesCommonLoop: bj [
		
	"Pattern matching for phi,comp,branch with a standard phi."
	self initFromBackjump: bj.
	self matchesPhisAndComp ifFalse: [ ^ false ].
	self matchesBranch ifFalse: [ ^ false ].
	self matchesAddCst ifFalse: [ ^ false ].
	self matchesLoop ifFalse: [ ^ false ].
	^ self matchesLoopPhi
]

{ #category : #'pattern matching' }
SoCommonLoop >> matchesLoop [
	branch trueBasicBlock postOrder = (branch basicBlock postOrder + 1) ifFalse: [ ^ false ].
	branch falseBasicBlock postOrder <= backjump basicBlock postOrder ifTrue: [ ^ false ].
	^ true
]

{ #category : #'pattern matching' }
SoCommonLoop >> matchesLoopPhi [
	^ phis 
		detect: [ :phi | 
			comp receiver = phi 
				and: [ addCst receiver = phi
				and: [ phi loopPhiForwardInput isSmiConstant ] ] ] 
		ifFound: [ :elem | loopPhi := elem. true ]
		ifNone: [ false ]
]

{ #category : #'pattern matching' }
SoCommonLoop >> matchesPhisAndComp [
		
	phis := backjump targetBasicBlock phis.
	phis ifEmpty: [ ^ false ].
	comp := phis last nextInstr.
	^ comp isSmiLessOrLessOrEqual
]

{ #category : #'accessing - other' }
SoCommonLoop >> maxCount [
  	^ comp firstArg constant - comp isSmiLessOp asBit 
]

{ #category : #opt }
SoCommonLoop >> patchCompUses [
	"All the uses of the comp phi are remapped.
	If the use is the branch -> not remapped.
	If the use is in the loop -> remapped to true.
	If the use is not in the loop -> remapped to false"
	
	"Common case, comp used only in the branch"
	comp uses size = 1 ifTrue: [ ^ self ].
	
	comp uses copy do: [ :use |
		use basicBlock = branch basicBlock ifFalse: [ 
			use 
				replaceSubNode: comp 
				by: (SoConstant constant: use basicBlock postOrder <= self lastLoopPostOrder ) ] ]
]

{ #category : #accessing }
SoCommonLoop >> phis [
	<generated>
	^ phis
]

{ #category : #accessing }
SoCommonLoop >> phis: aValue [
	<generated>
	phis := aValue
]

{ #category : #'accessing - other' }
SoCommonLoop >> preLoopBasicBlock [
	^ self headBasicBlock forwardPredecessors anyOne
]
