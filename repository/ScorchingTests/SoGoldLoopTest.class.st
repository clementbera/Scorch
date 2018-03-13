Class {
	#name : #SoGoldLoopTest,
	#superclass : #SoAbsPassTest,
	#category : #'ScorchingTests-UnitTests'
}

{ #category : #tests }
SoGoldLoopTest >> testDeadLoop [
	| optCode |
	optCode := self run: { SoGoldLoopOptimiser } on: #deadLoop1.
	self assert: optCode bytecodeSize <= 2.
	self assert: (self exec: optCode) = 111.
]

{ #category : #tests }
SoGoldLoopTest >> testDeadLoop2 [
	| optCode |
	optCode := self run: { SoGoldLoopOptimiser } on: #deadLoop2.
	self assert: optCode bytecodeSize <= 2.
	self assert: (self exec: optCode) = 111.
]

{ #category : #tests }
SoGoldLoopTest >> testFullUnroll1 [
	| optCode |
	optCode := self run: { SoGoldLoopOptimiser . SoSubexpressionElimination . SoEscapeOptimisation } on: #fullUnroll1.
	self assert: optCode bytecodeSize < 10.
	self assert: (self exec: optCode) = 111.
]

{ #category : #tests }
SoGoldLoopTest >> testFullUnroll2 [
	| optCode |
	optCode := self run: { SoGoldLoopOptimiser . SoSubexpressionElimination . SoEscapeOptimisation } on: #fullUnroll2.
	self assert: optCode bytecodeSize < 10.
	self assert: (self exec: optCode) = 111.
]

{ #category : #tests }
SoGoldLoopTest >> testFullUnroll3 [
	| optCode |
	optCode := self run: { SoLICM . SoGoldLoopOptimiser . SoSubexpressionElimination . SoEscapeOptimisation . SoSubexpressionElimination . SoDeadBranchElimination } on: #fullUnroll3.
	self assert: optCode bytecodeSize < 18.
	self assert: (self exec: optCode) = 2.
]

{ #category : #tests }
SoGoldLoopTest >> testFullUnroll4 [
	| optCode |
	optCode := self run: { SoGoldLoopOptimiser . SoSubexpressionElimination } on: #fullUnroll4.
	self assert: optCode bytecodeSize < 10.
	self assert: (self exec: optCode) = 111.
]

{ #category : #tests }
SoGoldLoopTest >> testFullUnroll5 [
	| optCode |
	optCode := self run: { SoGoldLoopOptimiser . SoSubexpressionElimination . SoEscapeOptimisation} on: #fullUnroll5.
	self assert: optCode bytecodeSize < 10.
	self assert: (self exec: optCode) = 111.
]

{ #category : #tests }
SoGoldLoopTest >> testPeel1 [
	| optCode |
	optCode := self run: { SoGoldLoopOptimiser . SoSubexpressionElimination . SoEscapeOptimisation} on: #peel1.
	self assert: optCode bytecodeSize > 40.
	self assert: (self exec: optCode) = 111.
]

{ #category : #tests }
SoGoldLoopTest >> testPeel2 [
	| optCode |
	optCode := self run: { SoGoldLoopOptimiser . SoSubexpressionElimination . SoEscapeOptimisation} on: #peel2.
	self assert: optCode bytecodeSize > 40.
	self assert: (self exec: optCode) = 111.
]

{ #category : #tests }
SoGoldLoopTest >> testPeel3 [
	| optCode |
	optCode := self run: { SoGoldLoopOptimiser . SoSubexpressionElimination . SoEscapeOptimisation} on: #peel3.
	self assert: optCode bytecodeSize > 40.
	self assert: (self exec: optCode) = 0.
]

{ #category : #tests }
SoGoldLoopTest >> testPeel4 [
	| optCode |
	optCode := self run: { SoGoldLoopOptimiser . SoSubexpressionElimination . SoEscapeOptimisation} on: #peel4.
	self assert: optCode bytecodeSize > 40.
	self assert: (self exec: optCode) = 111.
]
