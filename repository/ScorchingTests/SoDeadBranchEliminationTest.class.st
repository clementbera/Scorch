Class {
	#name : #SoDeadBranchEliminationTest,
	#superclass : #SoAbsPassTest,
	#category : #'ScorchingTests-UnitTests'
}

{ #category : #tests }
SoDeadBranchEliminationTest >> testInstanceOfBranch [
	| optCode |
	optCode := self run: { SoDeadBranchElimination } on: #deadInstanceBranch.
	self assert: optCode bytecodeSize <= 2.
	self assert: (self exec: optCode) = 42.
]

{ #category : #tests }
SoDeadBranchEliminationTest >> testInstanceOfBranch2 [
	| optCode |
	optCode := self run: { SoDeadBranchElimination } on: #deadInstanceBranch2.
	self assert: optCode bytecodeSize <= 2.
	self assert: (self exec: optCode) = 0.
]

{ #category : #tests }
SoDeadBranchEliminationTest >> testPipeBranch [
	| optCode |
	optCode := self run: { SoSubexpressionElimination . SoDeadBranchElimination } on: #deadPipeBranch.
	self assert: optCode bytecodeSize <= 2.
	self assert: (self exec: optCode) = 0.
]

{ #category : #tests }
SoDeadBranchEliminationTest >> testPipeBranch2 [
	| optCode |
	optCode := self run: { SoSubexpressionElimination . SoDeadBranchElimination } on: #deadPipeBranch2.
	self assert: optCode bytecodeSize <= 2.
	self assert: (self exec: optCode) = 1.
]

{ #category : #tests }
SoDeadBranchEliminationTest >> testSTBoolBranch [
	| optCode |
	optCode := self run: { SoDeadBranchElimination } on: #deadSTBoolBranch.
	self assert: optCode bytecodeSize <= 2.
	self assert: (self exec: optCode) = 1.
]

{ #category : #tests }
SoDeadBranchEliminationTest >> testSTBoolBranch2 [
	| optCode |
	optCode := self run: { SoDeadBranchElimination } on: #deadSTBoolBranch2.
	self assert: optCode bytecodeSize <= 2.
	self assert: (self exec: optCode) = 0.
]

{ #category : #tests }
SoDeadBranchEliminationTest >> testSTBoolBranchLoop [
	| optCode |
	optCode := self run: { SoDeadBranchElimination } on: #deadSTBoolBranchLoop.
	self assert: optCode bytecodeSize <= 2.
	self assert: (self exec: optCode) = 0.
]
