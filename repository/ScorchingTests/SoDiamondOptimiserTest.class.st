Class {
	#name : #SoDiamondOptimiserTest,
	#superclass : #SoAbsPassTest,
	#category : #'ScorchingTests-UnitTests'
}

{ #category : #tests }
SoDiamondOptimiserTest >> testDeadDiamond [
	| optCode |
	optCode := self run: { SoDiamondOptimiser } on: #deadDiamond.
	self assert: optCode bytecodeSize <= 2.
	self assert: (self exec: optCode) = 5.
]

{ #category : #tests }
SoDiamondOptimiserTest >> testDeadLoop [
	| optCode |
	optCode := self run: { SoDiamondOptimiser . SoSubexpressionElimination . SoDeadBranchElimination} on: #deadLoop.
	self assert: optCode bytecodeSize <= 2.
	self assert: (self exec: optCode) = 111.
]

{ #category : #tests }
SoDiamondOptimiserTest >> testLoopToDiamond [
	| optCode |
	optCode := self run: { SoLICM . SoDiamondOptimiser . SoSubexpressionElimination . SoDeadBranchElimination} on: #loopToDiamond:.
	self assert: optCode bytecodeSize <= 5.
	self assert: (self exec: optCode withArgs: #( #(2 3 4) ) ) = 3.
]
